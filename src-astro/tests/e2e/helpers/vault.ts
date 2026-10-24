import { expect, type Page } from '@playwright/test';

/**
 * Creates a vault through the onboarding UI (the page must already have a virtual passkey) and
 * walks the wizard to the end. Returns the recovery code shown to the user.
 * Resolves once the app shell is open at /app (vault unlocked, same JS session).
 */
export async function createVault(page: Page, name: string): Promise<string> {
  await page.goto('/app/onboarding');
  await expect(page.locator('[data-testid="area-onboarding"]')).toBeVisible();

  while (await page.locator('button', { hasText: 'Siguiente' }).isVisible()) {
    await page.locator('button', { hasText: 'Siguiente' }).click();
  }
  await page.locator('button', { hasText: 'Empezar' }).click();

  await page.locator('input#vault-name').fill(name);
  await page.locator('button', { hasText: 'Crear passkey' }).click();

  const codeDisplay = page.locator('.code-display');
  await expect(codeDisplay).toBeVisible();
  const code = (await codeDisplay.textContent())!.trim();
  const parts = code.includes('-') ? code.split('-') : code.split(' ');

  for (let i = 0; i < 3; i++) {
    const labelText = await page.locator(`label[for="part-${i}"]`).textContent();
    const idx = parseInt(labelText!.match(/Parte (\d+)/)![1]!, 10) - 1;
    await page.locator(`input#part-${i}`).fill(parts[idx]!);
  }
  await page.locator('button', { hasText: 'Confirmar' }).click();

  await expect(page.locator('h2', { hasText: 'Perfil básico' })).toBeVisible();
  await page.locator('input#full-name').fill(name);
  await page.locator('button', { hasText: 'Guardar perfil' }).click();

  await expect(page.locator('h2', { hasText: 'Familia' })).toBeVisible();
  await page.locator('button', { hasText: 'Omitir por ahora' }).click();

  await expect(page.locator('h2', { hasText: '¡Todo listo!' })).toBeVisible();
  await page.locator('button', { hasText: 'Entrar a la app' }).click();
  await expect(page.locator('[data-testid="area-home"]')).toBeVisible();
  return code;
}

/** Client-side navigation (a full page load would start a new, locked session). */
export async function navigateInApp(page: Page, path: string): Promise<void> {
  await page.evaluate((p) => {
    history.pushState({}, '', p);
    dispatchEvent(new PopStateEvent('popstate'));
  }, path);
}

/** The routed area (the shell wrapper has its own area-shell test id). */
const anyArea = (page: Page) => page.locator('[data-testid^="area-"]:not([data-testid="area-shell"])').first();

/** If the vault gate shows the lock screen, unlocks with the passkey (client-side, same session). */
export async function unlockIfLocked(page: Page): Promise<void> {
  const area = anyArea(page);
  await expect(area).toBeVisible();
  if ((await area.getAttribute('data-testid')) === 'area-lock') {
    await page.getByRole('button', { name: 'Desbloquear' }).click();
    await expect(page.locator('[data-testid="area-home"]')).toBeVisible();
  }
}

/**
 * Opens an app route keeping/restoring an unlocked session: a full page load (goto/reload) starts a
 * new locked session, so this loads the SPA once and then navigates client-side, unlocking when the
 * gate asks for it.
 */
export async function visit(page: Page, path: string): Promise<void> {
  if (!/\/app/.test(page.url())) await page.goto('/app');
  await unlockIfLocked(page);
  await navigateInApp(page, path);
  await expect(anyArea(page)).toBeVisible();
}

/** Full reload followed by unlocking (what a user does after closing/reopening the tab). */
export async function reloadAndUnlock(page: Page, path: string): Promise<void> {
  await page.goto('/app');
  await unlockIfLocked(page);
  await navigateInApp(page, path);
}
