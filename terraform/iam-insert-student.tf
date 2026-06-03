# =============================================================================
# IAM Role for Lambda - Insert Student Function
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for InsertStudentLambda (RDS + Secrets Manager Access)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_insert_student_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_insert_student" {
  name               = "${local.name_prefix}-lambda-insert-student-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_insert_student_assume_role.json

  tags = {
    Name = "${local.name_prefix}-lambda-insert-student-role"
  }
}

# -----------------------------------------------------------------------------
# IAM Policy for InsertStudentLambda (RDS + Secrets Manager + VPC + CloudWatch)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_insert_student_policy" {
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

  # Secrets Manager - GetSecretValue for DB credentials
  statement {
    sid    = "SecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.rds_credentials.arn
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

resource "aws_iam_policy" "lambda_insert_student" {
  name        = "${local.name_prefix}-lambda-insert-student-policy"
  description = "Policy for InsertStudentLambda to connect to RDS and read secrets"
  policy      = data.aws_iam_policy_document.lambda_insert_student_policy.json

  tags = {
    Name = "${local.name_prefix}-lambda-insert-student-policy"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_insert_student" {
  role       = aws_iam_role.lambda_insert_student.name
  policy_arn = aws_iam_policy.lambda_insert_student.arn
}

# -----------------------------------------------------------------------------
# Instance Profile for InsertStudentLambda
# -----------------------------------------------------------------------------

resource "aws_iam_instance_profile" "lambda_insert_student" {
  name = "${local.name_prefix}-lambda-insert-student-profile"
  role = aws_iam_role.lambda_insert_student.name

  tags = {
    Name = "${local.name_prefix}-lambda-insert-student-profile"
  }
}
