# =============================================================================
# Lambda Deployment Packaging - archive_file only (no null_resource)
# =============================================================================
# IMPORTANT: Run 'npm install' in lambda directories BEFORE 'terraform apply':
#   cd lambda/insertStudentLambda && npm install
#   cd lambda/getEmployeeImagesLambda && npm install

# -----------------------------------------------------------------------------
# InsertStudentLambda: zip packaging
# -----------------------------------------------------------------------------

data "archive_file" "insert_student_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/insertStudentLambda"
  output_path = "${path.module}/insert_student_lambda.zip"
}

# -----------------------------------------------------------------------------
# ServeImagesLambda: zip packaging
# -----------------------------------------------------------------------------

data "archive_file" "serve_images_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/getEmployeeImagesLambda"
  output_path = "${path.module}/serve_images_lambda.zip"
}