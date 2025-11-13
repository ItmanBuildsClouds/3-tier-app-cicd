output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = module.vpc.public_subnets
}
output "web_sg_id" {
  description = "Web SG ID"
  value       = module.web_sg.security_group_id
}
output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = module.vpc.private_subnets
}
output "app_sg_id" {
  description = "App SG ID"
  value       = module.app_sg.security_group_id
}
output "efs_sg_id" {
  description = "EFS SG ID"
  value       = aws_security_group.efs_sg.id
}
output "db_sg_id" {
  description = "DB SG ID"
  value       = module.db_sg.security_group_id
}
output "db_subnet_group" {
  description = "DB Subnet group"
  value       = module.vpc.database_subnet_group
}