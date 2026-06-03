# =============================================================================
# EC2 Launch Template
# =============================================================================

# Data source to look up Amazon Linux 2023 AMI (latest based on aws region)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

resource "aws_launch_template" "nexacloud" {
  name_prefix   = "${local.name_prefix}-"
  image_id      = data.aws_ami.amazon_linux_2023.image_id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_pair

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${local.name_prefix}-instance"
      Project = var.project_name
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name    = "${local.name_prefix}-volume"
      Project = var.project_name
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name    = "${local.name_prefix}-eni"
      Project = var.project_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}