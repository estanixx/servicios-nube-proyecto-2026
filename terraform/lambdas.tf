# =============================================================================
# Lambda - Packaging, Functions, and API Gateway Permissions
# =============================================================================
# IMPORTANT: Run 'npm install' in each lambda directory before 'terraform apply':
#   cd lambda/insertStudentLambda && npm install
#   cd lambda/getEmployeeImagesLambda && npm install
#   cd lambda/seedDatabaseLambda && npm install

variable "api_key" {
  description = "API Key value injected into Lambda environment"
  type        = string
  sensitive   = true
  default     = ""
}

# -----------------------------------------------------------------------------
# Packaging
# -----------------------------------------------------------------------------

data "archive_file" "insert_student_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/insertStudentLambda"
  output_path = "${path.module}/insert_student_lambda.zip"
}

data "archive_file" "serve_images_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/getEmployeeImagesLambda"
  output_path = "${path.module}/serve_images_lambda.zip"
}

data "archive_file" "seed_database_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/seedDatabaseLambda"
  output_path = "${path.module}/seed_database_lambda.zip"
}

# -----------------------------------------------------------------------------
# InsertStudentLambda
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

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      API_KEY     = var.api_key
      DB_HOST     = aws_db_instance.main.address
      DB_PORT     = tostring(var.rds_port)
      DB_NAME     = var.rds_db_name
      DB_USER     = var.rds_username
      DB_PASSWORD = var.rds_password
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_insert_student]

  tags = {
    Name        = "${local.name_prefix}-insert-student"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# ServeImagesLambda
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "serve_images" {
  filename         = data.archive_file.serve_images_lambda_zip.output_path
  function_name    = "${local.name_prefix}-serve-images"
  role             = aws_iam_role.lambda_images.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.serve_images_lambda_zip.output_base64sha256
  runtime          = "nodejs18.x"
  timeout          = 30
  memory_size      = 256

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.employee_images.bucket
      API_KEY        = var.api_key
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_images]

  tags = {
    Name        = "${local.name_prefix}-serve-images"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# SeedDatabaseLambda
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "seed_database" {
  filename         = data.archive_file.seed_database_lambda_zip.output_path
  function_name    = "${local.name_prefix}-seed-database"
  role             = aws_iam_role.lambda_insert_student.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.seed_database_lambda_zip.output_base64sha256
  runtime          = "nodejs18.x"
  timeout          = 60
  memory_size      = 256

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.main.address
      DB_PORT     = tostring(var.rds_port)
      DB_NAME     = var.rds_db_name
      DB_USER     = var.rds_username
      DB_PASSWORD = var.rds_password
    }
  }

  depends_on = [
    aws_db_instance.main,
    aws_iam_role_policy_attachment.lambda_insert_student,
  ]

  tags = {
    Name        = "${local.name_prefix}-seed-database"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# API Gateway invoke permissions
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway_insert_student" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.insert_student.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.nexacloud.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_serve_images" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serve_images.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.nexacloud.execution_arn}/*/*"
}
