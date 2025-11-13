variable "project_name" {
  type    = string
  default = "tierapp"
}
variable "owner_name" {
  type    = string
  default = "Piotr"
}
variable "environment_name" {
  type    = string
  default = "local"
}
variable "s3_remote_id" {
  type    = string
  default = "tierapp-6imjz7"
}
variable "db_remote_id" {
  type    = string
  default = "tierapp-remote-state"
}
variable "identifier" {
  type    = string
  default = "wordpress"
}
variable "db_name" {
  type    = string
  default = "wordpress"
}
variable "engine" {
  type    = string
  default = "mysql"
}
variable "engine_version" {
  type    = string
  default = "8.0.42"
}
variable "family" {
  type    = string
  default = "mysql8.0"
}
variable "major_engine_version" {
  type    = string
  default = "8.0"
}
variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}
variable "skip_final_snapshot" {
  type    = bool
  default = true
}
variable "manage_master_user_password" {
  type    = bool
  default = false
}
variable "port" {
  type    = number
  default = 3306
}