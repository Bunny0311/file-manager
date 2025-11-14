import sqlite3

conn = sqlite3.connect('files.db')
c = conn.cursor()

c.execute('''
    CREATE TABLE IF NOT EXISTS files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT,
        filesize INTEGER,
        s3_key TEXT,
        uploaded_at TEXT
    )
''')

conn.commit()
conn.close()
