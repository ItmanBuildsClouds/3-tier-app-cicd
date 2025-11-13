module "alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "10.0.2"
  name                       = "${var.project_name}-alb"
  load_balancer_type         = "application"
  vpc_id                     = data.terraform_remote_state.networking.outputs.vpc_id
  subnets                    = data.terraform_remote_state.networking.outputs.public_subnet_id
  security_groups            = [data.terraform_remote_state.networking.outputs.web_sg_id]
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