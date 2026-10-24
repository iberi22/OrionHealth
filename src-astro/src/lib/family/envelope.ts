import { b64u, canonical, fromB64u, fromUtf8, sealBlob, openBlob, sign, verify, utf8 } from '../crypto/index.js';
import type { Envelope, Category } from '../contracts/types.js';

export function envelopeAad(env: Omit<Envelope, 'sig'> | Envelope): Uint8Array<ArrayBuffer> {
  return utf8(`orion/v1|${env.circle}|${env.owner}|${env.author}|${env.category}|${env.epoch}|${env.id}`);
}

export interface SealArgs {
  id: string;
  circle: string;
  owner: string;
  author: string;
  device: string;
  category: Category;
  epoch: number;
  hlc: string;
  plaintext: unknown;
  categoryKey: CryptoKey;
  authorSignPkcs8: string;
}

export async function sealEnvelope(args: SealArgs): Promise<Envelope> {
  const partialEnv: Omit<Envelope, 'ct' | 'nonce' | 'sig'> = {
    v: 1,
    id: args.id,
    circle: args.circle,
    owner: args.owner,
    author: args.author,
    device: args.device,
    category: args.category,
    epoch: args.epoch,
    hlc: args.hlc,
  };

  const plainBytes = utf8(JSON.stringify(args.plaintext));
  const aad = envelopeAad(partialEnv as Envelope);
  const blob = await sealBlob(args.categoryKey, plainBytes, aad);
  const blobBytes = fromB64u(blob);

  // nonce 12 B
  const nonceBytes = blobBytes.subarray(0, 12);
  const ctBytes = blobBytes.subarray(12);

  const envWithoutSig: Omit<Envelope, 'sig'> = {
    ...partialEnv,
    nonce: b64u(nonceBytes),
    ct: b64u(ctBytes),
  };

  const canonicalBytes = canonical(envWithoutSig, ['sig']);
  const signature = await sign(args.authorSignPkcs8, canonicalBytes);

  return {
    ...envWithoutSig,
    sig: signature,
  };
}

export async function verifyEnvelope(env: Envelope, authorSignSpki: string): Promise<boolean> {
  const canonicalBytes = canonical(env, ['sig']);
  return verify(authorSignSpki, canonicalBytes, env.sig);
}

export async function openEnvelope(env: Envelope, key: CryptoKey): Promise<unknown> {
  const aad = envelopeAad(env);

  const nonceBytes = fromB64u(env.nonce);
  const ctBytes = fromB64u(env.ct);

  const blobBytes = new Uint8Array(nonceBytes.length + ctBytes.length);
  blobBytes.set(nonceBytes, 0);
  blobBytes.set(ctBytes, nonceBytes.length);
  const blob = b64u(blobBytes);

  const plainBytes = await openBlob(key, blob, aad);
  return JSON.parse(fromUtf8(plainBytes));
}
