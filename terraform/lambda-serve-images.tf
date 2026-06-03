# =============================================================================
# Lambda Function - ServeImagesLambda (getEmployeeImagesLambda)
# =============================================================================

# -----------------------------------------------------------------------------
# Lambda Function: ServeImagesLambda
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

  # VPC Configuration - Lambda in private subnets (S3 accessed via VPC endpoint)
  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  # Environment variables
  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.employee_images.bucket
      API_KEY        = var.api_key
    }
  }

  tags = {
    Name        = "${local.name_prefix}-serve-images"
    Project     = var.project_name
    Environment = "production"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_images
  ]
}