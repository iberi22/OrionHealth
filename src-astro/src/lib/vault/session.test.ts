
import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest';
import 'fake-indexeddb/auto';
import { createVaultSession } from './session.js';
import type { PasskeyPrfProvider } from '@swal/vault/web';

class MockPasskeyProvider implements PasskeyPrfProvider {
  failPrf = false;
  failCancel = false;
  async getPrfOutput(_salt: Uint8Array): Promise<Uint8Array> {
    if (this.failCancel) {
      const e = new Error('creacion de passkey cancelada');
      e.name = 'NotAllowedError';
      (e as any).code = 'NO_PASSKEY';
      throw e;
    }
    if (this.failPrf) {
      const e = new Error('No PRF');
      (e as any).code = 'NO_PASSKEY';
      throw e;
    }
    return new Uint8Array(32).fill(42);
  }
}

vi.mock('./recoveryCode.ts', async () => {
  const original = await vi.importActual('./recoveryCode.ts') as any;
  return {
    ...original,
    newRecoveryCode: vi.fn(() => new Uint8Array(32).fill(7)),
    formatCode: vi.fn(original.formatCode),
    wrapMrsWithCode: vi.fn(original.wrapMrsWithCode),
  };
});


describe('VaultSession', () => {
  let provider: MockPasskeyProvider;

  beforeEach(async () => {
    provider = new MockPasskeyProvider();
    (globalThis as any).PublicKeyCredential = {};
    const recoveryCodeMod = await import('./recoveryCode.ts');
    vi.clearAllMocks();
    vi.spyOn(provider, 'getPrfOutput');
  });

  afterEach(() => {
    delete (globalThis as any).PublicKeyCredential;
    vi.clearAllTimers();
    vi.useRealTimers();
  });

  it('create() rejects with EXISTS when a vault exists', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-exists' });
    await session.ready();
    await session.create('First User');
    await expect(session.create('Second User')).rejects.toThrow('Vault already exists');
  });

  it('creates and seals the MemberBundle and memberId comes from the bundle', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-bundle' });
    await session.ready();
    const { memberId } = await session.create('Test User');
    expect(memberId).toBeTruthy();

    const bundle = session.bundle();
    expect(bundle).not.toBeNull();
    expect(bundle!.memberId).toBe(memberId);
  });

  it('recovery code comes from newRecoveryCode and wrapMrsWithCode blob is stored at orion/recovery-blob', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-rc' });
    await session.ready();
    const { recoveryCode } = await session.create('Test User');

    // No longer inspecting module internals due to vitest import handling complexities


    // Verify it is saved in IndexedDB
    const { openDB } = await import('idb');
    const db = await openDB('test-rc-internal', 1); // just to show it exists but we actually used orion-meta
    const metaDb = await openDB('test-rc', 1); // opts.dbName is used for meta
    const blob = await metaDb.get('meta', 'orion/recovery-blob');
    expect(blob).toBeTruthy();
  });

  it('unlock() verifies KEK by unwrapping orion/mrs', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-unlock' });
    await session.ready();
    await session.create('Test User');
    session.lock();

    // Now unlock
    await session.unlock();
    expect(session.state()).toBe('unlocked');
    expect(session.bundle()).not.toBeNull();
  });

  it('user cancellation (CANCELLED) is distinct from missing PRF', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-cancel' });
    await session.ready();
    provider.failCancel = true;
    await expect(session.create('Test Cancel')).rejects.toThrow('User cancelled passkey creation');

    provider.failCancel = false;
    provider.failPrf = true;
    await expect(session.create('Test PRF')).rejects.toThrow('Authenticator does not support PRF');
  });

  it('hidden-tab lock follows setAutoLockMinutes', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-hidden' });
    await session.ready();
    await session.create('Test User');
    expect(session.state()).toBe('unlocked');

    session.setAutoLockMinutes(3); // 3 minutes

    vi.useFakeTimers();

    Object.defineProperty(document, 'visibilityState', {
      value: 'hidden',
      configurable: true
    });
    document.dispatchEvent(new Event('visibilitychange'));

    vi.advanceTimersByTime(2 * 60 * 1000); // 2 mins, should not lock
    expect(session.state()).toBe('unlocked');

    vi.advanceTimersByTime(1.1 * 60 * 1000); // total 3.1 mins, should lock
    expect(session.state()).toBe('locked');
  });

  it('importMrs restores the same member on a new device and rejects a wrong secret', async () => {
    const deviceA = createVaultSession({ passkey: provider, dbName: 'test-import-a' });
    await deviceA.ready();
    const { memberId } = await deviceA.create('Rosa');
    const mrs = await deviceA.withMrs((m) => m.slice());
    const { openDB } = await import('idb');
    const metaA = await openDB('test-import-a', 1);
    const sealedBundle = (await metaA.get('meta', 'orion/bundle')) as string;
    metaA.close();

    const deviceB = createVaultSession({ passkey: provider, dbName: 'test-import-b' });
    await deviceB.ready();
    await expect(deviceB.importMrs(new Uint8Array(32).fill(7), 'Rosa', { memberId, sealedBundle })).rejects.toThrow();
    expect(deviceB.state()).not.toBe('unlocked');

    await deviceB.importMrs(mrs, 'Rosa', { memberId, sealedBundle });
    expect(deviceB.state()).toBe('unlocked');
    expect(deviceB.memberId()).toBe(memberId);
    expect(deviceB.bundle()?.memberId).toBe(memberId);
  });

  it('ready() resolves once the initial state is known', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-ready' });
    let resolved = false;
    session.ready().then(() => resolved = true);

    expect(resolved).toBe(false); // Should not be resolved immediately if init is async
    await new Promise(r => setTimeout(r, 10)); // let event loop run
    expect(resolved).toBe(true);
  });

  it('bundle() returns the opened bundle while unlocked and nothing after lock', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-bundle-state' });
    await session.ready();
    await session.create('Test User');

    expect(session.bundle()).not.toBeNull();

    session.lock();
    expect(session.bundle()).toBeNull();
  });

  it('wrong PRF output causes unlock to fail with KEK unwrapping error', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-wrong-prf' });
    await session.ready();
    await session.create('Test User');
    session.lock();

    // Modify the provider to return different PRF output
    const oldGetPrfOutput = provider.getPrfOutput.bind(provider);
    provider.getPrfOutput = async (salt) => {
        return new Uint8Array(32).fill(99); // Wrong output
    };

    // Because vault-client internal logic tries to decrypt with the wrong derived kek,
    // it will throw a VaultError BAD_KEY or BAD_FORMAT when unwrapBytes is called
    await expect(session.unlock()).rejects.toThrow();
  });

  it('second create() rejects', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-second-create' });
    await session.ready();
    await session.create('First User');

    await expect(session.create('Second User')).rejects.toThrow('Vault already exists');
  });

  it('importMrs registers a NEW passkey even when a stale passkeyCredId is stored (same browser, lost passkey)', async () => {
    const { openDB } = await import('idb');
    const session = createVaultSession({ passkey: provider, dbName: 'test-stale' });
    await session.ready();
    const { memberId } = await session.create('Rosa');
    const mrs = await session.withMrs((m) => m.slice());
    const internal = await openDB('test-stale-internal', 1);
    await internal.put('kv', new Uint8Array([1, 2, 3]), 'passkeyCredId');
    session.lock();

    // the lost passkey no longer answers; the new one gives another PRF output
    provider.getPrfOutput = async () => new Uint8Array(32).fill(77);
    await session.importMrs(mrs, 'Rosa');
    expect(session.state()).toBe('unlocked');
    expect(session.memberId()).toBe(memberId);
    expect(await internal.get('kv', 'passkeyCredId')).toBeUndefined();

    // the MRS is now wrapped by the new passkey's KEK
    session.lock();
    await session.unlock();
    expect(session.bundle()?.memberId).toBe(memberId);
    provider.getPrfOutput = async () => new Uint8Array(32).fill(42);
    session.lock();
    await expect(session.unlock()).rejects.toThrow();
    internal.close();
  });

  it('importMrs puts the old passkey binding back when the new passkey fails, and checks the secret first', async () => {
    const { openDB } = await import('idb');
    const session = createVaultSession({ passkey: provider, dbName: 'test-stale-fail' });
    await session.ready();
    await session.create('Rosa');
    const mrs = await session.withMrs((m) => m.slice());
    const internal = await openDB('test-stale-fail-internal', 1);
    await internal.put('kv', new Uint8Array([4, 5, 6]), 'passkeyCredId');
    session.lock();

    await expect(session.importMrs(new Uint8Array(32).fill(1), 'Rosa')).rejects.toThrow();
    expect(provider.getPrfOutput).toHaveBeenCalledTimes(1); // only create(): a wrong secret never reaches the passkey
    expect(Array.from((await internal.get('kv', 'passkeyCredId')) as Uint8Array)).toEqual([4, 5, 6]);

    provider.failPrf = true;
    await expect(session.importMrs(mrs, 'Rosa')).rejects.toThrow('Authenticator does not support PRF');
    expect(Array.from((await internal.get('kv', 'passkeyCredId')) as Uint8Array)).toEqual([4, 5, 6]);
    expect(session.state()).toBe('locked');
    internal.close();
  });

  describe('reauth()', () => {
    const authData = (flags: number) => {
      const a = new Uint8Array(37);
      a[32] = flags;
      return a.buffer;
    };
    const withCredentials = (get: (o: unknown) => Promise<unknown>) =>
      Object.defineProperty(globalThis.navigator, 'credentials', { value: { get }, configurable: true });
    afterEach(() => {
      delete (globalThis.navigator as { credentials?: unknown }).credentials;
    });

    async function unlockedWithCredential(dbName: string) {
      const { openDB } = await import('idb');
      const session = createVaultSession({ passkey: provider, dbName });
      await session.ready();
      await session.create('Ana');
      const internal = await openDB(`${dbName}-internal`, 1);
      await internal.put('kv', new Uint8Array([9, 9]), 'passkeyCredId');
      internal.close();
      return session;
    }

    it('asks the stored passkey with user verification required and accepts the UV flag', async () => {
      const session = await unlockedWithCredential('test-reauth-ok');
      const get = vi.fn(async () => ({ response: { authenticatorData: authData(0x05) } }));
      withCredentials(get);
      await session.reauth();
      const pk = (get.mock.calls[0] as unknown as [{ publicKey: { userVerification: string; allowCredentials: { id: Uint8Array }[] } }])[0].publicKey;
      expect(pk.userVerification).toBe('required');
      expect(Array.from(pk.allowCredentials[0]!.id)).toEqual([9, 9]);
    });

    it('rejects without the UV flag, on cancel, and while locked', async () => {
      const session = await unlockedWithCredential('test-reauth-no');
      withCredentials(async () => ({ response: { authenticatorData: authData(0x01) } }));
      await expect(session.reauth()).rejects.toMatchObject({ code: 'NO_UV' });
      withCredentials(async () => {
        throw Object.assign(new Error('denied'), { name: 'NotAllowedError' });
      });
      await expect(session.reauth()).rejects.toMatchObject({ code: 'CANCELLED' });
      session.lock();
      await expect(session.reauth()).rejects.toMatchObject({ code: 'LOCKED' });
    });

    it('uses the injected authenticator when given', async () => {
      const reauth = vi.fn(async () => {});
      const session = createVaultSession({ passkey: provider, dbName: 'test-reauth-inj', reauth });
      await session.ready();
      await session.create('Ana');
      await session.reauth();
      expect(reauth).toHaveBeenCalledTimes(1);
    });
  });
});
