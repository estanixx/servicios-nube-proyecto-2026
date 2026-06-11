# =============================================================================
# Outputs - NexaCloud AWS Infrastructure
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the main VPC"
  value       = aws_vpc.main.cidr_block
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "public_subnet_1_id" {
  description = "ID of public subnet in AZ1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "ID of public subnet in AZ2"
  value       = aws_subnet.public_2.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "private_subnet_1_id" {
  description = "ID of private subnet in AZ1"
  value       = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  description = "ID of private subnet in AZ2"
  value       = aws_subnet.private_2.id
}

# -----------------------------------------------------------------------------
# Internet Gateway Output
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# -----------------------------------------------------------------------------
# NAT Gateway Outputs
# -----------------------------------------------------------------------------

output "nat_gateway_1_id" {
  description = "ID of NAT Gateway in AZ1"
  value       = aws_nat_gateway.main_1.id
}

output "nat_gateway_2_id" {
  description = "ID of NAT Gateway in AZ2"
  value       = aws_nat_gateway.main_2.id
}

# -----------------------------------------------------------------------------
# Route Table Outputs
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_1_id" {
  description = "ID of private route table for AZ1"
  value       = aws_route_table.private_1.id
}

output "private_route_table_2_id" {
  description = "ID of private route table for AZ2"
  value       = aws_route_table.private_2.id
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------


output "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.lambda.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

# -----------------------------------------------------------------------------
# RDS Outputs
# -----------------------------------------------------------------------------

output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "rds_instance_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.main.name
}

output "rds_secrets_arn" {
  description = "ARN of the RDS credentials secret"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "lambda_rds_role_arn" {
  description = "ARN of the Lambda RDS IAM role"
  value       = aws_iam_role.lambda_rds.arn
}

output "lambda_rds_instance_profile_arn" {
  description = "ARN of the Lambda instance profile for RDS auth"
  value       = aws_iam_instance_profile.lambda_rds.arn
}

# -----------------------------------------------------------------------------
# VPC Endpoint Outputs
# -----------------------------------------------------------------------------

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_vpc_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

# -----------------------------------------------------------------------------
# S3 Bucket Outputs
# -----------------------------------------------------------------------------

output "employee_images_bucket_name" {
  description = "Name of the employee images S3 bucket"
  value       = aws_s3_bucket.employee_images.bucket
}

output "employee_images_bucket_arn" {
  description = "ARN of the employee images S3 bucket"
  value       = aws_s3_bucket.employee_images.arn
}

# -----------------------------------------------------------------------------
# Lambda Function Outputs
# -----------------------------------------------------------------------------

output "insert_student_lambda_name" {
  description = "Name of the InsertStudentLambda function"
  value       = aws_lambda_function.insert_student.function_name
}

output "insert_student_lambda_arn" {
  description = "ARN of the InsertStudentLambda function"
  value       = aws_lambda_function.insert_student.arn
}

output "insert_student_lambda_role_arn" {
  description = "ARN of the InsertStudentLambda IAM role"
  value       = aws_iam_role.lambda_insert_student.arn
}

output "serve_images_lambda_name" {
  description = "Name of the ServeImagesLambda function"
  value       = aws_lambda_function.serve_images.function_name
}

output "serve_images_lambda_arn" {
  description = "ARN of the ServeImagesLambda function"
  value       = aws_lambda_function.serve_images.arn
}

output "serve_images_lambda_role_arn" {
  description = "ARN of the ServeImagesLambda IAM role"
  value       = aws_iam_role.lambda_images.arn
}

# -----------------------------------------------------------------------------
# EC2 Outputs
# -----------------------------------------------------------------------------

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "ec2_iam_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.arn
}

output "ec2_launch_template_id" {
  description = "ID of the EC2 launch template"
  value       = aws_launch_template.nexacloud.id
}

output "ec2_asg_name" {
  description = "Name of the EC2 Auto Scaling Group"
  value       = aws_autoscaling_group.nexacloud.name
}

# -----------------------------------------------------------------------------
# ALB Outputs
# -----------------------------------------------------------------------------

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.nexacloud.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB for Route53 alias records"
  value       = aws_lb.nexacloud.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.nexacloud.arn
}

# -----------------------------------------------------------------------------
# API Gateway Outputs
# -----------------------------------------------------------------------------

output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.nexacloud.id
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.nexacloud.execution_arn
}

output "api_gateway_prod_stage_url" {
  description = "Base URL for the prod stage of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.nexacloud.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
}

output "api_gateway_api_key" {
  description = "API Key for accessing the API Gateway"
  value       = aws_api_gateway_api_key.nexacloud.value
  sensitive   = true
}

output "lambda_api_key" {
  description = "API Key que las Lambdas validan en el header x-api-key"
  value       = aws_api_gateway_api_key.nexacloud.value
  sensitive   = true
}

# -----------------------------------------------------------------------------
# SNS Topic Outputs
# -----------------------------------------------------------------------------

output "sns_alerts_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alerts"
  value       = aws_sns_topic.nexacloud_alerts.arn
}

output "sns_alerts_topic_name" {
  description = "Name of the SNS topic for CloudWatch alerts"
  value       = aws_sns_topic.nexacloud_alerts.name
}

# -----------------------------------------------------------------------------
# CloudWatch Dashboard Output
# -----------------------------------------------------------------------------

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.nexacloud.dashboard_name
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm Outputs
# -----------------------------------------------------------------------------

output "cloudwatch_alarm_ec2_cpu_arn" {
  description = "ARN of the EC2 CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.ec2_cpu.arn
}

output "cloudwatch_alarm_alb_5xx_arn" {
  description = "ARN of the ALB 5XX CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}

output "cloudwatch_alarm_rds_cpu_arn" {
  description = "ARN of the RDS CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu.arn
}

output "cloudwatch_alarm_rds_storage_arn" {
  description = "ARN of the RDS storage CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.rds_storage.arn
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group Outputs
# -----------------------------------------------------------------------------

output "cloudwatch_log_group_insert_student" {
  description = "Name of the InsertStudent Lambda log group"
  value       = aws_cloudwatch_log_group.insert_student_logs.name
}

output "cloudwatch_log_group_serve_images" {
  description = "Name of the ServeImages Lambda log group"
  value       = aws_cloudwatch_log_group.serve_images_logs.name
}
