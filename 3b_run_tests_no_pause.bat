@echo off
set "APP=%~dp0..\cloud_quest_app"
if not exist "%APP%\pubspec.yaml" set "APP=%~dp0"
cd /d "%APP%"
if not exist evidence mkdir evidence
call firebase emulators:exec --config firebase.test.json --only firestore --project demo-cloud-quest "npm --prefix functions test" > evidence\test_output.txt 2>&1
echo exit code %errorlevel% >> evidence\test_output.txt
exit /b 0
