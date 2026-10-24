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
  sink: (env: Envelope) => void | Promise<void>;
  connect?: boolean;
}

export interface CircleReplica {
  add(env: Envelope): Promise<void>;
  destroy(): void;
  // internal use, e.g. tests that manually sync
  doc: Y.Doc;
}

export async function createCircleReplica(opts: CircleReplicaOptions): Promise<CircleReplica> {
  const doc = new Y.Doc();
  const envMap = doc.getMap<Envelope>('env');
  const validCache = new Map<string, Envelope>();

  let provider: any = null;

  if (opts.connect !== false) {
    const room = await circleRoom(opts.ck0);
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
        if (change.action === 'delete') {
          const lastValid = validCache.get(change.key);
          if (lastValid) {
            doc.transact(() => {
              envMap.set(change.key, lastValid);
            });
          }
        } else if (change.env) {
          const isValid = await opts.validate(change.env);
          if (isValid) {
            validCache.set(change.key, change.env);
            await opts.sink(change.env);
          } else {
            const lastValid = validCache.get(change.key);
            if (lastValid) {
              doc.transact(() => {
                envMap.set(change.key, lastValid);
              });
            }
          }
        }
      }
    });
  });

  return {
    async add(env: Envelope) {
      const isValid = await opts.validate(env);
      if (isValid) {
        validCache.set(env.id, env);
        doc.transact(() => {
          envMap.set(env.id, env);
        });
        await opts.sink(env);
      }
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
