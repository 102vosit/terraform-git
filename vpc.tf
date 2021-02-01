resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc"
  }
}
