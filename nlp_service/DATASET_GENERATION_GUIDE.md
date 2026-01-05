# 500-Complaint Dataset Generation & Analysis Guide

## Overview
This guide explains how to generate 500 complaints, process them through the NLP model, and analyze accuracy with visualizations.

## Files Created

### 1. `generate_complaints.py`
Generates 500 realistic complaints in Bengali, English, and Banglish.

**Distribution:**
- 15% Bengali (~75 complaints)
- 30% English (~150 complaints)
- 55% Banglish (~275 complaints)

**Features:**
- Realistic complaint templates
- Mixed categories (expired products, wrong price, quality issues, etc.)
- Random customer/shop assignments
- Timestamps over last 30 days

### 2. `insert_complaints.py`
Inserts generated complaints into the PostgreSQL database.

**Features:**
- Batch insertion for performance
- Auto-generates unique complaint numbers (CMP-XXXXXX)
- Sets default values for priority/severity (will be updated by AI)

### 3. `process_complaints.py`
Processes complaints through NLP model and updates database.

**Features:**
- Batch processing (10 complaints per batch)
- Calls NLP service API for each complaint
- Updates all AI analysis columns:
  - `validity_score`, `is_valid`, `validity_reasons`
  - `ai_priority_score`, `ai_priority_level`, `priority_reasons`
  - `sentiment_score`, `sentiment`, `emotion_intensity`
  - `ai_category`, `ai_category_confidence`, `matched_keywords`
  - `ai_summary`, `detected_language`
  - `ai_processing_time_ms`, `ai_full_analysis`
- Error handling and progress tracking

### 4. `analyze_accuracy.py`
Generates comprehensive accuracy analysis with 8 visualizations.

**Visualizations Generated:**
1. **language_distribution.png** - Pie chart of language distribution
2. **validity_distribution.png** - Valid vs invalid + score distribution
3. **priority_distribution.png** - Priority levels + score distribution
4. **severity_distribution.png** - Severity level distribution
5. **sentiment_analysis.png** - Sentiment distribution + score vs intensity
6. **category_distribution.png** - Top 10 complaint categories
7. **processing_time.png** - Processing time distribution + by language
8. **confidence_analysis.png** - 4-panel confidence analysis

**Text Report:**
- Overall statistics
- Language distribution
- Priority/severity distribution
- Sentiment distribution
- Top categories
- Performance insights

## Installation

### Step 1: Install Analysis Dependencies
```bash
cd nlp_service
pip install -r requirements_analysis.txt
```

### Step 2: Set Up Environment
Make sure your `.env` file has:
```env
DATABASE_URL=postgresql://user:password@host/database
```

## Usage

### Complete Workflow

```bash
cd nlp_service

# Step 1: Generate 500 complaints dataset
python generate_complaints.py

# Step 2: Insert into database
python insert_complaints.py

# Step 3: Start NLP service (in separate terminal)
./start_service.sh

# Step 4: Process complaints through NLP model
python process_complaints.py

# Step 5: Generate accuracy analysis
python analyze_accuracy.py
```

### Individual Steps

#### Generate Dataset Only
```bash
python generate_complaints.py
```
**Output:** `complaints_dataset.json` (500 complaints)

#### Insert to Database
```bash
python insert_complaints.py
```
**Prerequisites:** `complaints_dataset.json` must exist

#### Process with NLP
```bash
# Make sure NLP service is running first!
python process_complaints.py
```
**Prerequisites:** 
- NLP service running on http://localhost:8001
- Unprocessed complaints in database

#### Analyze Accuracy
```bash
python analyze_accuracy.py
```
**Output:** 
- `accuracy_analysis/` directory with 8 PNG visualizations
- `accuracy_analysis/accuracy_report.txt` text report

## Expected Output

### Console Output (process_complaints.py)
```
🚀 Starting batch complaint processing...
📡 NLP Service: http://localhost:8001/api/analyze-complaint
✅ NLP Service is running
🔌 Connecting to database...
📊 Found 500 unprocessed complaints

📦 Batch 1/50
🔄 Processing batch of 10 complaints...
✅ Processed complaint #1234 (2.35s)
✅ Processed complaint #1235 (1.89s)
...

==================================================
✅ Processing complete!
📊 Total: 500
✅ Success: 498
❌ Failed: 2
📈 Success Rate: 99.60%
==================================================
```

### Console Output (analyze_accuracy.py)
```
🚀 Starting NLP Accuracy Analysis...

🔌 Connecting to database...
📊 Loaded 500 processed complaints

📊 Calculating metrics...

📈 Generating visualizations...
✅ Saved: language_distribution.png
✅ Saved: validity_distribution.png
✅ Saved: priority_distribution.png
✅ Saved: severity_distribution.png
✅ Saved: sentiment_analysis.png
✅ Saved: category_distribution.png
✅ Saved: processing_time.png
✅ Saved: confidence_analysis.png

📝 Generating summary report...
✅ Saved: accuracy_report.txt

============================================================
✅ Analysis complete!
📁 All outputs saved to: accuracy_analysis/
============================================================
```

## Metrics Calculated

### Overall Statistics
- Total complaints processed
- Valid vs invalid count and percentage
- Average validity score
- Average sentiment score
- Average category confidence
- Average processing time

### Distribution Analysis
- **Language**: Bengali, English, Banglish percentages
- **Priority**: Critical, High, Medium, Low distribution
- **Severity**: Critical, Major, Moderate, Minor distribution
- **Sentiment**: Positive, Neutral, Negative distribution
- **Categories**: Top 10 complaint categories

### Performance Insights
- Validation accuracy rate
- Processing speed (ms per complaint)
- Confidence levels by language
- Sentiment detection across languages

## Troubleshooting

### NLP Service Not Available
```
❌ NLP Service is not available
💡 Please start the service first: cd nlp_service && ./start_service.sh
```
**Solution:** Start NLP service in another terminal

### No Processed Complaints
```
❌ No processed complaints found!
💡 Run process_complaints.py first
```
**Solution:** Run `process_complaints.py` to process complaints

### Database Connection Error
```
psycopg2.OperationalError: could not connect to server
```
**Solution:** Check DATABASE_URL in `.env` file

### Import Error (matplotlib/seaborn)
```
ModuleNotFoundError: No module named 'matplotlib'
```
**Solution:** Install analysis dependencies:
```bash
pip install -r requirements_analysis.txt
```

## Database Schema

### Complaints Table Columns Updated
```sql
-- Validity columns
validity_score DECIMAL
is_valid BOOLEAN
validity_reasons TEXT[]

-- Priority columns
ai_priority_score DECIMAL
ai_priority_level VARCHAR(20)
priority_reasons TEXT[]
priority VARCHAR(20)  -- Updated from AI

-- Severity column
severity VARCHAR(20)  -- Updated from AI

-- Sentiment columns
sentiment_score DECIMAL
sentiment VARCHAR(20)
emotion_intensity DECIMAL

-- Category columns
ai_category VARCHAR(255)
ai_category_confidence DECIMAL
matched_keywords TEXT[]

-- Summary & metadata
ai_summary TEXT
detected_language VARCHAR(50)
ai_analysis_date TIMESTAMP
ai_processing_time_ms INTEGER
ai_full_analysis JSONB
```

### complaints_with_ai View
This is automatically updated when `complaints` table is updated. No manual intervention needed.

## Performance Tips

### Faster Processing
- Increase `BATCH_SIZE` in `process_complaints.py` (default: 10)
- Use faster GPU if available for NLP model
- Process during off-peak hours

### Large Datasets
For datasets > 1000 complaints:
1. Increase batch size to 20-50
2. Add progress checkpoints
3. Use parallel processing (not implemented yet)

## Next Steps

1. **Review Visualizations**: Check `accuracy_analysis/` folder
2. **Read Report**: Open `accuracy_report.txt`
3. **Adjust Model**: Based on accuracy, tune NLP parameters
4. **Iterate**: Generate more diverse complaints if needed
5. **Production**: Deploy with validated model

## Contact
For issues or questions, refer to the main project documentation.
