# AI-Enhanced Complaint Management System - Quick Start

## 🎯 Your Thesis Topic

**AI-Enhanced Complaint Management System for Government-Regulated Marketplaces: A Bengali NLP Approach for Validity Detection, Priority Classification, and Sentiment Analysis**

---

## ✅ What I've Built for You

### **1. NLP Service (Python + BanglaBERT)**

- **Location:** `nlp_service/`
- **Features:**
  - ✅ Validity Detection (spam filtering)
  - ✅ Priority Classification (Urgent/High/Medium/Low)
  - ✅ Sentiment Analysis (Positive/Neutral/Negative)
  - ✅ Category Detection (8 complaint categories)
  - ✅ Multi-lingual Support (Bengali, English, Banglish)
  - ✅ AI Summary Generation
  - ✅ FastAPI REST API

### **2. Backend Integration (TypeScript)**

- **Location:** `Backend/src/`
- **Features:**
  - ✅ NLP Service Client (`services/nlp_service.ts`)
  - ✅ AI-Enhanced Complaint Controller (`controller/ai_complaint_controller.ts`)
  - ✅ Database Schema with AI fields
  - ✅ REST API endpoints

### **3. Database Enhancement**

- **Migration Script:** `Backend/add_ai_analysis_columns.ts`
- **New Columns:**
  - `validity_score`, `is_valid`, `validity_reasons`
  - `ai_priority_score`, `ai_priority_level`, `priority_reasons`
  - `sentiment_score`, `sentiment`, `emotion_intensity`
  - `ai_category`, `ai_summary`, `detected_language`
  - `ai_full_analysis` (JSONB)

### **4. Flutter UI Updates**

- **Enhanced:** `lib/screens/dncrp/dncrp_dashboard_screen.dart`
- **Features:**
  - ✅ AI badge indicator
  - ✅ Validity warnings
  - ✅ AI-generated summary display
  - ✅ Sentiment icons
  - ✅ Priority color coding

### **5. Documentation & Training**

- ✅ Complete system guide: `AI_COMPLAINT_SYSTEM_COMPLETE.md`
- ✅ NLP service README: `nlp_service/README.md`
- ✅ Training script: `nlp_service/training/train_priority_classifier.py`
- ✅ Annotation guide: `nlp_service/training/ANNOTATION_GUIDE.md`

---

## 🚀 Quick Setup (3 Steps)

### **Windows:**

```bash
setup_ai_system.bat
```

### **Linux/Mac:**

```bash
chmod +x setup_ai_system.sh
./setup_ai_system.sh
```

### **Manual Setup:**

**1. Database Migration:**

```bash
cd Backend
bun run add_ai_analysis_columns.ts
```

**2. Install Python Service:**

```bash
cd nlp_service
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

**3. Configure Environment:**

Create `Backend/.env`:

```env
NLP_SERVICE_URL=http://localhost:8001
NLP_API_KEY=your-secret-api-key-here
```

Create `nlp_service/.env`:

```env
SERVICE_PORT=8001
API_KEY=your-secret-api-key-here
MODEL_NAME=sagorsarker/bangla-bert-base
```

---

## 🎮 Running the System

### **Terminal 1 - NLP Service:**

```bash
cd nlp_service
venv\Scripts\activate
python main.py
```

Service runs on: http://localhost:8001

### **Terminal 2 - Backend:**

```bash
cd Backend
bun run dev
```

Backend runs on: http://localhost:3000

### **Terminal 3 - Flutter App:**

```bash
flutter run
```

---

## 📊 Testing the System

### **1. Test NLP Service Directly:**

```bash
curl -X POST http://localhost:8001/api/analyze-complaint \
  -H "X-API-Key: your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "complaint_text": "আমি গতকাল এই দোকান থেকে একটি মেয়াদোত্তীর্ণ পণ্য কিনেছি। এটি খাওয়ার পর আমার স্বাস্থ্য সমস্যা হয়েছে।"
  }'
```

### **2. Test via Backend:**

```bash
curl -X POST http://localhost:3000/api/ai-complaints/submit \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "রহিম আহমেদ",
    "customer_email": "rahim@example.com",
    "shop_name": "করিম স্টোর",
    "description": "মেয়াদোত্তীর্ণ বিস্কুট বিক্রি করছে"
  }'
```

### **3. Test via Flutter App:**

1. Open app
2. Login as customer
3. Submit complaint in Bengali/English/Banglish
4. Login as DNCRP admin
5. View AI-enhanced complaint list

---

## 📈 NLP Pipeline Flow

```
User submits complaint in Bengali/English/Banglish
              ↓
    Text Preprocessing
    - Language detection
    - Normalization
    - Cleaning
              ↓
    BanglaBERT Processing
    - Embeddings extraction
              ↓
    Multi-Task Analysis
    ├── Validity Detection
    ├── Priority Classification
    ├── Sentiment Analysis
    └── Category Detection
              ↓
    Summary Generation
              ↓
    Save to Database with AI insights
              ↓
    Display in Admin Dashboard
```

---

## 🎓 For Your Thesis

### **Phase 1: Current State (✅ Complete)**

- [x] System implementation
- [x] Rule-based NLP pipeline
- [x] BanglaBERT integration
- [x] Database schema
- [x] API endpoints
- [x] UI enhancements

### **Phase 2: Data Collection (Your Task)**

- [ ] Collect 500-1000 complaints
- [ ] Manually annotate:
  - Validity (valid/spam)
  - Priority (Urgent/High/Medium/Low)
  - Sentiment (Positive/Neutral/Negative)
- [ ] Create CSV datasets
- [ ] Calculate inter-annotator agreement

**See:** `nlp_service/training/ANNOTATION_GUIDE.md`

### **Phase 3: Model Training (Your Task)**

- [ ] Fine-tune BanglaBERT for priority classification
- [ ] Train validity classifier
- [ ] Train sentiment analyzer
- [ ] Evaluate on test set

**Run:**

```bash
cd nlp_service/training
python train_priority_classifier.py
```

### **Phase 4: Evaluation (Your Task)**

- [ ] Calculate metrics:
  - Accuracy, Precision, Recall, F1-Score
  - Confusion Matrix
  - Per-class performance
- [ ] Compare with baselines:
  - Random baseline
  - Rule-based only
  - Pre-trained BanglaBERT
  - Fine-tuned BanglaBERT

### **Phase 5: Thesis Writing**

- [ ] Introduction & Problem Statement
- [ ] Literature Review (Bengali NLP, Complaint Management)
- [ ] Methodology (Your NLP pipeline)
- [ ] Implementation Details
- [ ] Experiments & Results
- [ ] Discussion & Analysis
- [ ] Conclusion & Future Work

---

## 📚 Key Research Contributions

1. **Novel Dataset:** Bengali complaint corpus for government marketplace
2. **Multi-lingual NLP:** Handling Bengali, English, and code-mixed text
3. **Multi-task Learning:** Joint validity, priority, and sentiment analysis
4. **Real-world System:** Production-ready deployment
5. **BanglaBERT Application:** Fine-tuning for complaint classification

---

## 📊 Expected Thesis Results

### **Performance Metrics**

| Model                 | Accuracy | Precision | Recall   | F1-Score |
| --------------------- | -------- | --------- | -------- | -------- |
| Random Baseline       | ~25%     | -         | -        | -        |
| Rule-based            | ~65%     | 0.62      | 0.65     | 0.63     |
| Pre-trained BERT      | ~75%     | 0.73      | 0.75     | 0.74     |
| Fine-tuned BanglaBERT | **~85%** | **0.83**  | **0.85** | **0.84** |

_(Estimated - you'll get actual results after training)_

### **Language Coverage**

- Bengali (বাংলা): Primary
- English: Secondary
- Banglish (Mixed): Supported

---

## 🔧 Troubleshooting

### **NLP Service Not Starting**

```bash
# Check Python version
python --version  # Should be 3.8+

# Reinstall dependencies
pip install --upgrade -r requirements.txt

# Check model download
python -c "from transformers import AutoTokenizer; AutoTokenizer.from_pretrained('sagorsarker/bangla-bert-base')"
```

### **Backend Can't Connect to NLP**

- Check NLP service is running: `curl http://localhost:8001/health`
- Check `.env` file has correct `NLP_SERVICE_URL`
- Check API key matches in both services

### **Database Migration Fails**

```bash
# Check database connection
cd Backend
bun run check_database.js

# Re-run migration
bun run add_ai_analysis_columns.ts
```

---

## 📖 Documentation Files

| File                                                | Purpose                       |
| --------------------------------------------------- | ----------------------------- |
| `AI_COMPLAINT_SYSTEM_COMPLETE.md`                   | Complete system documentation |
| `nlp_service/README.md`                             | NLP service API docs          |
| `nlp_service/training/ANNOTATION_GUIDE.md`          | Dataset annotation guide      |
| `nlp_service/training/train_priority_classifier.py` | Model training script         |

---

## 🎯 Next Steps

1. ✅ **Setup system** (use `setup_ai_system.bat`)
2. ✅ **Test NLP pipeline** (submit test complaints)
3. 📝 **Collect data** (500-1000 complaints)
4. 🏷️ **Annotate dataset** (use annotation guide)
5. 🏋️ **Train models** (run training script)
6. 📊 **Evaluate performance** (calculate metrics)
7. 📄 **Write thesis** (document everything)

---

## 💡 Tips for Success

1. **Start Small:** Begin with 100 labeled complaints to test training
2. **Iterate:** Fine-tune, evaluate, improve iteratively
3. **Document Everything:** Keep notes of experiments
4. **Visualize Results:** Create graphs for thesis
5. **Compare Approaches:** Show improvement over baselines

---

## 🌟 System Features

### **For Customers:**

- Submit complaints in their preferred language
- Get instant AI feedback on submission
- Track complaint status

### **For Admins (DNCRP):**

- AI-filtered spam detection
- Automatic priority ranking
- AI-generated summaries for quick review
- Sentiment-based urgency indicators
- Smart filtering and sorting

---

## 📞 Support

If you encounter issues:

1. Check documentation files
2. Review error messages
3. Test each component separately
4. Check all services are running

---

**Good luck with your thesis! You have a complete, working AI-Enhanced Complaint Management System. 🎓🚀**

**The implementation is done. Now focus on:**

- Data collection & annotation
- Model training & evaluation
- Writing your thesis

**You've got this! 💪**
