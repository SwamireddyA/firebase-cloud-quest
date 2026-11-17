@echo off
set "APP=%~dp0..\cloud_quest_app"
if not exist "%APP%\pubspec.yaml" set "APP=%~dp0"
cd /d "%APP%"
echo Start your Android emulator first, and keep the emulator window (1_start_emulators) open.
call npm --prefix functions run seed
if errorlevel 1 (echo Seeding failed. Is 1_start_emulators.bat still running? & pause & exit /b 1)
call flutter devices
call flutter run
pause
