# Lighthouse Audit Report - 2026

**Date:** July 7, 2026
**Target URL:** http://localhost:4321/OrionHealth
**Environment:** Headless Chrome (v13.4.0)

## Summary Scores

| Category | Mobile | Desktop |
| --- | --- | --- |
| Performance | 95 | 100 |
| Accessibility | 94 | 89 |
| Best Practices | 100 | 100 |
| SEO | 100 | 100 |
| PWA | 100 | 100 |

## Core Web Vitals (Lab Data)

| Metric | Mobile | Desktop |
| --- | --- | --- |
| Largest Contentful Paint (LCP) | 2.4s | 0.7s |
| Total Blocking Time (TBT) | 0ms | 0ms |
| Cumulative Layout Shift (CLS) | 0 | 0 |

## PWA Features

The site successfully passes all automated PWA audits:
- **Service Worker:** Meet the installability requirements.
- **Manifest:** Manifest is valid, has maskable icons, and is configured for a custom splash screen.
- **Installability:** Site is installable as a PWA.
- **Theme Color:** Address bar theme color is set.
- **Viewport:** Mobile-friendly viewport configuration.

## Key Findings & Improvements

### Accessibility
- **Color Contrast (Mobile/Desktop):** Some elements have insufficient color contrast.
    - `kbd.med-search-hint` ("Ctrl+K"): Contrast ratio 3.17 (Expected 4.5:1).
    - `p.text-center` in footer/donate section: Contrast ratio 3.3 (Expected 4.5:1).
- **Desktop Specific:** Accessibility score on desktop is slightly lower (89) compared to mobile (94).

### Performance
- **Mobile Performance:** Excellent (95), LCP is 2.4s (within the good threshold but could be improved).
- **Desktop Performance:** Perfect score (100) with sub-second LCP.

### SEO & Best Practices
- **Perfect Scores:** Both SEO and Best Practices achieved 100% on both platforms.

## Conclusion
OrionHealth Documentation site is in excellent health, meeting high standards for performance and PWA readiness. The primary areas for immediate improvement are related to color contrast for specific small UI elements to achieve a perfect Accessibility score.
