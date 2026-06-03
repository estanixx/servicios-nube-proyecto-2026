# =============================================================================
# API Gateway Deployment and Stage
# =============================================================================

# -----------------------------------------------------------------------------
# Deployment (triggers redeployment when resources change)
# -----------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "nexacloud" {
  rest_api_id = aws_api_gateway_rest_api.nexacloud.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.estudiante.id,
      aws_api_gateway_resource.images.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.estudiante_lambda,
    aws_api_gateway_integration.images_lambda,
  ]
}

# -----------------------------------------------------------------------------
# Stage - prod
# -----------------------------------------------------------------------------

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.nexacloud.id
  rest_api_id   = aws_api_gateway_rest_api.nexacloud.id
  stage_name    = "prod"

  # Access logging settings (optional)
  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  # }

  tags = {
    Name        = "${local.name_prefix}-prod"
    Environment = "production"
  }
}