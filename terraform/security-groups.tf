# =============================================================================
# Security Groups
# =============================================================================

# -----------------------------------------------------------------------------
# SSH Security Group (non-default port 2222)
# -----------------------------------------------------------------------------

resource "aws_security_group" "ssh" {
  name        = "${local.name_prefix}-ssh-sg"
  description = "Security group for SSH access on non-default port from office IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from office IP"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.office_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ssh-sg"
  }
}

# -----------------------------------------------------------------------------
# Lambda Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions in private subnets"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-lambda-sg"
  }
}

# -----------------------------------------------------------------------------
# RDS Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for RDS PostgreSQL access from Lambda and VPC resources"
  vpc_id      = aws_vpc.main.id

  # Allow inbound from VPC CIDR (Lambda and EC2 instances)
  ingress {
    description = "PostgreSQL from VPC CIDR"
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow inbound from Lambda security group itself (for Lambda functions)
  ingress {
    description     = "PostgreSQL from Lambda SG"
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}
