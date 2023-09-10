variable "bucket_versioning_logs" {
  default     = false
  description = "State of bucket versioning for logs bucket"
  type        = bool
}

variable "bucket_versioning_site" {
  default     = false
  description = "State of bucket versioning for site bucket"
  type        = bool
}

variable "cloudfront_compress" {
  default     = true
  description = "To enable [CloudFront compression](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ServingCompressedFiles.html) or not"
  type        = bool
}

variable "cloudfront_default_root_object" {
  default     = null
  description = "The [CloudFront default root object](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DefaultRootObject.html) to display"
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
  description = "To enable CloudFront IPv6 or not (also controls [creation of two AAAA Route53 records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html))"
  type        = bool
}

variable "cloudfront_price_class" {
  default     = "PriceClass_100"
  description = "The [CloudFront price class](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html)"
  type        = string

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Variable must be 'PriceClass_All', 'PriceClass_200', or 'PriceClass_100'."
  }
}

variable "cloudfront_ssl_minimum_protocol_version" {
  default     = "TLSv1.2_2021"
  description = "The [CloudFront minimum SSL protocol](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html) to use"
  type        = string
}

variable "cloudfront_viewer_protocol_policy" {
  default     = "redirect-to-https"
  description = "The [CloudFront viewer protocol policy](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https-viewers-to-cloudfront.html) to enforce (e.g., redirect HTTP to HTTPS)"
  type        = string

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cloudfront_viewer_protocol_policy)
    error_message = "Variable must be 'allow-all', 'https-only', or 'redirect-to-https'."
  }
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
