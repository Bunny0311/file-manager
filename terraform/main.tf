# ---------------------------
# S3 BUCKET
# ---------------------------
resource "aws_s3_bucket" "file_bucket" {
  bucket = "bunny-file-manager-${random_id.bucket_id.hex}"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# ---------------------------
# IAM ROLE FOR EC2
# ---------------------------
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# ---------------------------
# IAM POLICY FOR S3
# ---------------------------
resource "aws_iam_policy" "s3_policy" {
  name        = "ec2_s3_policy"
  description = "Allow EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        aws_s3_bucket.file_bucket.arn,
        "${aws_s3_bucket.file_bucket.arn}/*"
      ]
    }]
  })
}

# ---------------------------
# ATTACH IAM POLICY TO EC2 ROLE
# ---------------------------
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# ---------------------------
# INSTANCE PROFILE FOR EC2
# ---------------------------
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# -------------------------------------
# RDS INSTANCE (FREE TIER)
# -------------------------------------
resource "aws_db_instance" "mysql" {
  identifier              = "file-manager-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  username                = "admin"
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false

  tags = {
    Name = "file-manager-rds"
  }
}

# -------------------------------------
# EC2 INSTANCE (FREE TIER SAFE)
# -------------------------------------
resource "aws_instance" "flask_ec2" {
  ami                    = data.aws_ami.amzn_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = file("userdata.sh")
  key_name = var.key_name


  associate_public_ip_address = true

  tags = {
    Name = "flask-server"
  }
}

# AMI Lookup
data "aws_ami" "amzn_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
