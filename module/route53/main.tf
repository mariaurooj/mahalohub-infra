data "aws_route53_zone" "selected" {
  name         = "mymahalohub.com"
  private_zone = false
}

/*resource "aws_route53_record" "aws_route53_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "mymahalohub.com"
  type    = "A"
 alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}*/
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = "mymahalohub.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = dvo.domain_name == "example.org" ? data.aws_route53_zone.selected.zone_id : data.aws_route53_zone.selected.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}