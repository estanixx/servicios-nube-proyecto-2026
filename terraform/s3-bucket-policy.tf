# =============================================================================
# S3 Bucket Policy - Explicit Deny for Public + Allow for Lambda
# =============================================================================

data "aws_iam_policy_document" "s3_employee_images_policy" {
  # Denegar acceso público (fuera de la cuenta). El Deny explícito sin condición
  # bloqueaba también al IAM role de la Lambda porque en AWS un Deny siempre
  # gana sobre cualquier Allow. Se usa aws:PrincipalAccount para excluir la
  # cuenta propia del Deny.
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