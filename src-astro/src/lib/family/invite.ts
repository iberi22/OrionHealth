import { randomBytes, b64u, fromB64u, hkdf, concat, utf8 } from '../crypto/index';

export class InviteError extends Error {
  constructor(message: string, public code: string) {
    super(message);
    this.name = 'InviteError';
  }
}

export interface Invite {
  c: string; // circleId
  s: string; // secret, 32 bytes b64url
  e: number; // expiresAt timestamp (ms)
}

export function createInvite(circleId: string, now: number = Date.now()): Invite {
  return {
    c: circleId,
    s: b64u(randomBytes(32)),
    e: now + 24 * 60 * 60 * 1000,
  };
}

export function inviteUrl(invite: Invite, origin: string = 'https://orionhealth.swal.network'): string {
  const json = JSON.stringify(invite);
  const fragment = b64u(utf8(json));
  return `${origin}/app/join#${fragment}`;
}

export function parseInviteUrl(urlStr: string, now: number = Date.now()): Invite {
  let url: URL;
  try {
    url = new URL(urlStr);
  } catch {
    throw new InviteError('Malformed invite URL', 'INVITE_MALFORMED');
  }

  const fragment = url.hash.startsWith('#') ? url.hash.slice(1) : url.hash;
  if (!fragment) {
    throw new InviteError('Missing fragment', 'INVITE_MALFORMED');
  }

  let jsonStr: string;
  try {
    const jsonBytes = fromB64u(fragment);
    jsonStr = new TextDecoder().decode(jsonBytes);
  } catch {
    throw new InviteError('Invalid fragment encoding', 'INVITE_MALFORMED');
  }

  let invite: Partial<Invite>;
  try {
    invite = JSON.parse(jsonStr);
  } catch {
    throw new InviteError('Invalid JSON in fragment', 'INVITE_MALFORMED');
  }

  if (typeof invite.c !== 'string' || typeof invite.s !== 'string' || typeof invite.e !== 'number') {
    throw new InviteError('Missing required fields', 'INVITE_MALFORMED');
  }

  if (now >= invite.e) {
    throw new InviteError('Invite has expired', 'INVITE_EXPIRED');
  }

  return invite as Invite;
}

export async function inviteRoom(secretB64u: string): Promise<string> {
  const secret = fromB64u(secretB64u);
  const roomBytes = await hkdf(secret, new Uint8Array(0), 'orion/v1/invite-room', 32);
  return b64u(roomBytes).slice(0, 22);
}

export async function computeSas(secretB64u: string, pubAB64u: string, pubBB64u: string): Promise<string> {
  const secret = fromB64u(secretB64u);

  // Sort the base64url strings directly before decoding.
  const sortedPubs = [pubAB64u, pubBB64u].sort().map(fromB64u);

  const h = await hkdf(
    concat(secret, sortedPubs[0], sortedPubs[1]),
    new Uint8Array(0),
    'orion/v1/sas',
    4
  );

  const view = new DataView(h.buffer, h.byteOffset, h.byteLength);
  const num = view.getUint32(0, false); // big endian or little endian? Let's use big-endian, the spec doesn't say "big endian" specifically for SAS, but standard network byte order is BE.
  const sas = num % 1000000;

  const sasStr = sas.toString().padStart(6, '0');
  return `${sasStr.slice(0, 3)} ${sasStr.slice(3)}`;
}
