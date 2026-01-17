
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

def check_complaint(complaint_id):
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()
        
        query = "SELECT id, ai_priority_level, ai_category, is_valid, ai_analysis_date FROM complaints WHERE id = %s"
        cursor.execute(query, (complaint_id,))
        result = cursor.fetchone()
        
        if result:
            print(f"✅ Complaint {complaint_id} Data:")
            print(f"   - AI Priority: {result[1]}")
            print(f"   - AI Category: {result[2]}")
            print(f"   - Is Valid: {result[3]}")
            print(f"   - Analysis Date: {result[4]}")
        else:
            print(f"❌ Complaint {complaint_id} not found.")
            
        conn.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_complaint(518)
