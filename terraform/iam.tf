# =============================================================================
# IAM - Roles and Policies for EC2, Lambda (insert-student, images, rds)
# =============================================================================

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# EC2
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "${local.name_prefix}-ec2-role" }
}

resource "aws_iam_policy" "ec2" {
  name        = "${local.name_prefix}-ec2-policy"
  description = "SSM Session Manager and CloudWatch access for EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMSessionManagerAccess"
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "S3ReadOnlyAccess"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.employee_images.arn,
          "${aws_s3_bucket.employee_images.arn}/*",
        ]
      },
    ]
  })

  tags = { Name = "${local.name_prefix}-ec2-policy" }
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = { Name = "${local.name_prefix}-ec2-profile" }
}

# -----------------------------------------------------------------------------
# Lambda - InsertStudent (RDS + Secrets Manager)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_insert_student_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_insert_student" {
  name               = "${local.name_prefix}-lambda-insert-student-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_insert_student_assume_role.json

  tags = { Name = "${local.name_prefix}-lambda-insert-student-role" }
}

data "aws_iam_policy_document" "lambda_insert_student_policy" {
  statement {
    sid     = "RDSDBConnect"
    effect  = "Allow"
    actions = ["rds-db:connect"]
    resources = [
      "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.main.identifier}",
    ]
  }

  statement {
    sid     = "SecretsManagerRead"
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.rds_credentials.arn]
  }

  statement {
    sid    = "VPCPermissions"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-*",
    ]
  }
}

resource "aws_iam_policy" "lambda_insert_student" {
  name        = "${local.name_prefix}-lambda-insert-student-policy"
  description = "InsertStudentLambda: RDS connect, Secrets Manager, VPC, CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_insert_student_policy.json

  tags = { Name = "${local.name_prefix}-lambda-insert-student-policy" }
}

resource "aws_iam_role_policy_attachment" "lambda_insert_student" {
  role       = aws_iam_role.lambda_insert_student.name
  policy_arn = aws_iam_policy.lambda_insert_student.arn
}

resource "aws_iam_instance_profile" "lambda_insert_student" {
  name = "${local.name_prefix}-lambda-insert-student-profile"
  role = aws_iam_role.lambda_insert_student.name

  tags = { Name = "${local.name_prefix}-lambda-insert-student-profile" }
}

# -----------------------------------------------------------------------------
# Lambda - ServeImages (S3 read)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_images_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_images" {
  name               = "${local.name_prefix}-lambda-images-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_images_assume_role.json

  tags = { Name = "${local.name_prefix}-lambda-images-role" }
}

data "aws_iam_policy_document" "lambda_images_policy" {
  statement {
    sid     = "S3GetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.employee_images.arn}/employee-images/*"]
  }

  statement {
    sid     = "S3ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.employee_images.arn]
  }

  statement {
    sid    = "VPCPermissions"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-*",
    ]
  }
}

resource "aws_iam_policy" "lambda_images" {
  name        = "${local.name_prefix}-lambda-images-policy"
  description = "ServeImagesLambda: S3 read, VPC, CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_images_policy.json

  tags = { Name = "${local.name_prefix}-lambda-images-policy" }
}

resource "aws_iam_role_policy_attachment" "lambda_images" {
  role       = aws_iam_role.lambda_images.name
  policy_arn = aws_iam_policy.lambda_images.arn
}

# -----------------------------------------------------------------------------
# Lambda - RDS IAM Auth (used for outputs/reference)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_rds_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_rds" {
  name               = "${local.name_prefix}-lambda-rds-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_rds_assume_role.json

  tags = { Name = "${local.name_prefix}-lambda-rds-role" }
}

data "aws_iam_policy_document" "lambda_rds_policy" {
  statement {
    sid     = "RDSDBConnect"
    effect  = "Allow"
    actions = ["rds-db:connect"]
    resources = [
      "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.main.identifier}",
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name_prefix}-*",
    ]
  }
}

resource "aws_iam_policy" "lambda_rds" {
  name        = "${local.name_prefix}-lambda-rds-policy"
  description = "Lambda RDS IAM authentication"
  policy      = data.aws_iam_policy_document.lambda_rds_policy.json

  tags = { Name = "${local.name_prefix}-lambda-rds-policy" }
}

resource "aws_iam_role_policy_attachment" "lambda_rds" {
  role       = aws_iam_role.lambda_rds.name
  policy_arn = aws_iam_policy.lambda_rds.arn
}

resource "aws_iam_instance_profile" "lambda_rds" {
  name = "${local.name_prefix}-lambda-rds-profile"
  role = aws_iam_role.lambda_rds.name

  tags = { Name = "${local.name_prefix}-lambda-rds-profile" }
}
