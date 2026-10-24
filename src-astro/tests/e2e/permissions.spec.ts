import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { startSignaling } from './helpers/signaling';

test.describe('Permissions', () => {
  test('guardian grant, read vitals, missing access, and revocation @real', async ({ browser }) => {
    await startSignaling();

    const adminContext = await browser.newContext();
    const adminPage = await adminContext.newPage();
    await addVirtualPasskey(adminPage);

    const joinerContext = await browser.newContext();
    const joinerPage = await joinerContext.newPage();
    await addVirtualPasskey(joinerPage);

    // Setup Admin
    await adminPage.goto('/app/onboarding');
    await adminPage.getByRole('button', { name: 'Siguiente' }).click();
    await adminPage.getByRole('button', { name: 'Empezar' }).click();
    await adminPage.getByLabel('¿Cómo te llamas?').fill('Admin');
    await adminPage.getByRole('button', { name: 'Crear passkey' }).click();

    // Confirm recovery code
    const recoveryCodeText = await adminPage.locator('.code-display').textContent();
    const recoveryCode = recoveryCodeText!.trim();
    const parts = recoveryCode.includes('-') ? recoveryCode.split('-') : recoveryCode.split(' ');
    const inputs = adminPage.locator('.input-group input');
    const inputCount = await inputs.count();
    for (let i = 0; i < inputCount; i++) {
      const id = await inputs.nth(i).getAttribute('id');
      const labelText = await adminPage.locator(`label[for="${id}"]`).textContent();
      const partIdx = parseInt(labelText!.replace('Parte ', ''), 10) - 1;
      await inputs.nth(i).fill(parts[partIdx]);
    }
    await adminPage.getByRole('button', { name: 'Confirmar' }).click();
    await adminPage.getByLabel('Nombre completo').fill('Admin Admin');
    await adminPage.getByRole('button', { name: 'Guardar perfil' }).click();
    await adminPage.getByRole('button', { name: 'Omitir por ahora' }).click();
    await adminPage.getByRole('button', { name: 'Entrar a la app' }).click();

    // Admin creates circle
    await adminPage.goto('/app/family');
    await adminPage.getByLabel('Nombre del círculo').fill('La Familia');
    await adminPage.getByRole('button', { name: 'Crear círculo' }).click();
    await expect(adminPage.getByRole('heading', { name: 'La Familia' })).toBeVisible();

    // Admin invites Joiner
    await adminPage.getByRole('button', { name: 'Invitar' }).click();
    const inviteUrlInput = adminPage.locator('.url-container input');
    await expect(inviteUrlInput).toBeVisible();
    const inviteUrl = await inviteUrlInput.inputValue();

    // Joiner joins
    await joinerPage.goto(inviteUrl);
    await joinerPage.getByLabel('Tu nombre').fill('Joiner');
    await joinerPage.getByRole('button', { name: 'Unirse' }).click();

    // Admin approves
    const sasCodeLocator = joinerPage.locator('.sas-code');
    await expect(sasCodeLocator).toBeVisible();
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
    await joinerPage.goto('/app/family');
    await expect(joinerPage.getByRole('heading', { name: 'La Familia' })).toBeVisible();

    // Admin creates a vital record
    await adminPage.goto('/app/records');
    await adminPage.getByRole('tab', { name: 'Signos vitales' }).click();
    await adminPage.getByRole('button', { name: 'Añadir' }).click();
    await adminPage.locator('select#vital-type').selectOption('bp'); // Presión arterial
    await adminPage.getByLabel('Sistólica (mmHg)').fill('120');
    await adminPage.getByLabel('Diastólica (mmHg)').fill('80');
    await adminPage.getByRole('button', { name: 'Guardar' }).click();

    // Verify Admin sees it
    await expect(adminPage.getByText('120/80')).toBeVisible();

    // Joiner goes to guardian view - should not see the record
    await joinerPage.goto('/app/family/guardian');
    await expect(joinerPage.getByText('Actualmente no eres acudiente')).toBeVisible();
    await expect(joinerPage.getByText('120/80')).not.toBeVisible();

    // Admin grants Guardian to Joiner
    await adminPage.goto('/app/family/permissions');
    await adminPage.getByLabel('Miembro familiar').selectOption({ label: 'Joiner' });
    await adminPage.getByLabel('Nivel de acceso').selectOption('guardian');

    adminPage.once('dialog', async (dialog) => {
      await dialog.accept(); // Confirm the Guardian risk warning
    });
    await adminPage.getByRole('button', { name: 'Otorgar acceso' }).click();

    // Ensure it shows up in "Permisos otorgados"
    await expect(adminPage.getByText('Joiner')).toBeVisible();
    await expect(adminPage.getByRole('button', { name: 'Revocar' })).toBeVisible();

    // Joiner reloads Guardian view and can now read the vitals
    await joinerPage.reload();
    // Wait for summary to load
    await expect(joinerPage.getByRole('heading', { name: 'Admin Admin' })).toBeVisible();
    await expect(joinerPage.getByText('120/80')).toBeVisible();

    // Admin revokes access
    adminPage.once('dialog', async (dialog) => {
      await dialog.accept(); // Confirm revocation warning
    });
    await adminPage.getByRole('button', { name: 'Revocar' }).click();
    await expect(adminPage.getByRole('button', { name: 'Revocar' })).not.toBeVisible();

    // Admin creates new vital record
    await adminPage.goto('/app/records');
    await adminPage.getByRole('tab', { name: 'Signos vitales' }).click();
    await adminPage.getByRole('button', { name: 'Añadir' }).click();
    await adminPage.locator('select#vital-type').selectOption('bp');
    await adminPage.getByLabel('Sistólica (mmHg)').fill('130');
    await adminPage.getByLabel('Diastólica (mmHg)').fill('85');
    await adminPage.getByRole('button', { name: 'Guardar' }).click();
    await expect(adminPage.getByText('130/85')).toBeVisible();

    // Joiner should stop seeing new data (won't see 130/85)
    await joinerPage.reload();
    await expect(joinerPage.getByRole('heading', { name: 'Admin Admin' })).toBeVisible();
    await expect(joinerPage.getByText('120/80')).toBeVisible(); // Might still see old data since revocation doesn't erase what was already seen (as stated in the confirm dialog)
    await expect(joinerPage.getByText('130/85')).not.toBeVisible();

    await adminContext.close();
    await joinerContext.close();
  });
});
