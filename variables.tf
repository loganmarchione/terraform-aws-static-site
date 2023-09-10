variable "bucket_name" {
  description = "Name of the site bucket to be created in S3"
  type        = string

  validation {
    condition = (
      var.bucket_name != "" &&
      length(var.bucket_name) >= 3 &&
      length(var.bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    )
    error_message = "S3 bucket name contains invalid characters."
  }
}

variable "bucket_versioning_logs" {
  default     = "Disabled"
  description = "State of bucket versioning"
  type        = string

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning#status
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.bucket_versioning_logs)
    error_message = "Variable must be 'Enabled', 'Suspended', or 'Disabled'."
  }
}


variable "bucket_versioning_site" {
  default     = "Disabled"
  description = "State of bucket versioning"
  type        = string

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning#status
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.bucket_versioning_site)
    error_message = "Variable must be 'Enabled', 'Suspended', or 'Disabled'."
  }
}

variable "cloudfront_default_root_object" {
  default     = null
  description = "Specify the default root object or leave it as null"
  type        = string
}

variable "cloudfront_enabled" {
  default     = true
  description = "To enable CloudFront or not"
  type        = bool
}

variable "cloudfront_http_version" {
  default     = "http2"
  description = "The CloudFront HTTP version"
  type        = string
}

variable "cloudfront_ipv6" {
  default     = true
  description = "To enable IPv6 or not"
  type        = bool
}

variable "cloudfront_price_class" {
  default     = "PriceClass_100"
  description = "The CloudFront price class"
  type        = string

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#price_class
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Variable must be 'PriceClass_All', 'PriceClass_200', or 'PriceClass_100'."
  }
}

variable "cloudfront_ssl_minimum_protocol_version" {
  default = "TLSv1.2_2021"
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#minimum_protocol_version
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html
  description = "The minimum SSL protocol to use"
  type        = string
}

variable "domain_name" {
  description = "Domain name of the site and should be the same as the Route53 hosted zone (e.g., example.com)"
  type        = string
}

variable "test_page" {
  default     = true
  description = "To push a test index.html page to the S3 bucket or not"
  type        = bool
}
