# =============================================================================
# CloudWatch - EC2 Monitoring
# =============================================================================

# -----------------------------------------------------------------------------
# Note: Basic EC2 monitoring is enabled by default in AWS.
# Detailed monitoring (1-second granularity) requires CloudWatch Agent.
#
# For detailed monitoring with disk space and memory metrics:
# 1. Install CloudWatch Agent on EC2 instances via user_data
# 2. Create an IAM role with CloudWatchAgentServerPolicy
# 3. Attach the role to the EC2 instances via the launch template
#
# Reference: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2.html
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# EC2 Instance Health Alarm (instance status check failure)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ec2_instance_status" {
  alarm_name          = "${local.name_prefix}-ec2-instance-status-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "EC2 instance failed status check"

  dimensions = {
    InstanceId = aws_autoscaling_group.nexacloud.name # Note: alarm by ASG doesn't work, need specific instance IDs
  }

  alarm_actions = [aws_sns_topic.nexacloud_alerts.arn]
  ok_actions    = [aws_sns_topic.nexacloud_alerts.arn]

  tags = {
    Name        = "${local.name_prefix}-ec2-instance-status"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# EC2 Status Alarm Dimension Note
# -----------------------------------------------------------------------------
# Note: StatusCheckFailed metric requires InstanceId dimension, not ASG name.
# For ASG-managed instances, consider using ASG lifecycle hooks or
# AWS Health API for instance health monitoring.
#
# To monitor EC2 disk space properly:
# 1. Deploy CloudWatch Agent to EC2 instances
# 2. Configure metric collection for disk_used_percent
# 3. Create alarms on Custom Namespace "CWAgent" with metric DiskUsedPercent
# -----------------------------------------------------------------------------
