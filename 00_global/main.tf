resource "random_string" "random_suffix" {
    length = 5
    special = false
    upper = false
}

resource "aws_s3_bucket" "remote_state_s3" {
    bucket = "${var.project_name}-${random_string.random_suffix.result}"
    lifecycle {
        prevent_destroy = true
    }
}
resource "aws_s3_bucket_versioning" "remote_state_s3_versioning" {
    bucket = aws_s3_bucket.remote_state_s3.id
    versioning_configuration {
        status = "Enabled"
    }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_s3_encryption" {
    bucket = aws_s3_bucket.remote_state_s3.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}
resource "aws_dynamodb_table" "remote_state_dynamodb" {
    name = "${var.project_name}-${random_string.random_suffix.result}"
    hash_key = "LockID"
    billing_mode = "PAY_PER_REQUEST"
    attribute {
        name = "LockID"
        type = "S"
    }
    lifecycle {
        prevent_destroy = true
    }
}