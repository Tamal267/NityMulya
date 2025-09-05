@echo off
echo Starting Flutter app with CORS disabled Chrome...
echo.
echo This will start Chrome with disabled web security for testing messaging
echo.

cd /d "d:\SDP 2\NityMulya"
flutter run -d chrome --web-port=8080 --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor"
