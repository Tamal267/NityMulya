#!/bin/bash

echo "🚀 Setting up AI-Enhanced Complaint System"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed. Please install Python 3.8+${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python found: $(python3 --version)${NC}"

# Step 1: Check for python3-venv
echo ""
echo "🔍 Checking for python3-venv..."
if ! dpkg -l | grep -q python3.*-venv; then
    echo -e "${YELLOW}⚠️  python3-venv not found. Installing...${NC}"
    sudo apt install -y python3.12-venv
fi

# Step 2: Install NLP service dependencies
echo ""
echo "📦 Installing NLP service dependencies..."

if [ ! -d "nlp_service" ]; then
    echo -e "${RED}❌ nlp_service directory not found${NC}"
    exit 1
fi

cd nlp_service

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to create virtual environment${NC}"
        echo "Please run: sudo apt install python3.12-venv"
        cd ..
        exit 1
    fi
    echo -e "${GREEN}✅ Virtual environment created${NC}"
fi

echo "Activating virtual environment..."
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to activate virtual environment${NC}"
        cd ..
        exit 1
    fi
else
    echo -e "${RED}❌ venv/bin/activate not found${NC}"
    cd ..
    exit 1
fi

echo "Installing packages..."
pip install -q -r requirements.txt

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ NLP dependencies installed${NC}"
else
    echo -e "${RED}❌ Failed to install NLP dependencies${NC}"
    deactivate
    exit 1
fi

deactivate
cd ..

# Step 2: Setup database
echo ""
echo "🗄️  Setting up database..."
cd Backend

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Creating .env file...${NC}"
    cat > .env << EOF
# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/nitymulya

# NLP Service Configuration
NLP_SERVICE_URL=http://localhost:8000
NLP_API_KEY=your-secret-api-key-change-in-production

# JWT Configuration
JWT_SECRET=your-jwt-secret-change-in-production
EOF
    echo -e "${YELLOW}⚠️  Please update .env with your actual database credentials${NC}"
fi

# Run database migration
echo "Running database migrations..."
if command -v bun &> /dev/null; then
    bun run add_ai_analysis_columns.ts
    echo -e "${GREEN}✅ Database migrations completed${NC}"
else
    echo -e "${YELLOW}⚠️  Bun not found. Please run 'bun run add_ai_analysis_columns.ts' manually${NC}"
fi

cd ..

# Step 3: Create startup scripts
echo ""
echo "📝 Creating startup scripts..."

# Create NLP service startup script
cat > start_nlp_service.sh << 'EOF'
#!/bin/bash
echo "🤖 Starting NLP Service..."
cd nlp_service
source venv/bin/activate
python main.py
EOF
chmod +x start_nlp_service.sh

# Create backend startup script
cat > start_backend.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Backend Server..."
cd Backend
bun run dev
EOF
chmod +x start_backend.sh

# Create Flutter startup script
cat > start_flutter.sh << 'EOF'
#!/bin/bash
echo "📱 Starting Flutter App..."
flutter run -d chrome
EOF
chmod +x start_flutter.sh

# Create start all script
cat > start_all.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting all services..."
echo "=========================================="

# Start NLP service in background
echo "Starting NLP Service..."
./start_nlp_service.sh &
NLP_PID=$!
sleep 5

# Start Backend in background
echo "Starting Backend..."
./start_backend.sh &
BACKEND_PID=$!
sleep 3

# Start Flutter
echo "Starting Flutter App..."
./start_flutter.sh

# Cleanup function
cleanup() {
    echo ""
    echo "Stopping all services..."
    kill $NLP_PID $BACKEND_PID 2>/dev/null
    exit 0
}

trap cleanup INT TERM

wait
EOF
chmod +x start_all.sh

echo -e "${GREEN}✅ Startup scripts created${NC}"

# Summary
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update Backend/.env with your database credentials"
echo "2. Start services:"
echo ""
echo "   Option A - Start all at once:"
echo "   $ ./start_all.sh"
echo ""
echo "   Option B - Start individually:"
echo "   Terminal 1: $ ./start_nlp_service.sh"
echo "   Terminal 2: $ ./start_backend.sh"
echo "   Terminal 3: $ ./start_flutter.sh"
echo ""
echo "Services will run on:"
echo "  - NLP Service: http://localhost:8000"
echo "  - Backend API: http://localhost:3000"
echo "  - Flutter App: http://localhost:***"
echo ""
echo "Test NLP service:"
echo "  $ curl http://localhost:8000/health"
echo ""
echo "=========================================="
