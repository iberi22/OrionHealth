import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { createVault, navigateInApp } from './helpers/vault';

test('records CRUD and persistence @real', async ({ page }) => {
  await addVirtualPasskey(page);

  await createVault(page, 'Test Vault');

  await navigateInApp(page, '/app/records');
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

  await navigateInApp(page, '/app/records');
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
