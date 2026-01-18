import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.getenv("DATABASE_URL")

try:
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()
    
    cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
    tables = cur.fetchall()
    print("Tables:", [t[0] for t in tables])
    
    for table in ['complaints', 'complaints_with_ai']:
        if (table,) in tables:
            print(f"\nStructure for {table}:")
            cur.execute(f"SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '{table}';")
            columns = cur.fetchall()
            for col in columns:
                print(f"  {col[0]}: {col[1]}")
        else:
            print(f"\nTable {table} does not exist.")
            
    conn.close()
except Exception as e:
    print(f"Error: {e}")
