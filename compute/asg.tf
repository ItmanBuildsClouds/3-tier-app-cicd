resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  max_size            = 5
  min_size            = 1
  desired_capacity    = 3
  vpc_zone_identifier = data.terraform_remote_state.networking.outputs.private_subnet_id
  target_group_arns   = [module.alb.target_groups["app"].arn]
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
}