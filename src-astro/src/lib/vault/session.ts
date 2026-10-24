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
  /** Replaces the WebAuthn assertion of reauth() (tests, or a host with its own authenticator). */
  reauth?: () => Promise<void>;
}

export type VaultSession = VaultService & {
  withMrs: <T>(fn: (mrs: Uint8Array) => T | Promise<T>) => Promise<T>;
  ready: () => Promise<void>;
  bundle: () => MemberBundle | null;
  importMrs: (mrs: Uint8Array, displayName: string, restore?: { memberId: string; sealedBundle: string }) => Promise<void>;
  saveBundle: (bundle: MemberBundle) => Promise<string>;
  putMeta: (key: string, value: string) => Promise<void>;
  getMeta: (key: string) => Promise<string | undefined>;
  /** Fresh user-verified passkey assertion (no PRF); required before a trustee releases a share (spec §9.3). */
  reauth: () => Promise<void>;
  /** memberId stored on this device, readable while locked (same-browser recovery). */
  storedMemberId: () => Promise<string | null>;
  /** The MRS wrapped with the recovery code (spec §9.1), if this device has it. */
  recoveryBlob: () => Promise<string | undefined>;
  putRecoveryBlob: (blob: string) => Promise<void>;
  /** The MBK-sealed member bundle stored on this device. */
  sealedBundle: () => Promise<string | undefined>;
};

/** Keys of the @swal/vault internal store that bind the vault to one passkey. */
const PASSKEY_BINDING = ['passkeyCredId', 'kekSalt', 'meshKeyWrapped'];

export function createVaultSession(opts: VaultSessionOptions): VaultSession {
  const dbName = opts.dbName ?? 'orion-meta';
  const dbPromise = openDB(dbName, 1, {
    upgrade(db) {
      if (!db.objectStoreNames.contains('meta')) {
        db.createObjectStore('meta');
      }
    },
  });

  const internalDbName = `${dbName}-internal`;
  const vault = createVaultClient({
    storage: 'idb',
    passkey: opts.passkey,
    dbName: internalDbName,
  });
  /** The @swal/vault store (same name, version and object store as vault-client.js). */
  const internal = async <T>(fn: (db: Awaited<ReturnType<typeof openDB>>) => Promise<T>): Promise<T> => {
    const db = await openDB(internalDbName, 1, {
      upgrade(d) {
        if (!d.objectStoreNames.contains('kv')) d.createObjectStore('kv');
      },
    });
    try {
      return await fn(db);
    } finally {
      db.close();
    }
  };

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
    /**
     * Recovery: installs a recovered MRS on this device. Registers / unlocks a passkey first (the MRS is
     * wrapped by its KEK), then stores the member bundle. On a new phone the bundle and memberId come
     * from the circle replica (`restore`); on the same device they are read locally.
     */
    async importMrs(mrs: Uint8Array, displayName: string, restore?: { memberId: string; sealedBundle: string }): Promise<void> {
      const memberId = restore?.memberId ?? (await get<string>('orion/meta/memberId'));
      const sealedBundle = restore?.sealedBundle ?? (await get<string>('orion/bundle'));
      if (!memberId || !sealedBundle) {
        throw new VaultSessionError('NO_BUNDLE', 'Recovered secret has no member bundle to open');
      }
      // Fails (and changes nothing, passkey binding included) if the secret does not open this member's bundle.
      const bundle = await openBundle(mrs, memberId, sealedBundle);

      // The passkey that wrapped the old MRS is lost, and @swal/vault only creates a credential when none is stored,
      // so the stale binding is set aside and a NEW passkey is registered (spec §9.3). It is put back if that fails.
      vault.lock();
      const stale = await internal(async (db) => {
        const old: [string, unknown][] = [];
        for (const k of PASSKEY_BINDING) {
          const v = await db.get('kv', k);
          if (v !== undefined) old.push([k, v]);
          await db.delete('kv', k);
        }
        return old;
      });
      try {
        await vault.unlock({ passkey: true });
        prfSupported = true;
      } catch (e: any) {
        await internal(async (db) => {
          for (const [k, v] of stale) await db.put('kv', v, k);
        });
        if (currentState === 'unlocked') self.lock();
        if (e.code === 'NO_PASSKEY') {
          prfSupported = false;
          throw new VaultSessionError('PRF_UNSUPPORTED', 'Authenticator does not support PRF');
        }
        throw e;
      }
      await put('orion/bundle', sealedBundle);
      await put('orion/meta/memberId', memberId);
      await put('orion/mrs', await vault.wrapKey(mrs));
      await put('orion/meta/displayName', displayName);
      _bundle = bundle;
      _memberId = memberId;
      _displayName = displayName;
      updateState('unlocked');
      setupListeners();
    },
    /** Re-seals the (mutated) bundle with the MRS, stores it and returns the sealed blob for replication. */
    async saveBundle(bundle: MemberBundle): Promise<string> {
      const sealed = await self.withMrs((mrs) => sealBundle(mrs, bundle));
      await put('orion/bundle', sealed);
      _bundle = bundle;
      return sealed;
    },
    /** Opaque metadata for the kernel; callers store only ciphertext here (keys are sealed by the caller). */
    async putMeta(key: string, value: string): Promise<void> {
      await put(`orion/kv/${key}`, value);
    },
    async getMeta(key: string): Promise<string | undefined> {
      return get<string>(`orion/kv/${key}`);
    },
    async reauth(): Promise<void> {
      if (currentState !== 'unlocked') throw new VaultSessionError('LOCKED', 'Vault is locked');
      if (opts.reauth) return opts.reauth();
      const credentials = (win?.navigator ?? globalThis.navigator)?.credentials;
      if (typeof PublicKeyCredential === 'undefined' || !credentials) {
        throw new VaultSessionError('UNSUPPORTED', 'WebAuthn not available');
      }
      const id = await internal((db) => db.get('kv', 'passkeyCredId') as Promise<Uint8Array | undefined>);
      if (!id) throw new VaultSessionError('NO_PASSKEY', 'No passkey registered on this device');
      let assertion: PublicKeyCredential | null;
      try {
        assertion = (await credentials.get({
          publicKey: {
            challenge: randomBytes(32),
            allowCredentials: [{ type: 'public-key', id: new Uint8Array(id) }],
            userVerification: 'required',
          },
        })) as PublicKeyCredential | null;
      } catch (e: any) {
        if (e?.name === 'NotAllowedError' || e?.name === 'AbortError') throw new VaultSessionError('CANCELLED', 'User cancelled the passkey check');
        throw e;
      }
      if (!assertion) throw new VaultSessionError('CANCELLED', 'User cancelled the passkey check');
      const data = new Uint8Array((assertion.response as AuthenticatorAssertionResponse).authenticatorData);
      // authenticatorData flags byte (offset 32): bit 2 = user verified
      if (data.length < 33 || !(data[32]! & 0x04)) throw new VaultSessionError('NO_UV', 'The authenticator did not verify the user');
    },
    storedMemberId: async () => (await get<string>('orion/meta/memberId')) ?? null,
    recoveryBlob: () => get<string>('orion/recovery-blob'),
    putRecoveryBlob: async (blob: string) => {
      await put('orion/recovery-blob', blob);
    },
    sealedBundle: () => get<string>('orion/bundle'),
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

      const wrappedMrs = await vault.wrapKey(mrs);
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

      const mrs = await vault.unwrapKey(wrappedMrs);
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
        mrs = await vault.unwrapKey(wrappedMrs);
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
