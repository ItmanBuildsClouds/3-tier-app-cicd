output "s3_remote" {
    value = module.s3-bucket.s3_bucket_id
}
output "db_remote" {
    value = module.dynamodb-table.dynamodb_table_id
}