// WebCrypto-only primitives for the web vault (spec §2). No other crypto dependency is allowed.

const subtle = () => globalThis.crypto.subtle;
const te = new TextEncoder();

/** Copies into a fresh ArrayBuffer-backed view (WebCrypto rejects SharedArrayBuffer-typed views). */
export function bytes(u: Uint8Array): Uint8Array<ArrayBuffer> {
  const out = new Uint8Array(new ArrayBuffer(u.byteLength));
  out.set(u);
  return out;
}

export function utf8(s: string): Uint8Array<ArrayBuffer> {
  return bytes(te.encode(s));
}

export function fromUtf8(b: Uint8Array): string {
  return new TextDecoder().decode(b);
}

export function randomBytes(n: number): Uint8Array<ArrayBuffer> {
  return globalThis.crypto.getRandomValues(new Uint8Array(new ArrayBuffer(n)));
}

export function b64u(b: Uint8Array): string {
  let s = '';
  for (const x of b) s += String.fromCharCode(x);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export function fromB64u(s: string): Uint8Array<ArrayBuffer> {
  if (!/^[A-Za-z0-9_-]*$/.test(s)) throw new Error('invalid base64url');
  const pad = s.length % 4 === 0 ? '' : '='.repeat(4 - (s.length % 4));
  const bin = atob(s.replace(/-/g, '+').replace(/_/g, '/') + pad);
  const out = new Uint8Array(new ArrayBuffer(bin.length));
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

export function concat(...parts: Uint8Array[]): Uint8Array<ArrayBuffer> {
  const out = new Uint8Array(new ArrayBuffer(parts.reduce((n, p) => n + p.length, 0)));
  let o = 0;
  for (const p of parts) {
    out.set(p, o);
    o += p.length;
  }
  return out;
}

/** Deterministic JSON with sorted keys; `omit` keys are dropped at the top level (e.g. "sig"). */
export function canonical(value: unknown, omit: readonly string[] = []): Uint8Array<ArrayBuffer> {
  const norm = (v: unknown): unknown => {
    if (Array.isArray(v)) return v.map(norm);
    if (v && typeof v === 'object') {
      return Object.fromEntries(
        Object.keys(v as object)
          .sort()
          .filter((k) => (v as Record<string, unknown>)[k] !== undefined)
          .map((k) => [k, norm((v as Record<string, unknown>)[k])]),
      );
    }
    return v;
  };
  const top = { ...(value as Record<string, unknown>) };
  for (const k of omit) delete top[k];
  return utf8(JSON.stringify(norm(top)));
}

// ---------- KDF ----------

export async function hkdf(ikm: Uint8Array, salt: Uint8Array, info: string, length = 32): Promise<Uint8Array<ArrayBuffer>> {
  const key = await subtle().importKey('raw', bytes(ikm), 'HKDF', false, ['deriveBits']);
  const bits = await subtle().deriveBits({ name: 'HKDF', hash: 'SHA-256', salt: bytes(salt), info: utf8(info) }, key, length * 8);
  return new Uint8Array(bits);
}

export async function hmac(key: Uint8Array, data: Uint8Array): Promise<Uint8Array<ArrayBuffer>> {
  const k = await subtle().importKey('raw', bytes(key), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return new Uint8Array(await subtle().sign('HMAC', k, bytes(data)));
}

export async function sha256(data: Uint8Array): Promise<Uint8Array<ArrayBuffer>> {
  return new Uint8Array(await subtle().digest('SHA-256', bytes(data)));
}

// ---------- AEAD (AES-256-GCM) ----------

export async function aesKey(raw: Uint8Array): Promise<CryptoKey> {
  if (raw.length !== 32) throw new Error('AES-256 key must be 32 bytes');
  return subtle().importKey('raw', bytes(raw), 'AES-GCM', false, ['encrypt', 'decrypt']);
}

export async function seal(key: CryptoKey, plaintext: Uint8Array, aad: Uint8Array): Promise<{ nonce: Uint8Array<ArrayBuffer>; ct: Uint8Array<ArrayBuffer> }> {
  const nonce = randomBytes(12);
  const ct = new Uint8Array(await subtle().encrypt({ name: 'AES-GCM', iv: nonce, additionalData: bytes(aad), tagLength: 128 }, key, bytes(plaintext)));
  return { nonce, ct };
}

/** Throws on any tampering of nonce, ciphertext, tag or AAD. */
export async function open(key: CryptoKey, nonce: Uint8Array, ct: Uint8Array, aad: Uint8Array): Promise<Uint8Array<ArrayBuffer>> {
  return new Uint8Array(await subtle().decrypt({ name: 'AES-GCM', iv: bytes(nonce), additionalData: bytes(aad), tagLength: 128 }, key, bytes(ct)));
}

/** nonce ‖ ciphertext in one blob, for wrapped keys. */
export async function sealBlob(key: CryptoKey, plaintext: Uint8Array, aad: Uint8Array): Promise<string> {
  const { nonce, ct } = await seal(key, plaintext, aad);
  return b64u(concat(nonce, ct));
}

export async function openBlob(key: CryptoKey, blob: string, aad: Uint8Array): Promise<Uint8Array<ArrayBuffer>> {
  const b = fromB64u(blob);
  return open(key, b.subarray(0, 12), b.subarray(12), aad);
}

// ---------- Signatures (ECDSA P-256) and key agreement (ECDH P-256) ----------

const ECDSA = { name: 'ECDSA', namedCurve: 'P-256' } as const;
const ECDH = { name: 'ECDH', namedCurve: 'P-256' } as const;

export interface KeyPairB64 {
  publicSpki: string;
  privatePkcs8: string;
}

async function exportPair(pair: CryptoKeyPair): Promise<KeyPairB64> {
  return {
    publicSpki: b64u(new Uint8Array(await subtle().exportKey('spki', pair.publicKey))),
    privatePkcs8: b64u(new Uint8Array(await subtle().exportKey('pkcs8', pair.privateKey))),
  };
}

export async function generateSigningPair(): Promise<KeyPairB64> {
  return exportPair(await subtle().generateKey(ECDSA, true, ['sign', 'verify']));
}

export async function generateBoxPair(): Promise<KeyPairB64> {
  return exportPair(await subtle().generateKey(ECDH, true, ['deriveBits']));
}

export async function sign(privatePkcs8: string, data: Uint8Array): Promise<string> {
  const key = await subtle().importKey('pkcs8', fromB64u(privatePkcs8), ECDSA, false, ['sign']);
  return b64u(new Uint8Array(await subtle().sign({ name: 'ECDSA', hash: 'SHA-256' }, key, bytes(data))));
}

export async function verify(publicSpki: string, data: Uint8Array, signature: string): Promise<boolean> {
  try {
    const key = await subtle().importKey('spki', fromB64u(publicSpki), ECDSA, false, ['verify']);
    return await subtle().verify({ name: 'ECDSA', hash: 'SHA-256' }, key, fromB64u(signature), bytes(data));
  } catch {
    return false;
  }
}

/** 32-byte ECDH shared secret between my private box key and a peer public box key. */
export async function ecdh(privatePkcs8: string, peerPublicSpki: string): Promise<Uint8Array<ArrayBuffer>> {
  const priv = await subtle().importKey('pkcs8', fromB64u(privatePkcs8), ECDH, false, ['deriveBits']);
  const pub = await subtle().importKey('spki', fromB64u(peerPublicSpki), ECDH, false, []);
  return new Uint8Array(await subtle().deriveBits({ name: 'ECDH', public: pub }, priv, 256));
}

/**
 * Wraps `secret` to a recipient box key with a fresh ephemeral pair (spec §6):
 * key = HKDF(ECDH(eph, recipient), salt = ephPub bytes, info).
 */
export async function wrapTo(recipientBoxSpki: string, secret: Uint8Array, info: string, aad: Uint8Array): Promise<{ ephPub: string; wrapped: string }> {
  const eph = await generateBoxPair();
  const shared = await ecdh(eph.privatePkcs8, recipientBoxSpki);
  const key = await aesKey(await hkdf(shared, fromB64u(eph.publicSpki), info));
  return { ephPub: eph.publicSpki, wrapped: await sealBlob(key, secret, aad) };
}

export async function unwrapFrom(myBoxPkcs8: string, ephPub: string, wrapped: string, info: string, aad: Uint8Array): Promise<Uint8Array<ArrayBuffer>> {
  const shared = await ecdh(myBoxPkcs8, ephPub);
  const key = await aesKey(await hkdf(shared, fromB64u(ephPub), info));
  return openBlob(key, wrapped, aad);
}

/** memberId = b64url(SHA-256(signing SPKI))[0..22] (spec §3). */
export async function memberIdFromSpki(signSpki: string): Promise<string> {
  return b64u(await sha256(fromB64u(signSpki))).slice(0, 22);
}
