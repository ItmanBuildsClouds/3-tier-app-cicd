resource "aws_launch_template" "launch_template" {
  name                   = "${var.project_name}-launch-template"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [data.terraform_remote_state.networking.outputs.app_sg_id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_name     = var.db_name
    db_user     = data.terraform_remote_state.database.outputs.db_username
    db_password = data.terraform_remote_state.database.outputs.db_password
    db_endpoint = data.terraform_remote_state.database.outputs.rds_db_address
    efs_id      = aws_efs_file_system.efs.id
    region      = var.region
    }
  ))
  depends_on = [aws_efs_mount_target.efs_mount]
}