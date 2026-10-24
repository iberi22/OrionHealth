import { describe, it, expect } from 'vitest';
import {
  createMemberBundle,
  sealBundle,
  openBundle,
  rotateCategory,
  currentEpoch,
  cekFor,
  VaultError,
} from './keyring';
import { randomBytes, b64u } from '../crypto/index';

describe('Vault Keyring', () => {
  it('creates, seals, and opens a member bundle', async () => {
    const mrs = randomBytes(32);

    // Create
    const bundle = await createMemberBundle(mrs);
    expect(bundle.v).toBe(1);
    expect(bundle.memberId).toBeTypeOf('string');
    expect(bundle.signPkcs8).toBeTypeOf('string');
    expect(bundle.signPub).toBeTypeOf('string');
    expect(bundle.boxPkcs8).toBeTypeOf('string');
    expect(bundle.boxPub).toBeTypeOf('string');
    expect(bundle.ceks).toEqual({});

    // Seal
    const blob = await sealBundle(mrs, bundle);
    expect(blob).toBeTypeOf('string');
    expect(blob).not.toBe(JSON.stringify(bundle));

    // Open
    const openedBundle = await openBundle(mrs, bundle.memberId, blob);
    expect(openedBundle).toEqual(bundle);
  });

  it('fails to open bundle with wrong MRS', async () => {
    const mrs = randomBytes(32);
    const wrongMrs = randomBytes(32);

    const bundle = await createMemberBundle(mrs);
    const blob = await sealBundle(mrs, bundle);

    await expect(openBundle(wrongMrs, bundle.memberId, blob)).rejects.toThrow(VaultError);
    await expect(openBundle(wrongMrs, bundle.memberId, blob)).rejects.toHaveProperty('code', 'DECRYPT_FAILED');
  });

  it('fails to open bundle with wrong memberId (AAD mismatch)', async () => {
    const mrs = randomBytes(32);

    const bundle = await createMemberBundle(mrs);
    const blob = await sealBundle(mrs, bundle);

    const wrongMemberId = b64u(randomBytes(16));

    await expect(openBundle(mrs, wrongMemberId, blob)).rejects.toThrow(VaultError);
  });

  it('rotates categories and gets correct epochs', async () => {
    const mrs = randomBytes(32);
    const bundle = await createMemberBundle(mrs);

    expect(currentEpoch(bundle, 'emergency')).toBe(0);
    expect(() => cekFor(bundle, 'emergency')).toThrow(VaultError);

    rotateCategory(bundle, 'emergency');
    expect(currentEpoch(bundle, 'emergency')).toBe(1);
    const cek1 = cekFor(bundle, 'emergency');
    expect(cek1).toBeTypeOf('string');
    expect(cek1.length).toBeGreaterThan(0);

    rotateCategory(bundle, 'emergency');
    expect(currentEpoch(bundle, 'emergency')).toBe(2);
    const cek2 = cekFor(bundle, 'emergency');
    expect(cek2).toBeTypeOf('string');
    expect(cek2).not.toBe(cek1);

    // Get old epoch
    expect(cekFor(bundle, 'emergency', 1)).toBe(cek1);
    expect(cekFor(bundle, 'emergency', 2)).toBe(cek2);
  });
});
