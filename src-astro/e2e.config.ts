import { type E2EConfig } from 'e2e';
import { web } from '@e2e-dev/web';

export default {
  tests: ['e2e-ta/**/*.e2e.ts', '!e2e-ta/findings/**'],
  targets: [
    {
      name: 'local',
      engine: web(),
      app: {
        command: { executable: 'pnpm', args: ['run', 'preview', '--port', '{port}'], log: '.e2e/app.log' },
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
