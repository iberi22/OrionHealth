import { test, expect } from '@playwright/test';
// @ts-ignore - Task orion2-b.05 provides this module
import { addVirtualPasskey } from './helpers/webauthn';

test('full onboarding flow', async ({ page }) => {
  await addVirtualPasskey(page);

  await page.goto('/app/onboarding');

  const area = page.locator('[data-testid="area-onboarding"]');
  await expect(area).toBeVisible();

  while (await page.locator('button', { hasText: 'Siguiente' }).isVisible()) {
    await page.locator('button', { hasText: 'Siguiente' }).click();
  }
  await page.locator('button', { hasText: 'Empezar' }).click();

  await page.locator('input#vault-name').fill('Test User');
  await page.locator('button', { hasText: 'Crear passkey' }).click();

  const codeDisplay = page.locator('.code-display');
  await expect(codeDisplay).toBeVisible();

  const code = await codeDisplay.textContent();
  const parts = code!.includes('-') ? code!.trim().split('-') : code!.trim().split(' ');

  for (let i = 0; i < 3; i++) {
    const label = page.locator(`label[for="part-${i}"]`);
    const labelText = await label.textContent();
    const match = labelText!.match(/Parte (\d+)/);
    if (match) {
      const idx = parseInt(match[1], 10) - 1;
      await page.locator(`input#part-${i}`).fill(parts[idx]);
    }
  }

  await page.locator('button', { hasText: 'Confirmar' }).click();

  await expect(page.locator('h2', { hasText: 'Perfil básico' })).toBeVisible();
  await page.locator('input#full-name').fill('Test User');
  await page.locator('button', { hasText: 'Guardar perfil' }).click();

  await expect(page.locator('h2', { hasText: 'Familia' })).toBeVisible();
  await page.locator('button', { hasText: 'Omitir por ahora' }).click();

  await expect(page.locator('h2', { hasText: '¡Todo listo!' })).toBeVisible();
  await page.locator('button', { hasText: 'Entrar a la app' }).click();

  await expect(page).toHaveURL(/\/app(?:\/.*)?$/);
});
