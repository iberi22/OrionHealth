import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit, createVault } from './helpers/vault';
import { addVirtualPasskey } from './helpers/webauthn';
import fs from 'fs';
import path from 'path';
import os from 'os';

test.describe('@real Recovery with new device (v2)', () => {
  test('recovers via admin invite + trustees, then code+file, then invite+code', async ({ browser, baseURL }) => {
    test.setTimeout(240_000); // 4 minutes for 3 recoveries
    await startSignaling();

    const admin = await newMember(browser, baseURL, 'Alice');

    // Create Bea manually to capture the recovery file
    const beaCtx = await browser.newContext({ baseURL });
    const beaPage = await beaCtx.newPage();
    await addVirtualPasskey(beaPage);

    await beaPage.goto('/app/onboarding');
    await expect(beaPage.locator('[data-testid="area-onboarding"]')).toBeVisible();

    while (await beaPage.locator('button', { hasText: 'Siguiente' }).isVisible()) {
      await beaPage.locator('button', { hasText: 'Siguiente' }).click();
    }
    await beaPage.locator('button', { hasText: 'Empezar' }).click();

    await beaPage.locator('input#vault-name').fill('Bea');
    await beaPage.locator('button', { hasText: 'Crear passkey' }).click();

    const codeDisplay = beaPage.locator('.code-display');
    await expect(codeDisplay).toBeVisible();
    const codeText = (await codeDisplay.textContent())!.trim();
    const parts = codeText.includes('-') ? codeText.split('-') : codeText.split(' ');
    const beaCode = codeText;

    // Wait for the file download
    const [download] = await Promise.all([
      beaPage.waitForEvent('download'),
      beaPage.locator('button', { hasText: 'Descargar archivo de recuperación' }).click()
    ]);
    const downloadPath = path.join(os.tmpdir(), 'orion-recovery.json');
    await download.saveAs(downloadPath);

    for (let i = 0; i < 3; i++) {
      const labelText = await beaPage.locator(`label[for="part-${i}"]`).textContent();
      const idx = parseInt(labelText!.match(/Parte (\d+)/)![1]!, 10) - 1;
      await beaPage.locator(`input#part-${i}`).fill(parts[idx]!);
    }
    await beaPage.locator('button', { hasText: 'Confirmar' }).click();

    await expect(beaPage.locator('h2', { hasText: 'Perfil básico' })).toBeVisible();
    await beaPage.locator('input#full-name').fill('Bea');
    await beaPage.locator('button', { hasText: 'Guardar perfil' }).click();

    await expect(beaPage.locator('h2', { hasText: 'Familia' })).toBeVisible();
    await beaPage.locator('button', { hasText: 'Omitir por ahora' }).click();

    await expect(beaPage.locator('h2', { hasText: '¡Todo listo!' })).toBeVisible();
    await beaPage.locator('button', { hasText: 'Entrar a la app' }).click();
    await expect(beaPage.locator('[data-testid="area-home"]')).toBeVisible();

    const bea = { context: beaCtx, page: beaPage, recoveryCode: beaCode };

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

    // Bea creates a record to verify restoration
    await visit(bea.page, '/app/records');
    await bea.page.locator('button', { hasText: 'Añadir' }).first().click();
    await bea.page.locator('input#cond-name').fill('Gripe');
    await bea.page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
    await expect(bea.page.locator('.record-list')).toContainText('Gripe');

    // ---------------------------------------------------------
    // 1st Recovery: Admin Invite + 2 of 3 Trustees
    // ---------------------------------------------------------

    // The admin creates a recovery invitation for Bea
    await visit(admin.page, '/app/recovery');
    await admin.page.getByRole('button', { name: 'Solicitudes' }).click();
    await admin.page.getByLabel('Miembro a recuperar').selectOption({ label: 'Bea' });
    await admin.page.getByRole('button', { name: 'Crear invitación de recuperación' }).click();
    const inviteUrl = await admin.page.getByLabel('Enlace de recuperación').inputValue();
    await admin.page.getByRole('button', { name: 'Cerrar' }).click();
    expect(inviteUrl).toContain('/app/recovery#');

    // Brand-new device 1
    const fresh1 = await browser.newContext({ baseURL });
    const device1 = await fresh1.newPage();
    await addVirtualPasskey(device1);
    await device1.goto(inviteUrl);
    await device1.getByRole('button', { name: 'Continuar' }).click();
    await expect(device1.getByRole('heading', { name: 'Conectando con tu familia...' })).toBeVisible();
    const sas1 = (await device1.locator('.sas').textContent({ timeout: 20_000 }))!.trim();

    // Admin vouches
    const join1 = admin.page.locator('.request-card', { hasText: 'dice ser de' });
    await expect(join1).toContainText(sas1, { timeout: 20_000 });
    await join1.getByRole('button', { name: 'Coincide', exact: true }).click();
    await expect(device1.getByRole('heading', { name: 'Esperando aprobaciones' })).toBeVisible({ timeout: 20_000 });

    // Two of the three trustees check the SAS and approve
    for (const t of trustees.slice(0, 2)) {
      await visit(t.page, '/app/recovery');
      await t.page.getByRole('button', { name: 'Solicitudes' }).click();
      const card = t.page.locator('.request-card', { hasText: 'Solicitud de recuperación para la cuenta de' });
      await expect(card).toContainText('Bea', { timeout: 30_000 });
      await expect(card).toContainText(sas1);
      await card.getByLabel(/Llamé o vi en persona/).check();
      await card.getByRole('button', { name: 'Aprobar con mi passkey' }).click();
    }

    await expect(device1.getByRole('heading', { name: '¡Recuperación completada!' })).toBeVisible({ timeout: 30_000 });
    await device1.getByRole('button', { name: 'Ir al inicio' }).click();
    await visit(device1, '/app/records');
    await expect(device1.locator('.record-list')).toContainText('Gripe');
    await fresh1.close();

    // ---------------------------------------------------------
    // 2nd Recovery: Code + orion-recovery.json File
    // ---------------------------------------------------------
    const fresh2 = await browser.newContext({ baseURL });
    const device2 = await fresh2.newPage();
    await addVirtualPasskey(device2);

    await visit(device2, '/app/recovery');
    await device2.getByRole('button', { name: 'Usar código de recuperación' }).click();

    // Set the file and input the code
    await device2.setInputFiles('input[type="file"]', downloadPath);
    await device2.locator('textarea').fill(beaCode);
    await device2.getByRole('button', { name: 'Recuperar' }).click();

    await expect(device2.getByRole('heading', { name: '¡Recuperación completada!' })).toBeVisible({ timeout: 30_000 });
    await device2.getByRole('button', { name: 'Ir al inicio' }).click();
    await visit(device2, '/app/records');
    await expect(device2.locator('.record-list')).toContainText('Gripe');
    await fresh2.close();

    for (const ctx of [admin.context, beaCtx, fresh2, ...trustees.map((t) => t.context)]) await ctx.close();
  });
});
