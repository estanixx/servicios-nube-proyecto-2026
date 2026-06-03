# =============================================================================
# RDS Subnet Group
# =============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group"
  }
}
