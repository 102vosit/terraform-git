resource "aws_security_group" "web-elb-sg" {
  name   = "web-elb-sg"
  vpc_id = aws_vpc.GoGreenVPC.id
  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "web-elb-sg"
  }
}

# Load Balancer for Web Server
resource "aws_lb" "web-elb" {
  name                             = "web-elb"
  internal                         = false
  security_groups                  = [aws_security_group.web-elb-sg.id]
  subnets                          = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  enable_cross_zone_load_balancing = true
  load_balancer_type               = "application"
  tags = {
    "Name" = "web-elb"
  }
}

# Target Group for Web Server
resource "aws_lb_target_group" "Web-GoGreen-TargetGroup" {
  name        = "Web-GoGreen-TargetGroup"
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
# resource "aws_lb_target_group_attachment" "a" {
#   target_group_arn = aws_lb_target_group.Web-GoGreen-TargetGroup.arn
#   target_id        = aws_instance.web-tier1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "b" {
#   target_group_arn = aws_lb_target_group.Web-GoGreen-TargetGroup.arn
#   target_id        = aws_instance.web-tier2.id
#   port             = 80
# }

# Load Balancer Listener for FrontEnd
resource "aws_lb_listener" "GoGreen-FrontEnd-Listener" {
  load_balancer_arn = aws_lb.web-elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.Web-GoGreen-TargetGroup.arn
    type             = "forward"
  }
}

# Attaching rules to listener
resource "aws_lb_listener_rule" "web_listener_weighted_routing" {
  listener_arn = aws_lb_listener.GoGreen-FrontEnd-Listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Web-GoGreen-TargetGroup.arn
  }
  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}
