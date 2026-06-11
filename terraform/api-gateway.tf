# =============================================================================
# API Gateway - REST API, Resources, Methods, Integrations, Stage, Key
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

# -----------------------------------------------------------------------------
# POST /estudiante -> InsertStudentLambda
# -----------------------------------------------------------------------------

resource "aws_api_gateway_resource" "estudiante" {
  rest_api_id = aws_api_gateway_rest_api.nexacloud.id
  parent_id   = aws_api_gateway_rest_api.nexacloud.root_resource_id
  path_part   = "estudiante"
}

resource "aws_api_gateway_method" "estudiante_post" {
  rest_api_id      = aws_api_gateway_rest_api.nexacloud.id
  resource_id      = aws_api_gateway_resource.estudiante.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "estudiante_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.nexacloud.id
  resource_id             = aws_api_gateway_resource.estudiante.id
  http_method             = aws_api_gateway_method.estudiante_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.insert_student.invoke_arn
}

# -----------------------------------------------------------------------------
# GET /images -> ServeImagesLambda
# -----------------------------------------------------------------------------

resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.nexacloud.id
  parent_id   = aws_api_gateway_rest_api.nexacloud.root_resource_id
  path_part   = "images"
}

resource "aws_api_gateway_method" "images_get" {
  rest_api_id      = aws_api_gateway_rest_api.nexacloud.id
  resource_id      = aws_api_gateway_resource.images.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "images_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.nexacloud.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.images_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.serve_images.invoke_arn
}

# -----------------------------------------------------------------------------
# Deployment and Stage
# -----------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "nexacloud" {
  rest_api_id = aws_api_gateway_rest_api.nexacloud.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.estudiante.id,
      aws_api_gateway_resource.images.id,
      aws_api_gateway_method.estudiante_post.api_key_required,
      aws_api_gateway_method.images_get.api_key_required,
      aws_api_gateway_integration.estudiante_lambda.uri,
      aws_api_gateway_integration.images_lambda.uri,
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

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.nexacloud.id
  rest_api_id   = aws_api_gateway_rest_api.nexacloud.id
  stage_name    = "prod"

  tags = {
    Name        = "${local.name_prefix}-prod"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# API Key and Usage Plan
# -----------------------------------------------------------------------------

resource "aws_api_gateway_api_key" "nexacloud" {
  name        = "${local.name_prefix}-api-key"
  description = "API Key for NexaCloud API Gateway"

  tags = {
    Name        = "${local.name_prefix}-api-key"
    Environment = "production"
  }
}

resource "aws_api_gateway_usage_plan" "basic" {
  name        = "${local.name_prefix}-usage-plan"
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

resource "aws_api_gateway_usage_plan_key" "basic" {
  key_id        = aws_api_gateway_api_key.nexacloud.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.basic.id
}
