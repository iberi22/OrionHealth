export type DeviceLockResult = {
  id: string;
} | null;

export async function isDeviceLockAvailable(): Promise<boolean> {
  try {
    if (typeof globalThis.PublicKeyCredential !== 'undefined' &&
        typeof globalThis.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable === 'function') {
      return await globalThis.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
    }
    return false;
  } catch (e) {
    return false;
  }
}

export async function registerDeviceLock(options?: any): Promise<DeviceLockResult> {
  try {
    if (typeof navigator === 'undefined' || !navigator.credentials || !navigator.credentials.create) {
      return null;
    }

    const randomUserId = new Uint8Array(16);
    if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
      crypto.getRandomValues(randomUserId);
    } else {
      for (let i = 0; i < randomUserId.length; i++) {
        randomUserId[i] = Math.floor(Math.random() * 256);
      }
    }

    const credential = await navigator.credentials.create({
      publicKey: {
        challenge: new Uint8Array(16), // Dummy challenge, as we only need the ID
        rp: {
          name: "OrionHealth Local Session",
        },
        user: {
          id: randomUserId,
          name: "local-user",
          displayName: "Local User"
        },
        pubKeyCredParams: [
          { type: "public-key", alg: -7 }, // ES256
          { type: "public-key", alg: -257 } // RS256
        ],
        authenticatorSelection: {
          authenticatorAttachment: "platform",
          residentKey: "preferred",
          requireResidentKey: false,
          userVerification: "required"
        },
        ...options
      }
    }) as PublicKeyCredential;

    if (credential && credential.id) {
      return { id: credential.id };
    }
    return null;
  } catch (e) {
    return null;
  }
}

export async function verifyDeviceLock(credentialId: string): Promise<boolean> {
  try {
    if (typeof navigator === 'undefined' || !navigator.credentials || !navigator.credentials.get) {
      return false;
    }

    const credential = await navigator.credentials.get({
      publicKey: {
        challenge: new Uint8Array(16),
        userVerification: "required"
      }
    }) as PublicKeyCredential;

    if (credential && credential.id === credentialId) {
        return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}
