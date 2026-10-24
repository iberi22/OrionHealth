import type { Page } from '@playwright/test';

/**
 * Enables WebAuthn and adds a virtual authenticator to the page.
 * Uses CDP to simulate a passkey compatible with PRF.
 */
export async function addVirtualPasskey(page: Page) {
  const cdpSession = await page.context().newCDPSession(page);
  await cdpSession.send('WebAuthn.enable');
  await cdpSession.send('WebAuthn.addVirtualAuthenticator', {
    options: {
      protocol: 'ctap2',
      transport: 'internal',
      hasUserVerification: true,
      isUserVerified: true,
      hasResidentKey: true,
      hasPrf: true,
    },
  });
  return cdpSession;
}
