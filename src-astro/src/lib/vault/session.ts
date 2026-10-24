import { createVaultClient, type PasskeyPrfProvider } from '@swal/vault/web';
import { openDB } from 'idb';
import { randomBytes } from '../crypto/index.js';
import { createMemberBundle, sealBundle, openBundle, type MemberBundle } from './keyring.ts';
import { newRecoveryCode, formatCode, wrapMrsWithCode } from './recoveryCode.ts';
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

export function createVaultSession(opts: VaultSessionOptions): VaultService & { withMrs: <T>(fn: (mrs: Uint8Array) => T | Promise<T>) => Promise<T>, ready: () => Promise<void>, bundle: () => MemberBundle | null, importMrs: (mrs: Uint8Array, displayName: string) => Promise<void> } {
  const dbName = opts.dbName ?? 'orion-meta';
  const dbPromise = openDB(dbName, 1, {
    upgrade(db) {
      if (!db.objectStoreNames.contains('meta')) {
        db.createObjectStore('meta');
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
  let _bundle: MemberBundle | null = null;
  let resolveInit: () => void;
  const initPromise = new Promise<void>(r => resolveInit = r);
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
  const get = async <T>(k: string): Promise<T | undefined> => (await getDb()).get('meta', k);
  const put = async (k: string, v: any) => (await getDb()).put('meta', v, k);

  const init = async () => {
    const caps = await self.capabilities();
    if (!caps.webauthn || !caps.indexedDb) {
      updateState('unsupported');
      resolveInit();
      return;
    }

    const wrappedMrs = await get<string>('orion/mrs');
    if (!wrappedMrs) {
      updateState('empty');
      resolveInit();
      return;
    }

    if (vault.isUnlocked()) {
      _memberId = await get<string>('orion/meta/memberId') ?? null;
      _displayName = await get<string>('orion/meta/displayName') ?? null;
      updateState('unlocked');
    } else {
      updateState('locked');
    }
    resolveInit();
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
      }, autoLockMinutes * 60 * 1000);
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
    ready(): Promise<void> {
      return initPromise;
    },
    bundle(): MemberBundle | null {
      return currentState === 'unlocked' ? _bundle : null;
    },
    async importMrs(mrs: Uint8Array, displayName: string): Promise<void> {
      const sealedBundle = await get<string>('orion/bundle');
      if (sealedBundle) {
        try { _bundle = await openBundle(mrs, await get<string>('orion/meta/memberId') ?? '', sealedBundle); } catch(e) {}
      }
      const wrapped = await (vault as any).wrapBytes(mrs);
      await put('orion/mrs', wrapped);
      _displayName = displayName;
      await put('orion/meta/displayName', displayName);
      updateState('unlocked');
    },
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

      const existing = await get<string>('orion/mrs');
      if (existing) {
        throw new VaultSessionError('EXISTS', 'Vault already exists');
      }

      try {
        await vault.unlock({ passkey: true });
        prfSupported = true;
      } catch (e: any) {
        if (e.code === 'NO_PASSKEY') {
          prfSupported = false;
          if (e.name === 'NotAllowedError' || (e.message && e.message.includes('cancelada'))) {
            throw new VaultSessionError('CANCELLED', 'User cancelled passkey creation');
          }
          throw new VaultSessionError('PRF_UNSUPPORTED', 'Authenticator does not support PRF');
        }
        throw e;
      }

      const mrs = randomBytes(32);
      const bundle = await createMemberBundle(mrs);
      const memberId = bundle.memberId;

      const sealedBundle = await sealBundle(mrs, bundle);
      await put('orion/bundle', sealedBundle);

      _memberId = memberId;
      _displayName = displayName;
      _bundle = bundle;
      await put('orion/meta/memberId', memberId);
      await put('orion/meta/displayName', displayName);

      const wrappedMrs = await (vault as any).wrapBytes(mrs);
      await put('orion/mrs', wrappedMrs);

      const codeBytes = newRecoveryCode();
      const recoveryCode = await formatCode(codeBytes);
      const recoveryBlob = await wrapMrsWithCode(recoveryCode, mrs, memberId);
      await put('orion/recovery-blob', recoveryBlob);

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

      const mrs = await (vault as any).unwrapBytes(wrappedMrs);
      // const mrs = new Uint8Array(32);

      _memberId = await get<string>('orion/meta/memberId') ?? null;
      _displayName = await get<string>('orion/meta/displayName') ?? null;

      const sealedBundle = await get<string>('orion/bundle');
      if (sealedBundle && _memberId) {
        _bundle = await openBundle(mrs, _memberId, sealedBundle);
      }
      mrs.fill(0);

      updateState('unlocked');
      setupListeners();
    },

    lock() {
      vault.lock();
      teardownListeners();
      _memberId = null;
      _displayName = null;
      _bundle = null;
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
        mrs = await (vault as any).unwrapBytes(wrappedMrs);
        return await fn(mrs!);
      } finally {
        if (mrs) mrs.fill(0);
      }
    }
  };

  init().catch((err) => {
    console.error(err);
    resolveInit();
  });

  return self;
}
