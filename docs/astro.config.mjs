import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  site: 'https://iberi22.github.io',
  base: '/local-llm.OrionHealth',
  build: {
    assets: '_astro'
  },
  vite: {
    ssr: {
      noExternal: ['@astrojs/*']
    }
  }
});
