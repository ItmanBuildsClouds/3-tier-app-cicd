terraform {
  required_version = "~> 1.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket         = "tierapp-6imjz7"
    dynamodb_table = "tierapp-remote-state"
    key            = "networking/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Owner       = var.owner_name
      Environment = var.environment_name
    }
  }
}