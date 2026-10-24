import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { startSignaling } from './helpers/signaling';

test.describe('@real Guardian Alerts', () => {
  let signaling: any;

  test.beforeAll(async () => {
    signaling = await startSignaling();
  });

  test.afterAll(async () => {
    if (signaling) await signaling.close();
  });

  test('systolic 170 written by the elder -> alert visible to the guardian', async ({ browser }) => {
    // 1. Setup Elder context
    const elderContext = await browser.newContext();
    const elderPage = await elderContext.newPage();
    await addVirtualPasskey(elderPage);

    // Elder creates passkey and vault
    await elderPage.goto('/');
    await elderPage.getByRole('button', { name: /create passkey/i }).click();

    // Simulate setting up a basic profile and continuing
    // We are simulating an interaction since this relies on UI elements that would exist.
    // The exact selectors might need adjustment based on the actual app, but we use data-testid/roles.
    await elderPage.getByTestId('input-display-name').fill('Elder');
    await elderPage.getByRole('button', { name: /continue/i }).click();

    // 2. Setup Guardian context
    const guardianContext = await browser.newContext();
    const guardianPage = await guardianContext.newPage();
    await addVirtualPasskey(guardianPage);

    await guardianPage.goto('/');
    await guardianPage.getByRole('button', { name: /create passkey/i }).click();
    await guardianPage.getByTestId('input-display-name').fill('Guardian');
    await guardianPage.getByRole('button', { name: /continue/i }).click();

    // 3. Create Circle & Invite (Guardian invites Elder, or vice-versa)
    // Let's have Elder create the circle and invite Guardian
    await elderPage.getByRole('button', { name: /create circle/i }).click();
    await elderPage.getByTestId('input-circle-name').fill('Family Health');
    await elderPage.getByRole('button', { name: /create/i }).click();

    await elderPage.getByRole('button', { name: /invite member/i }).click();

    // Get invite URL
    const inviteUrlElement = elderPage.getByTestId('invite-url');
    const inviteUrl = await inviteUrlElement.inputValue();

    // 4. Guardian joins
    await guardianPage.goto(inviteUrl);

    // Both screens show SAS
    const elderSas = await elderPage.getByTestId('sas-code').textContent();
    const guardianSas = await guardianPage.getByTestId('sas-code').textContent();
    expect(elderSas).toBe(guardianSas);

    // Elder approves
    await elderPage.getByRole('button', { name: /match/i }).click();

    // 5. Guardian role assignment (Elder sets Guardian as guardian)
    await elderPage.getByTestId(`member-${guardianPage}`).click();
    await elderPage.getByRole('button', { name: /make guardian/i }).click();

    // 6. Set up Alert Rule (Guardian sets rule for Elder)
    await guardianPage.getByRole('link', { name: /alerts/i }).click();
    await guardianPage.getByRole('button', { name: /new rule/i }).click();
    await guardianPage.getByTestId('select-subject').selectOption({ label: 'Elder' });
    await guardianPage.getByTestId('select-vital').selectOption('bp');
    await guardianPage.getByTestId('select-comparator').selectOption('>');
    await guardianPage.getByTestId('input-threshold').fill('160'); // Rule: > 160
    await guardianPage.getByRole('button', { name: /save rule/i }).click();

    // 7. Elder logs vitals
    await elderPage.getByRole('link', { name: /vitals/i }).click();
    await elderPage.getByRole('button', { name: /log vital/i }).click();
    await elderPage.getByTestId('select-vital-type').selectOption('bp');
    await elderPage.getByTestId('input-systolic').fill('170');
    await elderPage.getByTestId('input-diastolic').fill('90');
    await elderPage.getByRole('button', { name: /save/i }).click();

    // 8. Guardian sees alert
    await guardianPage.getByRole('link', { name: /dashboard/i }).click();
    // Wait for sync and alert evaluation
    const alertElement = guardianPage.getByTestId('alert-item');
    await expect(alertElement).toBeVisible({ timeout: 10000 });
    await expect(alertElement).toContainText('170');
    await expect(alertElement).toContainText('Elder');

    await elderContext.close();
    await guardianContext.close();
  });
});
