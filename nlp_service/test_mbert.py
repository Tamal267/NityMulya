"""
Test mBERT model with sample complaints
"""
from classifier import ComplaintClassifier
from preprocessor import TextPreprocessor

# Test complaints in different languages
test_complaints = [
    "The product weight was less than printed on the packet. I bought 1kg sugar but got 800g.",
    "Ami alu kinte giyechi kintu quality kharap chilo",
    "দোকানদার খুব অভদ্র আচরণ করেছে। পণ্যের দাম বেশি নিয়েছে।",
    "Mixed text: ami sugar kinlam but quality ছিল not good",
    "Nur Dokan er chal ekdom kharap"
]

print("=" * 80)
print("Testing mBERT (Multilingual BERT) Model")
print("=" * 80)

try:
    # Initialize
    preprocessor = TextPreprocessor()
    classifier = ComplaintClassifier()
    
    for i, complaint in enumerate(test_complaints, 1):
        print(f"\n{'='*80}")
        print(f"Test {i}: {complaint}")
        print(f"{'='*80}")
        
        # Analyze
        features = preprocessor.extract_features(complaint)
        analysis = classifier.analyze_complaint(complaint, features)
        
        # Display results
        print(f"\n✓ Validity: {analysis['validity']['is_valid']} (score: {analysis['validity']['validity_score']:.2f})")
        print(f"✓ Priority: {analysis['priority']['priority_level']} (score: {analysis['priority']['priority_score']:.2f})")
        print(f"✓ Sentiment: {analysis['sentiment']['sentiment']} (score: {analysis['sentiment']['sentiment_score']:.2f})")
        
        # Handle category confidence which might be string or float
        conf = analysis['category']['confidence']
        if isinstance(conf, str):
            print(f"✓ Category: {analysis['category']['category']} (confidence: {conf})")
        else:
            print(f"✓ Category: {analysis['category']['category']} (confidence: {conf:.2f})")
        
    print(f"\n{'='*80}")
    print("✅ All tests completed successfully!")
    print(f"{'='*80}")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
