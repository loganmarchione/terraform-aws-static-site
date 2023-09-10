################################################################################
### S3
################################################################################

########################################
### Site bucket
########################################

# Create a bucket
resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name

#  lifecycle {
#    prevent_destroy = true
#  }
}

# Set bucket versioning
resource "aws_s3_bucket_versioning" "site" {
  count  = var.bucket_versioning_site == true ? 1 : 0
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Make sure the bucket is not public
resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable logging to log bucket
resource "aws_s3_bucket_logging" "site" {
  bucket = aws_s3_bucket.site.id

  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "s3_${aws_s3_bucket.site.id}/"

  depends_on = [aws_s3_bucket.logging]
}

# Upload a test page (if enabled)
resource "aws_s3_object" "site" {
  count        = var.test_page ? 1 : 0
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/files/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/files/index.html")
}

########################################
### Logging bucket
########################################

# Create a bucket
# Ignore KICS scan: S3 Bucket Logging Disabled
# Reason: This bucket is the logging bucket
# kics-scan ignore-line
resource "aws_s3_bucket" "logging" {
  bucket = "${local.bucket_name}-logging"

#  lifecycle {
#    prevent_destroy = true
#  }
}

# Set bucket versioning
resource "aws_s3_bucket_versioning" "logging" {
  count  = var.bucket_versioning_logs == true ? 1 : 0
  bucket = aws_s3_bucket.logging.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Make sure the bucket is not public
resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Set ownership controls
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls#rule-configuration-block
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Setup bucket ACL
# Starting in April 2023, you need to to override the best practice and enable ACLs when sending CloudFront logs to S3
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
resource "aws_s3_bucket_acl" "logging" {
  bucket = aws_s3_bucket.logging.id
  acl    = "log-delivery-write"

  depends_on = [aws_s3_bucket_ownership_controls.logging]
}

# Bucket lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    id     = "move_files_to_IA"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  rule {
    id     = "prune_old_files"
    status = "Enabled"
    expiration {
      days = 365
    }
  }
}
