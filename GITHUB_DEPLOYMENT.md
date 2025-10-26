# GitHub Pages Deployment Guide

## Quick Setup (5 Minutes)

Follow these steps to deploy your Braille Notepad to GitHub Pages:

---

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and log in
2. Click the **"+"** icon in top right → **"New repository"**
3. Fill in:
   - **Repository name**: `braille-notepad` (or your preferred name)
   - **Description**: "A professional Braille notepad app with fdsjkl key input mapping"
   - **Visibility**: Public (required for free GitHub Pages)
   - **DO NOT** initialize with README (we already have files)
4. Click **"Create repository"**

---

## Step 2: Push Your Code to GitHub

I've already initialized git for you. Now run these commands:

```bash
cd "d:\My Code\DartFlutter\Braille Notepad"

# Configure git (replace with your info)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add all files
git add .

# Create first commit
git commit -m "Initial commit - Braille Notepad v1.0.0"

# Add your GitHub repository as remote (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/braille-notepad.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Important**: Replace `YOUR_USERNAME` with your GitHub username!

---

## Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **"Settings"** tab
3. Click **"Pages"** in the left sidebar
4. Under **"Build and deployment"**:
   - **Source**: Select "GitHub Actions"
5. That's it! The workflow will run automatically

---

## Step 4: Wait for Deployment

1. Go to the **"Actions"** tab in your repository
2. You should see a workflow running called "Deploy to GitHub Pages"
3. Wait for it to complete (usually 2-3 minutes)
4. Once complete, your app will be live!

---

## Step 5: Access Your App

Your app will be available at:
```
https://YOUR_USERNAME.github.io/braille-notepad/
```

Replace `YOUR_USERNAME` with your actual GitHub username.

---

## How It Works

The GitHub Actions workflow ([.github/workflows/deploy.yml](.github/workflows/deploy.yml)) automatically:

1. ✅ Checks out your code
2. ✅ Sets up Flutter
3. ✅ Installs dependencies
4. ✅ Runs all tests
5. ✅ Builds the web app
6. ✅ Deploys to GitHub Pages

**Every time you push to the `main` branch, it will automatically redeploy!**

---

## Customizing the Base URL

If your repository name is different from `braille-notepad`, update the base-href in [.github/workflows/deploy.yml](.github/workflows/deploy.yml):

```yaml
# Line 33
run: flutter build web --release --base-href /YOUR-REPO-NAME/
```

---

## Troubleshooting

### "remote: Permission denied" when pushing

You need to authenticate with GitHub. Options:

**Option A: Personal Access Token**
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic) with `repo` scope
3. Use token as password when pushing

**Option B: SSH Key**
1. Generate SSH key: `ssh-keygen -t ed25519 -C "your.email@example.com"`
2. Add to GitHub: Settings → SSH and GPG keys
3. Use SSH URL: `git@github.com:YOUR_USERNAME/braille-notepad.git`

### GitHub Actions workflow fails

1. Check the Actions tab for error details
2. Common issues:
   - Tests failing: Run `flutter test` locally first
   - Build errors: Run `flutter build web` locally first
   - Permissions: Ensure Pages permissions are enabled

### Page shows 404

1. Make sure GitHub Pages is enabled in Settings → Pages
2. Check the correct URL (includes repository name)
3. Wait a few minutes after first deployment
4. Hard refresh browser (Ctrl+Shift+R)

---

## Alternative: Manual Deployment (Without GitHub Actions)

If you prefer to build locally and deploy manually:

### Step 1: Build locally
```bash
cd "d:\My Code\DartFlutter\Braille Notepad"
flutter build web --release --base-href /braille-notepad/
```

### Step 2: Create gh-pages branch
```bash
# Create orphan branch
git checkout --orphan gh-pages

# Remove all files
git rm -rf .

# Copy web build
cp -r build/web/* .

# Add and commit
git add .
git commit -m "Deploy web build"

# Push to GitHub
git push origin gh-pages

# Return to main branch
git checkout main
```

### Step 3: Configure GitHub Pages
- Go to Settings → Pages
- Set source to: **Deploy from a branch**
- Select branch: **gh-pages**
- Select folder: **/ (root)**

---

## Updating Your Deployed App

After making changes:

```bash
# Make your code changes
# Test them: flutter test
# Commit changes
git add .
git commit -m "Description of changes"

# Push to GitHub
git push origin main
```

The GitHub Actions workflow will automatically rebuild and redeploy!

---

## Using a Custom Domain (Optional)

1. Buy a domain (e.g., braillenotepad.com)
2. In your repository, go to Settings → Pages
3. Under "Custom domain", enter your domain
4. Create a `CNAME` file in your repository root with your domain
5. Configure DNS with your domain provider:
   - Add CNAME record pointing to `YOUR_USERNAME.github.io`

---

## Files Created for GitHub Deployment

- ✅ `.git/` - Git repository initialized
- ✅ `.gitignore` - Already exists (Flutter defaults)
- ✅ `.github/workflows/deploy.yml` - Automatic deployment workflow
- ✅ This guide - Step-by-step instructions

---

## What Gets Deployed

Only these files are deployed to GitHub Pages:
- HTML, CSS, JavaScript (from build/web)
- Assets (icons, fonts)
- Manifest files for PWA

**Source code is separate** and stored in your repository.

---

## Security Notes

- ✅ No secrets or API keys in code
- ✅ All code is public (public repository)
- ✅ No backend or database (static site)
- ✅ Safe to share repository URL

---

## Next Steps After Deployment

1. Share your app URL with users
2. Add a custom domain (optional)
3. Monitor GitHub Actions for successful builds
4. Update your README.md with the live URL
5. Consider adding a badge: [![Deploy](https://github.com/YOUR_USERNAME/braille-notepad/actions/workflows/deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/braille-notepad/actions/workflows/deploy.yml)

---

## Quick Reference Commands

```bash
# Check git status
git status

# See commit history
git log --oneline

# View remote repositories
git remote -v

# Pull latest changes
git pull origin main

# Push changes
git add .
git commit -m "Your message"
git push origin main

# View deployed URL
echo "https://YOUR_USERNAME.github.io/braille-notepad/"
```

---

## Support

- GitHub Pages docs: https://docs.github.com/en/pages
- GitHub Actions docs: https://docs.github.com/en/actions
- Flutter web deployment: https://docs.flutter.dev/deployment/web

---

**Your app is ready to deploy! Just follow Steps 1-5 above.** 🚀

If you need help with any step, let me know!
