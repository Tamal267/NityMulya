"""
Configuration for NLP Service
AI-Enhanced Complaint Management System
"""

import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Service Configuration
    SERVICE_PORT = int(os.getenv("SERVICE_PORT", 8001))
    SERVICE_HOST = os.getenv("SERVICE_HOST", "0.0.0.0")
    
    # Model Configuration
    BANGLA_BERT_MODEL = os.getenv("MODEL_NAME", "sagorsarker/bangla-bert-base")
    MAX_LENGTH = int(os.getenv("MAX_LENGTH", 512))
    BATCH_SIZE = int(os.getenv("BATCH_SIZE", 8))
    
    # Classification Thresholds
    VALIDITY_THRESHOLD = 0.6  # Minimum score to consider complaint valid
    HIGH_PRIORITY_THRESHOLD = 0.7
    URGENT_PRIORITY_THRESHOLD = 0.85
    
    # Database
    DATABASE_URL = os.getenv("DATABASE_URL", "")
    
    # Security
    API_KEY = os.getenv("API_KEY", "your-secret-api-key")
    
    # Logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    
    # Priority Keywords (for rule-based enhancement)
    PRIORITY_KEYWORDS = {
        "urgent": ["জরুরি", "urgent", "জলদি", "তাড়াতাড়ি", "immediately", "এখনই"],
        "high": [
            "স্বাস্থ্য", "health", "বিষক্রিয়া", "poison", "মেয়াদ উত্তীর্ণ", "expired",
            "খাদ্য", "food", "ওষুধ", "medicine", "শিশু", "child", "বাচ্চা"
        ],
        "medium": [
            "দাম", "price", "মূল্য", "টাকা", "ওজন", "weight", "পরিমাণ", "quantity",
            "মান", "quality"
        ]
    }
    
    # Validity Keywords (spam detection)
    SPAM_KEYWORDS = [
        "পুরস্কার", "prize", "win", "free", "ফ্রি", "লটারি", "lottery",
        "click here", "এখানে ক্লিক", "offer", "অফার"
    ]
    
    # Category Keywords
    CATEGORY_KEYWORDS = {
        "মূল্য সংক্রান্ত": ["দাম", "price", "মূল্য", "টাকা", "expensive", "costly"],
        "গুণগত মান": ["মান", "quality", "খারাপ", "bad", "নষ্ট", "damaged"],
        "ওজন/পরিমাণ": ["ওজন", "weight", "কম", "less", "পরিমাণ", "quantity"],
        "মেয়াদোত্তীর্ণ": ["মেয়াদ", "expired", "expire", "তারিখ", "date"],
        "স্বাস্থ্য সমস্যা": ["স্বাস্থ্য", "health", "অসুস্থ", "sick", "বিষক্রিয়া", "poison"],
        "প্যাকেজিং": ["প্যাকেট", "packet", "packaging", "বক্স", "box", "seal"],
        "পরিষেবা": ["service", "পরিষেবা", "ব্যবহার", "আচরণ", "behavior"],
        "প্রতারণা": ["প্রতারণা", "fraud", "ঠকানো", "cheat", "জাল", "fake"]
    }

config = Config()
