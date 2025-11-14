/***********************************************
 VPC, Subnets, Internet Gateway, Routing, SGs
***********************************************/

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "file-manager-vpc" }
}

# ---------------------------
# Public Subnet (For EC2)
# ---------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = { Name = "file-manager-public-subnet" }
}

# ---------------------------
# Private Subnet 1 (RDS Subnet in AZ a)
# ---------------------------
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"

  tags = { Name = "file-manager-private-subnet-1" }
}

# ---------------------------
# Private Subnet 2 (RDS Subnet in AZ b)
# ---------------------------
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"

  tags = { Name = "file-manager-private-subnet-2" }
}

# ---------------------------
# RDS Subnet Group (REQUIRES 2 AZs)
# ---------------------------
resource "aws_db_subnet_group" "rds_subnets" {
  name = "file-manager-db-subnet-group"

  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  tags = { Name = "file-manager-db-subnet-group" }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "file-manager-igw" }
}

# ---------------------------
# Public Route Table
# ---------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "file-manager-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------
# EC2 Security Group
# ---------------------------
resource "aws_security_group" "ec2_sg" {
  name   = "ec2_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask API"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH from your IP only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ec2-security-group" }
}

# ---------------------------
# RDS Security Group
# ---------------------------
resource "aws_security_group" "rds_sg" {
  name   = "rds_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
    description     = "MySQL access from EC2 only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-security-group" }
}
