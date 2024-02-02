output "bucket_id" {
  value = aws_s3_bucket.mybucket.arn
}
output "s3_bucket_domain_name" {
  value = aws_s3_bucket.mybucket.bucket_regional_domain_name
}