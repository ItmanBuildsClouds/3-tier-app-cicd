resource "random_string" "random_suffix" {
  length  = 5
  special = false
  upper   = false
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name               = "${var.project_name}-${random_string.random_suffix.result}"
  cidr               = var.vpc_cidr
  azs                = var.azs
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  database_subnets   = var.database_subnets
  enable_nat_gateway = var.nat_gateway
  single_nat_gateway = var.nat_gateway

  tags = {
    Project = var.project_name
  }
}


module "web_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.1"
  name        = "${var.project_name}-web-sg"
  description = "Security group for WordPress instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTP"
    },

    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTPS"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
module "app_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.1"
  name        = "${var.project_name}-app-sg"
  description = "Security group for incoming traffic from HTTP/HTTPS from web_sg"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.web_sg.security_group_id
      description              = "HTTP from web_sg"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
module "db_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.1"
  name        = "${var.project_name}-db-sg"
  description = "Security group for Database"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.app_sg.security_group_id
      description              = "Database from app_sg"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


module "rds" {
  source                      = "terraform-aws-modules/rds/aws"
  version                     = "6.13.1"
  identifier                  = "wordpress"
  db_name                     = "wordpress"
  engine                      = "mysql"
  engine_version              = "8.0.42"
  family                      = "mysql8.0"
  major_engine_version        = "8.0"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 60
  skip_final_snapshot         = true
  manage_master_user_password = false

  username = "admin"
  password = "adminadmin"
  port     = "3306"

  iam_database_authentication_enabled = false
  vpc_security_group_ids              = [module.db_sg.security_group_id]
  db_subnet_group_name                = module.vpc.database_subnet_group
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"

  tags = {
    Project = var.project_name
  }
}

resource "aws_launch_template" "launch_template" {
  name                   = "${var.project_name}-launch-template"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [module.app_sg.security_group_id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_endpoint = module.rds.db_instance_address
    EFS_ID      = aws_efs_file_system.efs.id
    efs_id      = aws_efs_file_system.efs.id
    REGION      = "eu-central-1"
    }
  ))
  depends_on = [aws_efs_mount_target.efs_mount]
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${var.project_name}-efs"

  tags = {
    Name    = "${var.project_name}-efs"
    Project = var.project_name
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [module.app_sg.security_group_id]
    description     = "NFS from app_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-efs-sg"
    Project = var.project_name
  }
}


module "alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "10.0.2"
  name                       = "${var.project_name}-alb"
  load_balancer_type         = "application"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  security_groups            = [module.web_sg.security_group_id]
  enable_deletion_protection = false

  target_groups = {
    app = {
      name              = "${var.project_name}-tg"
      backend_protocol  = "HTTP"
      backend_port      = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        enabled  = true
        interval = 30
        path     = "/"
        port     = "80"
        matcher  = "200-299"
      }
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "app"
      }
    }
  }
}
resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  max_size            = 5
  min_size            = 1
  desired_capacity    = 3
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [module.alb.target_groups["app"].arn]
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
}