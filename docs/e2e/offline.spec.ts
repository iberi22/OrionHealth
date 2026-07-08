import { test, expect } from '@playwright/test';

test.describe('PWA Offline Fallback', () => {
  test.beforeEach(async ({ page }) => {
    // Load the page and wait for Service Worker
    await page.goto('/OrionHealth/');
    await page.evaluate(async () => {
      await navigator.serviceWorker.ready;
    });
    // Give it time to cache the offline page
    await page.waitForTimeout(2000);
  });

  test('should show custom offline page when navigating without connection', async ({ page, context }) => {
    await context.setOffline(true);

    // Navigate to a non-existent page
    await page.goto('/OrionHealth/offline-fallback-test-' + Date.now()).catch(() => {});

    // Verify it's the offline page
    const heading = page.locator('h1').first();
    await expect(heading).toBeVisible({ timeout: 10000 });
    // Use regex to match either English or Spanish
    await expect(heading).toHaveText(/No Connection|Sin Conexión/);

    await expect(page.locator('.logo-text')).toContainText('ORIONHEALTH');

    // Check Retry button
    const retryBtn = page.locator('#retry-btn');

    // We mock navigator.onLine to be absolutely sure the JS logic treats it as offline
    await page.evaluate(() => {
        Object.defineProperty(navigator, 'onLine', { value: false, configurable: true });
    });

    await retryBtn.click();

    // It should update to "Still Offline" or "Sigue sin conexión"
    await expect(retryBtn).toHaveText(/Still Offline|Sigue sin conexión/);
  });

  test('should respect bilingual toggle on offline page', async ({ page, context }) => {
    await context.setOffline(true);
    await page.goto('/OrionHealth/offline-lang-test').catch(() => {});

    // Ensure we are on the offline page
    await expect(page.locator('#content-en')).toBeVisible({ timeout: 10000 });

    // Switch to Spanish
    await page.click('button:has-text("ES")');
    await expect(page.locator('#content-es')).toBeVisible();
    await expect(page.locator('#content-en')).not.toBeVisible();
  });
});
