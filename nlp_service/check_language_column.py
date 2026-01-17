import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

cur.execute("SELECT id, detected_language, description FROM complaints ORDER BY id DESC LIMIT 5")
rows = cur.fetchall()

print("ID | Detected Language | Description")
print("-" * 60)
for row in rows:
    print(f"{row[0]} | {row[1]} | {row[2]}")

cur.close()
conn.close()
