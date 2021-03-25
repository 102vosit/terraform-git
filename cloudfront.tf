data "aws_s3_bucket" "origin" {
  bucket = var.bucket_name
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.environment}-cloudfront-access-identity"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = data.aws_s3_bucket.origin.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  aliases             = var.aliases
  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = data.aws_s3_bucket.origin.bucket
    forwarded_values {
      query_string = var.query_string
      headers      = var.headers
      cookies {
        forward = var.forward
      }
    }
    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    compress               = var.compress
  }
  price_class = var.price_class
  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.locations
    }
  }
  tags = {
    Environment = var.environment
  }
  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
  }
}

# this is variable.tf file
variable "environment" {
  description = "Logical name of the environment."
  type        = string
  default     = "Dev"
}
variable "bucket_name" {
  type = string
  # needs exicting bucket name
  default = "vosit-source-bucket"
}
variable "bucket_visibility" {
  type    = string
  default = "private"
}
variable "bucket_tags" {
  type    = string
  default = "cloudfront-bucket"
}
variable "s3_origin_id" {
  type    = string
  default = "myS3Origin"
}
variable "enabled" {
  type    = bool
  default = true
}
variable "is_ipv6_enabled" {
  type    = bool
  default = true
}
variable "comment" {
  type        = string
  default     = null
  description = "Comment field for the distribution"
}
variable "default_root_object" {
  type    = string
  default = "index.html"
}
variable "aliases" {
  type = list(string)
  # ["mysite.example.com"]
  default = []
}
variable "include_cookies" {
  type    = bool
  default = false
}
variable "log_bucket" {
  type    = string
  default = "logb-bucket"
}
variable "log_prefix" {
  default = "cf_logs"
}
variable "allowed_methods" {
  type    = list(any)
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}
variable "cached_methods" {
  type    = list(any)
  default = ["GET", "HEAD"]
}
variable "min_ttl" {
  default = "0"
}
variable "default_ttl" {
  default = "3600"
}
variable "max_ttl" {
  default = "86400"
}
variable "headers" {
  type    = list(any)
  default = []
}
variable "query_string" {
  type    = bool
  default = "false"
}
variable "forward" {
  type    = string
  default = "none"
}
variable "compress" {
  type    = bool
  default = "true"
}
variable "viewer_protocol_policy" {
  type    = string
  default = "allow-all"
}
variable "price_class" {
  type    = string
  default = "PriceClass_200"
}
variable "restriction_type" {
  type    = string
  default = "none"
}
variable "locations" {
  type    = list(any)
  default = []
}
variable "cloudfront_default_certificate" {
  type    = bool
  default = "true"
}

# this is output.tf file
output "cloudfront_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}