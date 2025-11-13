resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}


module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.8.2"
  bucket  = "${var.project_name}-${random_string.random_suffix.result}"

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  force_destroy            = true
  versioning = {
    enabled = true
  }
}

module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.2.0"

  name         = "${var.project_name}-remote-state"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}