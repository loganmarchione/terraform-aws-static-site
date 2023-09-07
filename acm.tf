################################################################################
### ACM + DNS
################################################################################

resource "aws_acm_certificate" "site" {
  # Needed because CloudFront can only use ACM certs generated in us-east-1
  provider          = aws.us-east-1
  domain_name       = aws_route53_zone.site.name
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${aws_route53_zone.site.name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "site_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = aws_route53_zone.site.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "site" {
  # Needed because CloudFront can only use ACM certs generated in us-east-1
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.site_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}
