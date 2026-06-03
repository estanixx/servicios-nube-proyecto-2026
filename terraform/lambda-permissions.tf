# =============================================================================
# Lambda Permissions for API Gateway
# =============================================================================

# -----------------------------------------------------------------------------
# Permission for InsertStudentLambda
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway_insert_student" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.insert_student.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.nexacloud.execution_arn}/*/*"
}

# -----------------------------------------------------------------------------
# Permission for ServeImagesLambda
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "api_gateway_serve_images" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serve_images.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.nexacloud.execution_arn}/*/*"
}