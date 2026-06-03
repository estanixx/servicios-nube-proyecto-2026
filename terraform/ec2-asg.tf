# =============================================================================
# Auto Scaling Group for EC2 Instances
# =============================================================================

resource "aws_autoscaling_group" "nexacloud" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  min_size            = var.ec2_min_size
  max_size            = var.ec2_max_size
  desired_capacity    = var.ec2_desired_capacity

  launch_template {
    id      = aws_launch_template.nexacloud.id
    version = "$Latest"
  }

  # Health check grace period (time before ASG starts checking health)
  health_check_grace_period = 60

  # Health check type: ELB uses load balancer health checks
  health_check_type = "ELB"

  # Wait for instance to be fully running before marking healthy
  wait_for_capacity_timeout = "10m"

  # Termination policies
  termination_policies = ["OldestInstance"]

  # Enable load balancer target group attachment
  target_group_arns = [aws_lb_target_group.nexacloud.arn]

  # Instance tags propagated to ASG-managed instances
  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Auto Scaling Policy - Scale Up
# -----------------------------------------------------------------------------

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.nexacloud.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm - High CPU (triggers scale up)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nexacloud.name
  }

  alarm_description = "Scale up when CPU > 70% for 2 consecutive periods"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# -----------------------------------------------------------------------------
# Auto Scaling Policy - Scale Down
# -----------------------------------------------------------------------------

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.nexacloud.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm - Low CPU (triggers scale down)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nexacloud.name
  }

  alarm_description = "Scale down when CPU < 30% for 2 consecutive periods"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}