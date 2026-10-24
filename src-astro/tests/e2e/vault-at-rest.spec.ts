import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { createVault, navigateInApp } from './helpers/vault';
import { dumpIndexedDb } from './helpers/idb';

const MARKERS = ['ZZ-MARKER-1', 'ZZ-MARKER-2'];

test('vault data is encrypted at rest and contains no plain marker @real', async ({ page }) => {
  await addVirtualPasskey(page);
  await createVault(page, 'Test Vault');

  await navigateInApp(page, '/app/records');
  await expect(page.locator('[data-testid="area-records"]')).toBeVisible();

  // Condition
  await page.getByRole('button', { name: 'Añadir' }).click();
  await page.getByLabel('Nombre de la condición').fill(MARKERS[0]!);
  await page.getByRole('button', { name: 'Guardar' }).click();
  await expect(page.getByText(MARKERS[0]!)).toBeVisible();

  // Allergy
  await page.locator('button.tab-btn', { hasText: 'Alergias' }).click();
  await page.getByRole('button', { name: 'Añadir' }).first().click();
  await page.locator('input#al-substance').fill(MARKERS[1]!);
  await page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
  await expect(page.getByText(MARKERS[1]!)).toBeVisible();

  // IndexedDB: every database, every store, values and keys (guard: the dump is not vacuous).
  const idbDump = await dumpIndexedDb(page);
  expect(idbDump).toContain('orion-vault');
  expect(idbDump).toContain('orion-meta');
  for (const m of MARKERS) expect(idbDump).not.toContain(m);

  const ls = await page.evaluate(() => JSON.stringify(localStorage));
  const ss = await page.evaluate(() => JSON.stringify(sessionStorage));
  const cacheStr = await page.evaluate(async () => {
    const out: string[] = [];
    for (const key of await caches.keys()) {
      const cache = await caches.open(key);
      for (const req of await cache.keys()) {
        out.push(req.url);
        const res = await cache.match(req);
        if (res) out.push(await res.text());
      }
    }
    return JSON.stringify(out);
  });
  const urls = await page.evaluate(() => JSON.stringify(performance.getEntriesByType('resource').map((e) => e.name)));
  for (const m of MARKERS) {
    expect(ls).not.toContain(m);
    expect(ss).not.toContain(m);
    expect(cacheStr).not.toContain(m);
    expect(urls).not.toContain(m);
  }
});
