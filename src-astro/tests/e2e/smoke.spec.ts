import { expect, test } from '@playwright/test';

// Minimal gate that the local build serves every surface of the unified site.
test('landing, docs, knowledge base and app shell answer', async ({ page }) => {
  for (const path of ['/', '/docs/', '/kb/']) {
    const res = await page.goto(path);
    expect(res?.status(), path).toBe(200);
    await expect(page.locator('h1').first()).toBeVisible();
  }
  await page.goto('/app/family');
  await expect(page).toHaveURL(/\/app\/(lock|onboarding)/);
});
