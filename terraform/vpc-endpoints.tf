# =============================================================================
# VPC Endpoints - Gateway Type (S3 and DynamoDB)
# =============================================================================

# -----------------------------------------------------------------------------
# S3 Gateway Endpoint
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_1.id,
    aws_route_table.private_2.id,
  ]

  tags = {
    Name = "${local.name_prefix}-vpce-s3"
  }
}

# -----------------------------------------------------------------------------
# DynamoDB Gateway Endpoint (optional but recommended for Lambda in VPC)
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_1.id,
    aws_route_table.private_2.id,
  ]

  tags = {
    Name = "${local.name_prefix}-vpce-dynamodb"
  }
}
