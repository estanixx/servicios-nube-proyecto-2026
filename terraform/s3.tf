# =============================================================================
# S3 - Employee Images Bucket
# =============================================================================

resource "aws_s3_bucket" "employee_images" {
  bucket = "${local.name_prefix}-employee-images-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${local.name_prefix}-employee-images"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "employee_images" {
  bucket                  = aws_s3_bucket.employee_images.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "s3_employee_images_policy" {
  # Deny requests from outside this AWS account.
  # Condition excludes the account itself so Lambda roles are not blocked.
  statement {
    sid    = "DenyPublicAccess"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.employee_images.arn,
      "${aws_s3_bucket.employee_images.arn}/*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id
  policy = data.aws_iam_policy_document.s3_employee_images_policy.json
}
