import { openDB, type DBSchema, type IDBPDatabase } from 'idb';
import type { Envelope } from '../contracts/types';

// The spec says all binary fields must be base64url
const base64urlRegex = /^[A-Za-z0-9_-]*$/;

class EnvelopeStoreError extends Error {
  code: string;
  constructor(message: string, code: string) {
    super(message);
    this.name = 'EnvelopeStoreError';
    this.code = code;
  }
}

/**
 * Verifies that an object matches the exact shape of an Envelope (§5).
 * Throws NOT_AN_ENVELOPE otherwise.
 */
export function isEnvelope(v: any): v is Envelope {
  if (!v || typeof v !== 'object') return false;
  if (v.v !== 1) return false;

  if (typeof v.id !== 'string' || !base64urlRegex.test(v.id)) return false;
  if (typeof v.circle !== 'string') return false;
  if (typeof v.owner !== 'string') return false;
  if (typeof v.author !== 'string') return false;
  if (typeof v.device !== 'string') return false;
  if (typeof v.category !== 'string') return false;
  if (typeof v.epoch !== 'number') return false;
  if (typeof v.hlc !== 'string') return false;
  if (typeof v.nonce !== 'string' || !base64urlRegex.test(v.nonce)) return false;
  if (typeof v.ct !== 'string' || !base64urlRegex.test(v.ct)) return false;
  if (typeof v.sig !== 'string' || !base64urlRegex.test(v.sig)) return false;

  // ensure there are no extra fields?
  const allowedKeys = ['v', 'id', 'circle', 'owner', 'author', 'device', 'category', 'epoch', 'hlc', 'nonce', 'ct', 'sig'];
  for (const k of Object.keys(v)) {
    if (!allowedKeys.includes(k)) return false;
  }

  return true;
}

interface VaultSchema extends DBSchema {
  envelopes: {
    key: string;
    value: Envelope;
    indexes: {
      owner: string;
      category: string;
      circle: string;
      owner_category: [string, string];
    };
  };
}

export async function openEnvelopeStore(dbName = 'orion-vault') {
  const db = await openDB<VaultSchema>(dbName, 1, {
    upgrade(db) {
      const store = db.createObjectStore('envelopes', { keyPath: 'id' });
      store.createIndex('owner', 'owner');
      store.createIndex('category', 'category');
      store.createIndex('circle', 'circle');
      store.createIndex('owner_category', ['owner', 'category']);
    },
  });

  return {
    async put(envelope: Envelope): Promise<void> {
      if (!isEnvelope(envelope)) {
        throw new EnvelopeStoreError('Not a well-formed envelope', 'NOT_AN_ENVELOPE');
      }

      const tx = db.transaction('envelopes', 'readwrite');
      const store = tx.objectStore('envelopes');
      const existing = await store.get(envelope.id);

      if (existing) {
        if (envelope.hlc > existing.hlc) {
          await store.put(envelope);
        }
      } else {
        await store.put(envelope);
      }
      await tx.done;
    },

    async putMany(envelopes: Envelope[]): Promise<void> {
      for (const env of envelopes) {
        if (!isEnvelope(env)) {
          throw new EnvelopeStoreError('Not a well-formed envelope', 'NOT_AN_ENVELOPE');
        }
      }

      const tx = db.transaction('envelopes', 'readwrite');
      const store = tx.objectStore('envelopes');

      for (const env of envelopes) {
        const existing = await store.get(env.id);
        if (existing) {
          if (env.hlc > existing.hlc) {
            await store.put(env);
          }
        } else {
          await store.put(env);
        }
      }

      await tx.done;
    },

    async get(id: string): Promise<Envelope | undefined> {
      return db.get('envelopes', id);
    },

    async listByOwner(owner: string): Promise<Envelope[]> {
      return db.getAllFromIndex('envelopes', 'owner', owner);
    },

    async listByCategory(category: string): Promise<Envelope[]> {
      return db.getAllFromIndex('envelopes', 'category', category);
    },

    async listByCircle(circle: string): Promise<Envelope[]> {
      return db.getAllFromIndex('envelopes', 'circle', circle);
    },

    async delete(id: string): Promise<void> {
      return db.delete('envelopes', id);
    },

    async clear(): Promise<void> {
      return db.clear('envelopes');
    }
  };
}
