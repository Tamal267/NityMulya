import os
import psycopg2
from dotenv import load_dotenv
from preprocessor import TextPreprocessor

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

def fix_languages():
    print("🚀 Starting Language Fix...")
    
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()
        
        # Get all complaints with unknown language or null
        cur.execute("""
            SELECT id, description 
            FROM complaints 
            WHERE detected_language = 'unknown' OR detected_language IS NULL
        """)
        rows = cur.fetchall()
        print(f"📊 Found {len(rows)} complaints with unknown language")
        
        processor = TextPreprocessor()
        updated_count = 0
        
        for row in rows:
            complaint_id = row[0]
            description = row[1]
            
            if not description:
                continue
                
            detected_lang = processor.detect_language(description)
            
            # Update database
            cur.execute("""
                UPDATE complaints 
                SET detected_language = %s 
                WHERE id = %s
            """, (detected_lang, complaint_id))
            
            updated_count += 1
            if updated_count % 50 == 0:
                print(f"✅ Processed {updated_count} complaints...")
                conn.commit()
        
        conn.commit()
        print(f"🎉 Successfully updated {updated_count} complaints!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    fix_languages()
