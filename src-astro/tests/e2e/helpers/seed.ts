import { expect, type Page } from '@playwright/test';
import { navigateInApp } from './vault';

export async function seedPersonalData(page: Page) {
  await navigateInApp(page, '/app/records');
  await expect(page.getByTestId('area-records')).toBeVisible();

  // Condition
  await page.getByRole('button', { name: 'Añadir' }).first().click();
  await page.getByLabel('Nombre de la condición').fill('Asthma ZZ-PHI-1');
  await page.getByRole('button', { name: 'Guardar' }).click();
  await expect(page.getByTestId('area-records')).toContainText('ZZ-PHI-1');

  // Medication
  await page.getByRole('tab', { name: 'Medicamentos' }).click();
  await page.getByRole('button', { name: 'Añadir' }).first().click();
  await page.getByLabel('Nombre del medicamento').fill('Albuterol ZZ-PHI-2');
  await page.getByLabel('Dosis').fill('2 puffs');
  await page.getByLabel('Horario').fill('As needed');
  await page.getByRole('button', { name: 'Guardar' }).click();
  await expect(page.getByTestId('area-records')).toContainText('ZZ-PHI-2');
}
