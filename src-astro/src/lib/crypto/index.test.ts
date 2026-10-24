import { describe, expect, it } from 'vitest';
import {
  aesKey,
  b64u,
  canonical,
  ecdh,
  fromB64u,
  fromUtf8,
  generateBoxPair,
  generateSigningPair,
  hkdf,
  memberIdFromSpki,
  open,
  openBlob,
  randomBytes,
  seal,
  sealBlob,
  sign,
  unwrapFrom,
  utf8,
  verify,
  wrapTo,
} from './index';

describe('crypto primitives', () => {
  it('base64url round-trips and rejects other alphabets', () => {
    const b = randomBytes(33);
    expect(fromB64u(b64u(b))).toEqual(b);
    expect(b64u(b)).not.toMatch(/[+/=]/);
    expect(() => fromB64u('a+b/')).toThrow();
  });

  it('canonical bytes ignore key order and omitted fields', () => {
    const a = fromUtf8(canonical({ b: 1, a: { d: 2, c: 3 }, sig: 'x' }, ['sig']));
    const b = fromUtf8(canonical({ a: { c: 3, d: 2 }, b: 1 }));
    expect(a).toBe(b);
  });

  it('AES-GCM fails closed on tampered ciphertext or AAD', async () => {
    const key = await aesKey(randomBytes(32));
    const { nonce, ct } = await seal(key, utf8('presion 120/80'), utf8('aad-1'));
    expect(fromUtf8(await open(key, nonce, ct, utf8('aad-1')))).toBe('presion 120/80');
    await expect(open(key, nonce, ct, utf8('aad-2'))).rejects.toThrow();
    const bad = ct.slice();
    bad[0] = bad[0]! ^ 1;
    await expect(open(key, nonce, bad, utf8('aad-1'))).rejects.toThrow();
  });

  it('sealBlob/openBlob round-trip', async () => {
    const key = await aesKey(randomBytes(32));
    const blob = await sealBlob(key, utf8('k'), utf8('x'));
    expect(fromUtf8(await openBlob(key, blob, utf8('x')))).toBe('k');
  });

  it('hkdf is deterministic per info', async () => {
    const ikm = randomBytes(32);
    const salt = randomBytes(16);
    expect(await hkdf(ikm, salt, 'a')).toEqual(await hkdf(ikm, salt, 'a'));
    expect(await hkdf(ikm, salt, 'a')).not.toEqual(await hkdf(ikm, salt, 'b'));
  });

  it('ECDSA signs and rejects other data or keys', async () => {
    const a = await generateSigningPair();
    const b = await generateSigningPair();
    const sig = await sign(a.privatePkcs8, utf8('m'));
    expect(await verify(a.publicSpki, utf8('m'), sig)).toBe(true);
    expect(await verify(a.publicSpki, utf8('n'), sig)).toBe(false);
    expect(await verify(b.publicSpki, utf8('m'), sig)).toBe(false);
    expect(await verify(a.publicSpki, utf8('m'), 'not-a-sig')).toBe(false);
  });

  it('ECDH agrees on both sides and wrapTo/unwrapFrom only opens for the recipient', async () => {
    const a = await generateBoxPair();
    const b = await generateBoxPair();
    expect(await ecdh(a.privatePkcs8, b.publicSpki)).toEqual(await ecdh(b.privatePkcs8, a.publicSpki));
    const secret = randomBytes(32);
    const { ephPub, wrapped } = await wrapTo(b.publicSpki, secret, 'orion/v1/grant', utf8('g1'));
    expect(await unwrapFrom(b.privatePkcs8, ephPub, wrapped, 'orion/v1/grant', utf8('g1'))).toEqual(secret);
    await expect(unwrapFrom(a.privatePkcs8, ephPub, wrapped, 'orion/v1/grant', utf8('g1'))).rejects.toThrow();
    await expect(unwrapFrom(b.privatePkcs8, ephPub, wrapped, 'orion/v1/other', utf8('g1'))).rejects.toThrow();
  });

  it('memberId is 22 chars and stable', async () => {
    const a = await generateSigningPair();
    const id = await memberIdFromSpki(a.publicSpki);
    expect(id).toHaveLength(22);
    expect(await memberIdFromSpki(a.publicSpki)).toBe(id);
  });
});
