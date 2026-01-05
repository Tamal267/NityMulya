import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "")

conn = psycopg2.connect(DATABASE_URL)
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM complaints WHERE ai_analysis_date IS NOT NULL")
processed = cursor.fetchone()[0]

cursor.execute("SELECT COUNT(*) FROM complaints")
total = cursor.fetchone()[0]

cursor.close()
conn.close()

print(f"✅ Processed: {processed}/{total}")
print(f"⏳ Remaining: {total - processed}")
print(f"📈 Progress: {(processed/total*100):.1f}%")
