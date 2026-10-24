import { defineConfig } from 'vitest/config';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [svelte()],
  resolve: {
    alias: {
      'astro:middleware': 'astro/middleware',
    },
    // Svelte components mount in jsdom with the browser build.
    conditions: ['browser'],
  },
  test: {
    // Hermetic: never reach a real Xavier (on the owner's machine localhost:8006 is production).
    env: { PUBLIC_XAVIER_URL: 'http://127.0.0.1:9' },
    globals: true,
    environment: 'jsdom',
    include: ['src/**/*.test.ts', 'workers/**/*.test.ts'],
    exclude: ['node_modules', 'dist', '.astro', 'tests/e2e/**', 'playwright.config.*'],
  },
});
