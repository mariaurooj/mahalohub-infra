resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "mymahalohub-frontend"
}
locals {
  s3_origin_id = "mahalohub-frontend"
}
#data "aws_s3_bucket" "mybucket" {
 # bucket = "mahalohub-frontend"
#}
/*resource "aws_s3_bucket" "mybucket" {
  bucket = "mahalohub-frontend"
  tags = {
    Environment = "development"
    Name        = "mahalohub-frontend"
  }
}*/

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "mahalohub-frontend"
  default_root_object = "index.html"
  aliases             = ["mymahalohub.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Environment = "development"
    Name        = "mahalohub"
  }

  viewer_certificate {
    ssl_support_method             = "sni-only"
    acm_certificate_arn            = "arn:aws:acm:us-east-1:383798767483:certificate/6a822dad-49a1-4349-a7bc-9277ca2fd94a"
    cloudfront_default_certificate = false
  }
}
# to get the Cloud front URL if doamin/alias is not configured
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}