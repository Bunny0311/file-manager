variable "aws_region" {
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "db_password" {
  description = "MySQL master password"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Your public IP /32 for SSH"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}
