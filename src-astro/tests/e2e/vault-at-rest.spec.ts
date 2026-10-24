import { test, expect } from '@playwright/test';

// @ts-ignore - Helper is provided by orion2-b.05
import * as webauthn from './helpers/webauthn';
// @ts-ignore - Helper is provided by orion2-b.05
import * as idb from './helpers/idb';

test('vault data is encrypted at rest and contains no plain marker @real', async ({ page }) => {
  // @ts-ignore
  if (webauthn.addVirtualPasskey) await webauthn.addVirtualPasskey(page);

  await page.goto('/app/onboarding');
  await expect(page.locator('[data-testid="area-onboarding"]')).toBeVisible();

  await page.getByPlaceholder('Tu nombre').fill('Test Vault');
  await page.getByRole('button', { name: 'Crear passkey' }).click();

  // Recovery code step
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

  // Basic profile step
  await page.getByLabel('Nombre completo').fill('John Doe');
  await page.getByRole('button', { name: 'Guardar perfil' }).click();

  // Family step
  await page.getByRole('button', { name: 'Omitir por ahora' }).click();

  // Tour step
  await page.getByRole('button', { name: 'Entrar a la app' }).click();

  // App home
  await expect(page.locator('[data-testid="area-home"]')).toBeVisible();
  await page.goto('/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();

  // Add condition
  await page.getByRole('button', { name: 'Añadir' }).click();
  await page.getByLabel('Nombre de la condición').fill('ZZ-MARKER-1');
  await page.getByRole('button', { name: 'Guardar' }).click();

  // Wait for it to appear
  await expect(page.getByText('ZZ-MARKER-1')).toBeVisible();

  // Dump storage and verify
  // @ts-ignore
  if (idb.dumpIndexedDb) {
    // @ts-ignore
    const idbDump = await idb.dumpIndexedDb(page);
    expect(idbDump).not.toContain('ZZ-MARKER-1');
  }

  const ls = await page.evaluate(() => JSON.stringify(localStorage));
  expect(ls).not.toContain('ZZ-MARKER-1');

  const ss = await page.evaluate(() => JSON.stringify(sessionStorage));
  expect(ss).not.toContain('ZZ-MARKER-1');

  // Verify Cache Storage
  const cacheStr = await page.evaluate(async () => {
    const cacheKeys = await caches.keys();
    const allCaches: string[] = [];
    for (const key of cacheKeys) {
      const cache = await caches.open(key);
      const reqs = await cache.keys();
      for (const req of reqs) {
        const res = await cache.match(req);
        if (res) {
          const text = await res.text();
          allCaches.push(text);
        }
      }
    }
    return JSON.stringify(allCaches);
  });
  expect(cacheStr).not.toContain('ZZ-MARKER-1');

  // Get all visited URLs from page history/performance
  const urls = await page.evaluate(() => JSON.stringify(performance.getEntriesByType('resource').map(e => e.name)));
  expect(urls).not.toContain('ZZ-MARKER-1');
});
