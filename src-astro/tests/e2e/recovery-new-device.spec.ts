import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit, reloadAndUnlock, navigateInApp } from './helpers/vault';
import { addVirtualPasskey } from './helpers/webauthn';
import { dumpIndexedDb } from './helpers/idb';

test.describe('@real Recovery on a new device', () => {
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

    // Bea adds a condition record "Gripe"
    await navigateInApp(bea.page, '/app/records');
    await expect(bea.page.getByTestId('area-records')).toBeVisible();
    await bea.page.getByRole('button', { name: 'Añadir' }).first().click();
    await bea.page.getByLabel('Nombre de la condición').fill('Gripe');
    await bea.page.getByRole('button', { name: 'Guardar' }).click();
    await expect(bea.page.getByTestId('area-records')).toContainText('Gripe');

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
    const inviteUrl = await admin.page.getByLabel('Enlace de recuperación').inputValue();
    // The invitation dialog is modal: close it before waiting for the device's request
    await admin.page.getByRole('button', { name: 'Cerrar' }).click();
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

    // Reload device and check that the old record is listed (fixing wizard reload failure from orion4-a.04)
    await reloadAndUnlock(device, '/app/records');
    await expect(device.getByTestId('area-records')).toContainText('Gripe');

    for (const ctx of [admin.context, bea.context, fresh, ...trustees.map((t) => t.context)]) await ctx.close();
  });

  test('code + onboarding file on an empty device', async ({ browser, baseURL }) => {
    test.setTimeout(120_000);
    const charlie = await newMember(browser, baseURL, 'Charlie');
    const charlieCode = charlie.recoveryCode;

    const charlieDbStr = await dumpIndexedDb(charlie.page);
    const charlieDb = JSON.parse(charlieDbStr);
    const charlieMemberIdRow = charlieDb['orion-meta']?.kv?.find((r: any) => r.key === 'memberId');
    const charlieId = charlieMemberIdRow?.value;
    expect(charlieId).toBeTruthy();

    await visit(charlie.page, '/app/settings');
    const downloadPromise = charlie.page.waitForEvent('download');
    await charlie.page.getByRole('button', { name: 'Descargar archivo de recuperación' }).click();
    const download = await downloadPromise;
    const path = await download.path();

    const fresh2 = await browser.newContext({ baseURL });
    const device2 = await fresh2.newPage();
    await addVirtualPasskey(device2);
    await device2.goto('/app/recovery');

    await device2.getByRole('button', { name: 'Usar código de recuperación' }).click();
    await device2.locator('input[type="file"]').setInputFiles(path);
    await device2.locator('textarea').fill(charlieCode);
    await device2.getByRole('button', { name: 'Recuperar', exact: true }).click();

    await expect(device2.getByRole('heading', { name: '¡Recuperación completada!' })).toBeVisible({ timeout: 30_000 });

    const device2DbStr = await dumpIndexedDb(device2);
    const device2Db = JSON.parse(device2DbStr);
    const device2MemberIdRow = device2Db['orion-meta']?.kv?.find((r: any) => r.key === 'memberId');
    expect(device2MemberIdRow?.value).toBe(charlieId);

    await reloadAndUnlock(device2, '/app/records');
    await expect(device2.getByTestId('area-records')).toContainText('No hay condiciones registradas.');

    await charlie.context.close();
    await fresh2.close();
  });

  test.fixme('code after a recovery invitation', () => {
    // U2: needs orion4-a.04
  });
});
