import os
from datetime import datetime
import boto3
import pymysql
from flask import Flask, request, jsonify
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# AWS S3 setup
s3 = boto3.client('s3')
S3_BUCKET = os.getenv('S3_BUCKET')

# MySQL DB connection
def get_db():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASS", ""),
        database=os.getenv("DB_NAME", "file_manager"),
        cursorclass=pymysql.cursors.DictCursor
    )

# Upload route
@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    filename = file.filename
    file_bytes = file.read()
    filesize = len(file_bytes)
    file.seek(0)

    try:
        # Upload file to S3
        s3.upload_fileobj(file, S3_BUCKET, filename)
        uploaded_at = datetime.utcnow()

        # Save metadata in MySQL
        conn = get_db()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO files (filename, filesize, s3_key, uploaded_at) VALUES (%s, %s, %s, %s)",
            (filename, filesize, filename, uploaded_at)
        )
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            'message': 'Upload successful',
            'filename': filename,
            'filesize': filesize,
            'uploaded_at': uploaded_at.isoformat()
        }), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# List all files
@app.route('/files', methods=['GET'])
def list_files():
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT * FROM files")
        files = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(files), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Generate download link
@app.route('/download/<filename>', methods=['GET'])
def download_file(filename):
    try:
        url = s3.generate_presigned_url(
            ClientMethod='get_object',
            Params={'Bucket': S3_BUCKET, 'Key': filename},
            ExpiresIn=3600
        )
        return jsonify({'download_url': url}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

