import type { CircleState, Envelope, Grant } from '../contracts/types.js';
import { verify, canonical } from '../crypto/index.js';

export function isEnvelope(env: unknown): env is Envelope {
  if (!env || typeof env !== 'object') return false;
  const e = env as any;
  return (
    e.v === 1 &&
    typeof e.id === 'string' &&
    typeof e.circle === 'string' &&
    typeof e.owner === 'string' &&
    typeof e.author === 'string' &&
    typeof e.device === 'string' &&
    typeof e.category === 'string' &&
    typeof e.epoch === 'number' &&
    typeof e.hlc === 'string' &&
    typeof e.nonce === 'string' &&
    typeof e.ct === 'string' &&
    typeof e.sig === 'string'
  );
}

export interface ValidateContext {
  state: CircleState | null;
  grants: Grant[];
  revoked: Set<string>;
  signPubOf: (memberId: string) => Promise<string | null>;
  now: number;
}

export type ValidateResult = { ok: true } | { ok: false; reason: string };

export async function validateEnvelope(
  env: unknown,
  ctx: ValidateContext
): Promise<ValidateResult> {
  if (!isEnvelope(env)) {
    return { ok: false, reason: 'malformed' };
  }

  const signPub = await ctx.signPubOf(env.author);
  if (!signPub) {
    return { ok: false, reason: 'unknown-author' };
  }

  const validSig = await verify(signPub, canonical(env, ['sig']), env.sig);
  if (!validSig) {
    return { ok: false, reason: 'invalid-signature' };
  }

  const member = ctx.state?.members[env.author];
  if (!member || member.removed) {
    return { ok: false, reason: 'author-not-member' };
  }

  if (env.author !== env.owner) {
    const ownerPub = await ctx.signPubOf(env.owner);
    if (!ownerPub) {
      return { ok: false, reason: 'unknown-owner' };
    }

    const applicableGrants = ctx.grants.filter(
      (g) =>
        g.circle === env.circle &&
        g.from === env.owner &&
        g.to === env.author &&
        g.category === env.category &&
        g.epoch === env.epoch &&
        g.access === 'write' &&
        !ctx.revoked.has(g.id) &&
        (g.expiresAt === undefined || g.expiresAt > ctx.now)
    );

    let authorized = false;
    for (const g of applicableGrants) {
      const grantValid = await verify(ownerPub, canonical(g, ['sig']), g.sig);
      if (grantValid) {
        authorized = true;
        break;
      }
    }

    if (!authorized) {
      return { ok: false, reason: 'unauthorized-write' };
    }
  }

  return { ok: true };
}
