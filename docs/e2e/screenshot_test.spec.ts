import { test, expect } from '@playwright/test';

const BASE = 'http://localhost:4321/OrionHealth';

test('capture light mode', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await page.goto(BASE + '/');
  await page.waitForTimeout(2000); // Wait for animations
  await page.screenshot({ path: 'light-mode.png', fullPage: true });
});

test('capture dark mode', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'dark' });
  await page.goto(BASE + '/');
  await page.waitForTimeout(2000); // Wait for animations
  await page.screenshot({ path: 'dark-mode.png', fullPage: true });
});

test('capture offline fallback', async ({ page, context }) => {
  await page.goto(BASE + '/');
  await page.evaluate(async () => {
    const registration = await navigator.serviceWorker.ready;
    return registration.active?.state;
  });
  await page.waitForTimeout(2000);
  await context.setOffline(true);
  await page.goto(BASE + '/docs/non-existent', { waitUntil: 'networkidle' }).catch(() => {});
  await page.waitForTimeout(1000);
  await page.screenshot({ path: 'offline-fallback.png', fullPage: true });
});
