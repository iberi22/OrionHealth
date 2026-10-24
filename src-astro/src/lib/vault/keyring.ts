import {
  hkdf,
  aesKey,
  sealBlob,
  openBlob,
  utf8,
  fromUtf8,
  generateSigningPair,
  generateBoxPair,
  memberIdFromSpki,
  randomBytes,
  b64u,
} from '../crypto/index';

import type { Category } from '../contracts/types';

export interface MemberBundle {
  v: 1;
  memberId: string;
  signPkcs8: string;
  signPub: string;
  boxPkcs8: string;
  boxPub: string;
  ceks: Partial<Record<Category, Record<number, string>>>;
}

export class VaultError extends Error {
  code: string;
  constructor(code: string, message: string) {
    super(message);
    this.name = 'VaultError';
    this.code = code;
  }
}

export async function createMemberBundle(_mrs?: Uint8Array): Promise<MemberBundle> {
  const signPair = await generateSigningPair();
  const boxPair = await generateBoxPair();
  const memberId = await memberIdFromSpki(signPair.publicSpki);

  return {
    v: 1,
    memberId,
    signPkcs8: signPair.privatePkcs8,
    signPub: signPair.publicSpki,
    boxPkcs8: boxPair.privatePkcs8,
    boxPub: boxPair.publicSpki,
    ceks: {},
  };
}

export async function sealBundle(mrs: Uint8Array, bundle: MemberBundle): Promise<string> {
  const mbkRaw = await hkdf(mrs, utf8(bundle.memberId), 'orion/v1/bundle');
  const mbk = await aesKey(mbkRaw);
  const aad = utf8(`orion/v1/bundle|${bundle.memberId}`);

  const plaintext = utf8(JSON.stringify(bundle));
  return sealBlob(mbk, plaintext, aad);
}

export async function openBundle(mrs: Uint8Array, memberId: string, blob: string): Promise<MemberBundle> {
  const mbkRaw = await hkdf(mrs, utf8(memberId), 'orion/v1/bundle');
  const mbk = await aesKey(mbkRaw);
  const aad = utf8(`orion/v1/bundle|${memberId}`);

  let plaintext: Uint8Array;
  try {
    plaintext = await openBlob(mbk, blob, aad);
  } catch (e) {
    throw new VaultError('DECRYPT_FAILED', 'Failed to decrypt bundle');
  }

  let bundle: MemberBundle;
  try {
    bundle = JSON.parse(fromUtf8(plaintext));
  } catch (e) {
    throw new VaultError('INVALID_JSON', 'Bundle is not valid JSON');
  }

  if (bundle.v !== 1) {
    throw new VaultError('UNSUPPORTED_VERSION', `Unsupported bundle version: ${bundle.v}`);
  }
  if (bundle.memberId !== memberId) {
    throw new VaultError('MEMBER_ID_MISMATCH', 'Member ID in bundle does not match expected Member ID');
  }

  return bundle;
}

export function currentEpoch(bundle: MemberBundle, category: Category): number {
  const catCeks = bundle.ceks[category];
  if (!catCeks) return 0;

  const epochs = Object.keys(catCeks).map(Number).filter(n => !isNaN(n));
  if (epochs.length === 0) return 0;

  return Math.max(...epochs);
}

export function cekFor(bundle: MemberBundle, category: Category, epoch?: number): string {
  const catCeks = bundle.ceks[category];
  if (!catCeks) {
    throw new VaultError('NO_KEY_FOR_CATEGORY', `No key found for category: ${category}`);
  }

  const targetEpoch = epoch ?? currentEpoch(bundle, category);
  const cek = catCeks[targetEpoch];

  if (!cek) {
    throw new VaultError('KEY_NOT_FOUND', `Key not found for category ${category} at epoch ${targetEpoch}`);
  }

  return cek;
}

export function rotateCategory(bundle: MemberBundle, category: Category): void {
  const nextEpoch = currentEpoch(bundle, category) + 1;
  const newCek = b64u(randomBytes(32));

  if (!bundle.ceks[category]) {
    bundle.ceks[category] = {};
  }

  bundle.ceks[category]![nextEpoch] = newCek;
}
