import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { startSignaling } from './helpers/signaling';
import { createVault, navigateInApp, visit } from './helpers/vault';

test.describe('Family Circle', () => {
  test('creates a circle, invites and joins with local signaling @real', async ({ browser, baseURL }) => {
    // Start local signaling
    await startSignaling();

    // Context 1: Admin
    const adminContext = await browser.newContext({ baseURL });
    const adminPage = await adminContext.newPage();
    await addVirtualPasskey(adminPage);

    // Context 2: Joiner
    const joinerContext = await browser.newContext({ baseURL });
    const joinerPage = await joinerContext.newPage();
    await addVirtualPasskey(joinerPage);

    // Admin sets up vault and circle
    await createVault(adminPage, 'Admin');

    // Navigate to Family and create a circle
    await visit(adminPage, '/app/family');
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
    // Joining needs the joiner's own (unlocked) vault, so the joiner creates one first and opens the
    // invite client-side (a full load of the link would start a locked session).
    await createVault(joinerPage, 'Joiner');
    const invite = new URL(inviteUrl);
    await navigateInApp(joinerPage, invite.pathname + invite.hash);
    await joinerPage.getByLabel('Tu nombre').fill('Joiner');
    await joinerPage.getByRole('button', { name: 'Unirse' }).click();

    // Joiner sees SAS code
    const sasCodeLocator = joinerPage.locator('.sas-code');
    await expect(sasCodeLocator).toBeVisible({ timeout: 20_000 }); // WebRTC handshake over local signaling
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
