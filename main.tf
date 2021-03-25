## ZIYOTEK-TEAM04 
## Start typing your code here ...

provider "aws" {
  region     = "us-east-1"
}
# VPC
resource "aws_vpc" "GoGreenVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "GoGreenVPC"
  }
}

# Subnets

# Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    "Name" = "public-subnet-1"
  }
}
# Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    "Name" = "public-subnet-2"
  }
}
# Private Subnet 1
resource "aws_subnet" "private-subnet-1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.3.0/24"
  tags = {
    "Name" = "private-subnet-1"
  }
}
# Private Subnet 2
resource "aws_subnet" "private-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.4.0/24"
  tags = {
    "Name" = "private-subnet-2"
  }
}
# Private Subnet 3
resource "aws_subnet" "private-subnet-3" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.5.0/24"
  tags = {
    "Name" = "private-subnet-3"
  }
}
# Private Subnet 4
resource "aws_subnet" "private-subnet-4" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.6.0/24"
  tags = {
    "Name" = "private-subnet-4"
  }
}
# Private Subnet 5
resource "aws_subnet" "private-subnet-5" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.7.0/24"
  tags = {
    "Name" = "private-subnet-5"
  }
}
# Private Subnet 6
resource "aws_subnet" "private-subnet-6" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.GoGreenVPC.id
  cidr_block        = "10.0.8.0/24"
  tags = {
    "Name" = "private-subnet-6"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private-subnet-5.id, aws_subnet.private-subnet-6.id]

  tags = {
    Name = "db-subnet-group"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "GoGreenIGW" {
  vpc_id = aws_vpc.GoGreenVPC.id
  tags = {
    "Name" = "GoGreenIGW"
  }
}

# Nat Gateway 1a
resource "aws_nat_gateway" "GoGreenNGW-1a" {
  allocation_id = aws_eip.GoGreenEIP-1a.id
  subnet_id     = aws_subnet.public-subnet-1.id
  depends_on    = [aws_internet_gateway.GoGreenIGW]
  tags = {
    "Name" = "GoGreenNGW-1a"
  }
}
# Nat Gateway 2b
resource "aws_nat_gateway" "GoGreenNGW-1b" {
  allocation_id = aws_eip.GoGreenEIP-1b.id
  subnet_id     = aws_subnet.public-subnet-1.id
  depends_on    = [aws_internet_gateway.GoGreenIGW]
  tags = {
    "Name" = "GoGreenNGW-1b"
  }
}

# Elastic IP Address-1a
resource "aws_eip" "GoGreenEIP-1a" {
  vpc = true
  tags = {
    "Name" = "GoGreenEIP-1b"
  }
}
# Elastic IP Address-1b
resource "aws_eip" "GoGreenEIP-1b" {
  vpc = true
  tags = {
    "Name" = "GoGreenEIP-1b"
  }
}

# Route Tables

# Public Route Table-1a
resource "aws_route_table" "GoGreenPubRT-1a" {
  vpc_id = aws_vpc.GoGreenVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.GoGreenIGW.id
  }
  tags = {
    "Name" = "GoGreenPubRT-1a"
  }
}
# Public Route Table-1b
resource "aws_route_table" "GoGreenPubRT-1b" {
  vpc_id = aws_vpc.GoGreenVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.GoGreenIGW.id
  }
  tags = {
    "Name" = "GoGreenPubRT-1b"
  }
}
# Private Route Table-1a
resource "aws_route_table" "GoGreenPrivRT-1a" {
  vpc_id = aws_vpc.GoGreenVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.GoGreenNGW-1a.id
  }
  tags = {
    "Name" = "GoGreenPrivRT-1a"
  }
}
# Private Route Table-1b
resource "aws_route_table" "GoGreenPrivRT-1b" {
  vpc_id = aws_vpc.GoGreenVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.GoGreenNGW-1b.id
  }
  tags = {
    "Name" = "GoGreenPrivRT-1b"
  }
}

# Route Table Assocations

# Public Subnet Assocation 1
resource "aws_route_table_association" "a" {
  route_table_id = aws_route_table.GoGreenPubRT-1a.id
  subnet_id      = aws_subnet.public-subnet-1.id
}
# Public Subnet Assocation 2
resource "aws_route_table_association" "b" {
  route_table_id = aws_route_table.GoGreenPubRT-1b.id
  subnet_id      = aws_subnet.public-subnet-2.id
}


# Private Subnet Assocation 1
resource "aws_route_table_association" "c" {
  route_table_id = aws_route_table.GoGreenPrivRT-1a.id
  subnet_id      = aws_subnet.private-subnet-1.id
}
# Private Subnet Assocation 2
resource "aws_route_table_association" "d" {
  route_table_id = aws_route_table.GoGreenPrivRT-1b.id
  subnet_id      = aws_subnet.private-subnet-2.id
}
# Private Subnet Assocation 3
resource "aws_route_table_association" "e" {
  route_table_id = aws_route_table.GoGreenPrivRT-1a.id
  subnet_id      = aws_subnet.private-subnet-3.id
}
# Private Subnet Assocation 4
resource "aws_route_table_association" "f" {
  route_table_id = aws_route_table.GoGreenPrivRT-1b.id
  subnet_id      = aws_subnet.private-subnet-4.id
}
# Private Subnet Assocation 5
resource "aws_route_table_association" "g" {
  route_table_id = aws_route_table.GoGreenPrivRT-1a.id
  subnet_id      = aws_subnet.private-subnet-5.id
}
# Private Subnet Assocation 6
resource "aws_route_table_association" "h" {
  route_table_id = aws_route_table.GoGreenPrivRT-1b.id
  subnet_id      = aws_subnet.private-subnet-6.id
}

# Security Groups
resource "aws_security_group" "GoGreen-SG" {
  name   = "GoGreen-SG"
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
    "Name" = "GoGreen-SG"
  }
}

# DB Security Group
resource "aws_security_group" "DB-SG" {
  name   = "DB-SG"
  vpc_id = aws_vpc.GoGreenVPC.id
  #MySQL
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-elb-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "DB-SG"
  }
}

# EC2 Role
resource "aws_iam_role" "EC2-S3-ROLE" {
  name = "EC2-S3-ROLE"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    "Name" = "EC2-S3-ROLE"
  }
}

# EC2 instance profile
resource "aws_iam_instance_profile" "ec2-s3-profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.EC2-S3-ROLE.name
}

# EC2 Policy
resource "aws_iam_role_policy" "ec2-s3-policy" {
  name   = "ec2-s3-policy"
  role   = aws_iam_role.EC2-S3-ROLE.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

# DB Instance
resource "aws_db_instance" "GoGreenDB" {
  identifier             = "go-green-db"
  allocated_storage      = 10  # in GB
  max_allocated_storage  = 100 # in GB
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "GoGreenDB"
  username               = "admin"
  parameter_group_name   = "rds-pg"
  password               = "GoGreen-2021"
  vpc_security_group_ids = [aws_security_group.DB-SG.id]
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.name
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_kms_key" "GoGreenDB" {
  description             = "This key is used to encrypt db"
  deletion_window_in_days = 10
}
