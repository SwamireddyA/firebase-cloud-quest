@echo off
setlocal
set "SRC=%~dp0"
set "DEST=%SRC%..\cloud_quest_app"
echo === Cloud Quest setup (run once) ===
where flutter >nul 2>nul
if errorlevel 1 (echo Flutter not found in PATH. & pause & exit /b 1)
where node >nul 2>nul
if errorlevel 1 (echo Node.js not found in PATH. & pause & exit /b 1)
where firebase >nul 2>nul
if errorlevel 1 (echo Firebase CLI not found. Run: npm install -g firebase-tools & pause & exit /b 1)
if exist "%DEST%" (echo cloud_quest_app already exists next to this folder. Delete or rename it, then run again. & pause & exit /b 1)

pushd "%SRC%.."
call flutter create cloud_quest_app --project-name cloud_quest
if errorlevel 1 goto :err
popd

xcopy "%SRC%*" "%DEST%\" /E /Y /I /Q /H
if errorlevel 1 goto :err
if exist "%DEST%\test\widget_test.dart" del "%DEST%\test\widget_test.dart"

pushd "%DEST%"
call flutter pub add firebase_core firebase_auth cloud_firestore cloud_functions
if errorlevel 1 goto :err
pushd functions
call npm install
if errorlevel 1 goto :err
popd
copy /Y "functions\.env.example" "functions\.env" >nul
powershell -NoProfile -Command "(Get-Content 'functions\.env') -replace 'COACH_MOCK=false','COACH_MOCK=true' | Set-Content 'functions\.env'"
popd

echo.
echo === SETUP DONE. Project is in: %DEST% ===
echo Coach is in MOCK mode for now (no key needed). For your final screenshots, put a free Gemini key in functions\.env and set COACH_MOCK=false.
echo NEXT: open the cloud_quest_app folder and double-click 1_start_emulators.bat
pause
exit /b 0

:err
echo.
echo *** A step failed. Copy the red/error text above and send it to Claude. ***
pause
exit /b 1
