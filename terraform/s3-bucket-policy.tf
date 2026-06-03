# =============================================================================
# S3 Bucket Policy - Explicit Deny for Public + Allow for Lambda
# =============================================================================

data "aws_iam_policy_document" "s3_employee_images_policy" {
  # Deny all public access
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
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.employee_images.arn,
      "${aws_s3_bucket.employee_images.arn}/*"
    ]
  }

  # Allow any authenticated AWS principal (Lambda IAM role, etc.)
  statement {
    sid    = "AllowAuthenticatedAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.employee_images.arn,
      "${aws_s3_bucket.employee_images.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:sourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "employee_images" {
  bucket = aws_s3_bucket.employee_images.id
  policy = data.aws_iam_policy_document.s3_employee_images_policy.json
}