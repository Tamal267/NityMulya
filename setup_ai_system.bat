@echo off
REM AI-Enhanced Complaint Management System - Quick Setup (Windows)

echo.
echo ============================================================
echo AI-Enhanced Complaint Management System - Quick Setup
echo ============================================================
echo.

REM Step 1: Database Migration
echo Step 1/3: Database Migration
echo Running database migration to add AI analysis columns...
cd Backend
call bun run add_ai_analysis_columns.ts
if %ERRORLEVEL% EQU 0 (
    echo [32mDatabase migration completed[0m
) else (
    echo [31mDatabase migration failed[0m
    exit /b 1
)
echo.

REM Step 2: Python NLP Service Setup
echo Step 2/3: Python NLP Service Setup
cd ..\nlp_service

REM Check if virtual environment exists
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing Python dependencies...
pip install -r requirements.txt

if %ERRORLEVEL% EQU 0 (
    echo [32mPython dependencies installed[0m
) else (
    echo [31mPython installation failed[0m
    exit /b 1
)
echo.

REM Step 3: Environment Configuration
echo Step 3/3: Environment Configuration
cd ..

REM Check if .env files exist
if not exist "Backend\.env" (
    echo [33mBackend\.env not found. Please create it with:[0m
    echo    NLP_SERVICE_URL=http://localhost:8001
    echo    NLP_API_KEY=your-secret-api-key
)

if not exist "nlp_service\.env" (
    echo Creating nlp_service\.env from example...
    copy nlp_service\.env.example nlp_service\.env
    echo [32mCreated nlp_service\.env - Please update API_KEY[0m
)
echo.

REM Final Instructions
echo ============================================================
echo [32mSetup Complete![0m
echo.
echo Next Steps:
echo.
echo 1. Start NLP Service (Terminal 1):
echo    cd nlp_service
echo    venv\Scripts\activate
echo    python main.py
echo.
echo 2. Start Backend (Terminal 2):
echo    cd Backend
echo    bun run dev
echo.
echo 3. Start Flutter App (Terminal 3):
echo    flutter run
echo.
echo Documentation:
echo    - System Guide: AI_COMPLAINT_SYSTEM_COMPLETE.md
echo    - NLP Service: nlp_service\README.md
echo    - Training Guide: nlp_service\training\ANNOTATION_GUIDE.md
echo.
echo For Thesis:
echo    - Collect 500-1000 labeled complaints
echo    - Run training: python nlp_service\training\train_priority_classifier.py
echo    - Evaluate metrics and document results
echo.
echo Good luck! [32m[0m
echo ============================================================

pause
