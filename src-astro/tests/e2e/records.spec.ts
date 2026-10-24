import { test, expect } from '@playwright/test';
// @ts-ignore - Task orion2-b.05 provides this module
import { addVirtualPasskey } from './helpers/webauthn';

test('records CRUD and persistence @real', async ({ page }) => {
  await addVirtualPasskey(page);

  await page.goto('/app/onboarding');
  await expect(page.locator('[data-testid="area-onboarding"]')).toBeVisible();

  while (await page.locator('button', { hasText: 'Siguiente' }).isVisible()) {
    await page.locator('button', { hasText: 'Siguiente' }).click();
  }
  await page.locator('button', { hasText: 'Empezar' }).click();

  await page.locator('input#vault-name').fill('Test Vault');
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
  await page.locator('input#full-name').fill('Test Vault');
  await page.locator('button', { hasText: 'Guardar perfil' }).click();

  await expect(page.locator('h2', { hasText: 'Familia' })).toBeVisible();
  await page.locator('button', { hasText: 'Omitir por ahora' }).click();

  await expect(page.locator('h2', { hasText: '¡Todo listo!' })).toBeVisible();
  await page.locator('button', { hasText: 'Entrar a la app' }).click();

  await expect(page).toHaveURL(/\/app(?:\/.*)?$/);

  await page.goto('/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();

  // Conditions
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#cond-name').fill('Asthma');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Asthma');

  // Medications
  await page.locator('button.tab-btn', { hasText: 'Medicamentos' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#med-name').fill('Albuterol');
  await page.locator('input#med-dose').fill('2 puffs');
  await page.locator('input#med-schedule').fill('As needed');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Albuterol');

  // Vitals
  await page.locator('button.tab-btn', { hasText: 'Signos vitales' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#vital-value').fill('120');
  await page.locator('input#vital-value2').fill('80');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.latest-reading .value')).toContainText('120/80');

  // Allergies
  await page.locator('button.tab-btn', { hasText: 'Alergias' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#al-substance').fill('Peanuts');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Peanuts');

  // Appointments
  await page.locator('button.tab-btn', { hasText: 'Citas' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#app-title').fill('Checkup');
  await page.locator('input#app-at').fill('2025-01-01T10:00');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Checkup');

  // Persistence
  await page.reload();
  await expect(page.locator('[data-testid="area-lock"]')).toBeVisible();

  await page.locator('button', { hasText: 'Desbloquear' }).click();
  await expect(page.locator('[data-testid="area-home"]')).toBeVisible();

  await page.goto('/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();

  await expect(page.locator('.record-list')).toContainText('Asthma');

  await page.locator('button.tab-btn', { hasText: 'Medicamentos' }).click();
  await expect(page.locator('.record-list')).toContainText('Albuterol');

  await page.locator('button.tab-btn', { hasText: 'Signos vitales' }).click();
  await expect(page.locator('.latest-reading .value')).toContainText('120/80');

  await page.locator('button.tab-btn', { hasText: 'Alergias' }).click();
  await expect(page.locator('.record-list')).toContainText('Peanuts');

  await page.locator('button.tab-btn', { hasText: 'Citas' }).click();
  await expect(page.locator('.record-list')).toContainText('Checkup');
});
