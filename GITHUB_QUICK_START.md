# 🚀 GitHub Pages - Quick Start Guide

## The Fastest Way to Deploy (2 Minutes!)

### Option 1: Automated Setup (Easiest!)

Just run the helper script:

```bash
cd "d:\My Code\DartFlutter\Braille Notepad"
setup-github.bat
```

This will:
1. Configure git with your name/email
2. Add all files to git
3. Create initial commit
4. Set up GitHub remote
5. Push to GitHub

Then follow the on-screen instructions!

---

### Option 2: Manual Setup

#### 1. Create GitHub Repository
- Go to https://github.com/new
- Repository name: `braille-notepad`
- Make it **Public**
- Don't initialize with README
- Click "Create repository"

#### 2. Push Your Code
```bash
cd "d:\My Code\DartFlutter\Braille Notepad"

# Configure git (one time only)
git config user.name "Your Name"
git config user.email "your@email.com"

# Add and commit
git add .
git commit -m "Initial commit - Braille Notepad v1.0.0"

# Push to GitHub (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/braille-notepad.git
git branch -M main
git push -u origin main
```

#### 3. Enable GitHub Pages
1. Go to repository Settings → Pages
2. Under "Build and deployment":
   - Source: **GitHub Actions**
3. Done! Wait 2-3 minutes for deployment

#### 4. Access Your App
Your app will be live at:
```
https://YOUR_USERNAME.github.io/braille-notepad/
```

---

## What's Already Set Up For You

✅ Git repository initialized
✅ `.gitignore` configured for Flutter
✅ GitHub Actions workflow created ([.github/workflows/deploy.yml](.github/workflows/deploy.yml))
✅ Automatic testing before deployment
✅ Automatic build and deployment on push
✅ README updated with live demo link

---

## After First Push

The GitHub Actions workflow will automatically:
1. ✅ Run `flutter test` (must pass)
2. ✅ Build web app with correct base URL
3. ✅ Deploy to GitHub Pages
4. ✅ Make your app live!

---

## Future Updates

Every time you make changes:
```bash
git add .
git commit -m "Description of changes"
git push
```

Your app automatically rebuilds and redeploys! 🎉

---

## Troubleshooting

**Q: Can't push - authentication failed?**
- Use a Personal Access Token instead of password
- Go to GitHub Settings → Developer settings → Personal access tokens
- Generate token with `repo` scope
- Use token as password when prompted

**Q: Workflow fails?**
- Check the Actions tab on GitHub for details
- Make sure tests pass locally: `flutter test`
- Check build works locally: `flutter build web`

**Q: Page shows 404?**
- Wait 5 minutes after first deployment
- Check Settings → Pages is set to "GitHub Actions"
- Verify URL includes repo name: `/braille-notepad/`

---

## Need More Details?

See [GITHUB_DEPLOYMENT.md](GITHUB_DEPLOYMENT.md) for comprehensive instructions.

---

**Ready? Run `setup-github.bat` and deploy in 2 minutes!** 🚀
