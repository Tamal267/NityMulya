"""
FastAPI Application for NLP Service
AI-Enhanced Complaint Management System
"""

from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import uvicorn
from datetime import datetime

from config import config
from preprocessor import TextPreprocessor
from classifier import ComplaintClassifier

# Initialize FastAPI app
app = FastAPI(
    title="NLP Service - Complaint Management",
    description="AI-Enhanced Complaint Analysis using BanglaBERT",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your backend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize NLP components
preprocessor = TextPreprocessor()
classifier = ComplaintClassifier()

# Pydantic models
class ComplaintRequest(BaseModel):
    complaint_text: str = Field(..., min_length=5, description="Complaint description in Bengali/English/Banglish")
    customer_name: Optional[str] = None
    shop_name: Optional[str] = None
    product_name: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "complaint_text": "আমি গতকাল এই দোকান থেকে একটি মেয়াদোত্তীর্ণ পণ্য কিনেছি। এটি খাওয়ার পর আমার স্বাস্থ্য সমস্যা হয়েছে।",
                "customer_name": "রহিম আহমেদ",
                "shop_name": "করিম স্টোর",
                "product_name": "বিস্কুট"
            }
        }

class ComplaintResponse(BaseModel):
    success: bool
    analysis: Dict[str, Any]
    processed_at: str
    processing_time_ms: float

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    timestamp: str

# Security dependency
async def verify_api_key(x_api_key: str = Header(None)):
    """Verify API key for authentication"""
    if x_api_key != config.API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return x_api_key

# API Endpoints
@app.get("/", response_model=HealthResponse)
async def root():
    """Health check endpoint"""
    return HealthResponse(
        status="running",
        model_loaded=True,
        timestamp=datetime.now().isoformat()
    )

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Detailed health check"""
    return HealthResponse(
        status="healthy",
        model_loaded=classifier.base_model is not None,
        timestamp=datetime.now().isoformat()
    )

@app.post("/api/analyze-complaint", response_model=ComplaintResponse)
async def analyze_complaint(
    request: ComplaintRequest,
    api_key: str = Depends(verify_api_key)
):
    """
    Analyze complaint text and return:
    - Validity detection (is it a real complaint or spam?)
    - Priority classification (Urgent/High/Medium/Low)
    - Sentiment analysis (Positive/Negative/Neutral)
    - Category detection
    - AI-generated summary
    """
    try:
        start_time = datetime.now()
        
        # Step 1: Preprocess text
        cleaned_text, features = preprocessor.preprocess(request.complaint_text)
        
        # Step 2: Run AI analysis
        analysis_result = classifier.analyze_complaint(cleaned_text, features)
        
        # Step 3: Add additional context
        analysis_result['original_text'] = request.complaint_text
        analysis_result['cleaned_text'] = cleaned_text
        
        # Add customer/shop context if provided
        if request.customer_name:
            analysis_result['customer_name'] = request.customer_name
        if request.shop_name:
            analysis_result['shop_name'] = request.shop_name
        if request.product_name:
            analysis_result['product_name'] = request.product_name
        
        # Calculate processing time
        processing_time = (datetime.now() - start_time).total_seconds() * 1000
        
        return ComplaintResponse(
            success=True,
            analysis=analysis_result,
            processed_at=datetime.now().isoformat(),
            processing_time_ms=round(processing_time, 2)
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error analyzing complaint: {str(e)}"
        )

@app.post("/api/batch-analyze")
async def batch_analyze_complaints(
    complaints: list[ComplaintRequest],
    api_key: str = Depends(verify_api_key)
):
    """
    Batch analyze multiple complaints
    Useful for processing existing complaints
    """
    try:
        results = []
        start_time = datetime.now()
        
        for complaint in complaints:
            cleaned_text, features = preprocessor.preprocess(complaint.complaint_text)
            analysis = classifier.analyze_complaint(cleaned_text, features)
            analysis['original_text'] = complaint.complaint_text
            results.append(analysis)
        
        processing_time = (datetime.now() - start_time).total_seconds() * 1000
        
        return {
            "success": True,
            "total_complaints": len(complaints),
            "results": results,
            "processing_time_ms": round(processing_time, 2)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error in batch processing: {str(e)}"
        )

@app.get("/api/model-info")
async def get_model_info(api_key: str = Depends(verify_api_key)):
    """Get information about the loaded model"""
    return {
        "model_name": config.BANGLA_BERT_MODEL,
        "max_length": config.MAX_LENGTH,
        "device": str(classifier.device),
        "validity_threshold": config.VALIDITY_THRESHOLD,
        "high_priority_threshold": config.HIGH_PRIORITY_THRESHOLD,
        "urgent_priority_threshold": config.URGENT_PRIORITY_THRESHOLD,
        "supported_languages": ["Bengali (বাংলা)", "English", "Banglish (Mixed)"]
    }

@app.post("/api/test-preprocessing")
async def test_preprocessing(
    text: str,
    api_key: str = Depends(verify_api_key)
):
    """Test text preprocessing"""
    cleaned_text, features = preprocessor.preprocess(text)
    return {
        "original_text": text,
        "cleaned_text": cleaned_text,
        "features": features
    }

# Run server
if __name__ == "__main__":
    print(f"🚀 Starting NLP Service on {config.SERVICE_HOST}:{config.SERVICE_PORT}")
    print(f"📊 Model: {config.BANGLA_BERT_MODEL}")
    print(f"🔑 API Key authentication enabled")
    
    uvicorn.run(
        "main:app",
        host=config.SERVICE_HOST,
        port=config.SERVICE_PORT,
        reload=True,
        log_level=config.LOG_LEVEL.lower()
    )
