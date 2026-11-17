@echo off
set "APP=%~dp0..\cloud_quest_app"
if not exist "%APP%\pubspec.yaml" set "APP=%~dp0"
cd /d "%APP%"
echo The emulators (1_start_emulators window) must be running.
call node functions\scripts\api_evidence.js
echo.
echo Send the text above (or evidence\api_evidence.txt) to Claude.
pause
