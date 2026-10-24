import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './webauthn';
import { createVault, reloadAndUnlock, navigateInApp } from './vault';

test('reloadAndUnlock unlocks the vault even when landing on a public route @real', async ({ page }) => {
  await addVirtualPasskey(page);
  await createVault(page, 'Test User');

  // Reload the page and attempt to reach a public route that does not prompt for unlock natively
  await reloadAndUnlock(page, '/app/recovery');

  // Verify we reached the target route correctly
  await expect(page.locator('[data-testid="area-recovery"]')).toBeVisible();

  // Verify the vault is actually unlocked by navigating to a private route
  // client-side and confirming it loads without bouncing back to the lock screen.
  await navigateInApp(page, '/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();
});
