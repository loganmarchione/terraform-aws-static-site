# static_site

Terraform module to create a static site in AWS using CloudFront, S3, ACM, Route53, etc...

## Explanation

An opinionated Terraform module to create a static site:

* Separate S3 buckets for site files (e.g., HTML, CSS, etc...) and logging
* S3 buckets are private
* Logs move to Standard IA after 30 days and are expired after 365
* Site files (e.g., HTML, CSS, etc...) can only be accessed through CloudFront (i.e., no direct access to files in S3)
* Creates an ACM certificate for `site_name.tld` and `*.site_name.tld` (i.e., for subdomains like `www.site_name.tld`)
* Validates the ACM certificate using Route53 DNS
* Creates A and AAAA records for `site_name.tld` and `www.site_name.tld`
* CloudFront distribution using Origin Access Control to S3
* CloudFront options for IPv6, TLS, HTTP versions, and more
* Sane defaults for CloudFront HTTP headers

## Caveats

The ACM validation **WILL FAIL** until you point your domain's nameservers to the nameservers provided by Route53. You should do this:

1. Run `terraform apply`
1. Wait for ACM validation to timeout (the default is 5min in Terraform)
1. Go into Route53 and find the four nameservers
1. Add the Route53 nameservers to your domain's control panel
1. Wait 5 minutes
1. Re-run `terraform apply`

## 

This documentation was generated automatically with [terraform-docs](https://github.com/terraform-docs/gh-actions)

<!-- BEGIN_TF_DOCS -->
{{ .Content }}
<!-- END_TF_DOCS -->
