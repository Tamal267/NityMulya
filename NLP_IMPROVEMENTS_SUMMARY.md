# NLP Service and Complaint System Improvements

## Date: January 5, 2026

## Summary of Changes

### 1. **Improved Gibberish Detection**
- Added advanced text validation to reject invalid complaints like "rdghhf xhvv dgg dv cvc x xc f fv fv fg fv"
- New validation features:
  - Repeated character detection
  - Consonant cluster analysis
  - Space ratio validation
  - Average word length checking
  - Vowel ratio validation (English and Bengali)
  - Proper sentence structure detection

### 2. **Removed Manual Priority and Severity Selection**
- **Flutter App**: Removed priority and severity dropdowns from complaint submission screen
- **Backend**: Removed priority and severity as required parameters
- **AI-Powered**: Priority and severity are now automatically determined by AI

### 3. **Added Severity Detection**
- New severity classification: Critical, Major, Moderate, Minor
- AI analyzes complaint text to determine severity based on:
  - Health/safety keywords
  - Financial impact
  - Category-based assessment
  - Urgency indicators

### 4. **Enhanced Validation**
Improved validity detection with stronger penalties for:
- Gibberish text (vowel deficiency increased penalty: 0.4 → 0.5)
- Consonant clusters (penalty increased: 0.4 → 0.5)
- Short text (penalty increased: 0.25 → 0.3)
- Spam keywords (penalty increased: 0.2 → 0.3)

### 5. **Better Context Understanding**
- Expanded context keywords list
- Added Bengali product/complaint terms
- Improved category detection
- Better sentiment analysis

## Files Modified

### NLP Service (Python)
1. **nlp_service/preprocessor.py**
   - Added gibberish detection features
   - Enhanced feature extraction

2. **nlp_service/classifier.py**
   - Improved validity detection
   - Added severity classification method
   - Updated priority classification
   - Enhanced gibberish detection

3. **nlp_service/config.py**
   - Added severity keywords configuration
   - Organized keywords by severity level

4. **nlp_service/test_nlp.py** (NEW)
   - Comprehensive test suite
   - Tests for gibberish detection
   - Validation for priority and severity

### Flutter App (Dart)
1. **lib/screens/customers/complaint_submission_screen.dart**
   - Removed priority dropdown UI
   - Removed severity dropdown UI
   - Removed priority/severity variables
   - Cleaned up form submission

2. **lib/network/customer_api.dart**
   - Removed priority parameter (required → removed)
   - Removed severity parameter (optional → removed)
   - Simplified API calls

### Backend (TypeScript/Bun)
1. **Backend/src/controller/ai_complaint_controller.ts**
   - Removed manual priority/severity parameters
   - Added AI-powered severity detection
   - Updated to use AI-determined values

2. **Backend/src/services/nlp_service.ts**
   - Added SeverityResult interface
   - Updated ComplaintAnalysisResult type
   - Added is_gibberish detection
   - Exported new types

## Database Schema Notes

The complaints table already supports these columns:
- `priority` - Will be filled by AI
- `severity` - Will be filled by AI  
- `validity_score` - AI validity assessment
- `is_valid` - Boolean validity flag
- `ai_priority_level` - AI-determined priority
- `ai_priority_score` - Priority confidence score
- Additional AI analysis columns

## Testing

Run tests with:
```bash
cd nlp_service
source venv/bin/activate
python test_nlp.py
```

Expected results:
- ✅ Valid complaints: Detected as valid
- ❌ Gibberish: Rejected (validity < 0.6)
- ✅ Priority: Correctly classified
- ✅ Severity: Appropriately assigned

## Example AI Classifications

### Valid Complaint (Bengali)
```
Text: "আমি গতকাল এই দোকান থেকে একটি মেয়াদোত্তীর্ণ পণ্য কিনেছি। পণ্যটি খাওয়ার পর আমার স্বাস্থ্য সমস্যা হয়েছে।"
Validity: 1.0 ✅ Valid
Priority: Urgent
Severity: Critical
Category: মেয়াদোত্তীর্ণ
```

### Gibberish (Rejected)
```
Text: "rdghhf xhvv dgg dv cvc x xc f fv fv fg fv"
Validity: 0.1 ❌ Invalid (Gibberish)
Reasons: Insufficient vowels, Unusual word length
```

### Spam (Rejected)
```
Text: "WIN A FREE PRIZE CLICK HERE NOW!!! অফার পুরস্কার লটারি"
Validity: 0.3 ❌ Invalid (Spam)
Reasons: Contains spam keywords, Excessive capitalization
```

## API Response Format

```json
{
  "success": true,
  "data": {
    "id": "123",
    "complaint_number": "DNCRP-1704441600000-ABC123",
    "status": "Received",
    "priority": "High",      // AI-determined
    "severity": "Major",     // AI-determined
    "category": "মেয়াদোত্তীর্ণ"
  },
  "ai_insights": {
    "validity": "Valid",
    "priority": "High",
    "severity": "Major",
    "sentiment": "Negative",
    "category": "মেয়াদোত্তীর্ণ",
    "summary": "Customer bought expired product...",
    "language": "bn"
  }
}
```

## Benefits

1. **Better Quality Control**: Gibberish and spam complaints are automatically rejected
2. **Consistent Classification**: AI ensures consistent priority and severity assignment
3. **User Experience**: Simplified form - no manual priority/severity selection needed
4. **Accurate Analysis**: Multi-factor validation ensures genuine complaints are processed
5. **Multilingual Support**: Works with Bengali, English, and Banglish text

## Next Steps

1. Monitor AI classification accuracy in production
2. Collect feedback on priority/severity assignments
3. Fine-tune validation thresholds based on real data
4. Add more Bengali complaint keywords
5. Train custom model on actual complaint data

## Configuration

NLP Service configuration in `nlp_service/config.py`:
- `VALIDITY_THRESHOLD = 0.6` - Minimum score for valid complaint
- `HIGH_PRIORITY_THRESHOLD = 0.7` - Threshold for high priority
- `URGENT_PRIORITY_THRESHOLD = 0.85` - Threshold for urgent

Adjust these based on production requirements.
