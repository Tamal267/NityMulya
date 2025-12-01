# NLP Service for Complaint Management

AI-Enhanced Complaint Management System using BanglaBERT for Bengali, English, and Banglish text analysis.

## Features

### 1. **Validity Detection**

- Filters spam and irrelevant complaints
- Rule-based + ML approach
- Confidence scoring

### 2. **Priority Classification**

- **Urgent**: Health/safety issues, expired products
- **High**: Quality issues, fraud
- **Medium**: Pricing, weight issues
- **Low**: General inquiries

### 3. **Sentiment Analysis**

- Detects emotion intensity
- Helps prioritize severe complaints

### 4. **Category Detection**

- মূল্য সংক্রান্ত (Price related)
- গুণগত মান (Quality)
- ওজন/পরিমাণ (Weight/Quantity)
- মেয়াদোত্তীর্ণ (Expired)
- স্বাস্থ্য সমস্যা (Health issues)
- প্যাকেজিং (Packaging)
- পরিষেবা (Service)
- প্রতারণা (Fraud)

### 5. **AI Summary Generation**

- Extractive summary for quick review

## Installation

### Prerequisites

- Python 3.8+
- pip

### Steps

1. **Navigate to NLP service directory:**

```bash
cd nlp_service
```

2. **Create virtual environment (recommended):**

```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

3. **Install dependencies:**

```bash
pip install -r requirements.txt
```

4. **Download BanglaBERT model (first run):**
   The model will be automatically downloaded on first run (~500MB)

5. **Configure environment:**

```bash
cp .env.example .env
# Edit .env with your settings
```

6. **Run the service:**

```bash
python main.py
```

The service will start on `http://localhost:8001`

## API Documentation

### 1. Analyze Complaint

**Endpoint:** `POST /api/analyze-complaint`

**Headers:**

```
X-API-Key: your-secret-api-key
Content-Type: application/json
```

**Request Body:**

```json
{
  "complaint_text": "আমি গতকাল এই দোকান থেকে একটি মেয়াদোত্তীর্ণ পণ্য কিনেছি। এটি খাওয়ার পর আমার স্বাস্থ্য সমস্যা হয়েছে।",
  "customer_name": "রহিম আহমেদ",
  "shop_name": "করিম স্টোর",
  "product_name": "বিস্কুট"
}
```

**Response:**

```json
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
      "emotion_intensity": "high",
      "reasons": ["Strong emotion detected"]
    },
    "category": {
      "category": "স্বাস্থ্য সমস্যা",
      "confidence": "high",
      "matched_keywords": 3
    },
    "summary": "গতকাল মেয়াদোত্তীর্ণ পণ্য কিনেছি এবং স্বাস্থ্য সমস্যা হয়েছে",
    "language": "bn"
  },
  "processed_at": "2025-12-02T10:30:00",
  "processing_time_ms": 245.5
}
```

### 2. Batch Analysis

**Endpoint:** `POST /api/batch-analyze`

Process multiple complaints at once.

### 3. Health Check

**Endpoint:** `GET /health`

Check if the service is running.

### 4. Model Info

**Endpoint:** `GET /api/model-info`

Get information about the loaded model.

## Integration with Backend

### TypeScript Backend Integration

Create a service to call the NLP API:

```typescript
// Backend/src/services/nlp_service.ts
import axios from "axios";

const NLP_SERVICE_URL = process.env.NLP_SERVICE_URL || "http://localhost:8001";
const NLP_API_KEY = process.env.NLP_API_KEY || "your-secret-api-key";

export async function analyzeComplaint(complaintText: string, metadata: any) {
  try {
    const response = await axios.post(
      `${NLP_SERVICE_URL}/api/analyze-complaint`,
      {
        complaint_text: complaintText,
        customer_name: metadata.customer_name,
        shop_name: metadata.shop_name,
        product_name: metadata.product_name,
      },
      {
        headers: {
          "X-API-Key": NLP_API_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    return response.data.analysis;
  } catch (error) {
    console.error("NLP analysis failed:", error);
    return null;
  }
}
```

## Model Training (For Thesis)

### Fine-tuning BanglaBERT

For better accuracy, you should fine-tune BanglaBERT on your complaint dataset:

1. **Collect labeled data:**

   - 500-1000 complaints manually labeled
   - Labels: Valid/Spam, Priority (Urgent/High/Medium/Low), Sentiment

2. **Create training script** (see `training/train_classifier.py`)

3. **Fine-tune model:**

```bash
python training/train_classifier.py --task priority --epochs 10
```

4. **Replace base model with fine-tuned model**

### Data Annotation Guidelines

For your thesis, create annotation guidelines:

- **Validity**: Is it a real complaint about a product/service?
- **Priority**: Based on urgency and severity
- **Sentiment**: Emotion intensity
- **Category**: Type of complaint

## Performance Metrics

For your thesis evaluation:

- **Accuracy**: Overall classification accuracy
- **Precision/Recall/F1**: Per class metrics
- **Confusion Matrix**: Error analysis
- **Processing Time**: Real-time performance
- **Language Coverage**: Bengali vs English vs Banglish

## Research Contributions

1. **Novel Dataset**: Bengali complaint corpus
2. **Multi-task Learning**: Joint validity, priority, and sentiment
3. **Code-mixing Handling**: Banglish support
4. **Real-world Deployment**: Production system

## Troubleshooting

### Model Download Issues

```bash
# Manually download model
from transformers import AutoTokenizer, AutoModel
AutoTokenizer.from_pretrained("sagorsarker/bangla-bert-base")
AutoModel.from_pretrained("sagorsarker/bangla-bert-base")
```

### Memory Issues

- Reduce `BATCH_SIZE` in config
- Use CPU instead of GPU for smaller models

### API Key Issues

- Ensure X-API-Key header is set
- Check `.env` file configuration

## License

MIT License

## Citation

```bibtex
@mastersthesis{your_thesis_2025,
  title={AI-Enhanced Complaint Management System for Government-Regulated Marketplaces},
  author={Your Name},
  year={2025},
  school={Your University}
}
```

## Contact

For issues and questions, contact: your.email@example.com
