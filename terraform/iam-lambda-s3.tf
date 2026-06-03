# =============================================================================
# IAM Role for Lambda - S3 Employee Images Access
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for ServeImagesLambda (S3 Read Access)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_images_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_images" {
  name               = "${local.name_prefix}-lambda-images-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_images_assume_role.json

  tags = {
    Name = "${local.name_prefix}-lambda-images-role"
  }
}

# -----------------------------------------------------------------------------
# IAM Policy for S3 GetObject and ListBucket + VPC + CloudWatch
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_images_policy" {
  # S3 GetObject permission for employee-images prefix
  statement {
    sid    = "S3GetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.employee_images.arn}/employee-images/*"
    ]
  }

  # S3 ListBucket permission
  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.employee_images.arn
    ]
  }

  # VPC permissions - CreateNetworkInterface for Lambda ENIs
  statement {
    sid    = "VPCPermissions"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

  # CloudWatch Logs permissions for Lambda logging
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-*"
    ]
  }
}

resource "aws_iam_policy" "lambda_images" {
  name        = "${local.name_prefix}-lambda-images-policy"
  description = "Policy for Lambda functions to read from S3 employee images bucket"
  policy      = data.aws_iam_policy_document.lambda_images_policy.json

  tags = {
    Name = "${local.name_prefix}-lambda-images-policy"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_images" {
  role       = aws_iam_role.lambda_images.name
  policy_arn = aws_iam_policy.lambda_images.arn
}
