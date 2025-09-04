@echo off
echo Fixing Flutter Chrome Debugging Issues...
echo.

echo Step 1: Cleaning Flutter project...
flutter clean
if %errorlevel% neq 0 (
    echo Error cleaning Flutter project
    exit /b 1
)

echo.
echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Warning: Dependencies installation had issues, continuing...
)

echo.
echo Step 3: Killing existing processes...
taskkill /F /IM flutter.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
taskkill /F /IM dart.exe >nul 2>&1

echo.
echo Step 4: Clearing Flutter tools cache...
rmdir /s /q "%LOCALAPPDATA%\Temp\flutter_tools*" >nul 2>&1
rmdir /s /q "%TEMP%\flutter_tools*" >nul 2>&1

echo.
echo Step 5: Running Flutter with Windows target (avoids Chrome issues)...
echo This will open the app in a desktop window instead of Chrome
echo.
flutter run -d windows

echo.
echo If you still want to use Chrome, try:
echo flutter run -d chrome --web-renderer html --web-port 8080
echo.
pause
