module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  identifier                  = var.identifier
  db_name                     = var.db_name
  engine                      = var.engine
  engine_version              = var.engine_version
  family                      = var.family
  major_engine_version        = var.major_engine_version
  instance_class              = var.instance_class
  allocated_storage           = 60
  skip_final_snapshot         = var.skip_final_snapshot
  manage_master_user_password = var.manage_master_user_password

  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value
  port     = var.port

  iam_database_authentication_enabled = false
  vpc_security_group_ids              = [data.terraform_remote_state.networking.outputs.db_sg_id]
  db_subnet_group_name                = data.terraform_remote_state.networking.outputs.db_subnet_group
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"

}