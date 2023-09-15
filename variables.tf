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

variable "cloudfront_custom_error_responses" {
  default = [
    {
      error_code            = 404
      response_code         = 404
      error_caching_min_ttl = 60
      response_page_path    = "/404.html"
    }
  ]
  description = "The [CloudFront custom error responses](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html)"
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
}

variable "cloudfront_default_root_object" {
  default     = null
  description = "The [CloudFront default root object](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DefaultRootObject.html) to display (this is `null` by default, so nothing will display at `https://domain.com` unless you set something here)"
  type        = string
}

variable "cloudfront_enabled" {
  default     = true
  description = "To enable CloudFront or not"
  type        = bool
}

variable "cloudfront_function_create" {
  default     = false
  description = "To create and associate a CloudFront function (this doesn't test the function, so make sure it works!)"
  type        = bool
}

variable "cloudfront_function_filename" {
  default     = "function.js"
  description = "The filename of the CloudFront function"
  type        = string
}

variable "cloudfront_function_name" {
  default     = "MyFunction"
  description = "The name of the CloudFront function"
  type        = string
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

variable "cloudfront_ttl_min" {
  default     = 3600
  description = "The [CloudFront minimum cache time](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html) (seconds)"
  type        = number
}

variable "cloudfront_ttl_default" {
  default     = 86400
  description = "The [CloudFront default cache time](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html) (seconds)"
  type        = number
}

variable "cloudfront_ttl_max" {
  default     = 31536000
  description = "The [CloudFront maximum cache time](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html) (seconds)"
  type        = number
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
  description = "Domain name of the site and **MUST** match the Route53 hosted zone name (e.g., `domain.com`)"
  type        = string
}

variable "iam_policy_site_updating" {
  default     = false
  description = "Optional IAM policy that provides permissions needed to update a static site (e.g., create CloudFront cache invalidation, update objects in S3, etc...)"
  type        = bool
}

variable "upload_index" {
  default     = true
  description = "To push a test `index.html` page or not"
  type        = bool
}

variable "upload_robots" {
  default     = false
  description = "To push a restrictive `robots.txt` file (useful if you don't want a site to be indexed) or not"
  type        = bool
}

variable "upload_404" {
  default     = false
  description = "To push a `404.html` page (useful if you want to test your custom error responses) or not"
  type        = bool
}
