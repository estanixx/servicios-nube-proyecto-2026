# =============================================================================
# API Gateway Resource - /estudiante
# =============================================================================

resource "aws_api_gateway_resource" "estudiante" {
  rest_api_id = aws_api_gateway_rest_api.nexacloud.id
  parent_id   = aws_api_gateway_rest_api.nexacloud.root_resource_id
  path_part   = "estudiante"
}

# -----------------------------------------------------------------------------
# Method - POST /estudiante
# -----------------------------------------------------------------------------

resource "aws_api_gateway_method" "estudiante_post" {
  rest_api_id   = aws_api_gateway_rest_api.nexacloud.id
  resource_id   = aws_api_gateway_resource.estudiante.id
  http_method   = "POST"
  authorization = "NONE"
}

# -----------------------------------------------------------------------------
# Integration - POST /estudiante -> InsertStudentLambda
# -----------------------------------------------------------------------------

resource "aws_api_gateway_integration" "estudiante_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.nexacloud.id
  resource_id             = aws_api_gateway_resource.estudiante.id
  http_method             = aws_api_gateway_method.estudiante_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.insert_student.invoke_arn
}