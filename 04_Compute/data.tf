data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "tierapp-6imjz7"
    key    = "networking/terraform.tfstate"
    region = "eu-central-1"
  }
}
data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = "tierapp-6imjz7"
    key    = "database/terraform.tfstate"
    region = "eu-central-1"
  }
}