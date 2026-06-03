# =============================================================================
# API Gateway Resource - /images
# =============================================================================

resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.nexacloud.id
  parent_id   = aws_api_gateway_rest_api.nexacloud.root_resource_id
  path_part   = "images"
}

# -----------------------------------------------------------------------------
# Method - GET /images
# -----------------------------------------------------------------------------

resource "aws_api_gateway_method" "images_get" {
  rest_api_id   = aws_api_gateway_rest_api.nexacloud.id
  resource_id   = aws_api_gateway_resource.images.id
  http_method   = "GET"
  authorization = "NONE"
}

# -----------------------------------------------------------------------------
# Integration - GET /images -> ServeImagesLambda
# -----------------------------------------------------------------------------

resource "aws_api_gateway_integration" "images_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.nexacloud.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.images_get.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.serve_images.invoke_arn
}