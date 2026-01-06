# 🚀 Deploy CI/CD System - Automated Deployment Script

Write-Host "🚀 OrionHealth CI/CD System Deployment" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host ""

# Check if we're in the right directory
if (-Not (Test-Path ".git")) {
    Write-Host "❌ Error: Not in a git repository!" -ForegroundColor Red
    Write-Host "Please run this script from the project root." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Git repository detected" -ForegroundColor Green
Write-Host ""

# Check git status
Write-Host "📊 Checking repository status..." -ForegroundColor Cyan
$status = git status --porcelain
if ($status) {
    Write-Host "📝 Uncommitted changes detected:" -ForegroundColor Yellow
    Write-Host $status
    Write-Host ""
} else {
    Write-Host "✅ Working directory clean" -ForegroundColor Green
    Write-Host ""
}

# Show what will be deployed
Write-Host "📦 New Workflows to Deploy:" -ForegroundColor Cyan
Write-Host "  1. ✅ ci-cd-main.yml - Main CI/CD Pipeline"
Write-Host "  2. 🔄 continuous-improvement.yml - Daily Code Analysis"
Write-Host "  3. 🚀 auto-deploy.yml - Automatic Documentation Deployment"
Write-Host "  4. 📚 CICD_SYSTEM_GUIDE.md - Complete Documentation"
Write-Host ""

# Confirm deployment
$confirm = Read-Host "Do you want to deploy these workflows? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "❌ Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔨 Starting deployment..." -ForegroundColor Cyan
Write-Host ""

# Stage files
Write-Host "📝 Staging files..." -ForegroundColor Cyan
try {
    git add .github/workflows/ci-cd-main.yml
    git add .github/workflows/continuous-improvement.yml
    git add .github/workflows/auto-deploy.yml
    git add docs/CICD_SYSTEM_GUIDE.md
    git add rust/Cargo.toml  # MCP dependencies

    Write-Host "✅ Files staged" -ForegroundColor Green
} catch {
    Write-Host "❌ Error staging files: $_" -ForegroundColor Red
    exit 1
}

# Create commit
Write-Host "💾 Creating commit..." -ForegroundColor Cyan
try {
    $commitMessage = @"
feat(ci): implement complete CI/CD system with AI agent integration

- Add main CI/CD pipeline (ci-cd-main.yml)
  - Rust backend tests (format, clippy, unit tests)
  - Flutter tests (analyze, unit tests)
  - Automatic error detection and issue creation
  - Agent dispatcher integration

- Add continuous improvement workflow
  - Daily code analysis (complexity, coverage, docs)
  - Security scanning
  - Performance hotspot detection
  - Automatic improvement issue creation

- Add auto-deploy workflow
  - Automatic docs deployment to GitHub Pages
  - Failure detection and issue creation

- Add complete system documentation
  - Full guide with examples
  - Troubleshooting section
  - Agent assignment logic

- Update Cargo.toml with MCP server dependencies
  - axum 0.7
  - tower 0.4
  - tower-http 0.5
  - tokio-stream 0.1

Features:
- 🚨 Automatic error detection
- 📋 Auto-create issues when tests fail
- 🤖 Intelligent assignment to Jules/Copilot
- 🔄 Daily code improvement analysis
- 🚀 Zero-intervention deployment
- 📊 Comprehensive reporting

Related: #1 (MCP Server), #3 (Model Manager), #4 (Gemini Integration)
"@

    git commit -m $commitMessage
    Write-Host "✅ Commit created" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creating commit: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📤 Pushing to remote..." -ForegroundColor Cyan

# Get current branch
$currentBranch = git rev-parse --abbrev-ref HEAD

Write-Host "Current branch: $currentBranch" -ForegroundColor Yellow
Write-Host ""

# Push
try {
    git push origin $currentBranch
    Write-Host "✅ Changes pushed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error pushing: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Tip: Try manually:" -ForegroundColor Yellow
    Write-Host "  git push origin $currentBranch" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "=" * 60
Write-Host "✨ Deployment Complete!" -ForegroundColor Green
Write-Host ""

# Get repository info
$repoUrl = git config --get remote.origin.url
$repoUrl = $repoUrl -replace "\.git$", ""
$repoUrl = $repoUrl -replace "git@github.com:", "https://github.com/"

Write-Host "🎯 What happens next:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. CI/CD Pipeline will run automatically" -ForegroundColor White
Write-Host "   - Rust tests" -ForegroundColor Gray
Write-Host "   - Flutter tests" -ForegroundColor Gray
Write-Host ""
Write-Host "2. If tests fail:" -ForegroundColor White
Write-Host "   - Issues will be created automatically" -ForegroundColor Gray
Write-Host "   - Agent dispatcher will assign to Jules or Copilot" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Continuous Improvement will run daily at 6 AM UTC" -ForegroundColor White
Write-Host ""

Write-Host "📊 Monitor Progress:" -ForegroundColor Cyan
Write-Host "  Workflows: $repoUrl/actions" -ForegroundColor White
Write-Host "  Issues:    $repoUrl/issues?q=is%3Aissue+is%3Aopen+label%3Aci-cd" -ForegroundColor White
Write-Host "  Agents:    $repoUrl/issues?q=is%3Aissue+is%3Aopen+label%3Aai-agent" -ForegroundColor White
Write-Host ""

Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "  Full Guide: docs/CICD_SYSTEM_GUIDE.md" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Manual Triggers:" -ForegroundColor Cyan
Write-Host "  gh workflow run ci-cd-main.yml" -ForegroundColor White
Write-Host "  gh workflow run continuous-improvement.yml" -ForegroundColor White
Write-Host "  gh workflow run agent-dispatcher.yml" -ForegroundColor White
Write-Host ""

Write-Host "=" * 60
Write-Host "🎉 System is now live and monitoring your codebase!" -ForegroundColor Green
Write-Host ""
