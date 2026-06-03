# =============================================================================
# CloudWatch Dashboard - Simplified metrics format
# =============================================================================

resource "aws_cloudwatch_dashboard" "nexacloud" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x     = 0
        y     = 0
        width = 12
        height = 6
        properties = {
          title  = "EC2 CPU Utilization"
          view   = "timeSeries"
          stat   = "Average"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/EC2", "CPUUtilization"]
          ]
        }
      },
      {
        type = "metric"
        x     = 12
        y     = 0
        width = 12
        height = 6
        properties = {
          title  = "ALB 5XX Count"
          view   = "timeSeries"
          stat   = "Sum"
          period = 60
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count"]
          ]
        }
      },
      {
        type = "metric"
        x     = 0
        y     = 6
        width = 6
        height = 6
        properties = {
          title  = "ALB Request Count"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount"]
          ]
        }
      },
      {
        type = "metric"
        x     = 6
        y     = 6
        width = 6
        height = 6
        properties = {
          title  = "RDS CPU Utilization"
          view   = "timeSeries"
          stat   = "Average"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/RDS", "CPUUtilization"]
          ]
        }
      },
      {
        type = "metric"
        x     = 12
        y     = 6
        width = 6
        height = 6
        properties = {
          title  = "RDS Free Storage Space"
          view   = "timeSeries"
          stat   = "Average"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/RDS", "FreeStorageSpace"]
          ]
        }
      },
      {
        type = "metric"
        x     = 18
        y     = 6
        width = 6
        height = 6
        properties = {
          title  = "RDS Database Connections"
          view   = "timeSeries"
          stat   = "Average"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/RDS", "DatabaseConnections"]
          ]
        }
      },
      {
        type = "metric"
        x     = 0
        y     = 12
        width = 12
        height = 6
        properties = {
          title  = "Lambda Invocations - InsertStudent"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations"]
          ]
        }
      },
      {
        type = "metric"
        x     = 12
        y     = 12
        width = 12
        height = 6
        properties = {
          title  = "Lambda Invocations - ServeImages"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations"]
          ]
        }
      },
      {
        type = "metric"
        x     = 0
        y     = 18
        width = 12
        height = 6
        properties = {
          title  = "Lambda Errors"
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Errors"]
          ]
        }
      }
    ]
  })
}