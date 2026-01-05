#!/bin/bash

# NLP Service Startup Script
# Starts the FastAPI NLP service with BanglaBERT

echo "🚀 Starting NLP Service..."
echo "================================"

cd "$(dirname "$0")"

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found!"
    echo "Please create one first:"
    echo "  python3 -m venv venv"
    echo "  source venv/bin/activate"
    echo "  pip install -r requirements.txt"
    exit 1
fi

# Activate venv
source venv/bin/activate

# Check if dependencies are installed
python -c "import transformers" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "📦 Installing dependencies..."
    pip install -r requirements.txt
fi

# Set environment variables
export SERVICE_PORT=8001
export SERVICE_HOST=0.0.0.0
export MODEL_NAME="sagorsarker/bangla-bert-base"
export API_KEY="your-secret-api-key"
export LOG_LEVEL="INFO"

echo ""
echo "📊 Configuration:"
echo "  Port: $SERVICE_PORT"
echo "  Host: $SERVICE_HOST"
echo "  Model: $MODEL_NAME"
echo ""

# Start service
echo "🎯 Starting service..."
python main.py

# Deactivate on exit
deactivate
