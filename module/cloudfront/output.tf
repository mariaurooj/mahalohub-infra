output "cloudfront_id" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}
output "oai_id" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.id
}