
# CloudWatch
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120" #seconds
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions = {
    #    InstanceId = aws_instance.web-tier1.id,
    #    InstanceId = aws_instance.web-tier2.id,
    #    InstanceId = aws_instance.app-tier1.id,
    #    InstanceId = aws_instance.app-tier2.id
  }
}