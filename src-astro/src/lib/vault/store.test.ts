import 'fake-indexeddb/auto';
import { describe, it, expect, beforeEach } from 'vitest';
import { isEnvelope, openEnvelopeStore } from './store';
import type { Envelope } from '../contracts/types';

describe('Envelope Store', () => {
  let store: Awaited<ReturnType<typeof openEnvelopeStore>>;

  const validEnvelope: Envelope = {
    v: 1,
    id: 'valid-id',
    circle: 'local',
    owner: 'owner1',
    author: 'author1',
    device: 'device1',
    category: 'vitals',
    epoch: 1,
    hlc: '2023-01-01T00:00:00.000Z-0000-device1',
    nonce: 'abcdef123456',
    ct: 'ciphertext_base64url',
    sig: 'signature_base64url',
  };

  beforeEach(async () => {
    // using a new db name for each test could be useful, or we just clear
    store = await openEnvelopeStore('test-orion-vault');
    await store.clear();
  });

  describe('isEnvelope', () => {
    it('returns true for a valid envelope', () => {
      expect(isEnvelope(validEnvelope)).toBe(true);
    });

    it('returns false if v is not 1', () => {
      expect(isEnvelope({ ...validEnvelope, v: 2 })).toBe(false);
    });

    it('returns false for missing fields', () => {
      const { id, ...missing } = validEnvelope;
      expect(isEnvelope(missing)).toBe(false);
    });

    it('returns false for invalid base64url fields', () => {
      expect(isEnvelope({ ...validEnvelope, id: 'invalid/id!' })).toBe(false);
      expect(isEnvelope({ ...validEnvelope, nonce: 'not base64+' })).toBe(false);
      expect(isEnvelope({ ...validEnvelope, ct: 'invalid ct' })).toBe(false); // contains space
      expect(isEnvelope({ ...validEnvelope, sig: 'invalid+sig' })).toBe(false);
    });

    it('returns false for extra fields', () => {
      expect(isEnvelope({ ...validEnvelope, extra: 'field' })).toBe(false);
    });
  });

  describe('store operations', () => {
    it('throws NOT_AN_ENVELOPE on put with invalid data', async () => {
      await expect(store.put({ ...validEnvelope, v: 2 } as any)).rejects.toThrow('Not a well-formed envelope');
      try {
        await store.put({ ...validEnvelope, v: 2 } as any);
      } catch (e: any) {
        expect(e.code).toBe('NOT_AN_ENVELOPE');
      }
    });

    it('stores and retrieves a valid envelope', async () => {
      await store.put(validEnvelope);
      const retrieved = await store.get(validEnvelope.id);
      expect(retrieved).toEqual(validEnvelope);
    });

    it('envelopes are immutable by id: identical is no-op, different throws ID_CONFLICT', async () => {
      await store.put(validEnvelope);

      // Same envelope is a no-op
      await store.put(validEnvelope);
      expect(await store.get(validEnvelope.id)).toEqual(validEnvelope);

      // Different envelope (by signature) with same ID throws ID_CONFLICT
      const differentEnvelope = { ...validEnvelope, sig: 'different_signature_base64url' };
      await expect(store.put(differentEnvelope)).rejects.toThrow('Envelope ID conflict');

      try {
        await store.put(differentEnvelope);
      } catch (e: any) {
        expect(e.code).toBe('ID_CONFLICT');
      }

      // Still the original validEnvelope
      expect(await store.get(validEnvelope.id)).toEqual(validEnvelope);
    });

    it('multiple openEnvelopeStore calls to same db work without blocking', async () => {
      const store1 = await openEnvelopeStore('test-multiple-open');
      const store2 = await openEnvelopeStore('test-multiple-open');

      const testEnv = { ...validEnvelope, id: 'multi-id' };
      await store1.put(testEnv);
      const retrieved = await store2.get('multi-id');
      expect(retrieved).toEqual(testEnv);
    });

    it('lists by owner, category, circle, and owner_category', async () => {
      const e1: Envelope = { ...validEnvelope, id: 'id1', owner: 'o1', category: 'vitals', circle: 'c1' };
      const e2: Envelope = { ...validEnvelope, id: 'id2', owner: 'o1', category: 'medications', circle: 'c2' };
      const e3: Envelope = { ...validEnvelope, id: 'id3', owner: 'o2', category: 'vitals', circle: 'c1' };

      await store.putMany([e1, e2, e3]);

      expect(await store.listByOwner('o1')).toEqual([e1, e2]);
      expect(await store.listByCategory('vitals')).toEqual([e1, e3]);
      expect(await store.listByCircle('c1')).toEqual([e1, e3]);
      expect(await store.listByCircle('c2')).toEqual([e2]);
      expect(await store.listByOwnerCategory('o1', 'vitals')).toEqual([e1]);
      expect(await store.listByOwnerCategory('o1', 'medications')).toEqual([e2]);
      expect(await store.listByOwnerCategory('o2', 'vitals')).toEqual([e3]);
    });

    it('raw indexedDB scan contains no plaintext health fields', async () => {
      // Test that when storing an envelope, a raw DB read doesn't show plaintext like fullName
      const testEnv: Envelope = {
        ...validEnvelope,
        ct: 'randomBytesct0123456789',
      };
      await store.put(testEnv);

      // open native IndexedDB to read raw values
      const request = indexedDB.open('test-orion-vault', 1);
      const rawRecords = await new Promise<any[]>((resolve, reject) => {
        request.onsuccess = () => {
          const db = request.result;
          const tx = db.transaction('envelopes', 'readonly');
          const objectStore = tx.objectStore('envelopes');
          const getAllRequest = objectStore.getAll();
          getAllRequest.onsuccess = () => {
            resolve(getAllRequest.result);
          };
          getAllRequest.onerror = () => reject(getAllRequest.error);
        };
        request.onerror = () => reject(request.error);
      });

      expect(rawRecords.length).toBe(1);
      const rawEnv = rawRecords[0];

      expect(rawEnv.id).toBe(validEnvelope.id);
      expect(rawEnv).not.toHaveProperty('fullName');
      expect(rawEnv).not.toHaveProperty('value');
      expect(rawEnv).not.toHaveProperty('name');

      const rawString = JSON.stringify(rawEnv);
      expect(rawString).not.toContain('fullName');
      expect(rawString).not.toContain('value');
      expect(rawString).not.toContain('name');
    });
  });
});
