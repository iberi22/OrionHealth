import { test, expect } from '@playwright/test';
// @ts-ignore - Helper is provided by orion2-b.05
import * as webauthn from './helpers/webauthn';

test('inactivity lock and hidden-tab lock return to /app/lock and the data is unreachable until unlock @real', async ({ page }) => {
  await page.clock.install({ time: new Date() });

  // @ts-ignore
  if (webauthn.addVirtualPasskey) await webauthn.addVirtualPasskey(page);

  await page.goto('/app/onboarding');
  await expect(page.locator('[data-testid="area-onboarding"]')).toBeVisible();

  await page.getByPlaceholder('Tu nombre').fill('Test Vault');
  await page.getByRole('button', { name: 'Crear passkey' }).click();

  await expect(page.getByText('Tu código de recuperación')).toBeVisible();
  const codeParagraph = page.getByText('Guarda este código en un lugar seguro.');
  const codeDisplay = codeParagraph.locator('xpath=following-sibling::div[1]');
  const codeText = await codeDisplay.textContent();
  const parts = codeText!.trim().includes('-') ? codeText!.trim().split('-') : codeText!.trim().split(' ');
  for (let i = 0; i < 3; i++) {
    const input = page.locator('input').nth(i);
    const id = await input.getAttribute('id');
    const labelText = await page.locator(`label[for="${id}"]`).textContent();
    const idx = parseInt(labelText!.replace('Parte ', '')) - 1;
    await input.fill(parts[idx]);
  }
  await page.getByRole('button', { name: 'Confirmar' }).click();

  await page.getByLabel('Nombre completo').fill('John Doe');
  await page.getByRole('button', { name: 'Guardar perfil' }).click();

  await page.getByRole('button', { name: 'Omitir por ahora' }).click();
  await page.getByRole('button', { name: 'Entrar a la app' }).click();

  await expect(page.locator('[data-testid="area-home"]')).toBeVisible();

  await page.goto('/app/records');
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

  // Go to records again
  await page.goto('/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();
  await expect(page.getByText('ZZ-MARKER-1')).toBeVisible();

  // Test hidden-tab lock
  await page.evaluate(() => {
    Object.defineProperty(document, 'visibilityState', { value: 'hidden', configurable: true });
    document.dispatchEvent(new Event('visibilitychange'));
  });

  await page.clock.fastForward(60000 + 1000); // 60s timeout for visibility

  await expect(page.locator('[data-testid="area-lock"]')).toBeVisible();
  await expect(page.locator('[data-testid="area-records"]')).not.toBeVisible();
  await expect(page.getByText('ZZ-MARKER-1')).not.toBeVisible();
});
