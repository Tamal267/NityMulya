"""
Batch process complaints through NLP model and update database
"""

import requests
import psycopg2
from psycopg2.extras import execute_batch
import os
from dotenv import load_dotenv
from datetime import datetime
import time
from typing import Dict, Any
import json

load_dotenv()

# Configuration
DATABASE_URL = os.getenv("DATABASE_URL", "")
NLP_SERVICE_URL = "http://localhost:8001/api/analyze-complaint"
API_KEY = os.getenv("API_KEY", "your-secret-api-key")

# Batch size for processing
BATCH_SIZE = 10


def get_unprocessed_complaints(conn, limit: int = None):
    """Get complaints that haven't been processed by AI"""
    
    cursor = conn.cursor()
    
    query = """
    SELECT id, description, category, shop_name, product_name
    FROM complaints
    WHERE ai_analysis_date IS NULL
    ORDER BY submitted_at DESC
    """
    
    if limit:
        query += f" LIMIT {limit}"
    
    cursor.execute(query)
    results = cursor.fetchall()
    cursor.close()
    
    complaints = []
    for row in results:
        complaints.append({
            "id": row[0],
            "description": row[1],
            "category": row[2],
            "shop_name": row[3],
            "product_name": row[4],
        })
    
    return complaints


def analyze_complaint(complaint: Dict[str, Any]) -> Dict[str, Any]:
    """Send complaint to NLP service for analysis"""
    
    try:
        payload = {
            "complaint_text": complaint["description"],
            "product_name": complaint["product_name"],
            "shop_name": complaint["shop_name"],
        }
        
        headers = {
            "X-API-Key": API_KEY,
            "Content-Type": "application/json"
        }
        
        response = requests.post(NLP_SERVICE_URL, json=payload, headers=headers, timeout=30)
        response.raise_for_status()
        
        result = response.json()
        # Extract analysis from response
        return result.get("analysis", result)
    
    except Exception as e:
        print(f"❌ Error analyzing complaint {complaint['id']}: {e}")
        return None


def update_complaint_with_ai(conn, complaint_id: int, analysis: Dict[str, Any], processing_time: float):
    """Update complaint with AI analysis results"""
    
    cursor = conn.cursor()
    
    # Extract data from analysis
    validity = analysis.get("validity", {})
    priority = analysis.get("priority", {})
    severity = analysis.get("severity", {})
    sentiment = analysis.get("sentiment", {})
    category = analysis.get("category", {})
    
    update_query = """
    UPDATE complaints SET
        validity_score = %s,
        is_valid = %s,
        validity_reasons = %s,
        ai_priority_score = %s,
        ai_priority_level = %s,
        priority_reasons = %s,
        sentiment_score = %s,
        sentiment = %s,
        emotion_intensity = %s,
        ai_category = %s,
        ai_category_confidence = %s,
        matched_keywords = %s,
        ai_summary = %s,
        detected_language = %s,
        ai_analysis_date = %s,
        ai_processing_time_ms = %s,
        ai_full_analysis = %s
    WHERE id = %s
    """
    
    cursor.execute(update_query, (
        validity.get("score", 0),
        validity.get("is_valid", False),
        validity.get("reasons", []),
        priority.get("priority_score", 0),
        priority.get("priority_level", "Low"),
        priority.get("reasons", []),
        sentiment.get("sentiment_score", 0),
        sentiment.get("sentiment", "neutral"),
        sentiment.get("emotion_intensity", 0),
        category.get("category", "অন্যান্য"),
        category.get("confidence", 0),
        category.get("matched_keywords", []),
        analysis.get("summary", ""),
        analysis.get("detected_language", "unknown"),
        datetime.now(),
        int(processing_time * 1000),
        json.dumps(analysis),
        complaint_id,
    ))
    
    conn.commit()
    cursor.close()


def process_batch(conn, complaints: list):
    """Process a batch of complaints"""
    
    print(f"🔄 Processing batch of {len(complaints)} complaints...")
    
    success_count = 0
    failed_count = 0
    
    for complaint in complaints:
        start_time = time.time()
        
        analysis = analyze_complaint(complaint)
        
        processing_time = time.time() - start_time
        
        if analysis:
            update_complaint_with_ai(conn, complaint["id"], analysis, processing_time)
            success_count += 1
            print(f"✅ Processed complaint #{complaint['id']} ({processing_time:.2f}s)")
        else:
            failed_count += 1
            print(f"❌ Failed to process complaint #{complaint['id']}")
        
        # Small delay to avoid overwhelming the service
        time.sleep(0.1)
    
    return success_count, failed_count


def main():
    """Main processing function"""
    
    print("🚀 Starting batch complaint processing...")
    print(f"📡 NLP Service: {NLP_SERVICE_URL}")
    
    # Test NLP service
    try:
        response = requests.get("http://localhost:8001/health", timeout=5)
        print(f"✅ NLP Service is running")
    except Exception as e:
        print(f"❌ NLP Service is not available: {e}")
        print(f"💡 Please start the service first: cd nlp_service && ./start_service.sh")
        return
    
    # Connect to database
    print(f"🔌 Connecting to database...")
    conn = psycopg2.connect(DATABASE_URL)
    
    # Get unprocessed complaints
    complaints = get_unprocessed_complaints(conn)
    print(f"📊 Found {len(complaints)} unprocessed complaints")
    
    if not complaints:
        print("✅ All complaints are already processed!")
        conn.close()
        return
    
    # Process in batches
    total_success = 0
    total_failed = 0
    
    for i in range(0, len(complaints), BATCH_SIZE):
        batch = complaints[i:i + BATCH_SIZE]
        print(f"\n📦 Batch {i // BATCH_SIZE + 1}/{(len(complaints) + BATCH_SIZE - 1) // BATCH_SIZE}")
        
        success, failed = process_batch(conn, batch)
        total_success += success
        total_failed += failed
    
    conn.close()
    
    print(f"\n" + "="*50)
    print(f"✅ Processing complete!")
    print(f"📊 Total: {len(complaints)}")
    print(f"✅ Success: {total_success}")
    print(f"❌ Failed: {total_failed}")
    print(f"📈 Success Rate: {(total_success / len(complaints) * 100):.2f}%")


if __name__ == "__main__":
    main()
