variable "project_name" {
  type    = string
  default = "tierapp"
}
variable "ami_id" {
  type    = string
  default = "ami-099981549d4358e9a"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name" {
  type    = string
  default = "DemoKeyPair"
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
variable "region" {
  type    = string
  default = "eu-central-1"
}
variable "db_name" {
  type    = string
  default = "wordpress"
}