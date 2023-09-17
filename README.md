# terraform-aws-static-site 

[![Terraform Checks](https://github.com/loganmarchione/terraform-aws-static-site/actions/workflows/terraform_checks.yml/badge.svg)](https://github.com/loganmarchione/terraform-aws-static-site/actions/workflows/terraform_checks.yml) [![Generate terraform docs](https://github.com/loganmarchione/terraform-aws-static-site/actions/workflows/terraform-docs.yml/badge.svg)](https://github.com/loganmarchione/terraform-aws-static-site/actions/workflows/terraform-docs.yml)

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
  source = "github.com/loganmarchione/terraform-aws-static-site?ref=x.y.z"

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
  cloudfront_function_create              = true
  cloudfront_function_filename            = "function.js"
  cloudfront_function_name                = "ReWrites"
  cloudfront_http_version                 = "http2and3"
  cloudfront_ipv6                         = true
  cloudfront_price_class                  = "PriceClass_100"
  cloudfront_ssl_minimum_protocol_version = "TLSv1.2_2021"
  cloudfront_ttl_min                      = 3600
  cloudfront_ttl_default                  = 86400
  cloudfront_ttl_max                      = 31536000
  cloudfront_viewer_protocol_policy       = "redirect-to-https"

  # IAM
  iam_policy_site_updating = false

  # Upload default files
  upload_index  = true
  upload_robots = true
  upload_404    = true
}
```

## Usage

This documentation was generated automatically with [terraform-docs](https://github.com/terraform-docs/gh-actions)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.15.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | >= 5.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_iam_policy.site_updating](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
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
| [aws_s3_object._404](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.index](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.robots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_route53_zone.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_versioning_logs"></a> [bucket\_versioning\_logs](#input\_bucket\_versioning\_logs) | State of bucket versioning for logs bucket | `bool` | `false` | no |
| <a name="input_bucket_versioning_site"></a> [bucket\_versioning\_site](#input\_bucket\_versioning\_site) | State of bucket versioning for site bucket | `bool` | `false` | no |
| <a name="input_cloudfront_compress"></a> [cloudfront\_compress](#input\_cloudfront\_compress) | To enable [CloudFront compression](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ServingCompressedFiles.html) or not | `bool` | `true` | no |
| <a name="input_cloudfront_custom_error_responses"></a> [cloudfront\_custom\_error\_responses](#input\_cloudfront\_custom\_error\_responses) | The [CloudFront custom error responses](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html) | <pre>list(object({<br>    error_code            = number<br>    response_code         = number<br>    error_caching_min_ttl = number<br>    response_page_path    = string<br>  }))</pre> | <pre>[<br>  {<br>    "error_caching_min_ttl": 60,<br>    "error_code": 404,<br>    "response_code": 404,<br>    "response_page_path": "/404.html"<br>  }<br>]</pre> | no |
| <a name="input_cloudfront_default_root_object"></a> [cloudfront\_default\_root\_object](#input\_cloudfront\_default\_root\_object) | The [CloudFront default root object](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DefaultRootObject.html) to display (this is `null` by default, so nothing will display at `https://domain.com` unless you set something here) | `string` | `null` | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | To enable CloudFront or not | `bool` | `true` | no |
| <a name="input_cloudfront_function_create"></a> [cloudfront\_function\_create](#input\_cloudfront\_function\_create) | To create and associate a CloudFront function (this doesn't test the function, so make sure it works!) | `bool` | `false` | no |
| <a name="input_cloudfront_function_filename"></a> [cloudfront\_function\_filename](#input\_cloudfront\_function\_filename) | The filename of the CloudFront function (the default is [this](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/example-function-add-index.html) AWS-provided function that appends `index.html` to requests that don't include a file name or extension (e.g., domain.com/foo) | `string` | `"function.js"` | no |
| <a name="input_cloudfront_function_name"></a> [cloudfront\_function\_name](#input\_cloudfront\_function\_name) | The name of the CloudFront function | `string` | `"MyFunction"` | no |
| <a name="input_cloudfront_http_version"></a> [cloudfront\_http\_version](#input\_cloudfront\_http\_version) | The CloudFront HTTP version | `string` | `"http2"` | no |
| <a name="input_cloudfront_ipv6"></a> [cloudfront\_ipv6](#input\_cloudfront\_ipv6) | To enable CloudFront IPv6 or not (also controls [creation of two AAAA Route53 records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html)) | `bool` | `true` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | The [CloudFront price class](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html) | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_ssl_minimum_protocol_version"></a> [cloudfront\_ssl\_minimum\_protocol\_version](#input\_cloudfront\_ssl\_minimum\_protocol\_version) | The [CloudFront minimum SSL protocol](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html) to use | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cloudfront_ttl_default"></a> [cloudfront\_ttl\_default](#input\_cloudfront\_ttl\_default) | The [CloudFront default cache time](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html) (seconds) | `number` | `86400` | no |
| <a name="input_cloudfront_ttl_max"></a> [cloudfront\_ttl\_max](#input\_cloudfront\_ttl\_max) | The [CloudFront maximum cache time](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html) (seconds) | `number` | `31536000` | no |
| <a name="input_cloudfront_ttl_min"></a> [cloudfront\_ttl\_min](#input\_cloudfront\_ttl\_min) | The [CloudFront minimum cache time](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html) (seconds) | `number` | `3600` | no |
| <a name="input_cloudfront_viewer_protocol_policy"></a> [cloudfront\_viewer\_protocol\_policy](#input\_cloudfront\_viewer\_protocol\_policy) | The [CloudFront viewer protocol policy](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https-viewers-to-cloudfront.html) to enforce (e.g., redirect HTTP to HTTPS) | `string` | `"redirect-to-https"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the site and **MUST** match the Route53 hosted zone name (e.g., `domain.com`) | `string` | n/a | yes |
| <a name="input_iam_policy_site_updating"></a> [iam\_policy\_site\_updating](#input\_iam\_policy\_site\_updating) | Optional IAM policy that provides permissions needed to update a static site (e.g., create CloudFront cache invalidation, update objects in S3, etc...) | `bool` | `false` | no |
| <a name="input_upload_404"></a> [upload\_404](#input\_upload\_404) | To push a `404.html` page (useful if you want to test your custom error responses) or not | `bool` | `false` | no |
| <a name="input_upload_index"></a> [upload\_index](#input\_upload\_index) | To push a test `index.html` page or not | `bool` | `true` | no |
| <a name="input_upload_robots"></a> [upload\_robots](#input\_upload\_robots) | To push a restrictive `robots.txt` file (useful if you don't want a site to be indexed) or not | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_site_updating_iam_policy_arn"></a> [site\_updating\_iam\_policy\_arn](#output\_site\_updating\_iam\_policy\_arn) | Value of site\_updating IAM policy ARN |
<!-- END_TF_DOCS -->
