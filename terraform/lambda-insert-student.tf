# =============================================================================
# Lambda Function - InsertStudentLambda
# =============================================================================

# -----------------------------------------------------------------------------
# Lambda Function: InsertStudentLambda (uses pg library for direct PostgreSQL)
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "insert_student" {
  filename         = data.archive_file.insert_student_lambda_zip.output_path
  function_name    = "${local.name_prefix}-insert-student"
  role             = aws_iam_role.lambda_insert_student.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.insert_student_lambda_zip.output_base64sha256
  runtime          = "nodejs18.x"
  timeout          = 30
  memory_size      = 256

  # VPC Configuration - Lambda in private subnets
  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  # Environment variables for direct PostgreSQL connection
  environment {
    variables = {
      API_KEY   = var.api_key
      DB_HOST   = aws_db_instance.main.endpoint
      DB_PORT   = tostring(var.rds_port)
      DB_NAME   = var.rds_db_name
      DB_USER   = var.rds_username
      DB_PASSWORD = var.rds_password
    }
  }

  tags = {
    Name        = "${local.name_prefix}-insert-student"
    Project     = var.project_name
    Environment = "production"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_insert_student
  ]
}

# -----------------------------------------------------------------------------
# Variable for API Key
# -----------------------------------------------------------------------------

variable "api_key" {
  description = "API Key for Lambda function authentication"
  type        = string
  sensitive   = true
  default     = "" # Must be provided via tfvars or environment variable TF_VAR_api_key
}