import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { createVault, navigateInApp } from './helpers/vault';

test('inactivity lock and hidden-tab lock return to /app/lock and the data is unreachable until unlock @real', async ({ page }) => {
  await page.clock.install({ time: new Date() });

  await addVirtualPasskey(page);
  await createVault(page, 'Test Vault');

  await navigateInApp(page, '/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();

  // Add condition to check its unreachability
  await page.getByRole('button', { name: 'Añadir' }).click();
  await page.getByLabel('Nombre de la condición').fill('ZZ-MARKER-1');
  await page.getByRole('button', { name: 'Guardar' }).click();
  await expect(page.getByText('ZZ-MARKER-1')).toBeVisible();

  // Test inactivity lock (default 5 minutes)
  await page.clock.fastForward(5 * 60 * 1000 + 1000);

  await expect(page.locator('[data-testid="area-lock"]')).toBeVisible();
  await expect(page.locator('[data-testid="area-records"]')).not.toBeVisible();
  await expect(page.getByText('ZZ-MARKER-1')).not.toBeVisible();

  // To truly prove it's unreachable, trying to force-navigate to records should bounce back or show nothing
  await page.goto('/app/records');
  await expect(page.locator('[data-testid="area-lock"]')).toBeVisible();

  // Unlock the vault again
  await page.getByRole('button', { name: 'Desbloquear' }).click();
  await expect(page.locator('[data-testid="area-home"]')).toBeVisible();

  // Go to records again (client-side: a full load would start a new locked session)
  await navigateInApp(page, '/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();
  await expect(page.getByText('ZZ-MARKER-1')).toBeVisible();

  // Test hidden-tab lock
  await page.evaluate(() => {
    Object.defineProperty(document, 'visibilityState', { value: 'hidden', configurable: true });
    document.dispatchEvent(new Event('visibilitychange'));
  });

  await page.clock.fastForward(5 * 60 * 1000 + 1000); // hidden tab locks after the same auto-lock timeout

  await expect(page.locator('[data-testid="area-lock"]')).toBeVisible();
  await expect(page.locator('[data-testid="area-records"]')).not.toBeVisible();
  await expect(page.getByText('ZZ-MARKER-1')).not.toBeVisible();
});
