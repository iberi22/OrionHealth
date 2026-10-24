import * as Y from 'yjs';
import type { Envelope } from '../contracts/types';
import { b64u, hmac, hkdf, utf8 } from '../crypto/index';

export async function circleRoom(ck0: Uint8Array): Promise<string> {
  const hash = await hmac(ck0, utf8('orion/v1/room'));
  return b64u(hash).slice(0, 22);
}

export async function transportPassword(ck0: Uint8Array): Promise<string> {
  const key = await hkdf(ck0, new Uint8Array(0), 'orion/v1/transport');
  return b64u(key);
}

export interface CircleReplicaOptions {
  circleId: string;
  ck0: Uint8Array;
  validate: (env: Envelope) => Promise<boolean> | boolean;
  onRejected?: (env: Envelope) => void;
  persist?: boolean;
  connect?: boolean;
}

export interface CircleReplica {
  add(env: Envelope): void;
  all(): Envelope[];
  byOwner(): Record<string, Envelope[]>;
  onEnvelope(cb: (env: Envelope) => void): () => void;
  destroy(): void;
  // internal use, e.g. tests that manually sync
  doc: Y.Doc;
}

export async function createCircleReplica(opts: CircleReplicaOptions): Promise<CircleReplica> {
  const doc = new Y.Doc();
  const envMap = doc.getMap<Envelope>('env');

  let provider: any = null;
  let persistence: any = null;

  if (opts.persist) {
    const { IndexeddbPersistence } = await import('y-indexeddb');
    persistence = new IndexeddbPersistence(`orion-circle-${opts.circleId}`, doc);
  }

  if (opts.connect !== false) {
    const room = await circleRoom(opts.ck0);
    const password = await transportPassword(opts.ck0);
    const signalingUrl = import.meta.env?.PUBLIC_SIGNALING_URL || 'wss://signal.orionhealth.swal.network';

    // dynamically import y-webrtc so it's lazy
    const { WebrtcProvider } = await import('y-webrtc');
    provider = new WebrtcProvider(room, doc, {
      password,
      signaling: [signalingUrl],
    });
  }

  const listeners = new Set<(env: Envelope) => void>();

  // Async validation queue
  let pendingValidations = Promise.resolve();

  envMap.observe((event, transaction) => {
    // We only validate remote inserts
    if (transaction.local) return;

    const changes = event.changes.keys;
    const addedEnvs: Envelope[] = [];

    changes.forEach((change, key) => {
      if (change.action === 'add' || change.action === 'update') {
        const env = envMap.get(key);
        if (env) addedEnvs.push(env);
      }
    });

    if (addedEnvs.length === 0) return;

    pendingValidations = pendingValidations.then(async () => {
      for (const env of addedEnvs) {
        const isValid = await opts.validate(env);
        if (isValid) {
          listeners.forEach(cb => cb(env));
        } else {
          // Drop invalid envelope from the map
          doc.transact(() => {
            envMap.delete(env.id);
          });
          if (opts.onRejected) {
            opts.onRejected(env);
          }
        }
      }
    });
  });

  return {
    add(env: Envelope) {
      doc.transact(() => {
        envMap.set(env.id, env);
      });
      // Also notify listeners for local additions to keep consistent
      listeners.forEach(cb => cb(env));
    },
    all() {
      return Array.from(envMap.values());
    },
    byOwner() {
      const result: Record<string, Envelope[]> = {};
      for (const env of envMap.values()) {
        if (!result[env.owner]) {
          result[env.owner] = [];
        }
        result[env.owner].push(env);
      }
      return result;
    },
    onEnvelope(cb: (env: Envelope) => void) {
      listeners.add(cb);
      return () => {
        listeners.delete(cb);
      };
    },
    destroy() {
      if (provider) {
        provider.destroy();
      }
      if (persistence) {
        persistence.destroy();
      }
      doc.destroy();
    },
    doc,
  };
}
