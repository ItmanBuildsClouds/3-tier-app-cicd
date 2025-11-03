variable "project_name" {
  type    = string
  default = "tierapp"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "database_subnets" {
  type    = list(string)
  default = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
}
variable "nat_gateway" {
  type    = bool
  default = true
}
variable "db_username" {
  type    = string
  default = "apptier"
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