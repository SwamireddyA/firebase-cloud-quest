@echo off
set "APP=%~dp0..\cloud_quest_app"
if not exist "%APP%\pubspec.yaml" set "APP=%~dp0"
cd /d "%APP%"
echo Leave this window OPEN while you use the app. Emulator UI: http://localhost:4000
call firebase emulators:start --only auth,firestore,functions --project demo-cloud-quest
pause
