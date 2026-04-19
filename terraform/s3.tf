# S3
# Free tier: 5 GB standard storage, 20,000 GET, 2,000 PUT/COPY/POST/LIST per month
#
# Removed for free tier:
# - aws_s3_bucket_versioning: versions count toward 5 GB limit; easy to blow through free tier

# 1. THE LOG ARCHIVE BUCKET
resource "aws_s3_bucket" "log_archive" {
  bucket = "easter-terraform-logs-archive"
}

# SSE-S3 (AES256) is free - uses AWS-managed keys, not customer KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "log_archive_crypto" {
  bucket = aws_s3_bucket.log_archive.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "log_archive_lockdown" {
  bucket                  = aws_s3_bucket.log_archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. SSL ENFORCEMENT POLICY (Fixes CKV_AWS_144) - free
resource "aws_s3_bucket_policy" "log_archive_ssl_only" {
  bucket = aws_s3_bucket.log_archive.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSSLRequestsOnly"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.log_archive.arn,
        "${aws_s3_bucket.log_archive.arn}/*"
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })
}

# 3. REGIONAL MAP WEBSITE BUCKET
resource "aws_s3_bucket" "website" {
  bucket = "regional-map-2024-website"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.id
  index_document { suffix = "index.html" }
}

# Same encryption for consistency
resource "aws_s3_bucket_server_side_encryption_configuration" "website_crypto" {
  bucket = aws_s3_bucket.website.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

# S3 access logging kept - storage counts toward the 5 GB free tier limit,
resource "aws_s3_bucket_logging" "website_logging" {
  bucket        = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.log_archive.id
  target_prefix = "s3-access-logs/regional-map/"
}
