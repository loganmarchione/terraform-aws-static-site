# static_site

Terraform module to create a static site in AWS using CloudFront, S3, ACM, Route53, etc...

## Explanation

An opinionated Terraform module to create a static site:

* Separate S3 buckets for site files (e.g., HTML, CSS, etc...) and logging
* S3 buckets are private
* Logs move to Standard IA after 30 days and are expired after 365
* Site files (e.g., HTML, CSS, etc...) can only be accessed through CloudFront (i.e., no direct access to files in S3)
* Creates an ACM certificate for `domain_name.tld` and `*.domain_name.tld` (i.e., for subdomains like `www.domain_name.tld`)
* Validates the ACM certificate using Route53 DNS
* Creates A and AAAA records for `domain_name.tld` and `www.domain_name.tld`
* CloudFront distribution using Origin Access Control to S3
* CloudFront options for IPv6, TLS, HTTP versions, and more
* Sane defaults for CloudFront HTTP headers

## Requirements

* You **MUST** already have a Route53 hosted zone and accompanying NS records created (this module does **NOT** do this for you) because ACM uses DNS for certficate validation. Below is an example of how to do this with Terraform.
```
resource "aws_route53_zone" "mydomain_com" {
  name = "domain.com"
}

resource "aws_route53_record" "mydomain_com_nameservers" {
  zone_id         = aws_route53_zone.mydomain_com.zone_id
  name            = aws_route53_zone.mydomain_com.name
  type            = "NS"
  ttl             = "3600"
  allow_overwrite = true
  records         = aws_route53_zone.mydomain_com.name_servers
}
```
* The `domain_name` input into the module **MUST** match the Route53 hosted zone name (e.g., `domain.com`).
* CloudFront can only use [ACM certs generated in `us-east-1`](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-aws-region). Some people (i.e., me) don't want their resources in `us-east-1`, except the ACM certificate and validation. Because of this, I had to add an extra `provider` configuration of `aws.us-east-1` to those two resources. You **NEED** to add this extra provider to your root module and again when calling the module itself (below is an example).
```
# Default
provider "aws" {
  region                   = "us-east-2"
  shared_credentials_files = ["~/.aws/credentials"]
}

# Needed because CloudFront can only use ACM certs generated in us-east-1
provider "aws" {
  alias                    = "us-east-1"
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

module "static_site_domain_com" {
  source = "github.com/loganmarchione/terraform-aws-static-site"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  # The domain name of the site (**MUST** match the Route53 hosted zone name (e.g., `domain.com`)
  domain_name   = "domain.com"

  # Since this is a static site, we probably don't need versioning, since our source files are stored in git
  bucket_versioning_logs = false
  bucket_versioning_site = false

  # CloudFront settings
  cloudfront_compress                     = true
  cloudfront_default_root_object          = "index.html"
  cloudfront_enabled                      = true
  cloudfront_http_version                 = "http2and3"
  cloudfront_ipv6                         = true
  cloudfront_price_class                  = "PriceClass_100"
  cloudfront_ssl_minimum_protocol_version = "TLSv1.2_2021"
  cloudfront_viewer_protocol_policy       = "redirect-to-https"

  # Upload a test page
  test_page = true
}
```

## Usage

This documentation was generated automatically with [terraform-docs](https://github.com/terraform-docs/gh-actions)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.15.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | ~> 5.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_route53_record.site_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_a_www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_aaaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_aaaa_www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_caa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_route53_zone.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_versioning_logs"></a> [bucket\_versioning\_logs](#input\_bucket\_versioning\_logs) | State of bucket versioning for logs bucket | `bool` | `false` | no |
| <a name="input_bucket_versioning_site"></a> [bucket\_versioning\_site](#input\_bucket\_versioning\_site) | State of bucket versioning for site bucket | `bool` | `false` | no |
| <a name="input_cloudfront_compress"></a> [cloudfront\_compress](#input\_cloudfront\_compress) | To enable [CloudFront compression](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ServingCompressedFiles.html) or not | `bool` | `true` | no |
| <a name="input_cloudfront_default_root_object"></a> [cloudfront\_default\_root\_object](#input\_cloudfront\_default\_root\_object) | The [CloudFront default root object](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DefaultRootObject.html) to display (this is `null` by default, so nothing will display at `https://domain.com` unless you set something here) | `string` | `null` | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | To enable CloudFront or not | `bool` | `true` | no |
| <a name="input_cloudfront_http_version"></a> [cloudfront\_http\_version](#input\_cloudfront\_http\_version) | The CloudFront HTTP version | `string` | `"http2"` | no |
| <a name="input_cloudfront_ipv6"></a> [cloudfront\_ipv6](#input\_cloudfront\_ipv6) | To enable CloudFront IPv6 or not (also controls [creation of two AAAA Route53 records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html)) | `bool` | `true` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | The [CloudFront price class](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html) | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_ssl_minimum_protocol_version"></a> [cloudfront\_ssl\_minimum\_protocol\_version](#input\_cloudfront\_ssl\_minimum\_protocol\_version) | The [CloudFront minimum SSL protocol](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html) to use | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cloudfront_viewer_protocol_policy"></a> [cloudfront\_viewer\_protocol\_policy](#input\_cloudfront\_viewer\_protocol\_policy) | The [CloudFront viewer protocol policy](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https-viewers-to-cloudfront.html) to enforce (e.g., redirect HTTP to HTTPS) | `string` | `"redirect-to-https"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the site and **MUST** match the Route53 hosted zone name (e.g., `domain.com`) | `string` | n/a | yes |
| <a name="input_test_page"></a> [test\_page](#input\_test\_page) | To push a test index.html page to the S3 bucket or not | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
