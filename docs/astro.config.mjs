import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  site: 'https://iberi22.github.io',
  base: '/OrionHealth',
  integrations: [tailwind({
    // Inject @tailwind base/components/utilities so every utility class
    // (flex, grid, responsive variants, etc.) resolves correctly.
    // The custom cyber-minimalist styles live in BaseLayout.astro as enhancements.
    applyBaseStyles: true,
  })],
  build: {
    assets: '_astro'
  },
  vite: {
    ssr: {
      noExternal: ['@astrojs/*']
    }
  }
});
