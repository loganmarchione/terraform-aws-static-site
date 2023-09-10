# Get the hosted zone for the domain name
data "aws_route53_zone" "site" {
  name         = var.domain_name
  private_zone = false
}

# Replace dots in the domain name with dashes for the bucket name
locals {
  bucket_name       = lower(replace(var.domain_name, ".", "-"))
  s3_origin_id_site = local.bucket_name
}
