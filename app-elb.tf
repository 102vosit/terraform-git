
resource "aws_security_group" "app-elb-sg" {
  name   = "app-elb-sg"
  vpc_id = aws_vpc.GoGreenVPC.id
  #HTTP
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-elb-sg.id]
  }
  #SSH
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web-elb-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "app-elb-sg"
  }
}

# Load Balancer for Application Server
resource "aws_lb" "app-elb" {
  name                             = "app-elb"
  internal                         = true
  security_groups                  = [aws_security_group.app-elb-sg.id]
  subnets                          = [aws_subnet.private-subnet-3.id, aws_subnet.private-subnet-4.id]
  enable_cross_zone_load_balancing = true
  load_balancer_type               = "application"
  tags = {
    "Name" = "app-elb"
  }
}

# Target Group for App
resource "aws_lb_target_group" "App-GoGreen-TargetGroup" {
  name        = "App-GoGreen-TargetGroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.GoGreenVPC.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

# # Attaching Instance to Target group
# resource "aws_lb_target_group_attachment" "c" {
#   target_group_arn = aws_lb_target_group.App-GoGreen-TargetGroup.arn
#   target_id        = aws_instance.app-tier1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "d" {
#   target_group_arn = aws_lb_target_group.App-GoGreen-TargetGroup.arn
#   target_id        = aws_instance.app-tier2.id
#   port             = 80
# }

# Load Balancer Listener BackEnd
resource "aws_lb_listener" "GoGreen-BackEnd-Listener" {
  load_balancer_arn = aws_lb.app-elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.App-GoGreen-TargetGroup.arn
    type             = "forward"
  }
}

# Attaching rules to listener
resource "aws_lb_listener_rule" "app_listener_weighted_routing" {
  listener_arn = aws_lb_listener.GoGreen-BackEnd-Listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.App-GoGreen-TargetGroup.arn
  }
  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}

# Output of app-lb-dns-name 
output "app_lb_dns_name" {
  description = "The DNS name of the ELB"
  value       = aws_lb.app-elb.dns_name
}
# Output of web-lb-dns-name 
output "web_lb_dns_name" {
  description = "The DNS name of the ELB"
  value       = aws_lb.web-elb.dns_name
}
