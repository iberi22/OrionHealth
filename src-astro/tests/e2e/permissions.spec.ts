import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { startSignaling } from './helpers/signaling';
import { createVault, navigateInApp, reloadAndUnlock, visit } from './helpers/vault';

test.describe('Permissions', () => {
  test('guardian grant, read vitals, missing access, and revocation @real', async ({ browser, baseURL }) => {
    await startSignaling();

    const adminContext = await browser.newContext({ baseURL });
    const adminPage = await adminContext.newPage();
    await addVirtualPasskey(adminPage);

    const joinerContext = await browser.newContext({ baseURL });
    const joinerPage = await joinerContext.newPage();
    await addVirtualPasskey(joinerPage);

    // Setup Admin
    await createVault(adminPage, 'Admin');

    // Admin creates circle
    await visit(adminPage, '/app/family');
    await adminPage.getByLabel('Nombre del círculo').fill('La Familia');
    await adminPage.getByRole('button', { name: 'Crear círculo' }).click();
    await expect(adminPage.getByRole('heading', { name: 'La Familia' })).toBeVisible();

    // Admin invites Joiner
    await adminPage.getByRole('button', { name: 'Invitar' }).click();
    const inviteUrlInput = adminPage.locator('.url-container input');
    await expect(inviteUrlInput).toBeVisible();
    const inviteUrl = await inviteUrlInput.inputValue();

    // Joiner joins
    // Joining needs the joiner's own (unlocked) vault; the invite is opened client-side.
    await createVault(joinerPage, 'Joiner');
    const invite = new URL(inviteUrl);
    await navigateInApp(joinerPage, invite.pathname + invite.hash);
    await joinerPage.getByLabel('Tu nombre').fill('Joiner');
    await joinerPage.getByRole('button', { name: 'Unirse' }).click();

    // Admin approves
    const sasCodeLocator = joinerPage.locator('.sas-code');
    await expect(sasCodeLocator).toBeVisible({ timeout: 20_000 }); // WebRTC handshake over local signaling
    const sasCode = await sasCodeLocator.textContent();

    await adminPage.getByRole('button', { name: 'Cerrar' }).click();
    adminPage.once('dialog', async (dialog) => {
      await dialog.accept();
    });
    const reviewBtn = adminPage.getByRole('button', { name: 'Revisar' }).first();
    await expect(reviewBtn).toBeVisible();
    await reviewBtn.click();
    await expect(adminPage.locator('.members-list').getByText('Joiner')).toBeVisible();

    // Wait for the joiner page to successfully redirect/reflect the approved join.
    // The user might be redirected to /app once approved, but let's navigate to ensure state.
    await visit(joinerPage, '/app/family');
    await expect(joinerPage.getByRole('heading', { name: 'La Familia' })).toBeVisible();

    // Admin creates a vital record
    await visit(adminPage, '/app/records');
    await adminPage.getByRole('tab', { name: 'Signos vitales' }).click();
    await adminPage.getByRole('button', { name: 'Añadir' }).click();
    await adminPage.locator('select#vital-type').selectOption('bp'); // Presión arterial
    await adminPage.getByLabel('Sistólica (mmHg)').fill('120');
    await adminPage.getByLabel('Diastólica (mmHg)').fill('80');
    await adminPage.getByRole('button', { name: 'Guardar' }).click();

    // Verify Admin sees it
    await expect(adminPage.getByText('120/80')).toBeVisible();

    // Joiner goes to guardian view - should not see the record
    await visit(joinerPage, '/app/family/guardian');
    await expect(joinerPage.getByText('Actualmente no eres acudiente')).toBeVisible();
    await expect(joinerPage.getByText(/120 mmHg \/ 80/)).not.toBeVisible();

    // Admin grants Guardian to Joiner
    await visit(adminPage, '/app/family/permissions');
    await adminPage.getByLabel('Miembro familiar').selectOption({ label: 'Joiner' });
    await adminPage.getByLabel('Nivel de acceso').selectOption('guardian');

    adminPage.once('dialog', async (dialog) => {
      await dialog.accept(); // Confirm the Guardian risk warning
    });
    await adminPage.getByRole('button', { name: 'Otorgar acceso' }).click();

    // Ensure it shows up in "Permisos otorgados"
    await expect(adminPage.locator('.grant-list .grant-item').getByText('Joiner').first()).toBeVisible();
    // A guardian grant is one grant per category, each with its own Revocar button
    await expect(adminPage.getByRole('button', { name: 'Revocar' }).first()).toBeVisible();

    // Joiner reloads Guardian view and can now read the vitals
    await reloadAndUnlock(joinerPage, '/app/family/guardian');
    await expect(joinerPage.getByRole('heading', { name: 'Admin', exact: true })).toBeVisible();
    await expect(joinerPage.getByText(/120 mmHg \/ 80/)).toBeVisible();

    // Admin revokes access (every category grant)
    adminPage.on('dialog', (dialog) => void dialog.accept()); // Confirm revocation warnings
    const revokeButtons = adminPage.getByRole('button', { name: 'Revocar' });
    while ((await revokeButtons.count()) > 0) {
      const before = await revokeButtons.count();
      await revokeButtons.first().click();
      await expect(revokeButtons).toHaveCount(before - 1);
    }
    await expect(adminPage.getByRole('button', { name: 'Revocar' })).not.toBeVisible();

    // Admin creates new vital record
    await visit(adminPage, '/app/records');
    await adminPage.getByRole('tab', { name: 'Signos vitales' }).click();
    await adminPage.getByRole('button', { name: 'Añadir' }).click();
    await adminPage.locator('select#vital-type').selectOption('bp');
    await adminPage.getByLabel('Sistólica (mmHg)').fill('130');
    await adminPage.getByLabel('Diastólica (mmHg)').fill('85');
    await adminPage.getByRole('button', { name: 'Guardar' }).click();
    await expect(adminPage.getByText('130/85')).toBeVisible();

    // After revocation the joiner no longer reads any of the admin's data: the guardian view is empty
    // (what was already seen cannot be erased from a person's memory, as the confirm dialog says, but
    // the app keeps showing nothing).
    await reloadAndUnlock(joinerPage, '/app/family/guardian');
    await expect(joinerPage.getByText('Actualmente no eres acudiente')).toBeVisible();
    await expect(joinerPage.getByText(/120 mmHg \/ 80/)).not.toBeVisible();
    await expect(joinerPage.getByText(/130 mmHg \/ 85/)).not.toBeVisible();

    await adminContext.close();
    await joinerContext.close();
  });
});
