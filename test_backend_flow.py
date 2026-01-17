
import requests
import json
import time

BASE_URL = "http://192.168.68.109:5000"

def test_backend():
    print("🚀 Starting Backend Test...")
    
    # 1. Signup/Login
    email = f"testuser_{int(time.time())}@example.com"
    password = "password123"
    
    print(f"👤 Creating user: {email}")
    
    # Signup
    signup_payload = {
        "full_name": "Test User",
        "email": email,
        "password": password,
        "contact": "01700000000",
        "address": "Test Address",
        "longitude": 0,
        "latitude": 0
    }
    
    try:
        r = requests.post(f"{BASE_URL}/signup_customer", json=signup_payload)
        # If user exists (409), that's fine, proceed to login
        if r.status_code not in [200, 409]:
            print(f"❌ Signup failed: {r.status_code} {r.text}")
            return
    except Exception as e:
        print(f"❌ Could not connect to backend: {e}")
        return

    # Login
    print("🔑 Logging in...")
    login_payload = {
        "email": email,
        "password": password
    }
    
    try:
        r = requests.post(f"{BASE_URL}/login_customer", json=login_payload)
        if r.status_code != 200:
            print(f"❌ Login failed: {r.status_code} {r.text}")
            return
            
        data = r.json()
        token = data.get("token")
        if not token:
            print("❌ No token received!")
            return
            
        print("✅ Login successful, token received.")
        
    except Exception as e:
        print(f"❌ Login request error: {e}")
        return

    # 2. Submit Complaint
    print("📝 Submitting complaint (without priority/severity)...")
    
    complaint_payload = {
        "shop_owner_id": "1",
        "shop_name": "Test Shop",
        "complaint_type": "Short Measurement",
        "description": "The product weight was less than printed on the packet. I bought 1kg sugar but got 800g.",
        "product_id": "100",
        "product_name": "Sugar"
    }
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    try:
        r = requests.post(f"{BASE_URL}/customer/complaints", json=complaint_payload, headers=headers)
        
        print(f"📡 Response Status: {r.status_code}")
        print(f"📡 Response Body: {r.text}")
        
        if r.status_code in [200, 201]:
            print("✅ Complaint submitted successfully!")
            
            # Check if updated complaint contains automated fields (if returned)
            resp_data = r.json()
            complaint = resp_data.get("complaint", {})
            
            # Since NLP runs async, we might not see AI fields immediately unless we wait or the controller awaits it.
            # IN my update I awaited it: "const nlpResponse = await fetch..." 
            # So it SHOULD be there if it worked.
            
            # Check for AI columns if returned
            if complaint:
                print("📋 Complaint Details:")
                print(f"   - ID: {complaint.get('id')}")
                print(f"   - Priority (AI): {complaint.get('ai_priority_level')}")
                print(f"   - Severity (AI): {complaint.get('severity')}") # Note: severity column dropped, so this should be undefined or mapped from AI? 
                # Wait, I mapped finalSeverity to 'severity' column in INSERT, but I DROPped the column 'severity'.
                # Ah! I DROPped the column 'severity' from the table.
                # But in `ai_complaint_controller.ts` I am still trying to INSERT into `severity` column?
                # Let me check my previous edit to `ai_complaint_controller.ts`.
                
        else:
             print("❌ Complaint submission failed.")

    except Exception as e:
        print(f"❌ Complaint request error: {e}")

if __name__ == "__main__":
    test_backend()
