import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import AstroPWA from '@vite-pwa/astro';

// https://astro.build/config
export default defineConfig({
  site: 'https://iberi22.github.io',
  base: '/OrionHealth',
  integrations: [
    tailwind({
      applyBaseStyles: true,
    }),
    AstroPWA({
      registerType: 'autoUpdate',
      manifest: {
        name: 'OrionHealth Docs',
        short_name: 'OrionHealth',
        description: 'OrionHealth is a privacy-first health assistant that leverages local AI to provide medical insights, manage health records, and ensure data sovereignty. This documentation covers its architecture, medical standards, and project dashboard.',
        theme_color: '#10B981',
        background_color: '#121212',
        display: 'standalone',
        start_url: '/OrionHealth/',
        scope: '/OrionHealth/',
        icons: [
          {
            src: 'favicon.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any maskable'
          },
          {
            src: 'android-chrome-192x192.png',
            sizes: '192x192',
            type: 'image/png',
            purpose: 'any maskable'
          },
          {
            src: 'android-chrome-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable'
          },
          {
            src: 'apple-touch-icon.png',
            sizes: '192x192',
            type: 'image/png'
          }
        ],
        screenshots: [
          {
            src: 'screenshots/landing.png',
            sizes: '1280x720',
            type: 'image/png',
            form_factor: 'wide',
            label: 'OrionHealth Documentation Landing Page'
          }
        ]
      },
      workbox: {
        // Essential core assets
        globPatterns: ['**/*.{js,css,html,svg,png,json}'],
        // Exclude the thousands of medical standard pages from precache
        // but keep the index pages and common assets
        globIgnores: [
          'medical-standards/icd-10/**/*',
          'medical-standards/loinc/**/*',
          'medical-standards/rxnorm/**/*',
          'medical-standards/snomed/**/*'
        ],
        // The fallback should be the offline page.
        // We use the URL as it appears in the build (without .html because of Astro's default routing)
        navigateFallback: 'offline',
        cleanupOutdatedCaches: true,
        clientsClaim: true,
        skipWaiting: true,
        runtimeCaching: [
          {
            urlPattern: /\/medical-standards\//,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'medical-standards-cache',
              expiration: {
                maxEntries: 50,
                maxAgeSeconds: 60 * 60 * 24 * 30
              }
            }
          },
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365
              },
              cacheableResponse: {
                statuses: [0, 200]
              }
            }
          }
        ]
      }
    })
  ],
  build: {
    assets: '_astro'
  },
  vite: {
    ssr: {
      noExternal: ['@astrojs/*']
    }
  }
});
