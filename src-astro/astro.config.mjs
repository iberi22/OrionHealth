import { defineConfig } from 'astro/config';
import svelte from '@astrojs/svelte';
import cloudflare from '@astrojs/cloudflare';
import AstroPWA from '@vite-pwa/astro';

// SSR (Cloudflare Workers) + PWA via @vite-pwa/astro (mismo patrón que docs/,
// que sí genera sw.js; vite-plugin-pwa crudo no emite SW con output:'server').
//
// Canonical domain: https://orionhealth.swal.network (custom domain of the Worker
// orionhealth-web, see wrangler.toml). orionhealth-web.iberi22.workers.dev stays as a
// fallback/health check. Override with PUBLIC_SITE_URL (previews).
const site = process.env.PUBLIC_SITE_URL ?? 'https://orionhealth.swal.network';

export default defineConfig({
  site,
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
            // SSR: cachear navegaciones visitadas para reload offline
            urlPattern: ({ request }) => request.mode === 'navigate',
            handler: 'NetworkFirst',
            options: { cacheName: 'pages', networkTimeoutSeconds: 3, expiration: { maxEntries: 32, maxAgeSeconds: 60 * 60 * 24 } },
          },
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
