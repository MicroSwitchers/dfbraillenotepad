@echo off
echo ========================================
echo Braille Notepad - GitHub Setup Helper
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo Step 1: Configure Git
echo.
set /p GIT_NAME="Enter your name (for git commits): "
set /p GIT_EMAIL="Enter your email: "

git config user.name "%GIT_NAME%"
git config user.email "%GIT_EMAIL%"

echo.
echo Git configured successfully!
echo.

echo Step 2: Add files to git
git add .
echo Files added to staging area
echo.

echo Step 3: Create initial commit
git commit -m "Initial commit - Braille Notepad v1.0.0"
echo.

echo Step 4: Set up GitHub remote
echo.
echo Please create a repository on GitHub first:
echo 1. Go to https://github.com/new
echo 2. Create a repository named: braille-notepad
echo 3. Do NOT initialize with README
echo.
set /p GITHUB_USERNAME="Enter your GitHub username: "
set /p REPO_NAME="Enter repository name (default: braille-notepad): "

if "%REPO_NAME%"=="" set REPO_NAME=braille-notepad

git remote add origin https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git
echo Remote added successfully!
echo.

echo Step 5: Push to GitHub
echo.
echo About to push to: https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
echo You may be prompted for your GitHub password/token
echo.
pause

git branch -M main
git push -u origin main

echo.
echo ========================================
echo SUCCESS! Your code is now on GitHub!
echo ========================================
echo.
echo Next steps:
echo 1. Go to https://github.com/%GITHUB_USERNAME%/%REPO_NAME%/settings/pages
echo 2. Under "Build and deployment" set Source to: "GitHub Actions"
echo 3. Wait for deployment (check Actions tab)
echo 4. Your app will be live at:
echo    https://%GITHUB_USERNAME%.github.io/%REPO_NAME%/
echo.
echo For detailed instructions, see GITHUB_DEPLOYMENT.md
echo.
pause
