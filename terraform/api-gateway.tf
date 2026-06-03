# =============================================================================
# API Gateway REST API
# =============================================================================

resource "aws_api_gateway_rest_api" "nexacloud" {
  name        = "${local.name_prefix}-api"
  description = "NexaCloud REST API for Lambda functions"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${local.name_prefix}-api"
    Environment = "production"
  }
}