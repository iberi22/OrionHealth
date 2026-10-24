import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest';
import 'fake-indexeddb/auto';
import { createVaultSession } from './session.js';
import type { PasskeyPrfProvider } from '@swal/vault/web';

class MockPasskeyProvider implements PasskeyPrfProvider {
  failPrf = false;
  async getPrfOutput(_salt: Uint8Array): Promise<Uint8Array> {
    if (this.failPrf) {
      const e = new Error('No PRF');
      (e as any).code = 'NO_PASSKEY';
      throw e;
    }
    return new Uint8Array(32).fill(42);
  }
}

describe('VaultSession', () => {
  let provider: MockPasskeyProvider;

  beforeEach(() => {
    provider = new MockPasskeyProvider();
    (globalThis as any).PublicKeyCredential = {};
  });

  afterEach(() => {
    delete (globalThis as any).PublicKeyCredential;
    vi.clearAllTimers();
    vi.useRealTimers();
  });

  it('capabilities report correctly', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-caps' });
    const caps = await session.capabilities();
    expect(caps.webauthn).toBe(true);
    expect(caps.indexedDb).toBe(true);
    expect(caps.prf).toBe('unknown');
  });

  it('create and unlock flow with MRS unwrapping', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-flow' });

    const { memberId, recoveryCode } = await session.create('Test User');
    expect(memberId).toBeTruthy();
    expect(recoveryCode).toBeTruthy();
    expect(session.state()).toBe('unlocked');
    expect(session.displayName()).toBe('Test User');
    expect(session.memberId()).toBe(memberId);

    const caps = await session.capabilities();
    expect(caps.prf).toBe(true);

    await session.withMrs((mrs) => {
      expect(mrs.length).toBe(32);
    });

    session.lock();
    expect(session.state()).toBe('locked');
    expect(session.displayName()).toBeNull();

    await session.unlock();
    expect(session.state()).toBe('unlocked');
    expect(session.displayName()).toBe('Test User');
  });

  it('rejects if PRF unsupported', async () => {
    provider.failPrf = true;
    const session = createVaultSession({ passkey: provider, dbName: 'test-prf-fail' });
    await expect(session.create('Test User')).rejects.toThrow('Authenticator does not support PRF');
    const caps = await session.capabilities();
    expect(caps.prf).toBe(false);
  });

  it('auto-locks after inactivity', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-autolock' });
    await session.create('Test User');
    expect(session.state()).toBe('unlocked');

    vi.useFakeTimers(); // Enable *after* create is done to avoid async timer lockup

    vi.advanceTimersByTime(4 * 60 * 1000);
    expect(session.state()).toBe('unlocked');

    document.dispatchEvent(new Event('mousemove'));

    vi.advanceTimersByTime(2 * 60 * 1000);
    expect(session.state()).toBe('unlocked');

    vi.advanceTimersByTime(4 * 60 * 1000);
    expect(session.state()).toBe('locked');
  });

  it('auto-locks after tab hidden', async () => {
    const session = createVaultSession({ passkey: provider, dbName: 'test-hidden' });
    await session.create('Test User');
    expect(session.state()).toBe('unlocked');

    vi.useFakeTimers();

    Object.defineProperty(document, 'visibilityState', {
      value: 'hidden',
      configurable: true
    });
    document.dispatchEvent(new Event('visibilitychange'));

    vi.advanceTimersByTime(30 * 1000);
    expect(session.state()).toBe('unlocked');

    vi.advanceTimersByTime(35 * 1000);
    expect(session.state()).toBe('locked');
  });
});
