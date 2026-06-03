# =============================================================================
# IAM Role for Lambda RDS Access (IAM Authentication)
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for Lambda Functions with RDS IAM Auth
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_rds_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_rds" {
  name               = "${local.name_prefix}-lambda-rds-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_rds_assume_role.json

  tags = {
    Name = "${local.name_prefix}-lambda-rds-role"
  }
}

# -----------------------------------------------------------------------------
# IAM Policy for RDS DB Connect (IAM Authentication)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_rds_policy" {
  # RDS DB Connect permission - allows Lambda to authenticate to RDS using IAM
  statement {
    sid    = "RDSDBConnect"
    effect = "Allow"
    actions = [
      "rds-db:connect"
    ]
    resources = [
      "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.main.identifier}"
    ]
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
    # Restrict to the project's log group prefix
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-*"
    ]
  }
}

resource "aws_iam_policy" "lambda_rds" {
  name        = "${local.name_prefix}-lambda-rds-policy"
  description = "Policy for Lambda functions to connect to RDS using IAM authentication"
  policy      = data.aws_iam_policy_document.lambda_rds_policy.json

  tags = {
    Name = "${local.name_prefix}-lambda-rds-policy"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_rds" {
  role       = aws_iam_role.lambda_rds.name
  policy_arn = aws_iam_policy.lambda_rds.arn
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Instance Profile for Lambda (used in VPC config)
# -----------------------------------------------------------------------------

resource "aws_iam_instance_profile" "lambda_rds" {
  name = "${local.name_prefix}-lambda-rds-profile"
  role = aws_iam_role.lambda_rds.name

  tags = {
    Name = "${local.name_prefix}-lambda-rds-profile"
  }
}
