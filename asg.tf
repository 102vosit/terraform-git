##############################
## Web AutoScaling Group    ##
##############################
# Launcher Template for Web
resource "aws_launch_configuration" "web_launcher" {
  name                        = "web_launcher"
  image_id                    = "ami-047a51fa27710816e"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.app-elb-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-s3-profile.name
  user_data                   = <<-EOF
            #! /bin/bash -ex
            sudo yum update -y
            sudo yum -y install httpd php mysql php-mysql
            sudo systemctl start httpd
            sudo systemctl enable httpd
            sudo echo " <VirtualHost *:80>
            ProxyPreserveHost On
            ProxyPass / http://"${aws_lb.app-elb.dns_name}"
            ProxyPassReverse / http://"${aws_lb.app-elb.dns_name}"
            </VirtualHost> ">>/etc/httpd/conf/httpd.conf
            sudo echo "web-server-fronted">/var/www/html/index.html
            sudo systemctl restart httpd
            EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for Web tier
resource "aws_autoscaling_group" "web-asg" {
  launch_configuration = aws_launch_configuration.web_launcher.name
  vpc_zone_identifier  = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
  min_size             = 3
  max_size             = 5
  desired_capacity     = 4
  target_group_arns    = [aws_lb_target_group.Web-GoGreen-TargetGroup.arn]
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }
}


##############################
## App AutoScaling Group    ##
##############################
# Launcher Template for App
resource "aws_launch_configuration" "app_launcher" {
  name                 = "app_launcher"
  image_id             = "ami-047a51fa27710816e"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.app-elb-sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-s3-profile.name
  user_data            = <<-EOF
                #!/bin/bash -ex
                sudo yum -y install httpd php mysql php-mysql
                sudo chkconfig httpd on
                sudo service httpd start
                if [ ! -f /var/www/html/lab-app.tgz ]; then
                sudo cd /var/www/html
                sudo wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/CUR-TF-200-ACACAD/studentdownload/lab-app.tgz
                sudo tar xvfz lab-app.tgz
                sudo chown apache:root /var/www/html/rds.conf.php
                sudo systemctl restart httpd
                fi
                EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for App tier
resource "aws_autoscaling_group" "app-asg" {
  launch_configuration = aws_launch_configuration.app_launcher.name
  vpc_zone_identifier  = [aws_subnet.private-subnet-3.id, aws_subnet.private-subnet-4.id]
  min_size             = 3
  max_size             = 5
  desired_capacity     = 4
  target_group_arns    = [aws_lb_target_group.App-GoGreen-TargetGroup.arn]
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}
