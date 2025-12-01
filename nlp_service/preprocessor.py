"""
Text Preprocessor for Bengali, English, and Banglish
Handles text normalization, language detection, and cleaning
"""

import re
import emoji
from langdetect import detect, LangDetectException
from typing import Dict, Tuple

class TextPreprocessor:
    def __init__(self):
        # Banglish to Bengali common mappings
        self.banglish_mappings = {
            "taka": "টাকা",
            "dam": "দাম",
            "kharap": "খারাপ",
            "valo": "ভালো",
            "kom": "কম",
            "beshi": "বেশি",
            "product": "পণ্য",
            "shop": "দোকান",
            "service": "সেবা",
            "complaint": "অভিযোগ"
        }
        
        # Bengali number to English number mapping
        self.bengali_to_english_nums = str.maketrans('০১২৩৪৫৬৭৮৯', '0123456789')
        
    def detect_language(self, text: str) -> str:
        """
        Detect language of the text
        Returns: 'bn' (Bengali), 'en' (English), or 'mixed' (Banglish)
        """
        try:
            # Check if text contains Bengali characters
            bengali_chars = re.findall(r'[\u0980-\u09FF]', text)
            english_chars = re.findall(r'[a-zA-Z]', text)
            
            bengali_ratio = len(bengali_chars) / max(len(text), 1)
            english_ratio = len(english_chars) / max(len(text), 1)
            
            if bengali_ratio > 0.3 and english_ratio > 0.1:
                return 'mixed'  # Banglish
            elif bengali_ratio > 0.3:
                return 'bn'
            elif english_ratio > 0.3:
                return 'en'
            else:
                # Fallback to langdetect
                lang = detect(text)
                return 'bn' if lang == 'bn' else 'en'
        except LangDetectException:
            return 'unknown'
    
    def normalize_bengali(self, text: str) -> str:
        """Normalize Bengali text"""
        # Convert Bengali numbers to English
        text = text.translate(self.bengali_to_english_nums)
        
        # Normalize Unicode (Bengali has various representations)
        # ো vs ো (combined vs separate)
        text = re.sub(r'া', 'া', text)
        text = re.sub(r'ি', 'ি', text)
        
        # Remove extra whitespaces
        text = ' '.join(text.split())
        
        return text
    
    def clean_text(self, text: str) -> str:
        """Clean and normalize text"""
        # Convert to lowercase (for English parts)
        # Keep Bengali as-is
        
        # Remove URLs
        text = re.sub(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', text)
        
        # Remove email addresses
        text = re.sub(r'\S+@\S+', '', text)
        
        # Convert emojis to text
        text = emoji.demojize(text, language='en')
        
        # Remove excessive punctuation
        text = re.sub(r'([!?.]){2,}', r'\1', text)
        
        # Remove extra whitespaces
        text = ' '.join(text.split())
        
        # Normalize Bengali
        text = self.normalize_bengali(text)
        
        return text.strip()
    
    def extract_features(self, text: str) -> Dict:
        """Extract features from text for analysis"""
        language = self.detect_language(text)
        cleaned_text = self.clean_text(text)
        
        # Count features
        word_count = len(cleaned_text.split())
        char_count = len(cleaned_text)
        
        # Check for specific markers
        has_numbers = bool(re.search(r'\d', cleaned_text))
        has_bengali = bool(re.search(r'[\u0980-\u09FF]', cleaned_text))
        has_english = bool(re.search(r'[a-zA-Z]', cleaned_text))
        
        # Punctuation analysis
        exclamation_count = cleaned_text.count('!')
        question_count = cleaned_text.count('?')
        
        # Check for capital letters (indicates urgency/emphasis in English)
        capital_ratio = sum(1 for c in cleaned_text if c.isupper()) / max(char_count, 1)
        
        return {
            'original_text': text,
            'cleaned_text': cleaned_text,
            'language': language,
            'word_count': word_count,
            'char_count': char_count,
            'has_numbers': has_numbers,
            'has_bengali': has_bengali,
            'has_english': has_english,
            'exclamation_count': exclamation_count,
            'question_count': question_count,
            'capital_ratio': capital_ratio,
            'is_short': word_count < 5,
            'is_long': word_count > 100
        }
    
    def preprocess(self, text: str) -> Tuple[str, Dict]:
        """
        Main preprocessing function
        Returns: (cleaned_text, features_dict)
        """
        features = self.extract_features(text)
        return features['cleaned_text'], features
