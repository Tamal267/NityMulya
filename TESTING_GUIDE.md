# Testing AI Complaint System - Quick Guide

## ✅ System Status

The AI-Enhanced Complaint System is **FULLY IMPLEMENTED** and ready to test!

### What's Already Done:
- ✅ Dart Complaint Model with AI fields
- ✅ DNCRP Dashboard with priority filters
- ✅ Backend API controllers ready
- ✅ Database schema with AI columns
- ✅ Python NLP service (BanglaBERT)
- ✅ Complaint submission form

## 🧪 Testing Guide - Submit Complaints from Customer

### Prerequisites:
1. Backend server running (`cd Backend && bun run dev`)
2. Flutter app running (already running on Chrome)
3. Customer account logged in

### Step 1: Login as Customer

1. Open the Flutter app in your browser
2. Click **"গ্রাহক"** (Customer) button
3. Use test credentials:
   - Phone: `01234567890` (or any existing customer)
   - Password: `password123`

### Step 2: Navigate to a Shop

1. After login, you'll see the home screen with shops
2. Click on any shop card (e.g., "Rahim Store", "করিম স্টোর")
3. Scroll down to the **"অভিযোগ"** (Complaint) section
4. Click the red **"অভিযোগ করুন"** (Submit Complaint) button

### Step 3: Fill Out Complaint Form

**Required Fields:**
- **অভিযোগের ধরন** (Complaint Type): Select from dropdown
  - পণ্যের গুণগত মান সমস্যা (Quality Issue)
  - ভুল দাম বা অতিরিক্ত চার্জ (Wrong Price)
  - পণ্যের ওজন কম (Short Weight)
  - খারাপ আচরণ (Bad Behavior)
  - মেয়াদোত্তীর্ণ পণ্য (Expired Product)
  - অন্যান্য (Others)

- **পণ্য নির্বাচন করুন** (Select Product): Optional
  
- **অভিযোগ বিবরণ** (Complaint Description): Write your complaint
  - Example (Bengali): "আমি গতকাল এই দোকান থেকে চাল কিনেছি কিন্তু গুণগত মান খুবই খারাপ"
  - Example (English): "I bought rice yesterday but the quality is very poor"

### Test Cases to Try:

#### Test Case 1: High Priority Complaint (Quality Issue)
```
Type: পণ্যের গুণগত মান সমস্যা
Description: আমি গতকাল এই দোকান থেকে একটি মেয়াদোত্তীর্ণ পণ্য কিনেছি। এটি খাওয়ার পর আমার স্বাস্থ্য সমস্যা হয়েছে।
Expected: Should be marked as High/Urgent priority
```

#### Test Case 2: Medium Priority (Price Issue)
```
Type: ভুল দাম বা অতিরিক্ত চার্জ
Description: দোকানদার আমার কাছে সরকারি দামের চেয়ে বেশি টাকা নিয়েছে।
Expected: Should be marked as Medium priority
```

#### Test Case 3: Behavior Complaint
```
Type: খারাপ আচরণ
Description: দোকানদার আমার সাথে খুব খারাপ ব্যবহার করেছে এবং অসম্মান করেছে।
Expected: Should be detected as emotional/serious
```

### Step 4: Submit Complaint

1. Click **"অভিযোগ জমা দিন"** (Submit Complaint) button
2. Wait for success message
3. Note the **Complaint Number** (e.g., DNCRP-1736069012-ABC123)

## 🔍 Viewing Complaints as DNCRP Admin

### Step 1: Login as DNCRP Admin

1. Logout from customer account
2. Click **"DNCRP"** button on welcome screen
3. Login credentials:
   - Username: `admin`
   - Password: `admin123`

### Step 2: View Complaints Dashboard

1. You'll see the DNCRP Dashboard
2. Click on **"Complaints"** tab (middle icon)
3. **Observe the AI Features:**

   **Priority Filter Chips:**
   - All | Urgent | High | Medium | Low
   - Click to filter by priority

   **Status Filter Chips:**
   - All | Received | Forwarded | Solved
   - Click to filter by status

   **Complaint Cards Show:**
   - 🤖 **AI Badge** - If analyzed by AI
   - ⚠️ **Validity Warning** - If flagged as suspicious
   - **Priority Badge** - Color-coded (Red=Urgent, Orange=High, Blue=Medium, Green=Low)
   - **Status Badge** - Current status
   - Customer name and shop name
   - Submission date

### Step 3: Test Filters

1. **Click "Urgent"** filter - See only urgent complaints
2. **Click "High"** filter - See high priority complaints
3. **Click "Received"** status - See pending complaints
4. **Click "All"** to reset filters

### Step 4: View Complaint Details

1. Click on any complaint card
2. View full details including:
   - Complete description
   - AI analysis results (if available)
   - Priority level
   - Validity score
   - Customer contact info

## 📊 What the AI Does (Backend)

### AI Analysis Features:

1. **Validity Detection**
   - Checks if complaint is genuine
   - Flags spam or invalid complaints
   - Provides confidence score (0-1)

2. **Priority Classification**
   - Analyzes urgency keywords
   - Detects emotional intensity
   - Assigns: Urgent | High | Medium | Low

3. **Sentiment Analysis**
   - Measures negative emotion level
   - Detects distress or anger
   - Helps prioritize serious cases

4. **Category Detection**
   - Auto-categorizes complaint type
   - Matches keywords
   - Improves routing

5. **Language Support**
   - Bengali (বাংলা)
   - English
   - Banglish (Mixed)

## 🔧 Troubleshooting

### If complaints don't appear:

1. **Check Backend** is running:
   ```bash
   cd Backend
   bun run dev
   ```

2. **Check Database** connection in Backend/.env

3. **Check Browser Console** for errors (F12)

### If AI analysis is missing:

The AI analysis is **optional** and done in the background. If the NLP service is not running, complaints will still be submitted with manual priority levels. To enable full AI features:

1. Install python3-venv:
   ```bash
   sudo apt install python3.12-venv
   ```

2. Create virtual environment:
   ```bash
   cd nlp_service
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. Start NLP service:
   ```bash
   python main.py
   ```

4. Service will run on http://localhost:8000

## ✅ Testing Checklist

- [ ] Customer can login
- [ ] Customer can view shops
- [ ] Customer can click complaint button
- [ ] Complaint form opens
- [ ] Form validation works
- [ ] Complaint submits successfully
- [ ] Complaint number is displayed
- [ ] DNCRP admin can login
- [ ] Admin can view complaints list
- [ ] Complaints are sorted by priority
- [ ] Filter chips work (Priority & Status)
- [ ] AI badges appear on analyzed complaints
- [ ] Clicking complaint shows details
- [ ] All Bengali text displays correctly

## 📝 Notes

- Complaints are stored in `complaints` table
- AI analysis happens asynchronously
- If NLP service is offline, complaints still work (manual priority)
- Priority sorting works with or without AI
- Filters work on both AI and manual priority fields

## 🎯 Success Criteria

**System is working if:**
1. ✅ Customer can submit complaints
2. ✅ DNCRP admin can view complaints
3. ✅ Complaints are sorted by priority (Urgent first)
4. ✅ Filters work correctly
5. ✅ UI is responsive and user-friendly

**AI is working if:**
6. ✅ AI badges appear on complaints
7. ✅ Priority is auto-assigned accurately
8. ✅ Validity warnings show for suspicious complaints

---

## 🚀 Quick Test Commands

```bash
# Terminal 1: Start Backend
cd Backend
bun run dev

# Terminal 2: Flutter is already running

# Terminal 3 (Optional): Start NLP Service
cd nlp_service
source venv/bin/activate
python main.py
```

**Test URL:** Your Flutter app should be running on Chrome at the URL shown in the terminal.

---

Ready to test! Start by logging in as a customer and submitting a complaint. 🎉
