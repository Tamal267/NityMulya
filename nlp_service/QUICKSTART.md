# Quick Start Guide - NLP Service

## What Changed?

1. **Gibberish Detection** - Rejects invalid text like "rdghhf xhvv dgg"
2. **Auto Priority** - AI determines Urgent/High/Medium/Low
3. **Auto Severity** - AI determines Critical/Major/Moderate/Minor
4. **No Manual Selection** - Users don't select priority/severity anymore

## Start NLP Service

```bash
cd nlp_service
./start_service.sh
```

Service runs on `http://localhost:8001`

## Test It

```bash
cd nlp_service
source venv/bin/activate
python test_nlp.py
```

## What to Expect

### ✅ Valid Complaint
```
Text: "আমি এই দোকান থেকে মেয়াদোত্তীর্ণ পণ্য কিনেছি"
Result: Valid ✅
Priority: Urgent
Severity: Critical
```

### ❌ Gibberish
```
Text: "rdghhf xhvv dgg dv cvc x xc f"
Result: Invalid ❌ (Gibberish detected)
```

### ❌ Spam
```
Text: "WIN FREE PRIZE!!!"
Result: Invalid ❌ (Spam detected)
```

## Integration

The backend automatically calls NLP service when complaint is submitted.
Priority and severity are filled by AI, not by user.

## Configuration

In `nlp_service/config.py`:
- VALIDITY_THRESHOLD = 0.6 (minimum score for valid)
- Adjust if too strict/lenient

## API Example

```bash
curl -X POST http://localhost:8001/api/analyze-complaint \
  -H "X-API-Key: your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "complaint_text": "আমি দোকান থেকে খারাপ পণ্য কিনেছি"
  }'
```

Response includes:
- validity (is_valid, score, reasons)
- priority (level, score)
- severity (level, score)
- category, sentiment, summary

## Files Modified

- Flutter: Removed priority/severity dropdowns
- Backend: Removed priority/severity params
- NLP: Added severity detection + improved validation

See `NLP_IMPROVEMENTS_SUMMARY.md` for full details.
