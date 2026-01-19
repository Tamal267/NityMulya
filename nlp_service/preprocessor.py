"""
Text Preprocessor for Bengali, English, and Banglish
Handles text normalization, language detection, and cleaning
"""

import re
import emoji
import difflib
from langdetect import detect, LangDetectException
from typing import Dict, Tuple
from banglish_dict import BANGLISH_MARKERS_SET, BANGLISH_TO_BN

class TextPreprocessor:
    def __init__(self):
        # Banglish to Bengali markers and full mapping
        self.banglish_markers = BANGLISH_MARKERS_SET
        self.banglish_to_bn = BANGLISH_TO_BN
        
        # Bengali number to English number mapping
        self.bengali_to_english_nums = str.maketrans('০১২৩৪৫৬৭৮৯', '0123456789')
        
        # Common English words that should NOT count as Banglish markers
        # and indicate the text is likely English
        self.english_stopwords = {
            # Pronouns
            'i', 'me', 'my', 'mine', 'you', 'your', 'yours', 'he', 'him', 'his', 'she', 'her', 'hers',
            'it', 'its', 'we', 'us', 'our', 'ours', 'they', 'them', 'their', 'theirs',
            'myself', 'yourself', 'himself', 'herself', 'itself', 'ourselves', 'themselves',
            
            # Verbs (Auxiliary & Common)
            'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
            'have', 'has', 'had', 'do', 'does', 'did', 'done',
            'can', 'could', 'will', 'would', 'shall', 'should', 'may', 'might', 'must',
            'go', 'come', 'think', 'know', 'want', 'need', 'get', 'got', 'give', 'take', 'make', 'see', 'look',
            'buy', 'buying', 'bought', 'purchase', 'purchased', 'order', 'ordered', 'sell', 'sold',
            'work', 'working', 'help', 'ask', 'say', 'said', 'tell', 'told',
            
            # Prepositions & Conjunctions
            'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while',
            'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through',
            'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 
            'again', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 'how',
            
            # Quantifiers & Adjectives
            'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'many', 'much',
            'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 'just', 'now',
            'good', 'bad', 'new', 'old', 'high', 'low', 'big', 'small', 'long', 'short',
            'first', 'last', 'next', 'best', 'worst',
            
            # Application Specific (Nouns that might be in Banglish dict but are English)
            'product', 'item', 'goods', 'packet', 'bag', 'bottle', 'box', 'can', 'jar',
            'price', 'cost', 'rate', 'money', 'cash', 'bill', 'receipt', 'discount', 'offer',
            'quality', 'quantity', 'weight', 'size', 'color', 'date', 'time',
            'shop', 'store', 'market', 'mart', 'traders', 'enterprise', 'bhandar',
            'sugar', 'salt', 'oil', 'rice', 'milk', 'egg', 'eggs', 'water', 'tea', 'coffee',
            'onion', 'potato', 'garlic', 'ginger', 'vegetable', 'fruit', 'fish', 'meat', 'chicken', 'beef',
            'biscuit', 'cake', 'bread', 'soap', 'shampoo', 'detergent', 'paste', 'brush',
            'yesterday', 'today', 'tomorrow', 'day', 'night', 'morning', 'afternoon', 'evening',
            'problem', 'issue', 'complaint', 'service', 'staff', 'behavior', 'rude', 'polite',
            'expire', 'expired', 'rotten', 'smell', 'broken', 'damaged'
        }

    def convert_banglish_to_bangla(self, text: str) -> str:
        """
        Convert Banglish text to Bengali with spell check
        """
        words = text.split()
        converted_words = []
        
        for word in words:
            word_lower = word.lower()
            
            # 1. Direct match
            if word_lower in self.banglish_to_bn:
                converted_words.append(self.banglish_to_bn[word_lower])
                continue
                
            # 2. Check if it's already Bengali or number
            if re.match(r'[\u0980-\u09FF]', word) or re.match(r'[0-9]', word):
                 converted_words.append(word)
                 continue

            # 3. Fuzzy match (Spell check) if length of word is reasonable
            # Find close matches in our dictionary keys
            if len(word) >= 3:
                matches = difflib.get_close_matches(word_lower, self.banglish_markers, n=1, cutoff=0.85)
                
                if matches:
                    close_match = matches[0]
                    converted_words.append(self.banglish_to_bn[close_match])
                else:
                    converted_words.append(word)
            else:
                converted_words.append(word)
                
        return ' '.join(converted_words)
        
    def detect_language(self, text: str) -> str:
        """
        Detect language of the text
        Returns: 'bn' (Bengali), 'en' (English), or 'mixed' (Banglish)
        """
        try:
            # Check if text contains Bengali characters
            bengali_chars = re.findall(r'[\u0980-\u09FF]', text)
            english_chars = re.findall(r'[a-zA-Z]', text)
            
            text_len = max(len(text), 1)
            bengali_ratio = len(bengali_chars) / text_len
            english_ratio = len(english_chars) / text_len
            
            # Case 1: Mixed Scripts (Bengali + English characters)
            if bengali_ratio > 0.15 and english_ratio > 0.15:
                return 'mixed'
                
            # Case 2: Mostly Bengali Script
            if bengali_ratio > 0.3:
                return 'bn'
                
            # Case 3: Mostly English Script - Check for Banglish markers
            if english_ratio > 0.3:
                words = text.lower().split()
                
                # Check for strong English indicators
                english_word_count = sum(1 for w in words if w in self.english_stopwords)
                if english_word_count >= 2 or (len(words) > 3 and english_word_count / len(words) > 0.2):
                    return 'en'

                # Count matches from loaded dictionary + hardcoded markers for safety
                # Exclude common English words from Banglish count even if they exist in dict
                banglish_count = sum(1 for w in words if w in self.banglish_markers and w not in self.english_stopwords)
                total_words = len(words)
                
                # If significant portion matches Banglish words (and NOT English structure)
                if banglish_count >= 2 or (total_words > 0 and banglish_count/total_words > 0.3):
                    return 'mixed'
                    
                return 'en'
            
            lang = detect(text)
            return 'bn' if lang == 'bn' else 'en'
            
        except LangDetectException:
            return 'en'
    
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
        words = cleaned_text.split()
        word_count = len(words)
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
        
        # NEW: Gibberish detection features
        # Count repeated characters (like "aaaa" or "xxxx")
        repeated_char_ratio = len(re.findall(r'(.)\1{2,}', cleaned_text)) / max(char_count, 1)
        
        # Count consonant clusters without vowels (gibberish indicator)
        consonant_clusters = len(re.findall(r'[bcdfghjklmnpqrstvwxyz]{4,}', cleaned_text.lower()))
        
        # Check for meaningful words (both English and Bengali)
        # Common Bengali vowels: া, ি, ী, ু, ূ, ৃ, ে, ৈ, ো, ৌ
        bengali_vowel_count = len(re.findall(r'[\u09BE\u09BF\u09C0\u09C1\u09C2\u09C3\u09C7\u09C8\u09CB\u09CC]', cleaned_text))
        vowel_ratio = bengali_vowel_count / max(char_count, 1) if has_bengali else 0
        
        # Check space ratio (gibberish usually lacks proper spacing)
        space_count = cleaned_text.count(' ')
        space_ratio = space_count / max(char_count, 1)
        
        # Average word length (gibberish often has unusual word lengths)
        avg_word_length = sum(len(word) for word in words) / max(word_count, 1)
        
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
            'is_long': word_count > 100,
            # Gibberish detection features
            'repeated_char_ratio': repeated_char_ratio,
            'consonant_clusters': consonant_clusters,
            'vowel_ratio': vowel_ratio,
            'space_ratio': space_ratio,
            'avg_word_length': avg_word_length
        }
    
    def preprocess(self, text: str) -> Tuple[str, Dict]:
        """
        Main preprocessing function
        Returns: (cleaned_text, features_dict)
        """
        features = self.extract_features(text)
        return features['cleaned_text'], features
