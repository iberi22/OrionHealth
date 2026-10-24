import type { Access, AccessPreset, Category, Envelope, Grant, PersonalCategory } from '../contracts/types';
import { PRESET_CATEGORIES } from '../contracts/types';
import { b64u, canonical, randomBytes, sign, unwrapFrom, utf8, verify, wrapTo } from '../crypto/index';

export async function createGrant(args: {
  circle: string;
  from: string;
  to: string;
  category: Category;
  epoch: number;
  access: Access;
  expiresAt?: number;
  cek: Uint8Array;
  granteeBoxSpki: string;
  ownerSignPkcs8: string;
}): Promise<Grant> {
  const id = b64u(randomBytes(16));
  const aad = utf8(['orion/v1/grant', args.circle, args.from, args.to, args.category, args.epoch, args.access].join('|'));

  const { ephPub, wrapped } = await wrapTo(args.granteeBoxSpki, args.cek, 'orion/v1/grant', aad);

  const grant: Omit<Grant, 'sig'> = {
    v: 1,
    id,
    circle: args.circle,
    from: args.from,
    to: args.to,
    category: args.category,
    epoch: args.epoch,
    access: args.access,
    ephPub,
    wrapped,
  };

  if (args.expiresAt !== undefined) {
    grant.expiresAt = args.expiresAt;
  }

  const sig = await sign(args.ownerSignPkcs8, canonical(grant, ['sig']));

  return { ...grant, sig } as Grant;
}

export async function verifyGrant(grant: Grant, fromSignSpki: string): Promise<boolean> {
  return verify(fromSignSpki, canonical(grant, ['sig']), grant.sig);
}

export async function unwrapGrant(grant: Grant, myBoxPkcs8: string): Promise<Uint8Array<ArrayBuffer>> {
  const aad = utf8(['orion/v1/grant', grant.circle, grant.from, grant.to, grant.category, grant.epoch, grant.access].join('|'));
  return unwrapFrom(myBoxPkcs8, grant.ephPub, grant.wrapped, 'orion/v1/grant', aad);
}

export function expandPreset(
  preset: AccessPreset,
  custom?: { categories: readonly PersonalCategory[]; access: Access }
): { categories: readonly PersonalCategory[]; access: Access } {
  if (preset === 'custom') {
    if (!custom) throw new Error('Custom preset requires custom config');
    return custom;
  }
  return PRESET_CATEGORIES[preset];
}

export function activeGrants(grants: Grant[], atMs: number, revoked?: Set<string>): Grant[] {
  return grants.filter((g) => {
    if (revoked && revoked.has(g.id)) return false;
    if (g.expiresAt !== undefined && g.expiresAt <= atMs) return false;
    return true;
  });
}

export function isWriteAuthorized(env: Envelope, grants: Grant[], atMs: number, revoked?: Set<string>): boolean {
  if (env.author === env.owner) return true;

  const active = activeGrants(grants, atMs, revoked);

  return active.some(
    (g) =>
      g.circle === env.circle &&
      g.from === env.owner &&
      g.to === env.author &&
      g.category === env.category &&
      g.epoch === env.epoch &&
      g.access === 'write'
  );
}
