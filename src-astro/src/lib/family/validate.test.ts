import { describe, test, expect } from 'vitest';
import { validateEnvelope } from './validate.js';
import type { ValidateContext } from './validate.js';
import type { Envelope, Grant, CircleState } from '../contracts/types.js';
import { generateSigningPair, sign, canonical } from '../crypto/index.js';

describe('validateEnvelope', () => {
  test('rejects malformed envelope', async () => {
    const ctx: ValidateContext = { state: null, grants: [], revoked: new Set(), signPubOf: async () => null, now: 0 };
    const res = await validateEnvelope({ foo: 'bar' }, ctx);
    expect(res).toEqual({ ok: false, reason: 'malformed' });
  });

  test('rejects unknown author', async () => {
    const env: Envelope = {
      v: 1, id: '1', circle: 'c', owner: 'a', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c', sig: 's'
    };
    const ctx: ValidateContext = { state: null, grants: [], revoked: new Set(), signPubOf: async () => null, now: 0 };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'unknown-author' });
  });

  test('rejects invalid signature', async () => {
    const pair = await generateSigningPair();
    const env: Envelope = {
      v: 1, id: '1', circle: 'c', owner: 'a', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c', sig: 's'
    };
    const ctx: ValidateContext = { state: null, grants: [], revoked: new Set(), signPubOf: async () => pair.publicSpki, now: 0 };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'invalid-signature' });
  });

  test('rejects author not member at hlc', async () => {
    const pair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'a', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const ctx: ValidateContext = { state: { circleId: 'c', name: 'n', epoch: 1, members: {} }, grants: [], revoked: new Set(), signPubOf: async () => pair.publicSpki, now: 0 };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'author-not-member' });
  });

  test('rejects author missing write grant', async () => {
    const pair = await generateSigningPair();
    const ownerPair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'ownerId', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const state: CircleState = {
      circleId: 'c', name: 'n', epoch: 1, members: {
        'a': { memberId: 'a', displayName: 'A', role: 'member', signPub: pair.publicSpki, boxPub: 'b', devices: ['d'], guardianOf: [], dependent: false, removed: false },
        'ownerId': { memberId: 'ownerId', displayName: 'O', role: 'member', signPub: ownerPair.publicSpki, boxPub: 'b', devices: [], guardianOf: [], dependent: false, removed: false }
      }
    };
    const ctx: ValidateContext = {
      state, grants: [], revoked: new Set(),
      signPubOf: async (id) => id === 'a' ? pair.publicSpki : ownerPair.publicSpki,
      now: 0
    };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'unauthorized-write' });
  });

  test('rejects expired grant', async () => {
    const pair = await generateSigningPair();
    const ownerPair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'ownerId', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const grantBase: Omit<Grant, 'sig'> = { v: 1, id: 'g1', circle: 'c', from: 'ownerId', to: 'a', category: 'emergency', epoch: 1, access: 'write', expiresAt: 100, ephPub: 'e', wrapped: 'w' };
    const grantSig = await sign(ownerPair.privatePkcs8, canonical(grantBase, ['sig']));
    const grant: Grant = { ...grantBase, sig: grantSig };

    const state: CircleState = {
      circleId: 'c', name: 'n', epoch: 1, members: {
        'a': { memberId: 'a', displayName: 'A', role: 'member', signPub: pair.publicSpki, boxPub: 'b', devices: ['d'], guardianOf: [], dependent: false, removed: false },
        'ownerId': { memberId: 'ownerId', displayName: 'O', role: 'member', signPub: ownerPair.publicSpki, boxPub: 'b', devices: [], guardianOf: [], dependent: false, removed: false }
      }
    };
    const ctx: ValidateContext = {
      state, grants: [grant], revoked: new Set(),
      signPubOf: async (id) => id === 'a' ? pair.publicSpki : ownerPair.publicSpki,
      now: 200
    };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'unauthorized-write' });
  });

  test('rejects revoked grant', async () => {
    const pair = await generateSigningPair();
    const ownerPair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'ownerId', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const grantBase: Omit<Grant, 'sig'> = { v: 1, id: 'g1', circle: 'c', from: 'ownerId', to: 'a', category: 'emergency', epoch: 1, access: 'write', ephPub: 'e', wrapped: 'w' };
    const grantSig = await sign(ownerPair.privatePkcs8, canonical(grantBase, ['sig']));
    const grant: Grant = { ...grantBase, sig: grantSig };

    const state: CircleState = {
      circleId: 'c', name: 'n', epoch: 1, members: {
        'a': { memberId: 'a', displayName: 'A', role: 'member', signPub: pair.publicSpki, boxPub: 'b', devices: ['d'], guardianOf: [], dependent: false, removed: false },
        'ownerId': { memberId: 'ownerId', displayName: 'O', role: 'member', signPub: ownerPair.publicSpki, boxPub: 'b', devices: [], guardianOf: [], dependent: false, removed: false }
      }
    };
    const ctx: ValidateContext = {
      state, grants: [grant], revoked: new Set(['g1']),
      signPubOf: async (id) => id === 'a' ? pair.publicSpki : ownerPair.publicSpki,
      now: 100
    };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'unauthorized-write' });
  });

  test('rejects invalid grant signature', async () => {
    const pair = await generateSigningPair();
    const ownerPair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'ownerId', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const grantBase: Omit<Grant, 'sig'> = { v: 1, id: 'g1', circle: 'c', from: 'ownerId', to: 'a', category: 'emergency', epoch: 1, access: 'write', ephPub: 'e', wrapped: 'w' };
    // Sign the grant with the AUTHOR's key instead of the OWNER's key, to make the signature invalid for the owner
    const grantSig = await sign(pair.privatePkcs8, canonical(grantBase, ['sig']));
    const grant: Grant = { ...grantBase, sig: grantSig };

    const state: CircleState = {
      circleId: 'c', name: 'n', epoch: 1, members: {
        'a': { memberId: 'a', displayName: 'A', role: 'member', signPub: pair.publicSpki, boxPub: 'b', devices: ['d'], guardianOf: [], dependent: false, removed: false },
        'ownerId': { memberId: 'ownerId', displayName: 'O', role: 'member', signPub: ownerPair.publicSpki, boxPub: 'b', devices: [], guardianOf: [], dependent: false, removed: false }
      }
    };
    const ctx: ValidateContext = {
      state, grants: [grant], revoked: new Set(),
      signPubOf: async (id) => id === 'a' ? pair.publicSpki : ownerPair.publicSpki,
      now: 100
    };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: false, reason: 'unauthorized-write' });
  });

  test('accepts valid envelope (owner)', async () => {
    const pair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'a', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const state: CircleState = {
      circleId: 'c', name: 'n', epoch: 1, members: {
        'a': { memberId: 'a', displayName: 'A', role: 'member', signPub: pair.publicSpki, boxPub: 'b', devices: ['d'], guardianOf: [], dependent: false, removed: false }
      }
    };
    const ctx: ValidateContext = { state, grants: [], revoked: new Set(), signPubOf: async () => pair.publicSpki, now: 100 };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: true });
  });

  test('accepts valid envelope (grantee)', async () => {
    const pair = await generateSigningPair();
    const ownerPair = await generateSigningPair();
    const envBase: Omit<Envelope, 'sig'> = {
      v: 1, id: '1', circle: 'c', owner: 'ownerId', author: 'a', device: 'd',
      category: 'emergency', epoch: 1, hlc: '0-0-d', nonce: 'n', ct: 'c'
    };
    const sig = await sign(pair.privatePkcs8, canonical(envBase, ['sig']));
    const env: Envelope = { ...envBase, sig };

    const grantBase: Omit<Grant, 'sig'> = { v: 1, id: 'g1', circle: 'c', from: 'ownerId', to: 'a', category: 'emergency', epoch: 1, access: 'write', ephPub: 'e', wrapped: 'w' };
    const grantSig = await sign(ownerPair.privatePkcs8, canonical(grantBase, ['sig']));
    const grant: Grant = { ...grantBase, sig: grantSig };

    const state: CircleState = {
      circleId: 'c', name: 'n', epoch: 1, members: {
        'a': { memberId: 'a', displayName: 'A', role: 'member', signPub: pair.publicSpki, boxPub: 'b', devices: ['d'], guardianOf: [], dependent: false, removed: false },
        'ownerId': { memberId: 'ownerId', displayName: 'O', role: 'member', signPub: ownerPair.publicSpki, boxPub: 'b', devices: [], guardianOf: [], dependent: false, removed: false }
      }
    };
    const ctx: ValidateContext = {
      state, grants: [grant], revoked: new Set(),
      signPubOf: async (id) => id === 'a' ? pair.publicSpki : ownerPair.publicSpki,
      now: 100
    };
    const res = await validateEnvelope(env, ctx);
    expect(res).toEqual({ ok: true });
  });
});
