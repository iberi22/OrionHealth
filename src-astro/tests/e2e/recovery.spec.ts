import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit } from './helpers/vault';
import { addVirtualPasskey } from './helpers/webauthn';

// Spec §9.3: Bea loses her phone. A brand-new browser context (EMPTY vault, new passkey) opens a recovery
// invitation created by the admin, both compare the SAS, the admin vouches, and two of Bea's three trustees
// approve after checking the SAS. The new device ends with Bea's account.
// Not covered here (JA13/JA14): an impostor's request shown to trustees, old records visible after recovery,
// and the code + orion-recovery.json variant.
test.describe('@real Recovery', () => {
  test('a new device recovers with an admin-vouched invitation and 2 of 3 trustees', async ({ browser, baseURL }) => {
    test.setTimeout(120_000);
    await startSignaling();

    const admin = await newMember(browser, baseURL, 'Alice');
    const bea = await newMember(browser, baseURL, 'Bea');
    const names = ['Trustee 1', 'Trustee 2', 'Trustee 3'];
    const trustees = [];
    for (const name of names) trustees.push(await newMember(browser, baseURL, name));

    await createCircle(admin.page, 'Trust Circle');
    await inviteAndJoin(admin.page, bea.page, 'Bea');
    for (const [i, t] of trustees.entries()) await inviteAndJoin(admin.page, t.page, names[i]!);

    // Bea sets the 2-of-3 trustee plan
    await visit(bea.page, '/app/recovery');
    await expect(bea.page.getByRole('heading', { name: 'Elegir custodios' })).toBeVisible();
    for (const name of names) await bea.page.getByLabel(name).check();
    await bea.page.locator('select#threshold-select').selectOption('2');
    bea.page.once('dialog', (dialog) => void dialog.accept());
    await bea.page.getByRole('button', { name: 'Guardar plan' }).click();

    // The admin creates a recovery invitation for Bea
    await visit(admin.page, '/app/recovery');
    await admin.page.getByRole('button', { name: 'Solicitudes' }).click();
    await admin.page.getByLabel('Miembro a recuperar').selectOption({ label: 'Bea' });
    await admin.page.getByRole('button', { name: 'Crear invitación de recuperación' }).click();
    const inviteUrl = await admin.page.locator('.recovery-invite-url').inputValue();
    expect(inviteUrl).toContain('/app/recovery#');

    // Brand-new device: own context, own (new) passkey, nothing stored
    const fresh = await browser.newContext({ baseURL });
    const device = await fresh.newPage();
    await addVirtualPasskey(device);
    await device.goto(inviteUrl);
    await device.getByRole('button', { name: 'Continuar' }).click();
    await expect(device.getByRole('heading', { name: 'Conectando con tu familia...' })).toBeVisible();
    const sas = (await device.locator('.sas').textContent({ timeout: 20_000 }))!.trim();

    // Admin compares the SAS and vouches
    const join = admin.page.locator('.request-card', { hasText: 'dice ser de' });
    await expect(join).toContainText(sas, { timeout: 20_000 });
    await join.getByRole('button', { name: 'Coincide', exact: true }).click();
    await expect(device.getByRole('heading', { name: 'Esperando aprobaciones' })).toBeVisible({ timeout: 20_000 });

    // Two of the three trustees check the SAS and approve with their passkey
    for (const t of trustees.slice(0, 2)) {
      await visit(t.page, '/app/recovery');
      await t.page.getByRole('button', { name: 'Solicitudes' }).click();
      const card = t.page.locator('.request-card', { hasText: 'Solicitud de recuperación para la cuenta de' });
      await expect(card).toContainText('Bea', { timeout: 30_000 });
      await expect(card).toContainText('Alice');
      await expect(card).toContainText(sas);
      await card.getByLabel(/Llamé o vi en persona/).check();
      await card.getByRole('button', { name: 'Aprobar con mi passkey' }).click();
    }

    await expect(device.getByRole('heading', { name: '¡Recuperación completada!' })).toBeVisible({ timeout: 30_000 });

    for (const ctx of [admin.context, bea.context, fresh, ...trustees.map((t) => t.context)]) await ctx.close();
  });
});
