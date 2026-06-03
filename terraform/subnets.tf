# =============================================================================
# Subnets - Public and Private across 2 Availability Zones
# =============================================================================

# -----------------------------------------------------------------------------
# Public Subnets (for NAT Gateways, ALB, and internet-facing resources)
# -----------------------------------------------------------------------------

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet-az1"
    Type = "public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet-az2"
    Type = "public"
  }
}

# -----------------------------------------------------------------------------
# Private Subnets (for RDS, Lambda, and internal resources)
# -----------------------------------------------------------------------------

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${local.name_prefix}-private-subnet-az1"
    Type = "private"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${local.name_prefix}-private-subnet-az2"
    Type = "private"
  }
}
