# =============================================================================
# AWS Secrets Manager - RDS Credentials
# =============================================================================

resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${local.name_prefix}-rds-credentials"
  description = "RDS PostgreSQL master credentials for ${local.name_prefix}"

  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-rds-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    username = var.rds_username
    password = var.rds_password # This should be provided via var.rds_password or environment
    engine   = "postgres"
    host     = aws_db_instance.main.endpoint
    port     = var.rds_port
    dbname   = var.rds_db_name
  })
}

# Variable for RDS password (should be provided via tfvars or environment variable)
variable "rds_password" {
  description = "Master password for RDS instance (use Secrets Manager in production)"
  type        = string
  sensitive   = true
  default     = "" # Must be provided via tfvars or environment variable TF_VAR_rds_password
}
