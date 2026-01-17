"""
Insert generated complaints into database
"""

import json
import psycopg2
from psycopg2.extras import execute_batch
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection
DATABASE_URL = os.getenv("DATABASE_URL", "")

def insert_complaints(complaints: list):
    """Insert complaints into database"""
    
    print(f"🔌 Connecting to database...")
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    
    print(f"📥 Inserting {len(complaints)} complaints...")
    
    # Generate unique complaint numbers
    cursor.execute("SELECT MAX(SUBSTRING(complaint_number FROM 5)::INTEGER) FROM complaints WHERE complaint_number LIKE 'CMP-%'")
    result = cursor.fetchone()
    last_number = result[0] if result[0] else 0
    
    insert_query = """
    INSERT INTO complaints (
        complaint_number,
        customer_id,
        customer_name,
        customer_email,
        customer_phone,
        shop_name,
        product_name,
        category,
        description,
        status,
        submitted_at
    ) VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
    
    data = []
    for i, complaint in enumerate(complaints):
        complaint_number = f"CMP-{last_number + i + 1:06d}"
        
        data.append((
            complaint_number,
            complaint["customer_id"],
            complaint["customer_name"],
            complaint["customer_email"],
            complaint["customer_phone"],
            complaint["shop_name"],
            complaint["product_name"],
            complaint["category"],
            complaint["description"],
            "Received",
            complaint["submitted_at"],
        ))
    
    # Batch insert
    execute_batch(cursor, insert_query, data, page_size=100)
    
    conn.commit()
    cursor.close()
    conn.close()
    
    print(f"✅ Successfully inserted {len(complaints)} complaints")
    print(f"📋 Complaint numbers: CMP-{last_number + 1:06d} to CMP-{last_number + len(complaints):06d}")


if __name__ == "__main__":
    print("🚀 Loading complaints dataset...")
    
    with open("complaints_dataset.json", "r", encoding="utf-8") as f:
        complaints = json.load(f)
    
    print(f"📊 Loaded {len(complaints)} complaints")
    
    insert_complaints(complaints)
