
provider "aws" {
  alias  = "central"
  region = "us-east-2"
}
resource "aws_iam_role" "replication" {
  name               = "go-green-iam-role-replication"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
resource "aws_iam_policy" "replication" {
  name   = "go-green-iam-role-policy-replication"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination.arn}/*"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}
resource "aws_s3_bucket" "destination" {
  provider = aws.central
  bucket   = "${var.bucket_name_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-replica"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "log"
    enabled = true
    #prefix = "testS3/"
    tags = {
      rule      = "log"
      autoclean = "true"
    }
    expiration {
      days = 7
    }
  }
}
#data "aws_caller_identity" "current" {}
#data "aws_region" "current" {}
variable "bucket_name_prefix" {
  type    = string
  default = "go-green-s3"
}
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-source"
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    id      = "log"
    enabled = true
    #prefix = "testS3/"
    tags = {
      rule      = "log"
      autoclean = "true"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 1780 #356*5
    }
  }
  replication_configuration {
    role = aws_iam_role.replication.arn
    rules {
      id = "foobar"
      #prefix = "foo"
      status = "Enabled"
      destination {
        bucket        = aws_s3_bucket.destination.arn
        storage_class = "STANDARD"
      }
    }
  }
}