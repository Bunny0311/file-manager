# 🚀 AWS Cloud File Manager

> A production-grade file management system built with Terraform, featuring Flask API, S3 storage, and RDS MySQL - fully automated infrastructure as code.

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-REST_API-000000?logo=flask)](https://flask.palletsprojects.com/)

---

## 🎯 What Makes This Special?

This isn't just another CRUD app - it's a **complete cloud infrastructure** that you can deploy in minutes:

✨ **Fully Automated** - One command deploys everything  
🏗️ **Production-Ready** - VPC isolation, IAM roles, security groups  
💰 **Cost-Optimized** - Free tier eligible (~$1-5/month)  
🔒 **Secure by Design** - Private database, least-privilege access  
📦 **Scalable Architecture** - S3 for storage, RDS for metadata  

## 🏛️ Architecture

```ascii
                                ┌─────────────────┐
                                │   Internet      │
                                └────────┬────────┘
                                         │
                                         ▼
                        ┌────────────────────────────┐
                        │    Internet Gateway        │
                        └────────────┬───────────────┘
                                     │
                        ┌────────────▼────────────┐
                        │  Public Subnet          │
                        │  (10.0.1.0/24)          │
                        │                         │
                        │  ┌──────────────────┐   │
                        │  │   EC2 Instance   │   │
                        │  │   Flask API      │◄──┼──── IAM Role
                        │  │   (t3.micro)     │   │
                        │  └──────┬───────────┘   │
                        └─────────┼───────────────┘
                                  │
                   ┌──────────────┼──────────────┐
                   │              │              │
                   ▼              ▼              ▼
            ┌──────────┐   ┌──────────────┐   ┌──────────────┐
            │ S3       │   │  Private      │   │  Private     │
            │ Bucket   │   │  Subnet 1     │   │  Subnet 2    │
            │          │   │  (10.0.11/24) │   │  (10.0.12/24)│
            │ Files ☁️  │   │               │   │              │
            └──────────┘   │  ┌─────────┐  │   │              │
                           │  │  RDS    │  │◄──┼──────────────┘
                           │  │  MySQL  │  │
                           │  └─────────┘  │
                           └───────────────┘
```

## 🎁 What You Get

| Component | Technology | Purpose |
|-----------|------------|---------|
| 🖥️ **Compute** | EC2 t3.micro | Flask REST API server |
| 💾 **Database** | RDS MySQL 8.0 | File metadata storage |
| 📦 **Storage** | S3 Standard | Scalable file storage |
| 🌐 **Network** | Custom VPC | Isolated cloud environment |
| 🔐 **Security** | IAM + SGs | Role-based access control |
| 🏗️ **IaC** | Terraform | Reproducible infrastructure |

## ⚡ Quick Start

### Prerequisites

```bash
# Required tools
✓ AWS Account
✓ Terraform >= 1.0
✓ AWS CLI configured
✓ SSH key pair
```

### 🚀 Deploy in 3 Steps

**Step 1:** Configure your variables

```bash
cat > terraform/terraform.tfvars << EOF
aws_region  = "ap-south-1"
db_password = "YourSecurePass123!"
my_ip       = "$(curl -s ifconfig.me)/32"
key_name    = "your-aws-key"
EOF
```

**Step 2:** Deploy infrastructure

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

**Step 3:** Get your endpoints

```bash
# EC2 Public IP
terraform output ec2_public_ip

# RDS Endpoint  
terraform output rds_endpoint

# S3 Bucket
terraform output s3_bucket_name
```

### 🎉 That's it! Your infrastructure is live.

---

## 🔌 API Endpoints

### Upload a File
```bash
curl -X POST http://<EC2_IP>:5000/upload \
  -F "file=@presentation.pdf"
```

**Response:**
```json
{
  "message": "Upload successful",
  "filename": "presentation.pdf",
  "filesize": 2048576,
  "uploaded_at": "2025-11-15T10:30:00"
}
```

### List All Files
```bash
curl http://<EC2_IP>:5000/files
```

**Response:**
```json
[
  {
    "id": 1,
    "filename": "presentation.pdf",
    "filesize": 2048576,
    "s3_key": "presentation.pdf",
    "uploaded_at": "2025-11-15T10:30:00"
  }
]
```

### Get Download Link
```bash
curl http://<EC2_IP>:5000/download/presentation.pdf
```

**Response:**
```json
{
  "download_url": "https://s3.amazonaws.com/bucket/file.pdf?X-Amz-..."
}
```
*Link valid for 1 hour*

---

## 🎨 Features & Highlights

### 🔒 Security First
- ✅ Database in private subnets (no internet access)
- ✅ IAM roles instead of access keys
- ✅ Security groups with least privilege
- ✅ SSH restricted to your IP only
- ✅ Presigned URLs with expiration

### 🏗️ Infrastructure as Code
- ✅ Complete Terraform automation
- ✅ Modular, reusable code
- ✅ State management
- ✅ One-command deployment
- ✅ Easy tear-down

### 💸 Cost Efficient
- ✅ Free tier eligible resources
- ✅ Pay only for what you use
- ✅ ~$1-5/month for light usage
- ✅ Auto-scaling ready (add ASG)

### 🚀 Production Ready
- ✅ VPC with public/private subnets
- ✅ Multi-AZ RDS subnet group
- ✅ Internet Gateway for connectivity
- ✅ Route tables configured
- ✅ DNS hostnames enabled

---

## 📂 Project Structure

```
aws-file-manager/
├── 📄 app.py                  # Flask REST API
├── 📋 requirements.txt        # Python dependencies
├── 🐳 Dockerfile             # Container image
├── 🐳 docker-compose.yml     # Local development
└── 🗂️  terraform/
    ├── main.tf              # Core resources (EC2, RDS, S3)
    ├── vpc_and_sg.tf        # Network infrastructure
    ├── provider.tf          # AWS provider config
    ├── variables.tf         # Input variables
    └── userdata.sh          # EC2 bootstrap script
```

---

## 🛠️ Advanced Setup

### Initialize Database

```bash
# SSH into EC2
ssh -i ~/.ssh/your-key.pem ec2-user@<EC2_IP>

# Set environment variables
export S3_BUCKET="your-bucket-name"
export DB_HOST="your-rds-endpoint"
export DB_PASS="your-password"
export DB_USER="admin"
export DB_NAME="file_manager"

# Create database and table
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS << 'EOF'
CREATE DATABASE IF NOT EXISTS file_manager;
USE file_manager;
CREATE TABLE IF NOT EXISTS files (
    id INT AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    filesize BIGINT NOT NULL,
    s3_key VARCHAR(255) NOT NULL,
    uploaded_at DATETIME NOT NULL,
    INDEX idx_filename (filename),
    INDEX idx_uploaded (uploaded_at)
);
EOF
```

### Run Application

```bash
# Install dependencies
pip3 install -r requirements.txt

# Run Flask app
python3 app.py
```

---

## 🐳 Local Development

Want to test locally? Use Docker:

```bash
# Start services
docker-compose up -d

# API available at http://localhost:5000
curl http://localhost:5000/files

# Stop services
docker-compose down
```

---

## 📊 Terraform Resources Created

| Resource Type | Count | Description |
|--------------|-------|-------------|
| VPC | 1 | Isolated network (10.0.0.0/16) |
| Subnets | 3 | 1 public, 2 private |
| Internet Gateway | 1 | Internet connectivity |
| Route Table | 1 | Public subnet routing |
| Security Groups | 2 | EC2 and RDS firewalls |
| EC2 Instance | 1 | t3.micro application server |
| RDS Instance | 1 | db.t3.micro MySQL 8.0 |
| S3 Bucket | 1 | File storage |
| IAM Role | 1 | EC2 S3 access |
| IAM Policy | 1 | S3 permissions |
| IAM Instance Profile | 1 | Attach role to EC2 |

**Total: 15 resources** managed by Terraform

---

## 💰 Cost Breakdown

| Service | Configuration | Monthly Cost* |
|---------|--------------|---------------|
| EC2 | t3.micro (750hrs free tier) | $0 - $10 |
| RDS | db.t3.micro (750hrs free tier) | $0 - $15 |
| S3 | First 5GB free | $0.023/GB |
| Data Transfer | 100GB free | $0.09/GB after |
| **Estimated Total** | | **$1 - $30/month** |

*With free tier: ~$1-5/month | Without: ~$20-30/month*

---

## 🔥 Pro Tips

### Customize Your Deployment

```hcl
# Change instance type
instance_type = "t3.small"  # More power

# Change region
aws_region = "us-east-1"  # Different region

# Enable encryption
storage_encrypted = true  # Encrypt RDS

# Multi-AZ for HA
multi_az = true  # High availability
```

### Add Terraform Outputs

Add to `terraform/outputs.tf`:

```hcl
output "ec2_public_ip" {
  value = aws_instance.flask_ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.file_bucket.id
}
```

---

## 🧪 Testing

```bash
# Test file upload
curl -X POST http://<EC2_IP>:5000/upload \
  -F "file=@test.txt" \
  -v

# Verify in S3
aws s3 ls s3://your-bucket-name/

# Check database
mysql -h <RDS_ENDPOINT> -u admin -p -e \
  "SELECT * FROM file_manager.files;"
```

---

## 🚨 Troubleshooting

### Can't SSH to EC2?
```bash
# Check security group
aws ec2 describe-security-groups \
  --group-ids <SG_ID> \
  --query "SecurityGroups[].IpPermissions"

# Update your IP
terraform apply -var="my_ip=$(curl -s ifconfig.me)/32"
```

### RDS Connection Failed?
```bash
# Verify RDS is available
aws rds describe-db-instances \
  --db-instance-identifier file-manager-db \
  --query "DBInstances[].DBInstanceStatus"

# Test connection
mysql -h <RDS_ENDPOINT> -u admin -p
```

### S3 Access Denied?
```bash
# Check IAM role
aws iam get-instance-profile --instance-profile-name ec2_instance_profile

# Verify permissions
aws iam get-policy-version \
  --policy-arn <POLICY_ARN> \
  --version-id v1
```

---

## 🧹 Cleanup

### Destroy Everything

```bash
# Empty S3 bucket first (if contains files)
aws s3 rm s3://your-bucket-name --recursive

# Destroy infrastructure
cd terraform
terraform destroy -auto-approve
```

**All AWS resources will be deleted. This action cannot be undone.**

---

## 🎓 Learning Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Boto3 S3 Guide](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3.html)

---

## 🤝 Contributing

Contributions welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest features  
- 🔧 Submit pull requests
- ⭐ Star this repo

---

## 📝 License

MIT License - feel free to use this project for learning or production!

---

## 🌟 Show Your Support

If you found this helpful, give it a ⭐️ on GitHub!

---

<div align="center">

**Built with ❤️ using Terraform & AWS**

[Report Bug](https://github.com/yourusername/repo/issues) · [Request Feature](https://github.com/yourusername/repo/issues)

</div>
