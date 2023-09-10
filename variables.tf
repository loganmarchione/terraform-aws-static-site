variable "bucket_versioning_logs" {
  default     = false
  description = "State of bucket versioning"
  type        = bool
}

variable "bucket_versioning_site" {
  default     = false
  description = "State of bucket versioning"
  type        = bool
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
