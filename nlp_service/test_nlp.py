"""
Test Script for NLP Service
Tests validity detection, priority, severity, and classification
"""

from preprocessor import TextPreprocessor
from classifier import ComplaintClassifier

# Initialize components
preprocessor = TextPreprocessor()
classifier = ComplaintClassifier()

# Test cases
test_cases = [
    {
        "name": "Valid Bangla Complaint",
        "text": "আমি গতকাল এই দোকান থেকে একটি মেয়াদোত্তীর্ণ পণ্য কিনেছি। পণ্যটি খাওয়ার পর আমার স্বাস্থ্য সমস্যা হয়েছে।",
        "expected_valid": True,
    },
    {
        "name": "Gibberish English",
        "text": "rdghhf xhvv dgg dv cvc x xc f fv fv fg fv",
        "expected_valid": False,
    },
    {
        "name": "Random Characters",
        "text": "aaaa bbbb cccc dddd eeee ffff gggg",
        "expected_valid": False,
    },
    {
        "name": "Short Invalid Text",
        "text": "xyz abc",
        "expected_valid": False,
    },
    {
        "name": "Valid English Complaint",
        "text": "I bought expired rice from this shop yesterday. The quality was very bad and I want a refund.",
        "expected_valid": True,
    },
    {
        "name": "Valid Banglish Complaint",
        "text": "Ami ei shop theke kharap product kinechi. Dam o beshi niche. Please action nin.",
        "expected_valid": True,
    },
    {
        "name": "Urgent Health Complaint",
        "text": "জরুরি! আমার বাচ্চা এই দোকানের পণ্য খেয়ে অসুস্থ হয়েছে। দ্রুত ব্যবস্থা নিন।",
        "expected_valid": True,
        "expected_priority": "Urgent",
        "expected_severity": "Critical",
    },
    {
        "name": "Price Complaint",
        "text": "এই দোকান ভুল দাম দিয়েছে। আমি ৫০০ টাকা বেশি দিয়েছি।",
        "expected_valid": True,
        "expected_priority": "Medium",
    },
    {
        "name": "Weight Shortage",
        "text": "The weight of the product was less than what I paid for. This is cheating.",
        "expected_valid": True,
    },
    {
        "name": "Spam Text",
        "text": "WIN A FREE PRIZE CLICK HERE NOW!!! অফার পুরস্কার লটারি",
        "expected_valid": False,
    },
]


def test_complaint(test_case):
    """Test a single complaint"""
    print(f"\n{'='*80}")
    print(f"TEST: {test_case['name']}")
    print(f"{'='*80}")
    print(f"Text: {test_case['text']}")
    print(f"-{'-'*78}")

    # Preprocess
    cleaned_text, features = preprocessor.preprocess(test_case["text"])

    print(f"\nPreprocessing:")
    print(f"  Language: {features['language']}")
    print(f"  Word Count: {features['word_count']}")
    print(f"  Char Count: {features['char_count']}")
    print(f"  Repeated Char Ratio: {features.get('repeated_char_ratio', 0):.3f}")
    print(f"  Space Ratio: {features.get('space_ratio', 0):.3f}")
    print(f"  Avg Word Length: {features.get('avg_word_length', 0):.2f}")

    # Analyze
    result = classifier.analyze_complaint(cleaned_text, features)

    # Validity
    validity = result["validity"]
    print(f"\nValidity Check:")
    print(f"  Score: {validity['validity_score']}")
    print(f"  Valid: {validity['is_valid']}")
    print(f"  Gibberish: {validity.get('is_gibberish', False)}")
    print(f"  Reasons: {', '.join(validity['reasons'][:3])}")

    # Priority
    priority = result["priority"]
    print(f"\nPriority:")
    print(f"  Level: {priority['priority_level']}")
    print(f"  Score: {priority['priority_score']}")

    # Severity
    severity = result["severity"]
    print(f"\nSeverity:")
    print(f"  Level: {severity['severity_level']}")
    print(f"  Score: {severity['severity_score']}")

    # Category
    category = result["category"]
    print(f"\nCategory:")
    print(f"  Category: {category['category']}")
    print(f"  Confidence: {category['confidence']}")

    # Summary
    print(f"\nSummary: {result['summary'][:80]}...")

    # Validate expectations
    print(f"\n{'='*80}")
    if "expected_valid" in test_case:
        actual = validity["is_valid"]
        expected = test_case["expected_valid"]
        status = "✅ PASS" if actual == expected else "❌ FAIL"
        print(f"{status} - Valid: Expected {expected}, Got {actual}")

    if "expected_priority" in test_case:
        actual = priority["priority_level"]
        expected = test_case["expected_priority"]
        status = "✅ PASS" if actual == expected else "⚠️  CHECK"
        print(f"{status} - Priority: Expected {expected}, Got {actual}")

    if "expected_severity" in test_case:
        actual = severity["severity_level"]
        expected = test_case["expected_severity"]
        status = "✅ PASS" if actual == expected else "⚠️  CHECK"
        print(f"{status} - Severity: Expected {expected}, Got {actual}")


# Run all tests
if __name__ == "__main__":
    print("🧪 TESTING NLP COMPLAINT CLASSIFIER")
    print("=" * 80)

    for test_case in test_cases:
        try:
            test_complaint(test_case)
        except Exception as e:
            print(f"\n❌ ERROR: {e}")

    print(f"\n\n{'='*80}")
    print(f"TESTS COMPLETED: {len(test_cases)} test cases")
    print(f"{'='*80}")
