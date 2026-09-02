import { defineConfig } from 'astro/config';
import svelte from '@astrojs/svelte';
import cloudflare from '@astrojs/cloudflare';
import AstroPWA from '@vite-pwa/astro';

// SSR (Cloudflare Workers) + PWA via @vite-pwa/astro (mismo patrón que docs/,
// que sí genera sw.js; vite-plugin-pwa crudo no emite SW con output:'server').
export default defineConfig({
  site: 'https://orionhealth-web.iberi22.workers.dev',
  output: 'server',
  adapter: cloudflare(),
  integrations: [
    svelte(),
    AstroPWA({
      registerType: 'autoUpdate',
      injectRegister: 'script',
      includeAssets: ['icon-192.png', 'icon-512.png'],
      manifest: false,
      workbox: {
        globPatterns: ['**/*.{js,css,svg,png,ico}'],
        navigateFallback: null,
        runtimeCaching: [
          {
            urlPattern: /\/api\/.*/i,
            handler: 'NetworkFirst',
            options: { cacheName: 'api', expiration: { maxEntries: 100, maxAgeSeconds: 60 * 5 } },
          },
          {
            urlPattern: /\/_astro\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'astro-assets',
              expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 * 24 * 30 },
            },
          },
        ],
      },
    }),
  ],
});
