import * as Y from 'yjs';
import type { Envelope } from '../contracts/types';
import { b64u, canonical, fromUtf8, hmac, hkdf, utf8 } from '../crypto/index';

const same = (a: Envelope, b: Envelope) => fromUtf8(canonical(a)) === fromUtf8(canonical(b));

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
  /** Circle key that names the room and its transport password (spec §8: the kernel passes the newest CK). */
  ck0: Uint8Array;
  validate: (env: Envelope) => Promise<boolean> | boolean;
  sink: (env: Envelope) => void | Promise<void>;
  connect?: boolean;
}

export interface CircleReplica {
  /** Room name derived from the key the replica was opened with. */
  room: string;
  add(env: Envelope): Promise<void>;
  /**
   * Puts already validated envelopes (the local store) into the Y.Map in one transaction, without calling
   * validate or sink. Idempotent: ids already known keep their first envelope (immutable by id).
   */
  seed(envs: Envelope[]): void;
  destroy(): void;
  // internal use, e.g. tests that manually sync
  doc: Y.Doc;
}

export async function createCircleReplica(opts: CircleReplicaOptions): Promise<CircleReplica> {
  const doc = new Y.Doc();
  const envMap = doc.getMap<Envelope>('env');
  const validCache = new Map<string, Envelope>();

  let provider: any = null;

  const room = await circleRoom(opts.ck0);
  if (opts.connect !== false) {
    const password = await transportPassword(opts.ck0);
    const signalingUrl = import.meta.env?.PUBLIC_SIGNALING_URL || 'wss://signal.orionhealth.swal.network';

    const { WebrtcProvider } = await import('y-webrtc');
    provider = new WebrtcProvider(room, doc, {
      password,
      signaling: [signalingUrl],
    });
  }

  let pendingProcessing = Promise.resolve();

  envMap.observe((event, transaction) => {
    if (transaction.local) return;

    const changesToProcess: { key: string, action: string, env?: Envelope }[] = [];
    event.changes.keys.forEach((change, key) => {
      changesToProcess.push({
        key,
        action: change.action,
        env: change.action !== 'delete' ? envMap.get(key) : undefined
      });
    });

    pendingProcessing = pendingProcessing.then(async () => {
      for (const change of changesToProcess) {
        // One bad change must never stop the replica from processing later ones.
        try {
          await processRemote(change);
        } catch {
          /* rejected change: the last valid envelope stays in place */
        }
      }
    });
  });

  const restore = (key: string) => {
    const lastValid = validCache.get(key);
    if (lastValid) doc.transact(() => envMap.set(key, lastValid));
  };

  async function processRemote(change: { key: string; action: string; env?: Envelope }) {
    const lastValid = validCache.get(change.key);
    if (change.action === 'delete' || !change.env) {
      restore(change.key);
      return;
    }
    // Envelopes are immutable by id (spec §5, §8): any different envelope under a known id is an overwrite.
    if (lastValid) {
      if (!same(lastValid, change.env)) restore(change.key);
      return;
    }
    if (!(await opts.validate(change.env))) return;
    await opts.sink(change.env);
    validCache.set(change.key, change.env);
  }

  return {
    room,
    async add(env: Envelope) {
      const known = validCache.get(env.id);
      if (known) {
        if (!same(known, env)) throw new Error('ID_CONFLICT');
        return;
      }
      if (!(await opts.validate(env))) return;
      await opts.sink(env);
      validCache.set(env.id, env);
      doc.transact(() => {
        envMap.set(env.id, env);
      });
    },
    seed(envs: Envelope[]) {
      const fresh = envs.filter((env) => !validCache.has(env.id));
      if (!fresh.length) return;
      for (const env of fresh) validCache.set(env.id, env);
      doc.transact(() => {
        for (const env of fresh) {
          const cur = envMap.get(env.id);
          if (!cur || !same(cur, env)) envMap.set(env.id, env);
        }
      });
    },
    destroy() {
      if (provider) {
        provider.destroy();
      }
      doc.destroy();
    },
    doc,
  };
}
