import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { createVault, navigateInApp, reloadAndUnlock } from './helpers/vault';

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

  // Edit Condition
  await page.locator('[data-testid^="edit-condition-"]').first().click();
  await page.locator('input#cond-name').fill('Asthma Updated');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Asthma Updated');

  // Delete Condition
  await page.locator('[data-testid^="delete-condition-"]').first().click();
  await expect(page.locator('.record-list')).not.toBeVisible();

  // Medications
  await page.locator('button.tab-btn', { hasText: 'Medicamentos' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#med-name').fill('Albuterol');
  await page.locator('input#med-dose').fill('2 puffs');
  await page.locator('input#med-schedule').fill('As needed');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Albuterol');

  // Edit Medication
  await page.locator('[data-testid^="edit-medication-"]').first().click();
  await page.locator('input#med-name').fill('Albuterol Updated');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Albuterol Updated');

  // Delete Medication
  await page.locator('[data-testid^="delete-medication-"]').first().click();
  await expect(page.locator('.record-list')).not.toBeVisible();

  // Vitals
  await page.locator('button.tab-btn', { hasText: 'Signos vitales' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#vital-value').fill('120');
  await page.locator('input#vital-value2').fill('80');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.latest-reading .value')).toContainText('120/80');

  // Edit Vital
  await page.locator('[data-testid^="edit-vital-"]').first().click();
  await page.locator('input#vital-value').fill('110');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.latest-reading .value')).toContainText('110/80');

  // Delete Vital
  await page.locator('[data-testid^="delete-vital-"]').first().click();
  await expect(page.locator('.vitals-grid')).not.toBeVisible();

  // Allergies
  await page.locator('button.tab-btn', { hasText: 'Alergias' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#al-substance').fill('Peanuts');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Peanuts');

  // Edit Allergy
  await page.locator('[data-testid^="edit-allergy-"]').first().click();
  await page.locator('input#al-substance').fill('Peanuts Updated');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Peanuts Updated');

  // Delete Allergy
  await page.locator('[data-testid^="delete-allergy-"]').first().click();
  await expect(page.locator('.record-list')).not.toBeVisible();

  // Appointments
  await page.locator('button.tab-btn', { hasText: 'Citas' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#app-title').fill('Checkup');
  await page.locator('input#app-at').fill('2025-01-01T10:00');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Checkup');

  // Edit Appointment
  await page.locator('[data-testid^="edit-appointment-"]').first().click();
  await page.locator('input#app-title').fill('Checkup Updated');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.locator('.record-list')).toContainText('Checkup Updated');

  // Delete Appointment
  await page.locator('[data-testid^="delete-appointment-"]').first().click();
  await expect(page.locator('.record-list')).not.toBeVisible();

  // Add one of each again so we can test persistence of existing ones
  // Conditions
  await page.locator('button.tab-btn', { hasText: 'Condiciones' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#cond-name').fill('Asthma');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();

  // Medications
  await page.locator('button.tab-btn', { hasText: 'Medicamentos' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#med-name').fill('Albuterol');
  await page.locator('input#med-dose').fill('2 puffs');
  await page.locator('input#med-schedule').fill('As needed');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();

  // Vitals
  await page.locator('button.tab-btn', { hasText: 'Signos vitales' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#vital-value').fill('120');
  await page.locator('input#vital-value2').fill('80');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();

  // Allergies
  await page.locator('button.tab-btn', { hasText: 'Alergias' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#al-substance').fill('Peanuts');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();

  // Appointments
  await page.locator('button.tab-btn', { hasText: 'Citas' }).click();
  await page.locator('button', { hasText: 'Añadir' }).first().click();
  await page.locator('input#app-title').fill('Checkup');
  await page.locator('input#app-at').fill('2025-01-01T10:00');
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();

  // Persistence (check existing AND that deleted ones are gone)
  await reloadAndUnlock(page, '/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();

  // Appointments check (was the last tab we left at)
  // Wait, reloadAndUnlock might just go back to /app/records which opens "Condiciones" by default
  await page.locator('button.tab-btn', { hasText: 'Condiciones' }).click();
  await expect(page.locator('.record-list')).toContainText('Asthma');
  await expect(page.locator('.record-list')).not.toContainText('Asthma Updated');

  await page.locator('button.tab-btn', { hasText: 'Medicamentos' }).click();
  await expect(page.locator('.record-list')).toContainText('Albuterol');
  await expect(page.locator('.record-list')).not.toContainText('Albuterol Updated');

  await page.locator('button.tab-btn', { hasText: 'Signos vitales' }).click();
  await expect(page.locator('.latest-reading .value')).toContainText('120/80');
  await expect(page.locator('.latest-reading .value')).not.toContainText('110/80');

  await page.locator('button.tab-btn', { hasText: 'Alergias' }).click();
  await expect(page.locator('.record-list')).toContainText('Peanuts');
  await expect(page.locator('.record-list')).not.toContainText('Peanuts Updated');

  await page.locator('button.tab-btn', { hasText: 'Citas' }).click();
  await expect(page.locator('.record-list')).toContainText('Checkup');
  await expect(page.locator('.record-list')).not.toContainText('Checkup Updated');
});
