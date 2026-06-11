# =============================================================================
# Networking - VPC, Subnets, IGW, NAT Gateways, Route Tables, VPC Endpoints
# =============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

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

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

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

resource "aws_nat_gateway" "main_1" {
  allocation_id = aws_eip.nat_gw_1.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${local.name_prefix}-nat-gw-az1"
  }
}

resource "aws_nat_gateway" "main_2" {
  allocation_id = aws_eip.nat_gw_2.id
  subnet_id     = aws_subnet.public_2.id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${local.name_prefix}-nat-gw-az2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_1.id
  }

  tags = {
    Name = "${local.name_prefix}-private-rt-az1"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_2.id
  }

  tags = {
    Name = "${local.name_prefix}-private-rt-az2"
  }
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

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
