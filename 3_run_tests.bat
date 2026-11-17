@echo off
set "APP=%~dp0..\cloud_quest_app"
if not exist "%APP%\pubspec.yaml" set "APP=%~dp0"
cd /d "%APP%"
echo CLOSE the 1_start_emulators window first (port 8080 must be free).
pause
if not exist evidence mkdir evidence
powershell -NoProfile -Command "firebase emulators:exec --only firestore --project demo-cloud-quest 'npm --prefix functions test' 2>&1 | Tee-Object -FilePath evidence\test_output.txt"
echo.
echo Output saved to evidence\test_output.txt  (paste it into README.md and send it to Claude)
pause
