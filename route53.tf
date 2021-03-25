# this is route53.tf file
resource "aws_route53_zone" "primary" {
  name = "gogreensteam04.com"
}
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.gogreensteam04.com"
  type    = "A"
  alias {
    name    = aws_lb.web-elb.dns_name
    zone_id = aws_lb.web-elb.zone_id
    #name = aws_cloudfront_distribution.s3_distribution.domain_name
    #zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}