# =============================================================================
# RDS PostgreSQL Instance
# =============================================================================

resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-postgres"

  # Engine configuration
  engine         = "postgres"
  engine_version = var.rds_engine_version
  port           = var.rds_port

  # Instance configuration
  instance_class = var.rds_instance_class

  # Storage configuration
  allocated_storage = var.rds_allocated_storage
  storage_type      = var.rds_storage_type
  storage_encrypted = true

  # Database configuration
  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password  # Direct password ( Secrets Manager updated after RDS creation)

  # High availability
  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = var.rds_maintenance_window

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Public access - explicitly disabled
  publicly_accessible = false

  # SSO/IAM authentication
  iam_database_authentication_enabled = true

  # Final snapshot on deletion (for safety)
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot"

  # Copy tags to snapshots
  copy_tags_to_snapshot = true

  tags = {
    Name = "${local.name_prefix}-rds"
  }
}
