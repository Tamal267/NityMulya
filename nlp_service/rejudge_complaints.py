import os
import psycopg2
import json
import logging
from dotenv import load_dotenv
from classifier import ComplaintClassifier
from preprocessor import TextPreprocessor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('rejudge.log'),
        logging.StreamHandler()
    ]
)

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

def get_columns(cur, table_name):
    cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}';")
    return {row[0] for row in cur.fetchall()}

def rejudge():
    if not DATABASE_URL:
        logging.error("❌ DATABASE_URL not found")
        return

    try:
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()
        
        # Enable BanglishBERT for Banglish translation
        logging.info("🚀 Initializing preprocessor with BanglishBERT...")
        preprocessor = TextPreprocessor(use_banglishbert=True)
        classifier = ComplaintClassifier()
        
        tables_to_process = ['complaints', 'complaints_with_ai']
        
        for table in tables_to_process:
            logging.info(f"🔄 Processing table: {table}")
            
            # Check if table exists
            cur.execute(f"SELECT to_regclass('public.{table}');")
            if not cur.fetchone()[0]:
                logging.warning(f"⚠️ Table {table} does not exist. Skipping.")
                continue

            # Get available columns to construct dynamic update query
            available_columns = get_columns(cur, table)
            
            # Select rows
            cur.execute(f"SELECT id, description, shop_name, complaint_number FROM {table}")
            rows = cur.fetchall()
            
            logging.info(f"📊 Found {len(rows)} complaints in {table} to re-judge...")
            
            updated_count = 0
            
            for row in rows:
                complaint_id = row[0]
                description = row[1]
                shop_name = row[2] or ""
                complaint_number = row[3] or "Unknown"
                
                if not description:
                    logging.warning(f"⚠️ Skipping ID {complaint_id}: No description")
                    continue
                    
                try:
                    # Using BanglishBERT for Banglish translation
                    # Detect if text is Banglish and convert to Bengali
                    
                    # 1. Preprocess & Detect Language
                    cleaned_text = preprocessor.clean_text(description)
                    features = preprocessor.extract_features(description)
                    detected_lang = features.get('language', 'en')
                    
                    # 2. If Banglish (mixed), translate to Bengali
                    text_to_analyze = description
                    if detected_lang == 'mixed':
                        logging.info(f"🔄 Translating Banglish to Bengali for complaint {complaint_number}...")
                        text_to_analyze = preprocessor.convert_banglish_to_bangla(cleaned_text)
                        logging.info(f"✅ Translated: {text_to_analyze[:100]}...")
                    
                    # 3. Run Analysis on translated/original text
                    analysis = classifier.analyze_complaint(text_to_analyze, features)
                    
                    validity = analysis.get("validity", {})
                    priority = analysis.get("priority", {})
                    severity = analysis.get("severity", {})
                    sentiment = analysis.get("sentiment", {})
                    category = analysis.get("category", {})

                    # Construct Update Fields based on available columns
                    update_fields = []
                    params = []

                    # Map analysis fields to DB columns
                    field_mapping = {
                        'validity_score': (validity.get("validity_score", 0), 'validity_score'),
                        'is_valid': (validity.get("is_valid", False), 'is_valid'),
                        'validity_reasons': (validity.get("reasons", []), 'validity_reasons'),
                        'ai_priority_score': (priority.get("priority_score", 0), 'ai_priority_score'),
                        'ai_priority_level': (priority.get("priority_level", "Low"), 'ai_priority_level'),
                        'priority_reasons': (priority.get("reasons", []), 'priority_reasons'),
                        'sentiment_score': (sentiment.get("sentiment_score", 0), 'sentiment_score'),
                        'sentiment': (sentiment.get("sentiment", "neutral"), 'sentiment'),
                        'emotion_intensity': (sentiment.get("emotion_intensity", "neutral"), 'emotion_intensity'),
                        'ai_category': (category.get("category", "Other"), 'ai_category'),
                        'ai_category_confidence': (str(category.get("confidence", 0)), 'ai_category_confidence'),
                        'matched_keywords': (1 if category.get("matched_keywords") else 0, 'matched_keywords'), # Integer count or list? DB says integer usually, but let's check. check_tables said integer.
                        'ai_summary': (analysis.get("summary", ""), 'ai_summary'),
                        'detected_language': (analysis.get("language", "en"), 'detected_language'),
                        'ai_analysis_date': ('NOW()', 'ai_analysis_date'),
                        'ai_full_analysis': (json.dumps(analysis), 'ai_full_analysis')
                    }

                    for key, (value, col_name) in field_mapping.items():
                        if col_name in available_columns:
                            if col_name == 'ai_analysis_date':
                                update_fields.append(f"{col_name} = NOW()")
                            else:
                                update_fields.append(f"{col_name} = %s")
                                params.append(value)
                    
                    if not update_fields:
                        continue

                    params.append(complaint_id)
                    
                    sql = f"UPDATE {table} SET {', '.join(update_fields)} WHERE id = %s"
                    
                    cur.execute(sql, tuple(params))
                    
                    updated_count += 1
                    if updated_count % 10 == 0:
                        conn.commit()
                        print(f"Processed {updated_count}/{len(rows)} in {table}", end='\r')
                        
                except Exception as e:
                    logging.error(f"❌ Error processing ID {complaint_id} in {table}: {str(e)}")
                    conn.rollback()
                    continue
            
            conn.commit()
            logging.info(f"✅ Finished updating {table}. Total: {updated_count}")

            
        cur.close()
        conn.close()
        logging.info("🎉 All tables processed successfully!")

    except Exception as e:
        logging.error(f"❌ Critical Error: {str(e)}")

if __name__ == "__main__":
    rejudge()
