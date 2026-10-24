import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit } from './helpers/vault';

// Covers the part of recovery the product supports today: a member with a trustee plan (2 of 3)
// starts a family recovery and two trustees approve it from their own devices. Recovery on a brand-new
// device (empty vault, or with the recovery code alone) is NOT covered: the new device has no member
// id, circle key or replica to read the request/code-blob from (see PENDING in lib/app/real.ts).
test.describe('@real Recovery', () => {
  test('2-of-3 trustees approve a family recovery', async ({ browser, baseURL }) => {
    await startSignaling();

    const main = await newMember(browser, baseURL, 'Alice');
    const names = ['Trustee 1', 'Trustee 2', 'Trustee 3'];
    const trustees = [];
    for (const name of names) trustees.push(await newMember(browser, baseURL, name));

    await createCircle(main.page, 'Trust Circle');
    for (const [i, t] of trustees.entries()) await inviteAndJoin(main.page, t.page, names[i]!);

    // Main sets the 2-of-3 trustee plan
    await visit(main.page, '/app/recovery');
    await expect(main.page.getByRole('heading', { name: 'Elegir custodios' })).toBeVisible();
    for (const name of names) await main.page.getByLabel(name).check();
    await main.page.locator('select#threshold-select').selectOption('2');
    main.page.once('dialog', (dialog) => void dialog.accept());
    await main.page.getByRole('button', { name: 'Guardar plan' }).click();

    // An invite link is needed by the wizard to start the family recovery
    await visit(main.page, '/app/family');
    await main.page.getByRole('button', { name: 'Invitar' }).click();
    const inviteUrl = await main.page.locator('.url-container input').inputValue();
    await main.page.getByRole('button', { name: 'Cerrar' }).click();

    await visit(main.page, '/app/recovery');
    await main.page.getByRole('button', { name: 'Recuperar en este dispositivo' }).click();
    await main.page.getByRole('button', { name: 'Recuperar con mi familia' }).click();
    await main.page.getByPlaceholder(/app\/join/).fill(inviteUrl);
    await main.page.getByRole('button', { name: 'Continuar' }).click();
    await expect(main.page.getByRole('heading', { name: 'Esperando aprobaciones' })).toBeVisible();

    // Two of the three trustees approve in their own contexts
    for (const t of trustees.slice(0, 2)) {
      await visit(t.page, '/app/recovery');
      await t.page.getByRole('button', { name: 'Solicitudes' }).click();
      await expect(t.page.getByText('quiere recuperar el acceso')).toBeVisible({ timeout: 20_000 });
      await t.page.getByLabel(/Confirma por llamada/).check();
      await t.page.getByRole('button', { name: 'Aprobar con mi passkey' }).click();
    }

    await expect(main.page.getByRole('heading', { name: '¡Recuperación completada!' })).toBeVisible({ timeout: 30_000 });

    await main.context.close();
    for (const t of trustees) await t.context.close();
  });
});
