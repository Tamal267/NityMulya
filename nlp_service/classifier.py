"""
BanglaBERT-based Complaint Classifier
Handles validity detection, priority classification, and sentiment analysis
"""

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification, AutoModel
import numpy as np
from typing import Dict, List, Tuple
from config import config
import re

class ComplaintClassifier:
    def __init__(self):
        """Initialize mBERT (Multilingual BERT) model and tokenizer"""
        print(f"Loading mBERT model: {config.BANGLA_BERT_MODEL}")
        
        # Load tokenizer and base model
        self.tokenizer = AutoTokenizer.from_pretrained(config.BANGLA_BERT_MODEL)
        self.base_model = AutoModel.from_pretrained(config.BANGLA_BERT_MODEL)
        
        # Set device
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.base_model.to(self.device)
        self.base_model.eval()
        
        print(f"Model loaded successfully on {self.device}")
    
    def get_embedding(self, text: str) -> np.ndarray:
        """Get BERT embedding for text"""
        # Tokenize
        inputs = self.tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            max_length=config.MAX_LENGTH,
            padding=True
        )
        
        # Move to device
        inputs = {k: v.to(self.device) for k, v in inputs.items()}
        
        # Get embeddings
        with torch.no_grad():
            outputs = self.base_model(**inputs)
            # Use [CLS] token embedding
            embeddings = outputs.last_hidden_state[:, 0, :].cpu().numpy()
        
        return embeddings[0]
    
    def detect_validity(self, text: str, features: Dict) -> Dict:
        """
        Detect if complaint is valid or spam/gibberish
        Returns: validity_score (0-1), is_valid (bool), reason
        """
        validity_score = 1.0
        reasons = []
        
        text_lower = text.lower()
        
        # CRITICAL: Gibberish detection
        # 1. Check for excessive repeated characters
        if features.get('repeated_char_ratio', 0) > 0.15:
            validity_score -= 0.6
            reasons.append("Excessive repeated characters (gibberish)")
        
        # 2. Check for consonant clusters (gibberish English)
        if features.get('consonant_clusters', 0) > 2:
            validity_score -= 0.5
            reasons.append(f"Too many consonant clusters ({features['consonant_clusters']})")
        
        # 3. Check space ratio (gibberish lacks proper spacing)
        space_ratio = features.get('space_ratio', 0)
        if space_ratio < 0.08 and features['char_count'] > 20:
            validity_score -= 0.5
            reasons.append("Improper spacing (gibberish)")
        
        # 4. Check average word length (gibberish has unusual lengths)
        avg_word_len = features.get('avg_word_length', 0)
        if avg_word_len < 2.5 or avg_word_len > 15:
            validity_score -= 0.4
            reasons.append(f"Unusual word length (avg: {avg_word_len:.1f})")
        
        # 5. Check for minimal vowels (especially for English text)
        if features.get('has_english') and not features.get('has_bengali'):
            # English text should have vowels
            vowel_count = len(re.findall(r'[aeiouAEIOU]', text))
            vowel_ratio = vowel_count / max(features['char_count'], 1)
            if vowel_ratio < 0.2 and features['char_count'] > 10:
                validity_score -= 0.5
                reasons.append(f"Insufficient vowels (gibberish English) - {vowel_ratio:.2f}")
        
        # 6. Check if Bengali text has proper structure
        if features.get('has_bengali'):
            vowel_ratio = features.get('vowel_ratio', 0)
            if vowel_ratio < 0.05:  # Bengali text needs vowel markers
                validity_score -= 0.4
                reasons.append("Invalid Bengali structure")
        
        # 7. Check if language is unknown (usually indicates gibberish)
        if features.get('language') == 'unknown' and features['word_count'] > 3:
            validity_score -= 0.4
            reasons.append("Unknown language structure")

        # 8. Check for common words (if English, should have at least one stop word)
        if features.get('language') == 'en' and features['word_count'] > 4:
            common_en = {'the', 'and', 'is', 'to', 'in', 'of', 'it', 'my', 'that', 'was', 'for', 'on', 'at'}
            has_common = any(w in text_lower.split() for w in common_en)
            if not has_common:
                validity_score -= 0.25
                reasons.append("No common vocabulary found")

        # 9. Check for words without vowels (gibberish indicator)
        words = text_lower.split()
        words_no_vowels = [w for w in words if len(w) > 2 and not re.search(r'[aeiouy]', w)]
        if len(words_no_vowels) > 0:
            validity_score -= 0.2 * len(words_no_vowels)
            reasons.append(f"Contains {len(words_no_vowels)} word(s) without vowels")

        # Rule-based checks
        # 8. Check for spam keywords
        spam_count = sum(1 for keyword in config.SPAM_KEYWORDS if keyword in text_lower)
        if spam_count > 0:
            validity_score -= 0.3 * spam_count
            reasons.append(f"Contains {spam_count} spam keyword(s)")
        
        # 8. Check if too short
        if features['is_short']:
            validity_score -= 0.3
            reasons.append("Text too short (minimum 5 words)")
        
        # 9. Check if contains excessive punctuation
        if features['exclamation_count'] > 5:
            validity_score -= 0.2
            reasons.append("Excessive exclamation marks")
        
        # 10. Check if all caps (spam indicator)
        if features['capital_ratio'] > 0.6 and features['char_count'] > 20:
            validity_score -= 0.2
            reasons.append("Excessive capitalization")
        
        # POSITIVE indicators
        # 11. Check for product/shop mention (valid complaints usually mention these)
        context_keywords = [
            'দোকান', 'shop', 'পণ্য', 'product', 'বিক্রেতা', 'seller',
            'কিনেছি', 'bought', 'purchased', 'খাবার', 'food', 'চাল', 'rice',
            'ডাল', 'lentil', 'তেল', 'oil', 'দাম', 'price', 'টাকা', 'taka',
            'ওজন', 'weight', 'মান', 'quality', 'সমস্যা', 'problem'
        ]
        context_count = sum(1 for word in context_keywords if word in text_lower)
        if context_count > 0:
            validity_score += min(0.3, context_count * 0.1)
            reasons.append(f"Contains {context_count} relevant context keyword(s)")
        
        # 12. Proper sentence structure (has periods or Bengali danda)
        has_structure = bool(re.search(r'[।.!?]', text))
        if has_structure and features['word_count'] > 5:
            validity_score += 0.1
            reasons.append("Proper sentence structure")
        
        # Normalize score
        validity_score = max(0.0, min(1.0, validity_score))
        
        is_valid = validity_score >= config.VALIDITY_THRESHOLD
        
        return {
            'validity_score': round(validity_score, 3),
            'is_valid': is_valid,
            'is_gibberish': validity_score < 0.4,  # Changed threshold
            'reasons': reasons,
            'confidence': 'high' if abs(validity_score - 0.5) > 0.3 else 'medium'
        }
    
    def classify_priority(self, text: str, features: Dict, category: str = None) -> Dict:
        """
        Classify complaint priority: Urgent, High, Medium, Low
        """
        priority_score = 0.5  # Start with Medium
        reasons = []
        
        text_lower = text.lower()
        
        # 1. Check for urgent keywords
        urgent_count = sum(1 for keyword in config.PRIORITY_KEYWORDS['urgent'] if keyword in text_lower)
        if urgent_count > 0:
            priority_score += 0.3
            reasons.append(f"Contains {urgent_count} urgent keyword(s)")
        
        # 2. Check for high priority keywords
        high_count = sum(1 for keyword in config.PRIORITY_KEYWORDS['high'] if keyword in text_lower)
        if high_count > 0:
            priority_score += 0.2
            reasons.append(f"Health/safety related ({high_count} keywords)")
        
        # 3. Exclamation marks indicate urgency
        if features['exclamation_count'] >= 2:
            priority_score += 0.1
            reasons.append("Multiple exclamation marks")
        
        # 4. Category-based priority boost
        high_priority_categories = ['স্বাস্থ্য সমস্যা', 'মেয়াদোত্তীর্ণ', 'প্রতারণা']
        if category in high_priority_categories:
            priority_score += 0.15
            reasons.append(f"High-priority category: {category}")
        
        # 5. Long detailed complaints might be more serious
        if features['word_count'] > 50:
            priority_score += 0.05
            reasons.append("Detailed complaint")
        
        # Normalize score
        priority_score = max(0.0, min(1.0, priority_score))
        
        # Determine priority level
        if priority_score >= config.URGENT_PRIORITY_THRESHOLD:
            priority_level = "Urgent"
        elif priority_score >= config.HIGH_PRIORITY_THRESHOLD:
            priority_level = "High"
        elif priority_score >= 0.4:
            priority_level = "Medium"
        else:
            priority_level = "Low"
        
        return {
            'priority_score': round(priority_score, 3),
            'priority_level': priority_level,
            'reasons': reasons,
            'confidence': 'high' if abs(priority_score - 0.5) > 0.3 else 'medium'
        }
    
    def detect_severity(self, text: str, features: Dict, category: str = None) -> Dict:
        """
        Detect severity of complaint: Critical, Major, Moderate, Minor
        """
        severity_score = 0.5  # Start with Moderate
        reasons = []
        
        text_lower = text.lower()
        
        # 1. Check for critical keywords
        critical_count = sum(1 for keyword in config.SEVERITY_KEYWORDS['critical'] if keyword in text_lower)
        if critical_count > 0:
            severity_score += 0.3
            reasons.append(f"Critical situation ({critical_count} keywords)")
        
        # 2. Check for major keywords
        major_count = sum(1 for keyword in config.SEVERITY_KEYWORDS['major'] if keyword in text_lower)
        if major_count > 0:
            severity_score += 0.2
            reasons.append(f"Major issue ({major_count} keywords)")
        
        # 3. Check for moderate keywords
        moderate_count = sum(1 for keyword in config.SEVERITY_KEYWORDS['moderate'] if keyword in text_lower)
        if moderate_count > 0:
            severity_score += 0.1
            reasons.append(f"Moderate issue ({moderate_count} keywords)")
        
        # 4. Category-based severity
        critical_categories = ['স্বাস্থ্য সমস্যা', 'প্রতারণা']
        major_categories = ['মেয়াদোত্তীর্ণ', 'গুণগত মান']
        
        if category in critical_categories:
            severity_score += 0.2
            reasons.append(f"Critical category: {category}")
        elif category in major_categories:
            severity_score += 0.15
            reasons.append(f"Major category: {category}")
        
        # 5. Health-related terms boost severity
        health_terms = ['স্বাস্থ্য', 'health', 'অসুস্থ', 'sick', 'হাসপাতাল', 'hospital', 'ডাক্তার', 'doctor']
        health_count = sum(1 for term in health_terms if term in text_lower)
        if health_count > 0:
            severity_score += 0.15
            reasons.append(f"Health impact mentioned ({health_count} terms)")
        
        # 6. Financial loss indicators
        financial_terms = ['ক্ষতি', 'loss', 'টাকা', 'taka', 'money', 'refund']
        financial_count = sum(1 for term in financial_terms if term in text_lower)
        if financial_count > 0:
            severity_score += 0.05
            reasons.append(f"Financial impact ({financial_count} terms)")
        
        # Normalize score
        severity_score = max(0.0, min(1.0, severity_score))
        
        # Determine severity level
        if severity_score >= 0.8:
            severity_level = "Critical"
        elif severity_score >= 0.65:
            severity_level = "Major"
        elif severity_score >= 0.4:
            severity_level = "Moderate"
        else:
            severity_level = "Minor"
        
        return {
            'severity_score': round(severity_score, 3),
            'severity_level': severity_level,
            'reasons': reasons,
            'confidence': 'high' if abs(severity_score - 0.5) > 0.3 else 'medium'
        }
    
    def analyze_sentiment(self, text: str, features: Dict) -> Dict:
        """
        Analyze sentiment: Positive, Negative, Neutral
        For complaints, most will be negative, but we can detect severity
        """
        sentiment_score = -0.5  # Complaints are generally negative
        reasons = []
        
        text_lower = text.lower()
        
        # Negative indicators
        negative_words = [
            'খারাপ', 'bad', 'ভয়ানক', 'terrible', 'নষ্ট', 'damaged',
            'রাগ', 'angry', 'ক্ষতি', 'loss', 'প্রতারণা', 'fraud'
        ]
        negative_count = sum(1 for word in negative_words if word in text_lower)
        if negative_count > 0:
            sentiment_score -= 0.1 * negative_count
            reasons.append(f"{negative_count} negative word(s)")
        
        # Positive indicators (might be sarcasm or comparison)
        positive_words = [
            'ভালো', 'good', 'সন্তুষ্ট', 'satisfied', 'ধন্যবাদ', 'thanks'
        ]
        positive_count = sum(1 for word in positive_words if word in text_lower)
        if positive_count > 0:
            sentiment_score += 0.15 * positive_count
            reasons.append(f"{positive_count} positive word(s)")
        
        # Exclamations usually indicate stronger emotion
        if features['exclamation_count'] >= 2:
            sentiment_score -= 0.1
            reasons.append("Strong emotion detected")
        
        # Normalize
        sentiment_score = max(-1.0, min(1.0, sentiment_score))
        
        # Classify sentiment
        if sentiment_score <= -0.4:
            sentiment = "Negative"
        elif sentiment_score >= 0.2:
            sentiment = "Positive"
        else:
            sentiment = "Neutral"
        
        return {
            'sentiment_score': round(sentiment_score, 3),
            'sentiment': sentiment,
            'emotion_intensity': 'high' if abs(sentiment_score) > 0.6 else 'medium',
            'reasons': reasons
        }
    
    def detect_category(self, text: str) -> Dict:
        """
        Detect complaint category based on keywords
        """
        text_lower = text.lower()
        category_scores = {}
        
        for category, keywords in config.CATEGORY_KEYWORDS.items():
            score = sum(1 for keyword in keywords if keyword in text_lower)
            if score > 0:
                category_scores[category] = score
        
        if not category_scores:
            return {
                'category': 'অন্যান্য',
                'confidence': 'low',
                'matched_keywords': 0
            }
        
        # Get category with highest score
        best_category = max(category_scores, key=category_scores.get)
        max_score = category_scores[best_category]
        
        return {
            'category': best_category,
            'confidence': 'high' if max_score >= 2 else 'medium',
            'matched_keywords': max_score,
            'all_categories': category_scores
        }
    
    def generate_summary(self, text: str, max_length: int = 500) -> str:
        """
        Generate a summary of the complaint
        Returns the full description without truncation
        """
        sentences = re.split(r'[।.!?]', text)
        sentences = [s.strip() for s in sentences if len(s.strip()) > 10]
        
        if not sentences:
            # Return full text without truncation
            return text.strip()
        
        # Take first meaningful sentence as summary
        summary = sentences[0]
        
        # Only truncate if extremely long (>500 chars)
        if len(summary) > max_length:
            summary = summary[:max_length] + "..."
        
        return summary
    
    def analyze_complaint(self, text: str, features: Dict) -> Dict:
        """
        Complete complaint analysis pipeline
        """
        # 1. Validity detection
        validity_result = self.detect_validity(text, features)
        
        # 2. Category detection
        category_result = self.detect_category(text)
        
        # 3. Priority classification
        priority_result = self.classify_priority(
            text, features, category_result['category']
        )
        
        # 4. Severity detection (NEW)
        severity_result = self.detect_severity(
            text, features, category_result['category']
        )
        
        # 5. Sentiment analysis
        sentiment_result = self.analyze_sentiment(text, features)
        
        # 6. Generate summary
        summary = self.generate_summary(text)
        
        # Compile all results
        return {
            'validity': validity_result,
            'category': category_result,
            'priority': priority_result,
            'severity': severity_result,  # NEW
            'sentiment': sentiment_result,
            'summary': summary,
            'language': features['language'],
            'metadata': {
                'word_count': features['word_count'],
                'char_count': features['char_count'],
                'has_numbers': features['has_numbers'],
                'is_gibberish': validity_result.get('is_gibberish', False)
            }
        }
