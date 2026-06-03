# =============================================================================
# SNS Topic for CloudWatch Alerts
# =============================================================================

# -----------------------------------------------------------------------------
# SNS Topic: nexacloud-alerts
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "nexacloud_alerts" {
  name = "${local.name_prefix}-alerts"

  tags = {
    Name        = "${local.name_prefix}-alerts"
    Project     = var.project_name
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# SNS Topic Subscription: Email Alert
# -----------------------------------------------------------------------------

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.nexacloud_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email

  filter_policy = jsonencode({
    severity = ["high", "medium"]
  })

  subscription_role_arn = "" # Not required for email subscriptions
}


