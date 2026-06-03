# =============================================================================
# CloudWatch Log Groups for Lambda Functions
# =============================================================================

# -----------------------------------------------------------------------------
# Log Group: InsertStudentLambda
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "insert_student_logs" {
  name              = "/aws/lambda/${aws_lambda_function.insert_student.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-insert-student-logs"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# Log Group: ServeImagesLambda
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "serve_images_logs" {
  name              = "/aws/lambda/${aws_lambda_function.serve_images.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-serve-images-logs"
    Project     = var.project_name
    Environment = "production"
  }
}
