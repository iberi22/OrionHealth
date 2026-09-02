# OrionHealth Flutter Web PWA Deployment

This directory contains configuration files for deploying the OrionHealth Flutter Web Progressive Web App (PWA) to Cloudflare Pages.

## Configuration

- `wrangler.toml`: Cloudflare Pages deployment configuration targeting `build/web`.

## Build & Deploy Commands

```bash
# Build Flutter Web PWA
flutter build web --release -t lib/main_web.dart --no-tree-shake-icons

# Deploy to Cloudflare Pages
npx wrangler pages deploy build/web --project-name=app-orionhealth --branch=main
```

## Live Application
- URL: https://app-orionhealth.pages.dev
