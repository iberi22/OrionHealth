import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { startSignaling } from './helpers/signaling';

test.describe('Family Circle', () => {
  test('creates a circle, invites and joins with local signaling @real', async ({ browser }) => {
    // Start local signaling
    await startSignaling();

    // Context 1: Admin
    const adminContext = await browser.newContext();
    const adminPage = await adminContext.newPage();
    await addVirtualPasskey(adminPage);

    // Context 2: Joiner
    const joinerContext = await browser.newContext();
    const joinerPage = await joinerContext.newPage();
    await addVirtualPasskey(joinerPage);

    // Admin sets up vault and circle
    await adminPage.goto('/app/onboarding');
    await adminPage.getByRole('button', { name: 'Siguiente' }).click();
    await adminPage.getByRole('button', { name: 'Empezar' }).click();

    // Create vault
    await adminPage.getByLabel('¿Cómo te llamas?').fill('Admin');
    await adminPage.getByRole('button', { name: 'Crear passkey' }).click();

    // Confirm recovery code
    const recoveryCodeText = await adminPage.locator('.code-display').textContent();
    const recoveryCode = recoveryCodeText!.trim();
    const parts = recoveryCode.includes('-') ? recoveryCode.split('-') : recoveryCode.split(' ');

    // Fill the 3 required inputs
    const inputs = adminPage.locator('.input-group input');
    const inputCount = await inputs.count();
    for (let i = 0; i < inputCount; i++) {
      const id = await inputs.nth(i).getAttribute('id');
      const idx = parseInt(id!.replace('part-', ''), 10);
      const labelText = await adminPage.locator(`label[for="${id}"]`).textContent();
      // labelText looks like "Parte X" where X is 1-based index of the part in the original code
      const partIdx = parseInt(labelText!.replace('Parte ', ''), 10) - 1;
      await inputs.nth(i).fill(parts[partIdx]);
    }
    await adminPage.getByRole('button', { name: 'Confirmar' }).click();

    // Basic profile
    await adminPage.getByLabel('Nombre completo').fill('Admin Admin');
    await adminPage.getByRole('button', { name: 'Guardar perfil' }).click();

    // Skip Family step during onboarding and go to /app
    await adminPage.getByRole('button', { name: 'Omitir por ahora' }).click();
    await adminPage.getByRole('button', { name: 'Entrar a la app' }).click();

    // Navigate to Family and create a circle
    await adminPage.goto('/app/family');
    await adminPage.getByLabel('Nombre del círculo').fill('La Familia');
    await adminPage.getByRole('button', { name: 'Crear círculo' }).click();

    // Wait for the circle to be created and header to show
    await expect(adminPage.getByRole('heading', { name: 'La Familia' })).toBeVisible();

    // Click "Invitar"
    await adminPage.getByRole('button', { name: 'Invitar' }).click();
    const inviteUrlInput = adminPage.locator('.url-container input');
    await expect(inviteUrlInput).toBeVisible();
    const inviteUrl = await inviteUrlInput.inputValue();

    expect(inviteUrl).toBeTruthy();

    // Joiner navigates to invite URL
    await joinerPage.goto(inviteUrl);
    await joinerPage.getByLabel('Tu nombre').fill('Joiner');
    await joinerPage.getByRole('button', { name: 'Unirse' }).click();

    // Joiner sees SAS code
    const sasCodeLocator = joinerPage.locator('.sas-code');
    await expect(sasCodeLocator).toBeVisible();
    const sasCode = await sasCodeLocator.textContent();
    expect(sasCode).toBeTruthy();

    // Admin approves
    await adminPage.getByRole('button', { name: 'Cerrar' }).click(); // Close invite dialog

    // Setup dialog handler to automatically accept when SAS matches
    adminPage.once('dialog', async (dialog) => {
      const message = dialog.message();
      expect(message).toContain(sasCode!);
      await dialog.accept();
    });

    // Admin should see pending request and click "Revisar"
    const reviewBtn = adminPage.getByRole('button', { name: 'Revisar' }).first();
    await expect(reviewBtn).toBeVisible();
    await reviewBtn.click();

    // Check that Joiner is now in the list of members
    await expect(adminPage.locator('.members-list').getByText('Joiner')).toBeVisible();

    await adminContext.close();
    await joinerContext.close();
  });
});
