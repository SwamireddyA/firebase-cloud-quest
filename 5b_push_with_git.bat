@echo off
cd /d "%~dp0"
echo === Push Cloud Quest using plain git ===
echo First create an EMPTY repo at https://github.com/new  (name: firebase-cloud-quest, Public, do NOT add a README).
echo.
set /p URL=Paste the repo URL here (https://github.com/YOURNAME/firebase-cloud-quest.git) and press Enter: 
where git >nul 2>&1 || (echo Git is not installed. Install from https://git-scm.com & pause & exit /b 1)
if not exist .git git init -b main
findstr /x /c:"functions/.env" .gitignore >nul 2>&1 || echo functions/.env>>.gitignore
git rm --cached functions/.env >nul 2>&1
git add -A
git reset -q functions/.env 2>nul
git commit -m "Firebase Cloud Quest: Flutter + Auth + Firestore + callable reward + supervised AI coach"
git branch -M main
git remote remove origin >nul 2>&1
git remote add origin %URL%
git push -u origin main
echo.
echo If a browser window asks you to sign in to GitHub, sign in and approve. Then rerun if needed.
pause
