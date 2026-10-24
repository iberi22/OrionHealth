import { expect, type Browser, type BrowserContext, type Page } from '@playwright/test';
import { addVirtualPasskey } from './webauthn';
import { createVault, navigateInApp, visit } from './vault';

export interface Member {
  context: BrowserContext;
  page: Page;
}

/** A new browser context (own storage and virtual passkey) with a vault created through the UI. */
export async function newMember(browser: Browser, baseURL: string | undefined, name: string): Promise<Member & { recoveryCode: string }> {
  const context = await browser.newContext({ baseURL });
  const page = await context.newPage();
  await addVirtualPasskey(page);
  const recoveryCode = await createVault(page, name);
  return { context, page, recoveryCode };
}

/** The admin creates a circle on /app/family. */
export async function createCircle(admin: Page, circleName: string): Promise<void> {
  await visit(admin, '/app/family');
  await admin.getByLabel('Nombre del círculo').fill(circleName);
  await admin.getByRole('button', { name: 'Crear círculo' }).click();
  await expect(admin.getByRole('heading', { name: circleName })).toBeVisible();
}

/**
 * The admin invites and the joiner (who already has a vault) joins, compares the SAS and the admin
 * approves. Resolves when the joiner shows in the admin's member list.
 */
export async function inviteAndJoin(admin: Page, joiner: Page, joinerName: string): Promise<void> {
  await admin.getByRole('button', { name: 'Invitar' }).click();
  const inviteUrlInput = admin.locator('.url-container input');
  await expect(inviteUrlInput).toBeVisible();
  const invite = new URL(await inviteUrlInput.inputValue());

  // Client-side: a full load of the link would start a locked session (and joining needs a vault).
  await navigateInApp(joiner, invite.pathname + invite.hash);
  await joiner.getByLabel('Tu nombre').fill(joinerName);
  await joiner.getByRole('button', { name: 'Unirse' }).click();

  const sasCode = joiner.locator('.sas-code');
  await expect(sasCode).toBeVisible({ timeout: 20_000 }); // WebRTC handshake over local signaling
  const sas = (await sasCode.textContent())!;

  await admin.getByRole('button', { name: 'Cerrar' }).click();
  admin.once('dialog', (dialog) => {
    expect(dialog.message()).toContain(sas);
    void dialog.accept();
  });
  await admin.getByRole('button', { name: 'Revisar' }).first().click();
  await expect(admin.locator('.members-list').getByText(joinerName)).toBeVisible();
}
