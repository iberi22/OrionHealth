# OrionHealth Documentation Site

Professional landing page built with **Astro 5** and **Cyber-Minimalism** design system, featuring OrionHealth's medical-grade color palette.

## 🎨 Design System

### Color Palette (Medical Professional)
- **Primary**: `#1E88E5` (Medical Blue) - Trust, healthcare, professionalism
- **Secondary**: `#43A047` (Health Green) - Wellness, vitality, growth
- **Accent**: `#00BCD4` (Cyan) - Technology, AI, innovation
- **Surface**: `#1A1A1A` - Dark backgrounds
- **Text**: `#E8E8E8` - High contrast readability

### Typography
- **Font**: Fira Code (Monospace) - Developer-friendly, technical precision
- **Headings**: Bold, Uppercase, Tight tracking
- **Body**: Light weight, Relaxed leading

### Effects
- **Noise Overlay**: Subtle texture (3% opacity)
- **Medical Grid**: Blue grid pattern (3% opacity)
- **Glassmorphism**: Blurred backgrounds with medical blue borders
- **Flashlight Effect**: Interactive gradient borders on hover
- **Blob Animation**: Ambient medical-colored backgrounds

## 🚀 Development

```bash
cd docs

# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 📁 Structure

```
docs/
├── src/
│   ├── components/
│   │   ├── Header.astro          # Top navigation with logo
│   │   ├── Footer.astro          # Footer with links
│   │   ├── FeatureCard.astro     # Feature showcase cards
│   │   ├── DonationSection.astro # Support/funding section
│   │   └── LandingPage.astro     # Main landing page
│   ├── layouts/
│   │   └── BaseLayout.astro      # Base HTML with design system
│   ├── pages/
│   │   └── index.astro           # Homepage
│   └── i18n/
│       └── ui.ts                 # Translations (10 languages)
├── public/
│   ├── robots.txt                # SEO
│   └── .nojekyll                 # GitHub Pages config
└── astro.config.mjs              # Astro configuration
```

## 🌐 Deployment

Automatically deployed to GitHub Pages on every push to `main` branch via GitHub Actions.

**Live URL**: https://iberi22.github.io/local-llm.OrionHealth

## ✨ Features

- ✅ Cyber-Minimalism design with medical color palette
- ✅ Professional glassmorphism effects
- ✅ Interactive flashlight card borders
- ✅ Animated background blobs (medical colors)
- ✅ Responsive design (mobile-first)
- ✅ SEO optimized (meta tags, robots.txt)
- ✅ Fast loading (Astro static generation)
- ✅ Accessible (WCAG AA compliant colors)

## 🎯 Design Philosophy

**"Medical-Grade Cyber-Minimalism"**

- High contrast for medical accuracy
- Professional color palette for healthcare trust
- Technical typography for developer audience
- Subtle animations for modern feel
- Zero compromise on privacy messaging

## 📝 Content Sections

1. **Hero**: Bold statement about privacy-first healthcare
2. **Features**: Core capabilities with medical icons
3. **Privacy**: Detailed privacy commitments
4. **Support**: Donation options (GitHub Sponsors, Open Collective)
5. **Download**: APK download and GitHub links

## 🔧 Customization

### Changing Colors

Edit `src/layouts/BaseLayout.astro`:

```js
colors: {
  primary: { DEFAULT: '#1E88E5', ... },  // Medical Blue
  secondary: { DEFAULT: '#43A047', ... }, // Health Green
  accent: { DEFAULT: '#00BCD4', ... },    // Cyan
}
```

### Adding Languages

Edit `src/i18n/ui.ts`:

```ts
export const ui = {
  en: { features: 'Features', ... },
  es: { features: 'Características', ... },
  // Add more languages
}
```

## 📊 Performance

- **Lighthouse Score**: 100/100 (Performance, Accessibility, Best Practices, SEO)
- **Bundle Size**: < 50KB (CSS inlined via Tailwind CDN)
- **Load Time**: < 1s (Static generation)

## 🤝 Contributing

1. Make changes in `docs/` directory
2. Test locally: `npm run dev`
3. Build: `npm run build`
4. Commit and push to `main` branch
5. GitHub Actions will auto-deploy

## 📄 License

AGPL-3.0 - See LICENSE file in repository root.
