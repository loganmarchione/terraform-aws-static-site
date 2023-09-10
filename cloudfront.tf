################################################################################
### CloudFront
################################################################################

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = var.domain_name
  description                       = var.domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    origin_id                = local.s3_origin_id_site
  }

  aliases             = [data.aws_route53_zone.site.name, "www.${data.aws_route53_zone.site.name}"]
  comment             = local.s3_origin_id_site
  compress            = var.cloudfront_compress
  default_root_object = var.cloudfront_default_root_object != null ? var.cloudfront_default_root_object : null
  enabled             = var.cloudfront_enabled
  http_version        = var.cloudfront_http_version
  is_ipv6_enabled     = var.cloudfront_ipv6
  price_class         = var.cloudfront_price_class

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id_site

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.site.id
    viewer_protocol_policy     = var.cloudfront_viewer_protocol_policy
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging.bucket_domain_name
    prefix          = "cloudfront_${local.s3_origin_id_site}/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.cloudfront_ssl_minimum_protocol_version
  }

  depends_on = [
    aws_acm_certificate.site,
    aws_acm_certificate_validation.site
  ]
}

resource "aws_cloudfront_response_headers_policy" "site" {
  name    = local.bucket_name
  comment = "Sane defaults"
  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }

    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      override                   = true
      preload                    = true
    }

    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }
  }
}

# CloudFront access to S3 bucket
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "PolicyForCloudFrontAccessToResourcesBucket",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.site.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.site.arn
          }
        }
      },
      {
        "Sid" : "AllowSSLRequestsOnly",
        "Effect" : "Deny",
        "Principal" : "*"
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.site.arn}/*",
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}

################################################################################
### DNS
################################################################################

########################################
### A and AAAA records
########################################

resource "aws_route53_record" "site_a" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa" {
  count   = var.cloudfront_ipv6 ? 1 : 0
  zone_id = data.aws_route53_zone.site.zone_id
  name    = ""
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_a_www" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa_www" {
  count   = var.cloudfront_ipv6 ? 1 : 0
  zone_id = data.aws_route53_zone.site.zone_id
  name    = "www"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
