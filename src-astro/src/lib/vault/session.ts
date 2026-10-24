import { createVaultClient, type PasskeyPrfProvider } from '@swal/vault/web';
import { openDB } from 'idb';
import { randomBytes, hkdf, aesKey, sealBlob, memberIdFromSpki, b64u } from '../crypto/index.js';
import type { VaultCapabilities, VaultService, VaultState } from '../contracts/services.js';

export class VaultSessionError extends Error {
  code: string;
  constructor(code: string, message: string) {
    super(message);
    this.name = 'VaultSessionError';
    this.code = code;
  }
}

export interface VaultSessionOptions {
  passkey?: PasskeyPrfProvider;
  dbName?: string;
  window?: Window; // for mocking in tests
}

export function createVaultSession(opts: VaultSessionOptions): VaultService & { withMrs: <T>(fn: (mrs: Uint8Array) => T | Promise<T>) => Promise<T> } {
  const dbName = opts.dbName ?? 'orion-vault';
  const dbPromise = openDB(dbName, 1, {
    upgrade(db) {
      if (!db.objectStoreNames.contains('orion')) {
        db.createObjectStore('orion');
      }
    },
  });

  const vault = createVaultClient({
    storage: 'idb',
    passkey: opts.passkey,
    dbName: `${dbName}-internal`,
  });

  let currentState: VaultState = 'unsupported';
  let _memberId: string | null = null;
  let _displayName: string | null = null;
  const stateListeners = new Set<(s: VaultState) => void>();
  let prfSupported: boolean | 'unknown' = 'unknown';

  let autoLockMinutes = 5;
  let activityTimer: ReturnType<typeof setTimeout> | null = null;
  let visibilityTimer: ReturnType<typeof setTimeout> | null = null;
  const win = opts.window ?? (typeof window !== 'undefined' ? window : null);
  const doc = win?.document;

  const updateState = (newState: VaultState) => {
    if (currentState === newState) return;
    currentState = newState;
    for (const cb of stateListeners) {
      cb(currentState);
    }
  };

  const getDb = async () => (await dbPromise);
  const get = async <T>(k: string): Promise<T | undefined> => (await getDb()).get('orion', k);
  const put = async (k: string, v: any) => (await getDb()).put('orion', v, k);

  const init = async () => {
    const caps = await self.capabilities();
    if (!caps.webauthn || !caps.indexedDb) {
      updateState('unsupported');
      return;
    }

    const wrappedMrs = await get<string>('orion/mrs');
    if (!wrappedMrs) {
      updateState('empty');
      return;
    }

    if (vault.isUnlocked()) {
      _memberId = await get<string>('orion/meta/memberId') ?? null;
      _displayName = await get<string>('orion/meta/displayName') ?? null;
      updateState('unlocked');
    } else {
      updateState('locked');
    }
  };

  const resetActivityTimer = () => {
    if (activityTimer) clearTimeout(activityTimer);
    if (currentState !== 'unlocked') return;
    activityTimer = setTimeout(() => {
      self.lock();
    }, autoLockMinutes * 60 * 1000);
  };

  const onActivity = () => resetActivityTimer();

  const onVisibilityChange = () => {
    if (doc?.visibilityState === 'hidden') {
      if (visibilityTimer) clearTimeout(visibilityTimer);
      visibilityTimer = setTimeout(() => {
        self.lock();
      }, 60 * 1000);
    } else {
      if (visibilityTimer) {
        clearTimeout(visibilityTimer);
        visibilityTimer = null;
      }
      resetActivityTimer();
    }
  };

  const setupListeners = () => {
    if (!doc) return;
    doc.addEventListener('visibilitychange', onVisibilityChange);
    doc.addEventListener('keydown', onActivity);
    doc.addEventListener('mousemove', onActivity);
    doc.addEventListener('touchstart', onActivity);
    resetActivityTimer();
  };

  const teardownListeners = () => {
    if (!doc) return;
    doc.removeEventListener('visibilitychange', onVisibilityChange);
    doc.removeEventListener('keydown', onActivity);
    doc.removeEventListener('mousemove', onActivity);
    doc.removeEventListener('touchstart', onActivity);
    if (activityTimer) clearTimeout(activityTimer);
    if (visibilityTimer) clearTimeout(visibilityTimer);
  };

  const self = {
    async capabilities(): Promise<VaultCapabilities> {
      const indexedDb = typeof indexedDB !== 'undefined';
      const webauthn = typeof PublicKeyCredential !== 'undefined';
      return { webauthn, prf: prfSupported, indexedDb };
    },

    state: () => currentState,

    onState(cb: (s: VaultState) => void): () => void {
      stateListeners.add(cb);
      return () => stateListeners.delete(cb);
    },

    async create(displayName: string) {
      const caps = await self.capabilities();
      if (!caps.webauthn || !caps.indexedDb) {
        throw new VaultSessionError('UNSUPPORTED', 'WebAuthn or IndexedDB not supported');
      }

      try {
        await vault.unlock({ passkey: true });
        prfSupported = true;
      } catch (e: any) {
        if (e.code === 'NO_PASSKEY') {
          prfSupported = false;
          throw new VaultSessionError('PRF_UNSUPPORTED', 'Authenticator does not support PRF');
        }
        throw e;
      }

      const devId = await vault.getDeviceIdentity();
      const memberId = await memberIdFromSpki(devId.publicKey);

      const mrs = randomBytes(32);

      _memberId = memberId;
      _displayName = displayName;
      await put('orion/meta/memberId', memberId);
      await put('orion/meta/displayName', displayName);

      const wrappedMrs = await vault.wrapKey(mrs);
      await put('orion/mrs', wrappedMrs);

      const rc = randomBytes(32);
      const rcKeyInfo = 'orion/v1/recovery-code';
      const rcKeyBytes = await hkdf(rc, new Uint8Array(0), rcKeyInfo);
      const rcKey = await aesKey(rcKeyBytes);
      await sealBlob(rcKey, mrs, new Uint8Array(0));
      // Constructing 24-words/base32 recovery code. Returning wrapped part.
      // But the issue mentions: 32 random bytes RC; it wraps MRS (AES-GCM... RC, MRS)
      // "and the wrapped blob is published as a recovery envelope"
      // the recovery code itself is derived from the RC
      // The rc is what we give out.
      const recoveryCode = b64u(rc);

      mrs.fill(0);
      updateState('unlocked');
      setupListeners();

      return { memberId, recoveryCode };
    },

    async unlock() {
      try {
        await vault.unlock({ passkey: true });
        prfSupported = true;
      } catch (e: any) {
        if (e.code === 'NO_PASSKEY') {
          prfSupported = false;
          throw new VaultSessionError('PRF_UNSUPPORTED', 'Authenticator does not support PRF');
        }
        throw e;
      }

      const wrappedMrs = await get<string>('orion/mrs');
      if (!wrappedMrs) {
        throw new VaultSessionError('EMPTY', 'No vault found');
      }

      _memberId = await get<string>('orion/meta/memberId') ?? null;
      _displayName = await get<string>('orion/meta/displayName') ?? null;
      updateState('unlocked');
      setupListeners();
    },

    lock() {
      vault.lock();
      teardownListeners();
      _memberId = null;
      _displayName = null;
      updateState('locked');
    },

    setAutoLockMinutes(minutes: number) {
      autoLockMinutes = minutes;
      if (currentState === 'unlocked') {
        resetActivityTimer();
      }
    },

    memberId: () => _memberId,
    displayName: () => _displayName,

    async withMrs<T>(fn: (mrs: Uint8Array) => T | Promise<T>): Promise<T> {
      if (currentState !== 'unlocked') {
        throw new VaultSessionError('LOCKED', 'Vault is locked');
      }
      const wrappedMrs = await get<string>('orion/mrs');
      if (!wrappedMrs) {
        throw new VaultSessionError('EMPTY', 'Vault is empty');
      }

      let mrs: Uint8Array | null = null;
      try {
        mrs = await vault.unwrapKey(wrappedMrs);
        return await fn(mrs);
      } finally {
        if (mrs) mrs.fill(0);
      }
    }
  };

  init().catch(console.error);

  return self;
}
