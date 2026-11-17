@echo off
cd /d "%~dp0"
echo === Push Cloud Quest to a NEW GitHub repo ===
where git >nul 2>&1 || (echo Git is not installed. Install from https://git-scm.com then rerun. & pause & exit /b 1)
where gh >nul 2>&1 || (echo GitHub CLI missing. Install from https://cli.github.com then run: gh auth login & pause & exit /b 1)
gh auth status >nul 2>&1 || (echo Not logged in. Run: gh auth login   then rerun this file. & pause & exit /b 1)
if not exist .git git init -b main
echo functions/.env>>.gitignore
git rm --cached functions/.env >nul 2>&1
git add -A
git reset -q functions/.env 2>nul
git commit -m "Firebase Cloud Quest: Flutter + Auth + Firestore + callable reward + supervised AI coach"
gh repo create firebase-cloud-quest --public --source . --push
echo.
echo DONE. Copy the repo URL above into README.md and submit it.
pause
