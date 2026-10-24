import { describe, expect, it } from 'vitest';
import { activeGrants, createGrant, expandPreset, isWriteAuthorized, unwrapGrant, verifyGrant } from './grants';
import { PERSONAL_CATEGORIES } from '../contracts/types';
import type { Envelope, Grant } from '../contracts/types';
import { generateBoxPair, generateSigningPair, randomBytes } from '../crypto/index';

describe('grants', () => {
  it('expands guardian preset to all personal categories with write access', () => {
    const expanded = expandPreset('guardian');
    expect(expanded.categories).toEqual(PERSONAL_CATEGORIES);
    expect(expanded.access).toBe('write');
  });

  it('custom preset requires custom config', () => {
    expect(() => expandPreset('custom')).toThrow('Custom preset requires custom config');
    const expanded = expandPreset('custom', { categories: ['vitals'], access: 'read' });
    expect(expanded.categories).toEqual(['vitals']);
    expect(expanded.access).toBe('read');
  });

  it('creates, verifies, and unwraps a grant end-to-end', async () => {
    const fromSign = await generateSigningPair();
    const toBox = await generateBoxPair();
    const cek = randomBytes(32);

    const grant = await createGrant({
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'read',
      cek,
      granteeBoxSpki: toBox.publicSpki,
      ownerSignPkcs8: fromSign.privatePkcs8,
    });

    expect(grant.v).toBe(1);
    expect(grant.id).toBeDefined();
    expect(grant.circle).toBe('circle-1');
    expect(grant.from).toBe('alice');
    expect(grant.to).toBe('bob');
    expect(grant.category).toBe('vitals');
    expect(grant.epoch).toBe(1);
    expect(grant.access).toBe('read');
    expect(grant.expiresAt).toBeUndefined();

    const isValid = await verifyGrant(grant, fromSign.publicSpki);
    expect(isValid).toBe(true);

    const unwrappedCek = await unwrapGrant(grant, toBox.privatePkcs8);
    expect(new Uint8Array(unwrappedCek)).toEqual(new Uint8Array(cek));
  });

  it('fails verification with wrong sign key', async () => {
    const fromSign = await generateSigningPair();
    const wrongSign = await generateSigningPair();
    const toBox = await generateBoxPair();
    const cek = randomBytes(32);

    const grant = await createGrant({
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'read',
      cek,
      granteeBoxSpki: toBox.publicSpki,
      ownerSignPkcs8: fromSign.privatePkcs8,
    });

    const isValid = await verifyGrant(grant, wrongSign.publicSpki);
    expect(isValid).toBe(false);
  });

  it('isWriteAuthorized returns true for owner', () => {
    const env = { owner: 'alice', author: 'alice' } as Envelope;
    expect(isWriteAuthorized(env, [], Date.now())).toBe(true);
  });

  it('isWriteAuthorized handles read vs write grants', () => {
    const env = {
      circle: 'circle-1',
      owner: 'alice',
      author: 'bob',
      category: 'vitals',
      epoch: 1,
    } as Envelope;

    const readGrant = {
      id: '1',
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'read',
    } as Grant;

    const writeGrant = {
      id: '2',
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'write',
    } as Grant;

    expect(isWriteAuthorized(env, [readGrant], Date.now())).toBe(false);
    expect(isWriteAuthorized(env, [writeGrant], Date.now())).toBe(true);
  });

  it('isWriteAuthorized handles expired and revoked grants', () => {
    const env = {
      circle: 'circle-1',
      owner: 'alice',
      author: 'bob',
      category: 'vitals',
      epoch: 1,
    } as Envelope;

    const now = 10000;

    const expiredGrant = {
      id: '1',
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'write',
      expiresAt: now - 100, // expired
    } as Grant;

    const revokedGrant = {
      id: '2',
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'write',
    } as Grant;

    const validGrant = {
      id: '3',
      circle: 'circle-1',
      from: 'alice',
      to: 'bob',
      category: 'vitals',
      epoch: 1,
      access: 'write',
      expiresAt: now + 100,
    } as Grant;

    expect(isWriteAuthorized(env, [expiredGrant], now)).toBe(false);
    expect(isWriteAuthorized(env, [revokedGrant], now, new Set(['2']))).toBe(false);
    expect(isWriteAuthorized(env, [validGrant], now)).toBe(true);
  });

  it('activeGrants correctly filters expired and revoked grants', () => {
    const now = 10000;
    const grants: Grant[] = [
      { id: '1', expiresAt: now - 100 } as Grant, // expired
      { id: '2', expiresAt: now + 100 } as Grant, // valid
      { id: '3' } as Grant,                       // valid (no expiry)
      { id: '4' } as Grant,                       // revoked
    ];

    const active = activeGrants(grants, now, new Set(['4']));
    expect(active.map(g => g.id)).toEqual(['2', '3']);
  });
});
