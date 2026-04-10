# Complaints Dataset - Thesis Research Data

## Dataset Overview

**Total Records:** 500 complaint entries  
**Created:** April 2026  
**Purpose:** Thesis research on AI-powered complaint analysis system  
**Database:** PostgreSQL (Supabase)

## Table Structure

### Table Name: `complaints`

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Auto-generated unique identifier |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Record creation timestamp |
| `customer_id` | UUID | NOT NULL | Customer unique identifier |
| `customer_name` | VARCHAR(100) | NOT NULL | Customer full name |
| `shop_id` | UUID | NOT NULL | Shop unique identifier |
| `shop_name` | VARCHAR(100) | NOT NULL | Shop name |
| `subcategory_id` | UUID | FOREIGN KEY | References subcategories(id) |
| `complaint_description` | TEXT | NOT NULL | Complaint text in Bangla/English/Banglish |
| `validity` | DECIMAL(3,2) | 0.0 - 1.0 | Complaint validity score |
| `priority` | DECIMAL(3,2) | 0.0 - 1.0 | Complaint priority score |
| `complaint_score` | DECIMAL(3,2) | 0.0 - 1.0 | Combined complaint score |
| `complaint_classification` | VARCHAR(20) | weak/medium/high | Final classification |

## Dataset Statistics

### Overall Metrics
- **Total Complaints:** 500
- **Average Validity:** 0.622
- **Average Priority:** 0.523
- **Average Complaint Score:** 0.583
- **Validity Range:** 0.10 - 0.95
- **Priority Range:** 0.20 - 0.95

### Classification Distribution
| Classification | Count | Percentage | Avg Score | Score Range |
|----------------|-------|------------|-----------|-------------|
| **High** | 120 | 24.0% | 0.76 | 0.70 - 0.91 |
| **Medium** | 310 | 62.0% | 0.58 | 0.40 - 0.69 |
| **Weak** | 70 | 14.0% | 0.31 | 0.16 - 0.39 |

## Language Distribution

The dataset contains complaints in three languages:

1. **Bangla (বাংলা):** Pure Bengali script complaints
2. **English:** English language complaints
3. **Banglish:** Mixed Bengali words in Latin script

All 500 records contain Bangla/Banglish text, creating a diverse linguistic dataset for NLP analysis.

## Feature Descriptions

### 1. Validity Score (0.0 - 1.0)
Calculated based on:
- **Price-related complaints:** Compares charged price against subcategory min/max price range
  - If charged price > max_price: High validity (0.6 - 0.95) → Valid complaint
  - If charged price within range: Low validity (0.1 - 0.4) → Invalid complaint
- **Quality/Service complaints:** Random validity based on complaint nature (0.3 - 0.9)

### 2. Priority Score (0.0 - 1.0)
Calculated based on complaint keywords:

**High Priority (0.7 - 0.95):** Contains health hazard keywords
- পচা (rotten), expired, মেয়াদ (expiry), স্বাস্থ্য (health)
- প্রতারণা (cheating), fake, ভুয়া (counterfeit)

**Medium Priority (0.4 - 0.7):** Contains quality issue keywords
- বাসি (stale), old, শুকনো (dried), কম (less), ওজন (weight)

**Low Priority (0.2 - 0.6):** General complaints
- Other service or price-related issues

### 3. Complaint Score (0.0 - 1.0)
**Formula:** `Score = (Validity × 0.6) + (Priority × 0.4)`

This weighted average emphasizes validity while considering urgency.

### 4. Classification
Automatically assigned based on complaint score:
- **High:** Score ≥ 0.70 (Requires immediate action)
- **Medium:** Score 0.40 - 0.69 (Needs attention)
- **Weak:** Score < 0.40 (Low priority or invalid)

## Complaint Types

### Price-Related Complaints (~40%)
Examples:
- "দোকানদার {product} এর দাম বেশি নিয়েছে। {X} টাকা দিয়েছি কিন্তু বাজারে {Y} টাকা।"
- "They charged {X} taka for {product} but market price is {Y} taka."

### Quality-Related Complaints (~30%)
Examples:
- "{Product} এর গুণমান খারাপ ছিল। পচা এবং দুর্গন্ধযুক্ত।"
- "The {product} quality was very poor. Rotten and smelly."

### Weight/Measurement Issues (~10%)
Examples:
- "{Product} কেনার সময় ওজনে কম দিয়েছে। ১ কেজি চেয়েছিলাম কিন্তু ৮০০ গ্রাম দিয়েছে।"
- "They gave less weight when buying {product}."

### Expired Products (~10%)
Examples:
- "দোকানে মেয়াদ উত্তীর্ণ {product} বিক্রি করে। স্বাস্থ্যের জন্য ক্ষতিকর।"
- "Selling expired {product} in the shop. Health hazard."

### Service/Behavior Issues (~10%)
Examples:
- "দোকানদার অসভ্য আচরণ করেছে এবং {product} এর দাম অতিরিক্ত নিয়েছে।"
- "Very rude behavior and overpriced {product}."

## Most Complained Subcategories (Top 10)

| Rank | Subcategory | Complaint Count | Avg Score |
|------|-------------|-----------------|-----------|
| 1 | ডানো | 18 | 0.58 |
| 2 | ডিপ্লোমা (নিউজিল্যান্ড) | 17 | 0.63 |
| 3 | মশুর ডাল (ছোট দানা) | 15 | 0.54 |
| 4 | পিঁয়াজ (দেশী) | 14 | 0.61 |
| 5 | লবণ(প্যাঃ)আয়োডিনযুক্ত | 14 | 0.62 |
| 6 | চাল (মাঝারী)পাইজাম/আটাশ | 14 | 0.57 |
| 7 | আলু (মানভেদে) | 14 | 0.58 |
| 8 | শুকনা মরিচ (দেশী) | 13 | 0.58 |
| 9 | লবঙ্গ | 13 | 0.60 |
| 10 | সয়াবিন তেল (বোতল) | 13 | 0.51 |

## Sample Queries

### Get all high-priority complaints
```sql
SELECT * FROM complaints 
WHERE complaint_classification = 'high'
ORDER BY complaint_score DESC;
```

### Get complaints by subcategory
```sql
SELECT c.*, s.subcat_name, s.min_price, s.max_price
FROM complaints c
JOIN subcategories s ON c.subcategory_id = s.id
WHERE s.subcat_name = 'আলু (মানভেদে)';
```

### Get statistics by shop
```sql
SELECT 
  shop_name,
  COUNT(*) as total_complaints,
  AVG(complaint_score) as avg_score,
  SUM(CASE WHEN complaint_classification = 'high' THEN 1 ELSE 0 END) as high_count
FROM complaints
GROUP BY shop_name
ORDER BY total_complaints DESC;
```

### Find price-related complaints
```sql
SELECT * FROM complaints
WHERE complaint_description ~ '\d+ টাকা'
  OR complaint_description ~ '\d+ taka'
ORDER BY validity DESC;
```

## Data Quality Features

✅ **Realistic Names:** 25 diverse Bengali and English customer names  
✅ **Realistic Shop Names:** 20 common shop name variations  
✅ **Language Diversity:** Bangla, English, and Banglish complaints  
✅ **Price Validation:** Complaints validated against actual subcategory price ranges  
✅ **Weighted Scoring:** Intelligent scoring based on validity and priority  
✅ **Balanced Distribution:** Realistic distribution across classifications  
✅ **Foreign Key Integrity:** All complaints linked to valid subcategories  

## Use Cases for Research

1. **NLP Analysis:** Multi-language text classification and sentiment analysis
2. **Machine Learning:** Training models for complaint classification
3. **Price Validation:** Automated price verification against market rates
4. **Priority Detection:** Keyword-based urgency classification
5. **Consumer Protection:** Identifying fraudulent business practices
6. **Market Analysis:** Understanding common consumer grievances

## Database Schema Diagram

```
complaints
├── id (PK)
├── created_at
├── customer_id
├── customer_name
├── shop_id
├── shop_name
├── subcategory_id (FK) ──→ subcategories(id)
├── complaint_description
├── validity
├── priority
├── complaint_score
└── complaint_classification
```

## Export Data

The dataset can be exported to CSV using:

```javascript
// Export to CSV
const { writeFileSync } = require('fs');
const complaints = await sql`SELECT * FROM complaints`;
// Convert to CSV format
```

## Version History

- **v1.0** (April 2026): Initial dataset with 500 records
  - 3 languages (Bangla, English, Banglish)
  - 49 subcategories covered
  - Intelligent validity and priority scoring
  - Classification: weak/medium/high

## Notes for Researchers

- All customer and shop IDs are randomly generated UUIDs
- Price data is validated against real subcategory price ranges from the database
- Complaint descriptions use realistic templates based on common consumer issues
- The validity score inversely correlates with overcharging magnitude
- Priority scores emphasize health and safety concerns
- This is synthetic data generated for research purposes

---

**Dataset Created By:** Thesis Research Team  
**Database:** Supabase PostgreSQL  
**Last Updated:** April 7, 2026
