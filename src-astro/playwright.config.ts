import { defineConfig, devices } from '@playwright/test';

// app-local: the real build served by `astro preview` (workerd), gate of web-ci.
// live: smoke against production only (e2e-web.yml); it never counts as feature coverage.
// Specs tagged @real need the real services (lib/app/real.ts); they run only with E2E_REAL=1.
const PORT = Number(process.env.E2E_PORT ?? 4321);
const chromium = {
  ...devices['Desktop Chrome'],
  // NixOS: system chromium; in CI (ubuntu) undefined -> bundled browser
  launchOptions: process.env.PW_CHROMIUM_PATH ? { executablePath: process.env.PW_CHROMIUM_PATH } : {},
};

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30_000,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [['github'], ['list']] : [['list']],
  use: { trace: 'retain-on-failure' },
  projects: [
    {
      name: 'app-local',
      testIgnore: /pwa-live\.spec\.ts/,
      grepInvert: process.env.E2E_REAL === '1' ? undefined : /@real/,
      use: { ...chromium, baseURL: `http://127.0.0.1:${PORT}` },
    },
    {
      name: 'live',
      testMatch: /pwa-live\.spec\.ts/,
      use: { ...chromium, baseURL: process.env.E2E_BASE_URL ?? 'https://orionhealth.swal.network' },
    },
  ],
  // Started only for app-local runs; `pnpm run build` must run before.
  webServer: process.argv.includes('--project=live')
    ? undefined
    : {
        command: `pnpm astro preview --ignore-lock --host 127.0.0.1 --port ${PORT}`,
        url: `http://127.0.0.1:${PORT}/`,
        reuseExistingServer: !process.env.CI,
        timeout: 120_000,
      },
});
