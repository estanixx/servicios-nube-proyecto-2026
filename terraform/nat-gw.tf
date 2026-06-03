# =============================================================================
# NAT Gateways and Elastic IPs
# =============================================================================

# -----------------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_eip" "nat_gw_1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${local.name_prefix}-eip-nat-gw-az1"
  }
}

resource "aws_eip" "nat_gw_2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${local.name_prefix}-eip-nat-gw-az2"
  }
}

# -----------------------------------------------------------------------------
# NAT Gateways (one per public subnet for HA)
# -----------------------------------------------------------------------------

resource "aws_nat_gateway" "main_1" {
  allocation_id = aws_eip.nat_gw_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "${local.name_prefix}-nat-gw-az1"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main_2" {
  allocation_id = aws_eip.nat_gw_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "${local.name_prefix}-nat-gw-az2"
  }

  depends_on = [aws_internet_gateway.main]
}
