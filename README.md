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

## Usage

The ACM validation **WILL FAIL** until you point your domain's nameservers to the nameservers provided by Route53. You should do this:

1. Run `terraform apply`
1. Wait for ACM validation to timeout (the default is 5min in Terraform)
1. Go into Route53 and find the four nameservers
1. Add the Route53 nameservers to your domain's control panel
1. Wait 5 minutes
1. Re-run `terraform apply`

## Documentation

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
| [aws_route53_record.site_nameservers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.site_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the site bucket to be created in S3 | `string` | n/a | yes |
| <a name="input_bucket_versioning_logs"></a> [bucket\_versioning\_logs](#input\_bucket\_versioning\_logs) | State of bucket versioning | `string` | `"Disabled"` | no |
| <a name="input_bucket_versioning_site"></a> [bucket\_versioning\_site](#input\_bucket\_versioning\_site) | State of bucket versioning | `string` | `"Disabled"` | no |
| <a name="input_cloudfront_default_root_object"></a> [cloudfront\_default\_root\_object](#input\_cloudfront\_default\_root\_object) | Specify the default root object or leave it as null | `string` | `null` | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | To enable CloudFront or not | `bool` | `true` | no |
| <a name="input_cloudfront_http_version"></a> [cloudfront\_http\_version](#input\_cloudfront\_http\_version) | The CloudFront HTTP version | `string` | `"http2"` | no |
| <a name="input_cloudfront_ipv6"></a> [cloudfront\_ipv6](#input\_cloudfront\_ipv6) | To enable IPv6 or not | `bool` | `true` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | The CloudFront price class | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_ssl_minimum_protocol_version"></a> [cloudfront\_ssl\_minimum\_protocol\_version](#input\_cloudfront\_ssl\_minimum\_protocol\_version) | The minimum SSL protocol to use | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the site (e.g., example.com) | `string` | n/a | yes |
| <a name="input_test_page"></a> [test\_page](#input\_test\_page) | To push a test index.html page to the S3 bucket or not | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
