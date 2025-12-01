# Dataset Annotation Guide

## For AI-Enhanced Complaint Management System

This guide helps you create a labeled dataset for training BanglaBERT models.

---

## **Dataset Structure**

Create CSV files with the following columns:

### **1. Priority Classification Dataset**

**File:** `labeled_complaints_priority.csv`

| complaint_text                           | priority_label | language |
| ---------------------------------------- | -------------- | -------- |
| আমার বাচ্চা এই খাবার খেয়ে অসুস্থ হয়েছে | Urgent         | bn       |
| দোকানে মেয়াদোত্তীর্ণ পণ্য বিক্রি করছে   | High           | bn       |
| দাম একটু বেশি নিয়েছে                    | Medium         | bn       |
| পণ্য সম্পর্কে জানতে চাই                  | Low            | bn       |

### **2. Validity Detection Dataset**

**File:** `labeled_complaints_validity.csv`

| complaint_text                | is_valid | reason               |
| ----------------------------- | -------- | -------------------- |
| দোকানে পচা মাছ বিক্রি করছে    | true     | legitimate_complaint |
| FREE PRIZE WIN NOW CLICK HERE | false    | spam                 |
| ভালো                          | false    | too_short            |
| দোকানদার ওজনে কম দিয়েছে      | true     | legitimate_complaint |

### **3. Sentiment Analysis Dataset**

**File:** `labeled_complaints_sentiment.csv`

| complaint_text                   | sentiment | emotion_intensity |
| -------------------------------- | --------- | ----------------- |
| এই দোকানের সেবা অত্যন্ত খারাপ!!! | Negative  | high              |
| দাম একটু বেশি কিন্তু মান ভালো    | Neutral   | medium            |
| পণ্যের গুণগত মান নিয়ে সমস্যা    | Negative  | medium            |

---

## **Annotation Guidelines**

### **Priority Classification**

#### **Urgent**

Requires immediate action within 24 hours.

**Examples:**

- ✅ Health hazards: "স্বাস্থ্য সমস্যা হয়েছে", "বিষক্রিয়া"
- ✅ Child safety: "বাচ্চার ক্ষতি হয়েছে"
- ✅ Severe fraud: "প্রচুর টাকা হারিয়েছি"
- ✅ Expired/poisonous products: "মেয়াদোত্তীর্ণ খাবার"

**Keywords:** জরুরি, urgent, স্বাস্থ্য, health, শিশু, child

#### **High**

Serious issues requiring action within 3-7 days.

**Examples:**

- ✅ Quality problems: "পণ্য নষ্ট", "খারাপ মান"
- ✅ Fraud: "প্রতারণা করেছে", "ঠকিয়েছে"
- ✅ Expired products (no health issue yet)
- ✅ Significant overcharging

**Keywords:** খারাপ, bad, নষ্ট, damaged, প্রতারণা, fraud

#### **Medium**

Standard complaints, action within 2 weeks.

**Examples:**

- ✅ Price issues: "দাম বেশি", "overpriced"
- ✅ Weight shortage: "ওজন কম"
- ✅ Service quality: "ব্যবহার খারাপ"
- ✅ Packaging issues

**Keywords:** দাম, price, ওজন, weight, পরিমাণ, quantity

#### **Low**

Minor issues or inquiries.

**Examples:**

- ✅ General questions: "জানতে চাই"
- ✅ Minor inconveniences
- ✅ Feedback (not really complaints)

---

### **Validity Detection**

#### **Valid Complaints**

Real complaints about products/services.

**Criteria:**

- ✅ Mentions shop, product, or service
- ✅ Describes specific problem
- ✅ Reasonable length (>5 words)
- ✅ Contains context

**Examples:**

- "দোকানে পচা সবজি বিক্রি করছে"
- "ওজনে কম দিয়েছে"
- "I bought expired biscuit"

#### **Invalid/Spam**

**Criteria:**

- ❌ Contains spam keywords (lottery, prize, free)
- ❌ Too short (<5 words): "খারাপ", "bad"
- ❌ No context or details
- ❌ Promotional content
- ❌ Random text

**Examples:**

- "WIN FREE PRIZE"
- "খারাপ" (just one word)
- "ক্লিক করুন অফার পান"

---

### **Sentiment Analysis**

#### **Negative**

Expresses dissatisfaction, anger, or frustration.

**Examples:**

- "খুবই খারাপ অভিজ্ঞতা!!!"
- "রাগে অস্থির"
- "ভয়ানক সেবা"

**Keywords:** খারাপ, bad, রাগ, angry, ভয়ানক, terrible

#### **Neutral**

Factual complaint without strong emotion.

**Examples:**

- "দাম একটু বেশি ছিল"
- "পণ্যের ওজন ঠিক ছিল না"

#### **Positive**

Rare in complaints, but possible in mixed feedback.

**Examples:**

- "পণ্য ভালো কিন্তু দাম বেশি"
- "দোকানদার ভদ্র কিন্তু সেবা ধীর"

---

## **Data Collection Strategy**

### **Option 1: Manual Collection**

1. **From existing complaints** in your system
2. **Create synthetic complaints** based on common patterns
3. **Crowdsource** from friends/colleagues

### **Option 2: Real User Data**

1. Deploy system without AI initially
2. Collect real complaints
3. Manually annotate 500-1000 samples
4. Train model
5. Deploy AI system

---

## **Sample Size Requirements**

### **Minimum (for thesis validation)**

- Priority: 500 labeled complaints (125 per class)
- Validity: 300 labeled (150 valid, 150 invalid)
- Sentiment: 300 labeled (100 per class)

### **Recommended (for production)**

- Priority: 2000+ labeled complaints
- Validity: 1000+ labeled
- Sentiment: 1000+ labeled

---

## **Inter-Annotator Agreement**

For research validity, have 2-3 annotators label the same 100 samples.

**Calculate Cohen's Kappa:**

```python
from sklearn.metrics import cohen_kappa_score

annotator1 = [1, 2, 3, 1, 2, ...]
annotator2 = [1, 2, 2, 1, 2, ...]

kappa = cohen_kappa_score(annotator1, annotator2)
print(f"Agreement: {kappa}")
# Kappa > 0.7 is good
```

---

## **Data Augmentation**

Increase dataset size using augmentation:

### **1. Back-translation**

Bengali → English → Bengali

```python
from googletrans import Translator

translator = Translator()

# Original
text = "দোকানে পচা মাছ বিক্রি করছে"

# Bengali → English
english = translator.translate(text, src='bn', dest='en').text

# English → Bengali
augmented = translator.translate(english, src='en', dest='bn').text
```

### **2. Synonym Replacement**

Replace words with Bengali synonyms:

- দাম → মূল্য
- খারাপ → নিম্নমানের
- দোকান → ব্যবসা প্রতিষ্ঠান

### **3. Code-mixing (Banglish)**

Create Banglish versions:

- "দোকানে পচা মাছ বিক্রি করছে" → "dokane pocha mach bikri korche"

---

## **Annotation Tools**

### **Option 1: Google Sheets**

Simple and collaborative.

### **Option 2: Label Studio**

Open-source annotation tool.

```bash
pip install label-studio
label-studio start
```

### **Option 3: Custom Web App**

Build simple annotation interface with React/Flutter.

---

## **Quality Checks**

Before training:

1. ✅ **Check class balance**

   ```python
   df['priority_label'].value_counts()
   ```

2. ✅ **Remove duplicates**

   ```python
   df.drop_duplicates(subset=['complaint_text'])
   ```

3. ✅ **Check for mislabeled data**

   - Read 10% randomly
   - Fix obvious errors

4. ✅ **Language distribution**
   ```python
   df['language'].value_counts()
   ```

---

## **Example Annotation Session**

```python
import pandas as pd

# Load existing complaints
complaints = [
    "দোকানে মেয়াদোত্তীর্ণ বিস্কুট বিক্রি করছে",
    "দাম একটু বেশি নিয়েছে",
    "বাচ্চা খেয়ে অসুস্থ হয়েছে",
    # ... more complaints
]

# Annotate
data = []
for text in complaints:
    print(f"\nComplaint: {text}")

    # Priority
    priority = input("Priority (Low/Medium/High/Urgent): ")

    # Validity
    is_valid = input("Valid? (yes/no): ") == "yes"

    # Sentiment
    sentiment = input("Sentiment (Positive/Neutral/Negative): ")

    data.append({
        'complaint_text': text,
        'priority_label': priority,
        'is_valid': is_valid,
        'sentiment': sentiment,
        'language': 'bn'
    })

# Save
df = pd.DataFrame(data)
df.to_csv('labeled_complaints.csv', index=False)
print(f"\n✅ Saved {len(df)} labeled complaints")
```

---

## **Next Steps After Annotation**

1. ✅ Create labeled CSV files
2. ✅ Run quality checks
3. ✅ Train models using `train_priority_classifier.py`
4. ✅ Evaluate on test set
5. ✅ Deploy fine-tuned models
6. ✅ Document results in thesis

---

## **Resources**

- **BanglaBERT Paper:** https://arxiv.org/abs/2101.00204
- **Hugging Face Datasets:** https://huggingface.co/docs/datasets
- **Label Studio:** https://labelstud.io/
- **Bengali NLP Resources:** https://github.com/sagorbrur/bnlp

---

**Good luck with your thesis! 🎓**
