import { type E2EConfig } from 'e2e';
import { web } from '@e2e-dev/web';

export default {
  tests: ['e2e-ta/**/*.e2e.ts', '!e2e-ta/findings/**'],
  targets: [
    {
      name: 'local',
      engine: web(),
      app: {
        command: {
          // Builds the checkout and serves it with the Cloudflare adapter's
          // local workerd preview on 127.0.0.1, so the run needs no build step,
          // no `astro preview` daemon and no Cloudflare credentials
          // (`CLOUDFLARE_VITE_FORCE_LOCAL` keeps every binding local instead of
          // opening a remote connection that needs a token).
          executable: 'pnpm',
          args: ['run', 'e2e:serve', '--port', '{port}'],
          env: { CLOUDFLARE_VITE_FORCE_LOCAL: 'true' },
          // The command builds first, so the first ready check happens well
          // after the default 60 s budget.
          startupTimeout: 300_000,
          log: '.e2e/app.log',
        },
        url: 'http://127.0.0.1:0',
      },
    },
    {
      name: 'live',
      engine: web(),
      app: {
        url: process.env.E2E_LIVE_URL || 'https://orionhealth-web.iberi22.workers.dev',
      },
    },
  ],
} satisfies E2EConfig;
