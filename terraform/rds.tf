# =============================================================================
# RDS - PostgreSQL Instance, Subnet Group, Secrets Manager
# =============================================================================

variable "rds_password" {
  description = "Master password for RDS instance. Set via TF_VAR_rds_password o terraform.tfvars"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.rds_password) >= 8
    error_message = "rds_password debe tener al menos 8 caracteres."
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.rds_engine_version
  port           = var.rds_port

  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  storage_type      = var.rds_storage_type
  storage_encrypted = true

  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password

  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = var.rds_maintenance_window

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible                 = false
  iam_database_authentication_enabled = true

  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot"
  copy_tags_to_snapshot     = true

  tags = {
    Name = "${local.name_prefix}-rds"
  }
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${local.name_prefix}-rds-credentials"
  description             = "RDS PostgreSQL master credentials for ${local.name_prefix}"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.name_prefix}-rds-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    username = var.rds_username
    password = var.rds_password
    engine   = "postgres"
    host     = aws_db_instance.main.endpoint
    port     = var.rds_port
    dbname   = var.rds_db_name
  })
}
