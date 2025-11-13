output "rds_db_address" {
  value = module.rds.db_instance_address
}
output "db_username" {
    value = data.aws_ssm_parameter.db_username.value
    sensitive = true
}
output "db_password" {
    value = data.aws_ssm_parameter.db_password.value
    sensitive = true
}