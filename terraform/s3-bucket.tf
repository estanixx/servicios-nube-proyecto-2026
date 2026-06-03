# =============================================================================
# S3 Bucket - Employee Images Storage
# =============================================================================

resource "aws_s3_bucket" "employee_images" {
  bucket = "${local.name_prefix}-employee-images-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${local.name_prefix}-employee-images"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket Versioning
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket Server-Side Encryption (AES-256)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket Public Access Block (both bucket policy AND block public access)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id

  # Block all public access settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# S3 Bucket Ownership Controls (ACLs disabled)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
