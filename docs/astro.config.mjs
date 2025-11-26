import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  site: 'https://iberi22.github.io',
  base: '/local-llm.OrionHealth',
  integrations: [tailwind()],
  build: {
    assets: '_astro'
  },
  vite: {
    ssr: {
      noExternal: ['@astrojs/*']
    }
  }
});
