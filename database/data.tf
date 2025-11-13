data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "tierapp-6imjz7"
    key    = "networking/terraform.tfstate"
    region = "eu-central-1"
  }
}