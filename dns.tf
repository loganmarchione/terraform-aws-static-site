################################################################################
### DNS
################################################################################

########################################
### Zone and NS records
########################################

resource "aws_route53_zone" "site" {
  name = var.site_name
}

resource "aws_route53_record" "site_nameservers" {
  zone_id         = aws_route53_zone.site.zone_id
  name            = aws_route53_zone.site.name
  type            = "NS"
  ttl             = "3600"
  allow_overwrite = true
  records         = aws_route53_zone.site.name_servers
}

########################################
### All other records
########################################

resource "aws_route53_record" "site_caa" {
  zone_id = aws_route53_zone.site.zone_id
  name    = ""
  type    = "CAA"
  ttl     = "3600"
  records = [
    "0 issue \"amazon.com\"",
    "0 issuewild \"amazon.com\""
  ]
}
