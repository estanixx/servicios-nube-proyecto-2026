# =============================================================================
# CloudWatch - Log Groups, Alarms, Dashboard, SNS
# =============================================================================

# -----------------------------------------------------------------------------
# SNS Topic for alerts
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "nexacloud_alerts" {
  name = "${local.name_prefix}-alerts"

  tags = {
    Name        = "${local.name_prefix}-alerts"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.nexacloud_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# -----------------------------------------------------------------------------
# Lambda Log Groups
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "insert_student_logs" {
  name              = "/aws/lambda/${aws_lambda_function.insert_student.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-insert-student-logs"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "serve_images_logs" {
  name              = "/aws/lambda/${aws_lambda_function.serve_images.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-serve-images-logs"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "seed_database_logs" {
  name              = "/aws/lambda/${aws_lambda_function.seed_database.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-seed-database-logs"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# Alarms - EC2
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
  alarm_description   = "EC2 CPU > 70% — notify via SNS"

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
# Alarms - ALB
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
  alarm_description   = "ALB 5XX errors > 5 per minute"

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

resource "aws_cloudwatch_metric_alarm" "alb_4xx" {
  alarm_name          = "${local.name_prefix}-alb-4xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 20
  alarm_description   = "ALB 4XX client errors > 20 per minute"

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
# Alarms - RDS
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
  alarm_description   = "RDS CPU > 70%"

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

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${local.name_prefix}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB
  alarm_description   = "RDS free storage < 5 GB"

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

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${local.name_prefix}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS connections > 80"

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

# -----------------------------------------------------------------------------
# Dashboard
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "nexacloud" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6
        properties = {
          title   = "EC2 CPU Utilization"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/EC2", "CPUUtilization"]]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6
        properties = {
          title   = "ALB 5XX Count"
          view    = "timeSeries"
          stat    = "Sum"
          period  = 60
          region  = var.aws_region
          metrics = [["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count"]]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 6, height = 6
        properties = {
          title   = "ALB Request Count"
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/ApplicationELB", "RequestCount"]]
        }
      },
      {
        type = "metric", x = 6, y = 6, width = 6, height = 6
        properties = {
          title   = "RDS CPU Utilization"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/RDS", "CPUUtilization"]]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 6, height = 6
        properties = {
          title   = "RDS Free Storage Space"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/RDS", "FreeStorageSpace"]]
        }
      },
      {
        type = "metric", x = 18, y = 6, width = 6, height = 6
        properties = {
          title   = "RDS Database Connections"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/RDS", "DatabaseConnections"]]
        }
      },
      {
        type = "metric", x = 0, y = 12, width = 12, height = 6
        properties = {
          title   = "Lambda Errors"
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/Lambda", "Errors"]]
        }
      },
      {
        type = "metric", x = 12, y = 12, width = 12, height = 6
        properties = {
          title   = "Lambda Invocations"
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          region  = var.aws_region
          metrics = [["AWS/Lambda", "Invocations"]]
        }
      },
    ]
  })
}
