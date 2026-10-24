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
    globals: true,
    environment: 'jsdom',
    include: ['src/**/*.test.ts', 'workers/**/*.test.ts'],
    exclude: ['node_modules', 'dist', '.astro', 'tests/e2e/**', 'playwright.config.*'],
  },
});
