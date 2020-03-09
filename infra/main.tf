# Initialize AWS provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create security group for load balancer
resource "aws_security_group" "elb" {
  name_prefix = "dyoung_alb_sg"
  description = "Code Test: Devin Young (Created via Terraform)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for EC2 instances
resource "aws_security_group" "ec2" {
  name_prefix = "dyoung_ec2_sg"
  description = "Code Test: Devin Young (Created via Terraform)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ALB
resource "aws_lb" "dyoung_web" {
  name_prefix     = "dyalb"
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.elb.id]
  internal        = false
}

# Create target group to attach to ALB
resource "aws_lb_target_group" "dyoung_tg" {
  name_prefix = "dytgrp"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path = "/killme?time=1&usage=0.01"
  }
}

# Attach ALB to target group on port 80
resource "aws_lb_listener" "dyoung_lbl" {
  load_balancer_arn = aws_lb.dyoung_web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dyoung_tg.arn
  }
}

# Create launch template for auto-scaling
resource "aws_launch_template" "dyoung_lt" {
  name_prefix            = "dyoung_ec2"
  image_id               = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  monitoring {
    enabled = true
  }
}

# Create auto-scaling group
resource "aws_autoscaling_group" "dyoung_asg" {
  name_prefix        = "dyoung_asg"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  target_group_arns  = [aws_lb_target_group.dyoung_tg.arn]
  default_cooldown   = 60


  launch_template {
    id = aws_launch_template.dyoung_lt.id
  }

  tags = [
    {
      key                 = "Name"
      value               = "Devin Young Code Test"
      propagate_at_launch = true
    }
  ]
}

# Create autoscaling policies
resource "aws_autoscaling_policy" "dyoung_asp" {
  name                   = "dyoung-up"
  autoscaling_group_name = aws_autoscaling_group.dyoung_asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
}
