@echo off
cd /d "%~dp0"
set URL=https://github.com/SwamireddyA/firebase-cloud-quest.git
echo === Pushing Cloud Quest to %URL% ===
where git >nul 2>&1 || (echo Git is not installed. & pause & exit /b 1)
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
echo ===== If you see "main -> main" above, the push WORKED. =====
echo If a browser opened to sign in to GitHub, sign in, approve, and run this file again.
pause
