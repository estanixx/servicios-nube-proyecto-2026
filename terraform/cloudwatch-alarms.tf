# =============================================================================
# CloudWatch Alarms
# =============================================================================

# -----------------------------------------------------------------------------
# EC2 CPU Alarm (for monitoring, separate from ASG scaling)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${local.name_prefix}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "EC2 CPU utilization exceeds 70% - notify via SNS"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nexacloud.name
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-ec2-cpu-high"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# ALB 5XX Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "ALB 5XX errors exceed 5 per minute"

  dimensions = {
    LoadBalancer = aws_lb.nexacloud.name
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-alb-5xx-high"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# ALB 4XX Alarm (client errors)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_4xx" {
  alarm_name          = "${local.name_prefix}-alb-4xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 20
  alarm_description   = "ALB 4XX client errors exceed 20 per minute"

  dimensions = {
    LoadBalancer = aws_lb.nexacloud.name
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-alb-4xx-high"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# RDS CPU Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "RDS CPU utilization exceeds 70%"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-rds-cpu-high"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# RDS Storage Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${local.name_prefix}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5GB in bytes
  alarm_description   = "RDS free storage below 5GB"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-rds-storage-low"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# RDS Database Connections Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${local.name_prefix}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS database connections exceed 80"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-rds-connections-high"
    Project     = var.project_name
    Environment = "production"
  }
}
