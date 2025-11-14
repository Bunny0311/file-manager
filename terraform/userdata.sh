#!/bin/bash
yum update -y
yum install -y python3 python3-pip

pip3 install flask boto3 pymysql python-dotenv cryptography

mkdir -p /app
cat << 'EOF' > /app/app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Flask on EC2 running successfully!"

app.run(host="0.0.0.0", port=5000)
EOF

python3 /app/app.py &
