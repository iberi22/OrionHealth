import { defineConfig } from 'astro/config';
import svelte from '@astrojs/svelte';
import cloudflare from '@astrojs/cloudflare';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  output: 'server',
  adapter: cloudflare(),
  integrations: [svelte()],
  vite: {
    plugins: [
      VitePWA({
        registerType: 'autoUpdate',
        includeAssets: ['icon-192.png', 'icon-512.png'],
        manifest: false,
        workbox: {
          globPatterns: ['**/*.{js,css,html,svg,png,ico}'],
          runtimeCaching: [
            {
              urlPattern: /^https:\/\/api\.swal\.dev\/.*/i,
              handler: 'NetworkFirst',
              options: { cacheName: 'api', expiration: { maxEntries: 100, maxAgeSeconds: 60 * 5 } },
            },
          ],
        },
      }),
    ],
  },
});
