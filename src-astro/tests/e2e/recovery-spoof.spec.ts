import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit, reloadAndUnlock } from './helpers/vault';
import { addVirtualPasskey } from './helpers/webauthn';

test.describe('@real Recovery Spoofing', () => {
  test.setTimeout(240_000);

  test("a non-admin cannot start recovery; a trustee's decline survives a reload", async ({ browser, baseURL }) => {
    await startSignaling();

    const admin = await newMember(browser, baseURL, 'Alice');
    const bea = await newMember(browser, baseURL, 'Bea');
    const charlie = await newMember(browser, baseURL, 'Charlie');
    const dave = await newMember(browser, baseURL, 'Dave');

    await createCircle(admin.page, 'Trust Circle');
    await inviteAndJoin(admin.page, bea.page, 'Bea');
    await inviteAndJoin(admin.page, charlie.page, 'Charlie');
    await inviteAndJoin(admin.page, dave.page, 'Dave');

    // Bea sets Charlie and Dave as her 2-of-2 trustees
    await visit(bea.page, '/app/recovery');
    await expect(bea.page.getByRole('heading', { name: 'Elegir custodios' })).toBeVisible();
    await bea.page.getByLabel('Charlie').check();
    await bea.page.getByLabel('Dave').check();
    await bea.page.locator('select#threshold-select').selectOption('2');
    bea.page.once('dialog', (dialog) => void dialog.accept());
    await bea.page.getByRole('button', { name: 'Guardar plan' }).click();

    // Verify non-admin (Charlie) cannot see the section to create recovery invites
    await visit(charlie.page, '/app/recovery');
    await charlie.page.getByRole('button', { name: 'Solicitudes' }).click();
    await expect(charlie.page.getByRole('heading', { name: 'Solicitudes esperando mi aprobación' })).toBeVisible();
    await expect(charlie.page.getByRole('heading', { name: 'Dispositivo nuevo de un miembro' })).not.toBeVisible();

    // Alice (Admin) creates a recovery invite for Bea
    await visit(admin.page, '/app/recovery');
    await admin.page.getByRole('button', { name: 'Solicitudes' }).click();
    await admin.page.getByLabel('Miembro a recuperar').selectOption({ label: 'Bea' });
    await admin.page.getByRole('button', { name: 'Crear invitación de recuperación' }).click();

    // The invitation dialog is modal. Wait for the URL and close the dialog before continuing.
    const inviteUrlInput = admin.page.getByLabel('Enlace de recuperación');
    await expect(inviteUrlInput).toBeVisible();
    const inviteUrl = await inviteUrlInput.inputValue();
    await admin.page.getByRole('button', { name: 'Cerrar' }).click();
    expect(inviteUrl).toContain('/app/recovery#');

    // Fresh browser context (new device) opens the invite link
    const fresh = await browser.newContext({ baseURL });
    const device = await fresh.newPage();
    await addVirtualPasskey(device);
    await device.goto(inviteUrl);
    await device.getByRole('button', { name: 'Continuar' }).click();
    await expect(device.getByRole('heading', { name: 'Conectando con tu familia...' })).toBeVisible();
    const sas = (await device.locator('.sas').textContent({ timeout: 20_000 }))!.trim();

    // Admin sees the pending join, verifies the SAS, and clicks "Coincide" to vouch
    const join = admin.page.locator('.request-card', { hasText: 'dice ser de' });
    await expect(join).toContainText(sas, { timeout: 20_000 });
    await join.getByRole('button', { name: 'Coincide', exact: true }).click();
    await expect(device.getByRole('heading', { name: 'Esperando aprobaciones' })).toBeVisible({ timeout: 20_000 });

    // Dave (trustee) sees the recovery request
    await visit(dave.page, '/app/recovery');
    await dave.page.getByRole('button', { name: 'Solicitudes' }).click();
    const card = dave.page.locator('.request-card', { hasText: 'Solicitud de recuperación para la cuenta de' });
    await expect(card).toContainText('Bea', { timeout: 30_000 });
    await expect(card).toContainText('Desde un dispositivo nuevo');
    await expect(card).toContainText('verificado por Alice');

    // Dave rejects the request
    await card.getByRole('button', { name: 'Rechazar' }).click();

    // Verify the request card disappears for Dave
    await expect(card).not.toBeVisible({ timeout: 10_000 });

    // Dave reloads and unlocks
    await reloadAndUnlock(dave.page, '/app/recovery');
    await visit(dave.page, '/app/recovery');
    await expect(dave.page.getByRole('button', { name: 'Solicitudes' })).toBeVisible({ timeout: 30_000 });
    await dave.page.getByRole('button', { name: 'Solicitudes' }).click({ timeout: 30_000 });
    await expect(dave.page.getByRole('heading', { name: 'Solicitudes esperando mi aprobación' })).toBeVisible();
    await expect(dave.page.locator('.request-card', { hasText: 'Solicitud de recuperación para la cuenta de' })).not.toBeVisible();

    // The new device is still stuck on the "Esperando aprobaciones" screen (no share was released)
    await expect(device.getByRole('heading', { name: 'Esperando aprobaciones' })).toBeVisible();

    // Charlie (trustee) sees the recovery request
    await visit(charlie.page, '/app/recovery');
    await charlie.page.getByRole('button', { name: 'Solicitudes' }).click();
    const charlieCard = charlie.page.locator('.request-card', { hasText: 'Solicitud de recuperación para la cuenta de' });
    await expect(charlieCard).toContainText('Bea', { timeout: 30_000 });

    // Charlie approves the request
    await charlieCard.getByLabel(/Llamé o vi en persona/).check();
    await charlieCard.getByRole('button', { name: 'Aprobar con mi passkey' }).click();

    // Verify Charlie's request card disappears
    await expect(charlieCard).not.toBeVisible({ timeout: 10_000 });

    // The device shows 1 of 2 approvals
    await expect(device.getByText('1 de 2 aprobaciones')).toBeVisible({ timeout: 30_000 });

    for (const ctx of [admin.context, bea.context, charlie.context, dave.context, fresh]) {
      await ctx.close();
    }
  });
});
