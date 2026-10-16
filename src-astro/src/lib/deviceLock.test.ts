import { describe, it, expect, vi, afterEach } from 'vitest';
import { isDeviceLockAvailable, registerDeviceLock, verifyDeviceLock } from './deviceLock';

describe('deviceLock', () => {
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
      const result = await verifyDeviceLock('fake-cred');
      expect(result).toBe(false);
    });

    it('verifies and returns true on success when id matches', async () => {
      const mockGet = vi.fn().mockResolvedValue({ id: 'fake-cred' });
      vi.stubGlobal('navigator', {
        credentials: { get: mockGet }
      });

      const result = await verifyDeviceLock('fake-cred');
      expect(result).toBe(true);

      expect(mockGet).toHaveBeenCalledTimes(1);
      const args = mockGet.mock.calls[0][0];
      expect(args.publicKey.userVerification).toBe('required');
      expect(args.publicKey.allowCredentials).toBeUndefined();
    });

    it('returns false when credential id does not match', async () => {
      const mockGet = vi.fn().mockResolvedValue({ id: 'wrong-cred' });
      vi.stubGlobal('navigator', {
        credentials: { get: mockGet }
      });

      const result = await verifyDeviceLock('fake-cred');
      expect(result).toBe(false);
    });

    it('swallows errors (e.g. NotAllowedError) and returns false', async () => {
      vi.stubGlobal('navigator', {
        credentials: { get: async () => { throw new Error('NotAllowedError'); } }
      });
      const result = await verifyDeviceLock('fake-cred');
      expect(result).toBe(false);
    });

    it('returns false if get resolves to a falsy value', async () => {
      vi.stubGlobal('navigator', {
        credentials: { get: async () => null }
      });
      const result = await verifyDeviceLock('fake-cred');
      expect(result).toBe(false);
    });
  });
});
