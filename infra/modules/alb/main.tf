#Application Load Balancer
resource "aws_lb" "this" {
  name               = "app-alb"
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.security_group_id]

  enable_deletion_protection = false

  tags = {
    Name = "app-alb"
  }
}

#Target Group (ECS connects here)
resource "aws_lb_target_group" "this" {
  name        = "app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"   # REQUIRED for Fargate
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "app-tg"
  }
}

#Listener (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
