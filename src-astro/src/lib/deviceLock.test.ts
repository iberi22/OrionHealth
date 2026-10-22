import { describe, it, expect, vi, afterEach, beforeEach } from 'vitest';
import { isDeviceLockAvailable, registerDeviceLock, verifyDeviceLock } from './deviceLock';

describe('deviceLock', () => {
  beforeEach(() => {
    vi.stubGlobal('crypto', {
      getRandomValues: (arr: Uint8Array) => {
        for(let i=0; i<arr.length; i++) arr[i] = 42; // use 42 to easily assert it was changed
        return arr;
      }
    });
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  describe('isDeviceLockAvailable', () => {
    it('returns false when PublicKeyCredential is undefined', async () => {
      vi.stubGlobal('PublicKeyCredential', undefined);
      const result = await isDeviceLockAvailable();
      expect(result).toBe(false);
    });

    it('returns false when isUserVerifyingPlatformAuthenticatorAvailable is missing', async () => {
      vi.stubGlobal('PublicKeyCredential', {});
      const result = await isDeviceLockAvailable();
      expect(result).toBe(false);
    });

    it('returns true when platform authenticator is available', async () => {
      vi.stubGlobal('PublicKeyCredential', {
        isUserVerifyingPlatformAuthenticatorAvailable: async () => true,
      });
      const result = await isDeviceLockAvailable();
      expect(result).toBe(true);
    });

    it('returns false when platform authenticator is not available', async () => {
      vi.stubGlobal('PublicKeyCredential', {
        isUserVerifyingPlatformAuthenticatorAvailable: async () => false,
      });
      const result = await isDeviceLockAvailable();
      expect(result).toBe(false);
    });

    it('swallows errors and returns false', async () => {
      vi.stubGlobal('PublicKeyCredential', {
        isUserVerifyingPlatformAuthenticatorAvailable: async () => { throw new Error('stub error'); },
      });
      const result = await isDeviceLockAvailable();
      expect(result).toBe(false);
    });
  });

  describe('registerDeviceLock', () => {
    it('returns null if navigator.credentials is not available', async () => {
      vi.stubGlobal('navigator', {});
      const result = await registerDeviceLock();
      expect(result).toBeNull();
    });

    it('returns null if crypto.getRandomValues is missing', async () => {
      vi.stubGlobal('crypto', undefined);
      vi.stubGlobal('navigator', {
        credentials: { create: async () => ({ id: 'fake-cred' }) }
      });
      const result = await registerDeviceLock();
      expect(result).toBeNull();
    });

    it('registers and returns credential id on success', async () => {
      const mockCreate = vi.fn().mockResolvedValue({ id: 'fake-cred' });
      vi.stubGlobal('navigator', {
        credentials: { create: mockCreate }
      });

      const result = await registerDeviceLock();
      expect(result).toEqual({ id: 'fake-cred' });

      expect(mockCreate).toHaveBeenCalledTimes(1);
      const args = mockCreate.mock.calls[0][0];
      expect(args.publicKey.authenticatorSelection.userVerification).toBe('required');
      expect(args.publicKey.authenticatorSelection.residentKey).toBe('preferred');
    });

    it('generates challenge and user id using crypto.getRandomValues', async () => {
      const mockCreate = vi.fn().mockResolvedValue({ id: 'fake-cred' });
      vi.stubGlobal('navigator', {
        credentials: { create: mockCreate }
      });

      const getRandomValuesSpy = vi.spyOn(globalThis.crypto, 'getRandomValues');

      await registerDeviceLock();

      expect(mockCreate).toHaveBeenCalledTimes(1);
      const args = mockCreate.mock.calls[0][0];

      const challenge = args.publicKey.challenge as Uint8Array;
      const userId = args.publicKey.user.id as Uint8Array;

      expect(getRandomValuesSpy).toHaveBeenCalledTimes(2);
      expect(challenge[0]).toBe(42); // Asserts our stub was called
      expect(userId[0]).toBe(42);    // Asserts our stub was called
    });

    it('prevents caller from weakening security options', async () => {
      const mockCreate = vi.fn().mockResolvedValue({ id: 'fake-cred' });
      vi.stubGlobal('navigator', {
        credentials: { create: mockCreate }
      });

      // Pass malicious options that attempt to override authenticatorSelection
      const result = await registerDeviceLock({
        authenticatorSelection: { userVerification: 'discouraged' }
      } as any);

      expect(result).toEqual({ id: 'fake-cred' });
      const args = mockCreate.mock.calls[0][0];
      // Security options should be applied AFTER the spread, so 'required' is maintained
      expect(args.publicKey.authenticatorSelection.userVerification).toBe('required');
    });

    it('swallows errors and returns null', async () => {
      vi.stubGlobal('navigator', {
        credentials: { create: async () => { throw new Error('NotAllowedError'); } }
      });
      const result = await registerDeviceLock();
      expect(result).toBeNull();
    });

    it('returns null if create resolves to a falsy value', async () => {
      vi.stubGlobal('navigator', {
        credentials: { create: async () => null }
      });
      const result = await registerDeviceLock();
      expect(result).toBeNull();
    });
  });

  describe('verifyDeviceLock', () => {
    it('returns false if navigator.credentials is not available', async () => {
      vi.stubGlobal('navigator', {});
      const result = await verifyDeviceLock('ZmFrZS1jcmVk'); // base64url of "fake-cred"
      expect(result).toBe(false);
    });

    it('returns false if crypto.getRandomValues is missing', async () => {
      vi.stubGlobal('crypto', undefined);
      vi.stubGlobal('navigator', {
        credentials: { get: async () => ({ id: 'fake-cred' }) }
      });
      const result = await verifyDeviceLock('ZmFrZS1jcmVk');
      expect(result).toBe(false);
    });

    it('verifies and returns true on success with allowCredentials using decoded buffer', async () => {
      // "fake-cred" encoded in base64url is "ZmFrZS1jcmVk"
      const fakeCredBase64 = 'ZmFrZS1jcmVk';
      const mockGet = vi.fn().mockResolvedValue({ id: fakeCredBase64 });
      vi.stubGlobal('navigator', {
        credentials: { get: mockGet }
      });

      const result = await verifyDeviceLock(fakeCredBase64);
      expect(result).toBe(true);

      expect(mockGet).toHaveBeenCalledTimes(1);
      const args = mockGet.mock.calls[0][0];
      expect(args.publicKey.userVerification).toBe('required');

      const allowCreds = args.publicKey.allowCredentials;
      expect(allowCreds).toBeDefined();
      expect(allowCreds[0].type).toBe('public-key');
      expect(allowCreds[0].transports).toEqual(['internal']);
      expect(allowCreds[0].id).toBeInstanceOf(Uint8Array);

      // Decoded bytes of "fake-cred"
      const expectedDecoded = new Uint8Array([102, 97, 107, 101, 45, 99, 114, 101, 100]);
      expect(allowCreds[0].id).toEqual(expectedDecoded);
    });

    it('generates challenge using crypto.getRandomValues', async () => {
      const fakeCredBase64 = 'ZmFrZS1jcmVk';
      const mockGet = vi.fn().mockResolvedValue({ id: fakeCredBase64 });
      vi.stubGlobal('navigator', {
        credentials: { get: mockGet }
      });

      const getRandomValuesSpy = vi.spyOn(globalThis.crypto, 'getRandomValues');

      await verifyDeviceLock(fakeCredBase64);

      expect(mockGet).toHaveBeenCalledTimes(1);
      const args = mockGet.mock.calls[0][0];

      const challenge = args.publicKey.challenge as Uint8Array;

      expect(getRandomValuesSpy).toHaveBeenCalledTimes(1);
      expect(challenge[0]).toBe(42); // Asserts our stub was called
    });

    it('returns false when credential id does not match', async () => {
      const mockGet = vi.fn().mockResolvedValue({ id: 'wrong-cred' });
      vi.stubGlobal('navigator', {
        credentials: { get: mockGet }
      });

      const result = await verifyDeviceLock('ZmFrZS1jcmVk');
      expect(result).toBe(false);
    });

    it('swallows errors (e.g. NotAllowedError) and returns false', async () => {
      vi.stubGlobal('navigator', {
        credentials: { get: async () => { throw new Error('NotAllowedError'); } }
      });
      const result = await verifyDeviceLock('ZmFrZS1jcmVk');
      expect(result).toBe(false);
    });

    it('returns false if get resolves to a falsy value', async () => {
      vi.stubGlobal('navigator', {
        credentials: { get: async () => null }
      });
      const result = await verifyDeviceLock('ZmFrZS1jcmVk');
      expect(result).toBe(false);
    });
  });
});
