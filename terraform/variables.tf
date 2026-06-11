# =============================================================================
# Variables - NexaCloud AWS Infrastructure
# =============================================================================


variable "project_name" {
  description = "Project name for resource naming and tags"
  type        = string
  default     = "nexacloud"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# VPC Configuration
# =============================================================================

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones for the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# =============================================================================
# Subnet Configuration
# =============================================================================

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# =============================================================================
# RDS Configuration
# =============================================================================

variable "rds_port" {
  description = "RDS PostgreSQL port"
  type        = number
  default     = 9876
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.14"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Initial database name"
  type        = string
  default     = "nexaclouddb"
}

variable "rds_username" {
  description = "Master username for RDS"
  type        = string
  default     = "nexacloud_admin"
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "rds_backup_retention_days" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_maintenance_window" {
  description = "RDS maintenance window (UTC)"
  type        = string
  default     = "Sun:00:00-Sun:03:00"
}

variable "rds_storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp3"
}


# =============================================================================
# EC2 Configuration
# =============================================================================


variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}


variable "ec2_min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 2
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 5
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 2
}

# =============================================================================
# SNS/Alerting Configuration
# =============================================================================

variable "alert_email" {
  description = "Email address for SNS alert subscriptions"
  type        = string
  default     = "ops@nexacloud.com"
}

# =============================================================================
# Name Tag Map (for consistent tagging)
# =============================================================================

locals {
  name_prefix = var.project_name
}
