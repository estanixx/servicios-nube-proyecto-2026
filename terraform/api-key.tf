# =============================================================================
# API Gateway API Key and Usage Plan
# =============================================================================

# -----------------------------------------------------------------------------
# API Key
# -----------------------------------------------------------------------------

resource "aws_api_gateway_api_key" "nexacloud" {
  name = "${local.name_prefix}-api-key"

  description = "API Key for NexaCloud API Gateway"

  tags = {
    Name        = "${local.name_prefix}-api-key"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# Usage Plan - Basic tier
# -----------------------------------------------------------------------------

resource "aws_api_gateway_usage_plan" "basic" {
  name = "${local.name_prefix}-usage-plan"

  description = "Basic usage plan for NexaCloud API"

  api_stages {
    api_id = aws_api_gateway_rest_api.nexacloud.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }

  quota_settings {
    limit  = 1000
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  tags = {
    Name        = "${local.name_prefix}-usage-plan"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# Associate API Key with Usage Plan (basic)
# -----------------------------------------------------------------------------

resource "aws_api_gateway_usage_plan_key" "basic" {
  key_id        = aws_api_gateway_api_key.nexacloud.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.basic.id
}