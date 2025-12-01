#!/bin/bash

echo "🚀 AI-Enhanced Complaint Management System - Quick Setup"
echo "=========================================================="
echo ""

# Step 1: Database Migration
echo "📊 Step 1/3: Database Migration"
echo "Running database migration to add AI analysis columns..."
cd Backend
bun run add_ai_analysis_columns.ts
if [ $? -eq 0 ]; then
    echo "✅ Database migration completed"
else
    echo "❌ Database migration failed"
    exit 1
fi
echo ""

# Step 2: Python NLP Service Setup
echo "🐍 Step 2/3: Python NLP Service Setup"
cd ../nlp_service

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

echo "Installing Python dependencies..."
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ Python dependencies installed"
else
    echo "❌ Python installation failed"
    exit 1
fi
echo ""

# Step 3: Environment Configuration
echo "⚙️  Step 3/3: Environment Configuration"
cd ..

# Check if .env files exist
if [ ! -f "Backend/.env" ]; then
    echo "⚠️  Backend/.env not found. Please create it with:"
    echo "   NLP_SERVICE_URL=http://localhost:8001"
    echo "   NLP_API_KEY=your-secret-api-key"
fi

if [ ! -f "nlp_service/.env" ]; then
    echo "⚠️  nlp_service/.env not found. Creating from example..."
    cp nlp_service/.env.example nlp_service/.env
    echo "✅ Created nlp_service/.env - Please update API_KEY"
fi
echo ""

# Final Instructions
echo "=========================================================="
echo "✅ Setup Complete!"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Start NLP Service (Terminal 1):"
echo "   cd nlp_service"
echo "   source venv/bin/activate"
echo "   python main.py"
echo ""
echo "2. Start Backend (Terminal 2):"
echo "   cd Backend"
echo "   bun run dev"
echo ""
echo "3. Start Flutter App (Terminal 3):"
echo "   flutter run"
echo ""
echo "📚 Documentation:"
echo "   - System Guide: AI_COMPLAINT_SYSTEM_COMPLETE.md"
echo "   - NLP Service: nlp_service/README.md"
echo "   - Training Guide: nlp_service/training/ANNOTATION_GUIDE.md"
echo ""
echo "🎓 For Thesis:"
echo "   - Collect 500-1000 labeled complaints"
echo "   - Run training: python nlp_service/training/train_priority_classifier.py"
echo "   - Evaluate metrics and document results"
echo ""
echo "Good luck! 🚀"
