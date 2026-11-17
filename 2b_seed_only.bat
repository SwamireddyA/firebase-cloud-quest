@echo off
cd /d "%~dp0"
echo Seeding challenges/today into the running emulator...
set FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
set GCLOUD_PROJECT=demo-cloud-quest
npm --prefix functions run seed
echo.
echo If it said "Seeded", go to the emulator and tap Retry.
pause
