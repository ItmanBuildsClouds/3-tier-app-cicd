resource "aws_efs_file_system" "efs" {
  creation_token = "${var.project_name}-efs"

  tags = {
    Name    = "${var.project_name}-efs"
    Project = var.project_name
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = length(data.terraform_remote_state.networking.outputs.private_subnet_id)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.networking.outputs.private_subnet_id[count.index]
  security_groups = [data.terraform_remote_state.networking.outputs.efs_sg_id]
}