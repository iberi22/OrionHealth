export type DeviceLockResult = {
  id: string;
} | null;

export type DeviceLockOptions = {
  rpName?: string;
  timeout?: number;
};

// Helper to convert a base64url string back to a Uint8Array
function base64urlToUint8Array(base64url: string): Uint8Array {
  const padding = '='.repeat((4 - (base64url.length % 4)) % 4);
  const base64 = (base64url + padding).replace(/-/g, '+').replace(/_/g, '/');
  const rawData = atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

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

export async function registerDeviceLock(options?: DeviceLockOptions): Promise<DeviceLockResult> {
  try {
    if (typeof navigator === 'undefined' || !navigator.credentials || !navigator.credentials.create) {
      return null;
    }

    if (typeof crypto === 'undefined' || typeof crypto.getRandomValues !== 'function') {
      return null;
    }

    const randomUserId = new Uint8Array(16);
    crypto.getRandomValues(randomUserId);

    const challenge = new Uint8Array(16);
    crypto.getRandomValues(challenge);

    const rpName = options?.rpName ?? "OrionHealth Local Session";

    const credential = await navigator.credentials.create({
      publicKey: {
        challenge: challenge as BufferSource,
        rp: {
          name: rpName,
        },
        user: {
          id: randomUserId as BufferSource,
          name: "local-user",
          displayName: "Local User"
        },
        pubKeyCredParams: [
          { type: "public-key", alg: -7 }, // ES256
          { type: "public-key", alg: -257 } // RS256
        ],
        ...options, // User options first
        authenticatorSelection: { // Security settings later to prevent override
          authenticatorAttachment: "platform",
          residentKey: "preferred",
          requireResidentKey: false,
          userVerification: "required"
        }
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

    if (typeof crypto === 'undefined' || typeof crypto.getRandomValues !== 'function') {
      return false;
    }

    const challenge = new Uint8Array(16);
    crypto.getRandomValues(challenge);

    const credentialIdBuffer = base64urlToUint8Array(credentialId);

    const credential = await navigator.credentials.get({
      publicKey: {
        challenge: challenge as BufferSource,
        allowCredentials: [
          {
            type: "public-key",
            id: credentialIdBuffer as BufferSource,
            transports: ["internal"]
          }
        ],
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
