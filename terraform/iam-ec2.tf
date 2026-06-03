# =============================================================================
# IAM Role for EC2 Instance Profile (SSM Session Manager access)
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for EC2
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-role"
  }
}

# -----------------------------------------------------------------------------
# IAM Policy for EC2 (CloudWatch Agent + SSM Session Manager)
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "ec2" {
  name        = "${local.name_prefix}-ec2-policy"
  description = "IAM policy for EC2 instances with SSM Session Manager and CloudWatch access"

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
          "ssm:GetConnectionStatus"
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
          "logs:GetLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "S3ReadOnlyAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.employee_images.arn,
          "${aws_s3_bucket.employee_images.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-policy"
  }
}

# -----------------------------------------------------------------------------
# Role-Policy Attachment
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2.arn
}

# -----------------------------------------------------------------------------
# Instance Profile for EC2
# -----------------------------------------------------------------------------

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name = "${local.name_prefix}-ec2-profile"
  }
}