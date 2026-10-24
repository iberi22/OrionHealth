import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { startSignaling } from './helpers/signaling';

test.describe('@real Recovery', () => {
  let signaling: any;

  test.beforeAll(async () => {
    signaling = await startSignaling();
  });

  test.afterAll(async () => {
    if (signaling) await signaling.close();
  });

  test('recovery with the code in a fresh context, and 2-of-3 trustees approving', async ({ browser }) => {
    // We need 4 total contexts for this test (1 member trying to recover, 3 trustees).
    // Wait, the test specifies "recovery with the code in a fresh context, and 2-of-3 trustees approving in their contexts."
    // Let's first create the main member context who creates the circle and sets 3 trustees.
    const mainContext = await browser.newContext();
    const mainPage = await mainContext.newPage();
    await addVirtualPasskey(mainPage);

    await mainPage.goto('/');
    await mainPage.getByRole('button', { name: /create passkey/i }).click();

    // Save recovery code
    const recoveryCodeText = await mainPage.getByTestId('recovery-code').textContent();
    expect(recoveryCodeText).toBeTruthy();

    await mainPage.getByTestId('input-display-name').fill('Alice (Main)');
    await mainPage.getByRole('button', { name: /continue/i }).click();

    // Create a circle
    await mainPage.getByRole('button', { name: /create circle/i }).click();
    await mainPage.getByTestId('input-circle-name').fill('Trust Circle');
    await mainPage.getByRole('button', { name: /create/i }).click();

    // Invite 3 trustees
    const trustees = [];
    for (let i = 0; i < 3; i++) {
      const trusteeContext = await browser.newContext();
      const trusteePage = await trusteeContext.newPage();
      await addVirtualPasskey(trusteePage);

      await trusteePage.goto('/');
      await trusteePage.getByRole('button', { name: /create passkey/i }).click();
      await trusteePage.getByTestId('input-display-name').fill(`Trustee ${i+1}`);
      await trusteePage.getByRole('button', { name: /continue/i }).click();

      // Main invites trustee
      await mainPage.getByRole('button', { name: /invite member/i }).click();
      const inviteUrl = await mainPage.getByTestId('invite-url').inputValue();

      // Trustee joins
      await trusteePage.goto(inviteUrl);
      const mainSas = await mainPage.getByTestId('sas-code').textContent();
      const trusteeSas = await trusteePage.getByTestId('sas-code').textContent();
      expect(mainSas).toBe(trusteeSas);

      // Main approves
      await mainPage.getByRole('button', { name: /match/i }).click();

      trustees.push({ context: trusteeContext, page: trusteePage });
    }

    // Main sets 2-of-3 trustees policy
    await mainPage.getByRole('link', { name: /recovery/i }).click();
    await mainPage.getByRole('button', { name: /setup trustees/i }).click();

    // Select all 3 trustees
    for (let i = 0; i < 3; i++) {
      await mainPage.getByTestId(`select-trustee-${i}`).click();
    }

    // Set threshold to 2
    await mainPage.getByTestId('input-threshold').fill('2');
    await mainPage.getByRole('button', { name: /save policy/i }).click();

    // Main loses phone/session... we create a new context to simulate recovery.
    const recoveryContext = await browser.newContext();
    const recoveryPage = await recoveryContext.newPage();
    await addVirtualPasskey(recoveryPage);

    await recoveryPage.goto('/');
    await recoveryPage.getByRole('button', { name: /recover/i }).click();

    // The user has two options generally: by code or by trustees.
    // The prompt says: "recovery with the code in a fresh context, and 2-of-3 trustees approving in their contexts."
    // Let's do the trustee recovery request first (since it involves the trustees),
    // Or we do both sequentially/interleaved if the code allows.
    // Assuming the test implies we initiate a social recovery request, and separately verify code recovery,
    // or the test uses the social recovery flow where 2-of-3 trustees approve.
    // Wait, let's re-read: "recovery with the code in a fresh context, and 2-of-3 trustees approving in their contexts"
    // Usually these are two separate flows. Let's start social recovery.

    // 1. Social Recovery Flow
    await recoveryPage.getByRole('button', { name: /social recovery/i }).click();

    // Need invite from any admin for social recovery
    await mainPage.getByRole('button', { name: /invite member/i }).click(); // assuming we can still use mainPage to invite, or one of trustees
    const recoveryInviteUrl = await mainPage.getByTestId('invite-url').inputValue();
    await recoveryPage.getByTestId('input-recovery-invite').fill(recoveryInviteUrl);
    await recoveryPage.getByRole('button', { name: /continue/i }).click();

    const recSas = await recoveryPage.getByTestId('sas-code').textContent();
    const invSas = await mainPage.getByTestId('sas-code').textContent();
    expect(recSas).toBe(invSas);
    await mainPage.getByRole('button', { name: /match/i }).click();

    // Recovery page waits for trustees
    await expect(recoveryPage.getByText(/awaiting approvals/i)).toBeVisible();

    // 2 of 3 trustees approve
    for (let i = 0; i < 2; i++) {
      const tPage = trustees[i].page;
      await tPage.getByRole('link', { name: /recovery/i }).click();
      await tPage.getByTestId('pending-recovery-request').click();
      await tPage.getByRole('button', { name: /approve/i }).click();
      // Assume they need to re-verify passkey or just click approve
    }

    // Wait for recovery to complete on new device
    await expect(recoveryPage.getByText(/register new passkey/i)).toBeVisible();
    await recoveryPage.getByRole('button', { name: /register/i }).click();
    await expect(recoveryPage.getByRole('heading', { name: /dashboard/i })).toBeVisible();

    // 2. Recovery with Code Flow in another fresh context
    const codeContext = await browser.newContext();
    const codePage = await codeContext.newPage();
    await addVirtualPasskey(codePage);

    await codePage.goto('/');
    await codePage.getByRole('button', { name: /recover/i }).click();
    await codePage.getByRole('button', { name: /recovery code/i }).click();
    await codePage.getByTestId('input-recovery-code').fill(recoveryCodeText || '');
    await codePage.getByRole('button', { name: /continue/i }).click();

    await expect(codePage.getByText(/register new passkey/i)).toBeVisible();
    await codePage.getByRole('button', { name: /register/i }).click();
    await expect(codePage.getByRole('heading', { name: /dashboard/i })).toBeVisible();

    // Cleanup
    await mainContext.close();
    await recoveryContext.close();
    await codeContext.close();
    for (const t of trustees) {
      await t.context.close();
    }
  });
});
