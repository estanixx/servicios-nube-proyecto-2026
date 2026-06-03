# =============================================================================
# Application Load Balancer
# =============================================================================

# -----------------------------------------------------------------------------
# ALB Resource
# -----------------------------------------------------------------------------

resource "aws_lb" "nexacloud" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  # Enable access logs to S3
  access_logs {
    bucket  = aws_s3_bucket.employee_images.bucket
    prefix  = "alb-logs"
    enabled = false # Set to true to enable access logs
  }

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

# -----------------------------------------------------------------------------
# Target Group
# -----------------------------------------------------------------------------

resource "aws_lb_target_group" "nexacloud" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }

  tags = {
    Name = "${local.name_prefix}-tg"
  }
}

# -----------------------------------------------------------------------------
# ALB Listener (HTTP on port 80)
# -----------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nexacloud.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexacloud.arn
  }

  tags = {
    Name = "${local.name_prefix}-listener"
  }
}

# -----------------------------------------------------------------------------
# Listener Rule for /api/* path (forward to Lambda via API Gateway)
# Note: ALB cannot directly invoke Lambda without a function URL or API GW
# The Next.js app will call API Gateway endpoints directly
# -----------------------------------------------------------------------------