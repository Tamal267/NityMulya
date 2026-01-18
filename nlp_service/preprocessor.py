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
            
            text_len = max(len(text), 1)
            bengali_ratio = len(bengali_chars) / text_len
            english_ratio = len(english_chars) / text_len
            
            # Case 1: Mixed Scripts (Bengali + English characters)
            if bengali_ratio > 0.15 and english_ratio > 0.15:
                return 'mixed'
                
            # Case 2: Mostly Bengali Script
            if bengali_ratio > 0.3:
                return 'bn'
                
            # Case 3: Mostly English Script - Check for Banglish (Bengali words in Latin script)
            if english_ratio > 0.3:
                # Common Banglish words/suffixes (Expanded list for Complaint System)
                banglish_markers = {
                    # Pronouns & People
                    'ami', 'amra', 'apni', 'apnara', 'tumi', 'tomra', 'tui', 'tora',
                    'amar', 'amader', 'apnar', 'apnader', 'tomar', 'tomader',
                    'bhai', 'bai', 'bro', 'vai', 'vaia', 'bhaia', 'sir', 'madam', 'mam', 'maam',
                    'customer', 'cust', 'seller', 'shopkeeper', 'dokan', 'dokandar',
                    'rider', 'deliveryman', 'man', 'lok', 'user', 'admin',

                    # Questions
                    'ki', 'key', 'keno', 'kno', 'kn', 'kobe', 'kbe', 'koi', 'kothay', 'kothai',
                    'kamne', 'kemon', 'kmn', 'koto', 'kto', 'koyta', 'koita', 'kon', 'konti',
                    'kivabe', 'kemne', 'karon',

                    # Verbs (Doing/Action)
                    'chai', 'cai', 'lagbe', 'den', 'din', 'diben', 'disen', 'diyeche', 'dice',
                    'dilam', 'nilam', 'nibo', 'nicchi', 'nebo', 'nite',
                    'kinechi', 'kinsi', 'kinbo', 'kinte', 'kena',
                    'ashe', 'asheni', 'aseni', 'ashbe', 'asbe', 'asche', 'ashse',
                    'gelo', 'geche', 'gese', 'jacche', 'jacce', 'jabo', 'jete',
                    'pacchi', 'pacci', 'paini', 'payni', 'pabo', 'peyechi', 'peyecho', 'paichi', 'paisi',
                    'dekhen', 'dekhun', 'dekho', 'dekhbo', 'dekhlam', 'dekha',
                    'koren', 'korun', 'koro', 'korbo', 'korben', 'korchi', 'korsi', 'koreche', 'korse',
                    'hobe', 'hbe', 'hoyeche', 'hoyese', 'hoyni', 'hoini', 'hoy', 'hoye',
                    'thakbe', 'thake', 'thako', 'thakun',
                    'bollen', 'bolchen', 'bolse', 'bolsi', 'bollam', 'bolo', 'bola',
                    'shunen', 'shunchen', 'shunse', 'shunsi', 'shunlam',
                    'janen', 'janan', 'janabo', 'janaben', 'jani', 'janai',
                    'pathan', 'pathabo', 'pathiye', 'pathaise', 'pathaisi',
                    'order', 'ordr', 'deleyvary', 'delivary', 'delivery', 'receive', 'return', 'cancel',
                    'refund', 'replace', 'exchange', 'change', 'fix', 'solved', 'solve',
                    'thokalen', 'thoksen', 'thoks', ' ঠoklam',

                    # Adjectives (Quality/Status)
                    'valo', 'bhalo', 'vl', 'bhala', 'good', 'best', 'fatafati', 'joss',
                    'kharap', 'khrap', 'baje', 'fakibaji', 'worst', 'bad', 'faltu', 'bogus',
                    'nosto', 'nosto', 'noshto', 'damage', 'vanga', 'bhanga', 'fata', 'chehra',
                    'pocha', 'pacha', 'rotten', 'shukna', 'shukno', 'bheja', 'veja',
                    'purono', 'puran', 'old', 'notun', 'new', 'fresh', 'taja',
                    'gorom', 'hot', 'thanda', 'cold', 'warm',
                    'onek', 'onk', 'beshi', 'bashi', 'kom', 'less', 'more',
                    'choto', 'small', 'boro', 'big', 'large', 'medium',
                    'heavy', 'halka', 'light', 'weight',
                    'missing', 'nai', 'nei', 'short', 'wrong', 'vul', 'bhul',
                    'fake', 'nokol', 'duplicate', 'copy', 'original', 'authentic', 'real',
                    'same', 'different', 'onnorkom', 'vinno',
                    'slow', 'fast', 'druto', 'taratari', 'late', 'deri',

                    # Nouns (Objects/Concepts)
                    'product', 'prodacat', 'prduct', 'item', 'jinish', 'mal', 'ponno',
                    'packet', 'pket', 'box', 'bag', 'bosta', 'polithin', 'wrap', 'packing',
                    'color', 'colour', 'rong', 'size', 'map', 'ojon', 'weight',
                    'kg', 'gm', 'gram', 'liter', 'ltr', 'pc', 'pcs', 'piece', 'pis',
                    'taka', 'tk', 'price', 'dam', 'rate', 'mullo', 'cost', 'charge', 'fee',
                    'bill', 'cash', 'money', 'payment', 'pay', 'due', 'baki', 'advance',
                    'bikash', 'bkash', 'nagad', 'rocket', 'card', 'bank',
                    'offer', 'discount', 'sar', 'coupon', 'voucher', 'gift',
                    'app', 'ap', 'website', 'site', 'link',
                    'msg', 'message', 'sms', 'call', 'kol', 'phone', 'phon', 'number', 'num',
                    'pic', 'picture', 'chobi', 'photo', 'video', 'ss', 'screenshot',
                    'review', 'rating', 'star',
                    'stock', 'available', 'out',

                    # Food Specific (Common in complaints)
                    'alu', 'potato', 'peyaj', 'onion', 'rosun', 'garlic', 'ada', 'ginger',
                    'mach', 'fish', 'mangsho', 'meat', 'chicken', 'beef', 'mutton',
                    'chal', 'rice', 'dal', 'oil', 'tel', 'lobon', 'salt', 'chini', 'sugar',
                    'sabji', 'shobji', 'vegetable', 'fruit', 'fol',
                    'biskut', 'biscuit', 'cake', 'ruti', 'bread', 'milk', 'dudh',
                    'dim', 'egg', 'pani', 'water',

                    # Expressions & Issues
                    'problem', 'prob', 'prblm', 'somossa', 'shomossha', 'issue', 'hamela', 'jamela', 'jhamela',
                    'complain', 'complaint', 'avijog', 'ovijog',
                    'cheat', 'cheater', 'fake', 'fraud', 'butpar', 'batpar', 'chater',
                    'chor', 'churi', 'dakat', 'm মিথ্যা', 'mittha', 'lie', 'liar',
                    'kotha', 'ktha', 'promise', 'commitment',
                    'service', 'sarvice', 'bebohar', 'bavor', 'behavior', 'rude', 'behay',
                    'rag', 'angry', 'mood', 'okhushi', 'h হতাশ', 'hotash', 'disappointed',
                    'thank', 'thanks', 'dhonnobad', 'tnx', 'plz', 'pls', 'please', 'doya',

                    # Connectors/Modifiers
                    'ar', 'er', 'r', 'o', 'and', 'but', 'kintu', 'tobu', 'tobe',
                    'na', 'nai', 'nei', 'ni', 'noy',
                    'h', 'ho', 'hae', 'ha', 'ji', 'hmm', 'ok', 'thik', 'thk', 'accha', 'acha',
                    'ta', 'ti', 'tar', 'ai', 'ei', 'oi', 'eta', 'oita', 'seta',
                    'j', 'je', 'ja', 'jar', 'jara',
                    'tay', 'tai', 'jobno', 'jnno', 'jonno',
                    'theke', 'thaka', 'theka', 'thike',
                    'diye', 'dia', 'diya',
                    'kore', 'kora', 'koira',
                    'moto', 'mot', 'mt',
                    'khub', 'kub', 'kkhub', 'onek', 'onk',
                    'ekhon', 'ekhn', 'akhon', 'tokhon', 'tkhn',
                    'aj', 'ajke', 'aik', 'kal', 'kalke', 'agamikal', 'grotokal',
                    'sokale', 'bikale', 'rate', 'dupura',
                    'ghonta', 'min', 'minute', 'din', 'mash', 'bochor', 'shopta',
                    'bar', 'bar', 'time', 'somoy', 'shomoy'
                }
                
                words = text.lower().split()
                banglish_count = sum(1 for w in words if w in banglish_markers)
                
                # If we find Banglish markers, classify as mixed
                if banglish_count >= 1:
                    return 'mixed'
                    
                return 'en'
            
            # Fallback
            lang = detect(text)
            return 'bn' if lang == 'bn' else 'en'
            
        except LangDetectException:
            # Fallback for errors or empty/symbol-only text
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
