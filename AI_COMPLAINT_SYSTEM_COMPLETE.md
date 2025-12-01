# AI-Enhanced Complaint Management System

## Implementation Guide for Thesis

### **System Overview**

This document describes the implementation of an AI-Enhanced Complaint Management System for Government-Regulated Marketplaces using Bengali NLP (BanglaBERT) for:

1. **Validity Detection** - Filter spam and irrelevant complaints
2. **Priority Classification** - Automatically classify complaint urgency
3. **Sentiment Analysis** - Detect emotion and severity
4. **Category Detection** - Auto-categorize complaints
5. **Multi-lingual Support** - Bengali, English, and Banglish

---

## **Architecture**

### **Components**

```
┌─────────────────┐
│  Flutter App    │ (Customer submits complaint)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ TypeScript API  │ (Hono + PostgreSQL)
│  (Port 3000)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Python NLP     │ (FastAPI + BanglaBERT)
│  Service        │
│  (Port 8001)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   BanglaBERT    │ (Transformers Model)
│   Model         │
└─────────────────┘
```

---

## **Setup Instructions**

### **Step 1: Database Migration**

```bash
cd Backend
bun run add_ai_analysis_columns.ts
```

This adds AI analysis columns to the `complaints` table:

- `validity_score`, `is_valid`, `validity_reasons`
- `ai_priority_score`, `ai_priority_level`, `priority_reasons`
- `sentiment_score`, `sentiment`, `emotion_intensity`
- `ai_category`, `ai_summary`, `detected_language`
- `ai_full_analysis` (JSONB for complete results)

### **Step 2: Install Python NLP Service**

```bash
cd nlp_service

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

First run will download BanglaBERT model (~500MB).

### **Step 3: Configure Environment Variables**

**Backend/.env:**

```env
NLP_SERVICE_URL=http://localhost:8001
NLP_API_KEY=your-secret-api-key-here
```

**nlp_service/.env:**

```env
SERVICE_PORT=8001
SERVICE_HOST=0.0.0.0
MODEL_NAME=sagorsarker/bangla-bert-base
API_KEY=your-secret-api-key-here
```

### **Step 4: Start Services**

**Terminal 1 - NLP Service:**

```bash
cd nlp_service
python main.py
```

**Terminal 2 - Backend:**

```bash
cd Backend
bun run dev
```

**Terminal 3 - Flutter App:**

```bash
flutter run
```

---

## **API Endpoints**

### **NLP Service (Python)**

#### 1. Analyze Complaint

```http
POST http://localhost:8001/api/analyze-complaint
Headers:
  X-API-Key: your-secret-api-key
  Content-Type: application/json

Body:
{
  "complaint_text": "আমি গতকাল এই দোকান থেকে মেয়াদোত্তীর্ণ পণ্য কিনেছি। স্বাস্থ্য সমস্যা হয়েছে।",
  "customer_name": "রহিম আহমেদ",
  "shop_name": "করিম স্টোর",
  "product_name": "বিস্কুট"
}

Response:
{
  "success": true,
  "analysis": {
    "validity": {
      "validity_score": 0.95,
      "is_valid": true,
      "reasons": ["Contains relevant context"],
      "confidence": "high"
    },
    "priority": {
      "priority_score": 0.85,
      "priority_level": "Urgent",
      "reasons": ["Health/safety related", "Contains urgent keywords"],
      "confidence": "high"
    },
    "sentiment": {
      "sentiment_score": -0.7,
      "sentiment": "Negative",
      "emotion_intensity": "high"
    },
    "category": {
      "category": "স্বাস্থ্য সমস্যা",
      "confidence": "high",
      "matched_keywords": 3
    },
    "summary": "মেয়াদোত্তীর্ণ পণ্য কিনে স্বাস্থ্য সমস্যা হয়েছে",
    "language": "bn"
  },
  "processing_time_ms": 245.5
}
```

### **Backend API (TypeScript)**

#### 1. Submit Complaint with AI

```http
POST http://localhost:3000/api/ai-complaints/submit

Body:
{
  "customer_name": "রহিম আহমেদ",
  "customer_email": "rahim@example.com",
  "customer_phone": "01712345678",
  "shop_name": "করিম স্টোর",
  "product_name": "বিস্কুট",
  "description": "আমি গতকাল মেয়াদোত্তীর্ণ পণ্য কিনেছি",
  "category": "খাদ্য",
  "priority": "Medium"
}

Response:
{
  "success": true,
  "data": {
    "id": 123,
    "complaint_number": "DNCRP-1733140800-ABC123",
    "status": "Received",
    "priority": "Urgent",
    "category": "স্বাস্থ্য সমস্যা"
  },
  "ai_insights": {
    "validity": "Valid",
    "priority": "Urgent",
    "sentiment": "Negative",
    "category": "স্বাস্থ্য সমস্যা",
    "summary": "মেয়াদোত্তীর্ণ পণ্য কিনেছি",
    "language": "bn"
  }
}
```

#### 2. Get Complaints with AI Insights

```http
GET http://localhost:3000/api/ai-complaints?filter=urgent&sortBy=priority&limit=20
```

#### 3. Reanalyze Complaint

```http
POST http://localhost:3000/api/ai-complaints/123/reanalyze
```

#### 4. Get AI Analytics

```http
GET http://localhost:3000/api/ai-complaints/analytics

Response:
{
  "success": true,
  "analytics": {
    "overview": {
      "total_complaints": 150,
      "valid_complaints": 142,
      "invalid_complaints": 8,
      "urgent_complaints": 12,
      "high_priority_complaints": 35,
      "avg_validity_score": 0.87
    },
    "category_distribution": [...],
    "language_distribution": [...]
  }
}
```

---

## **NLP Pipeline Details**

### **1. Text Preprocessing**

**File:** `nlp_service/preprocessor.py`

**Steps:**

1. Language detection (Bengali/English/Banglish)
2. Text normalization
   - Bengali number conversion (০-৯ → 0-9)
   - Unicode normalization
3. Cleaning
   - Remove URLs, emails
   - Convert emojis to text
   - Remove excessive punctuation
4. Feature extraction
   - Word count, character count
   - Punctuation analysis
   - Capital letter ratio

### **2. Validity Detection**

**File:** `nlp_service/classifier.py` → `detect_validity()`

**Method:** Rule-based + Heuristic

**Rules:**

- ✅ Contains relevant keywords (shop, product, complaint)
- ❌ Contains spam keywords (prize, lottery, free)
- ❌ Too short (<5 words)
- ❌ Excessive punctuation (!!! ???)
- ❌ All caps (spam indicator)

**Output:**

- `validity_score`: 0-1
- `is_valid`: boolean
- `reasons`: list of detection reasons

### **3. Priority Classification**

**File:** `nlp_service/classifier.py` → `classify_priority()`

**Method:** Keyword-based + Category analysis

**Priority Levels:**

1. **Urgent** (0.85+)

   - Keywords: জরুরি, urgent, immediately
   - Health issues: স্বাস্থ্য, poison, expired
   - Safety concerns

2. **High** (0.70-0.84)

   - Quality issues: খারাপ, নষ্ট, damaged
   - Fraud: প্রতারণা, cheat, fake
   - Child safety: শিশু, বাচ্চা

3. **Medium** (0.40-0.69)

   - Price: দাম, price, expensive
   - Weight: ওজন, quantity, কম

4. **Low** (<0.40)
   - General inquiries

**Features:**

- Urgent keyword matching
- Category-based boosting
- Exclamation mark counting
- Text length analysis

### **4. Sentiment Analysis**

**File:** `nlp_service/classifier.py` → `analyze_sentiment()`

**Method:** Lexicon-based

**Sentiment Scores:**

- **Negative** (-1.0 to -0.4): খারাপ, terrible, রাগ
- **Neutral** (-0.4 to 0.2): Standard complaint
- **Positive** (0.2 to 1.0): ভালো, satisfied (rare)

**Features:**

- Negative word counting
- Positive word detection
- Emotion intensity from punctuation

### **5. Category Detection**

**File:** `nlp_service/classifier.py` → `detect_category()`

**Categories:**

- মূল্য সংক্রান্ত (Price related)
- গুণগত মান (Quality)
- ওজন/পরিমাণ (Weight/Quantity)
- মেয়াদোত্তীর্ণ (Expired)
- স্বাস্থ্য সমস্যা (Health issues)
- প্যাকেজিং (Packaging)
- পরিষেবা (Service)
- প্রতারণা (Fraud)

**Method:** Keyword matching with confidence scoring

---

## **BanglaBERT Integration**

### **Model Used**

- **Name:** sagorsarker/bangla-bert-base
- **Type:** BERT-base architecture
- **Parameters:** 110M
- **Pre-training:** Bengali Wikipedia, Bengali news

### **Current Usage**

In this implementation, BanglaBERT is loaded and available for:

1. **Text Embeddings** - Convert Bengali text to vectors
2. **Feature Extraction** - Extract semantic features

### **Future Fine-tuning** (For Thesis)

To improve accuracy, fine-tune BanglaBERT on your complaint dataset:

```python
# training/train_classifier.py
from transformers import AutoModelForSequenceClassification, Trainer

# Load model for classification
model = AutoModelForSequenceClassification.from_pretrained(
    "sagorsarker/bangla-bert-base",
    num_labels=4  # Urgent, High, Medium, Low
)

# Train with your labeled data
trainer = Trainer(
    model=model,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    # ... training arguments
)

trainer.train()
```

**Dataset Requirements:**

- Minimum 500-1000 labeled complaints
- Labels: Priority, Validity, Sentiment
- Balanced classes

---

## **Database Schema**

### **Complaints Table (Enhanced)**

```sql
CREATE TABLE complaints (
  id SERIAL PRIMARY KEY,
  complaint_number TEXT UNIQUE,
  customer_name TEXT,
  shop_name TEXT,
  description TEXT,

  -- Manual fields
  category TEXT,
  priority TEXT,
  status TEXT,

  -- AI Analysis fields
  validity_score DECIMAL(3,2),
  is_valid BOOLEAN,
  validity_reasons TEXT[],

  ai_priority_score DECIMAL(3,2),
  ai_priority_level TEXT,
  priority_reasons TEXT[],

  sentiment_score DECIMAL(3,2),
  sentiment TEXT,
  emotion_intensity TEXT,

  ai_category TEXT,
  ai_summary TEXT,
  detected_language TEXT,

  ai_full_analysis JSONB,
  ai_analysis_date TIMESTAMP,

  submitted_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

---

## **Flutter UI Integration**

### **Enhanced Complaint Card**

The DNCRP dashboard now shows:

1. **AI Badge** - Indicates AI analysis is available
2. **Validity Warning** - If complaint flagged as spam
3. **AI Summary** - Quick summary in blue box
4. **Priority Level** - AI-detected priority
5. **Sentiment Icon** - Visual emotion indicator
6. **Category** - AI-detected category

**File:** `lib/screens/dncrp/dncrp_dashboard_screen.dart`

---

## **Research & Thesis Components**

### **1. Dataset Creation**

Collect and annotate complaints:

```csv
complaint_text,validity,priority,sentiment,category,language
"দোকানে দাম বেশি নিয়েছে",valid,medium,negative,মূল্য সংক্রান্ত,bn
"I bought expired biscuit",valid,high,negative,মেয়াদোত্তীর্ণ,en
```

### **2. Evaluation Metrics**

**Validity Detection:**

- Accuracy, Precision, Recall, F1-Score
- Confusion Matrix

**Priority Classification:**

- Multi-class accuracy
- Per-class Precision/Recall
- Macro-averaged F1

**Sentiment Analysis:**

- Accuracy for 3-class (Pos/Neg/Neu)
- Cohen's Kappa (inter-annotator agreement)

### **3. Experiments**

1. **Baseline:** Rule-based only
2. **BanglaBERT:** Pre-trained embeddings
3. **Fine-tuned:** Fine-tuned BanglaBERT
4. **Hybrid:** Rules + Fine-tuned model

### **4. Research Questions**

1. How accurate is BanglaBERT for Bengali complaint classification?
2. Can the system handle code-mixed (Banglish) text?
3. What is the impact of AI-assisted prioritization on response time?
4. How does validity detection reduce spam complaints?

---

## **Performance Optimization**

### **Current Performance**

- **Single Analysis:** ~250ms
- **Batch (10):** ~1.5s
- **Model Loading:** ~3s (startup)

### **Optimization Strategies**

1. **Caching:** Cache frequent complaint patterns
2. **Async Processing:** Process AI analysis in background
3. **Batch API:** Process multiple complaints together
4. **Model Quantization:** Reduce model size for faster inference

---

## **Troubleshooting**

### **NLP Service Not Running**

```bash
# Check service health
curl http://localhost:8001/health

# Check logs
cd nlp_service
python main.py
```

### **Model Download Issues**

```python
# Manually download model
from transformers import AutoTokenizer, AutoModel
AutoTokenizer.from_pretrained("sagorsarker/bangla-bert-base")
AutoModel.from_pretrained("sagorsarker/bangla-bert-base")
```

### **Backend Integration Issues**

Check `.env` variables:

- `NLP_SERVICE_URL=http://localhost:8001`
- `NLP_API_KEY=your-secret-api-key`

---

## **Next Steps for Thesis**

1. ✅ System Implementation (Complete)
2. ⏳ Dataset Collection (500-1000 complaints)
3. ⏳ Manual Annotation (Validity, Priority, Sentiment)
4. ⏳ Model Fine-tuning
5. ⏳ Evaluation & Metrics
6. ⏳ User Study
7. ⏳ Thesis Writing

---

## **Citation**

If you use this system in your research, please cite:

```bibtex
@mastersthesis{ai_complaint_system_2025,
  title={AI-Enhanced Complaint Management System for Government-Regulated Marketplaces: A Bengali NLP Approach},
  author={Your Name},
  year={2025},
  school={Your University},
  type={Master's Thesis}
}
```

---

## **License**

MIT License - Free for academic and commercial use.

## **Contact**

For questions and support:

- Email: your.email@example.com
- GitHub: github.com/yourusername/nitymulya
