// Real RecoveryService over the Kernel contract. Spec: docs/architecture/web-vault-family-health.md §9.
// Every payload is a `recovery` envelope (sealed with the circle key): share, policy, request, approval, code-blob.

import type { Kernel } from './kernel';
import type { RecoveryService } from '../../contracts/services';
import type { Envelope, Member, RecoveryProgress, TrusteePolicy } from '../../contracts/types';
import { generateBoxPair, unwrapFrom, utf8 } from '../../crypto/index';
import { computeSas, parseInviteUrl } from '../../family/invite';
import { combineShares, openShare, rewrapForRequest, splitToTrustees, validatePolicy } from '../../family/recovery';
import { unwrapMrsWithCode, wrapMrsWithCode } from '../../vault/recoveryCode';

/** The slice of the vault session the recovery service needs (the real session satisfies it). */
export interface RecoverySession {
  withMrs<T>(fn: (mrs: Uint8Array) => T | Promise<T>): Promise<T>;
  importMrs(mrs: Uint8Array, displayName: string, restore?: { memberId: string; sealedBundle: string }): Promise<void>;
  memberId(): string | null;
  displayName(): string | null;
}

export type RecoveryServiceWithCode = RecoveryService & {
  /** Publishes the MRS wrapped with the member's recovery code as a `code-blob` envelope (spec §9, recovery without family). */
  publishCodeBlob(code: string): Promise<void>;
};

type Payload = Record<string, unknown> & { kind: string };
interface Opened {
  env: Envelope;
  p: Payload;
}

const REQUEST_AAD = (member: string, requestId: string, tempBoxPub: string) =>
  utf8(`orion/v1/recovery-request|${member}|${requestId}|${tempBoxPub}`);

export function createRecoveryService(kernel: Kernel, session: RecoverySession): RecoveryServiceWithCode {
  let state: RecoveryProgress = { step: 'idle', approvals: 0, threshold: 0 };
  const subs = new Set<(p: RecoveryProgress) => void>();
  const setProgress = (u: Partial<RecoveryProgress>) => {
    state = { ...state, ...u };
    subs.forEach((cb) => cb(state));
  };
  const fail = (e: unknown) => setProgress({ step: 'failed', error: e instanceof Error ? e.message : String(e) });

  const me = () => session.memberId() ?? kernel.memberId();

  async function opened(kind: string): Promise<Opened[]> {
    const out: Opened[] = [];
    for (const env of await kernel.envelopes({ category: 'recovery' })) {
      try {
        const p = (await kernel.open(env)) as Payload | null;
        if (p && typeof p === 'object' && p.kind === kind) out.push({ env, p });
      } catch {
        /* not ours to read */
      }
    }
    return out;
  }
  const latest = (xs: Opened[]) => xs.sort((a, b) => (a.env.hlc < b.env.hlc ? 1 : -1))[0];

  async function memberOf(id: string): Promise<Member> {
    const known = (await kernel.circle())?.members[id];
    if (known) return known;
    return {
      memberId: id,
      displayName: id.slice(0, 8),
      role: 'member',
      signPub: (await kernel.signPubOf(id)) ?? '',
      boxPub: (await kernel.boxPubOf(id)) ?? '',
      devices: [],
      guardianOf: [],
      dependent: false,
      removed: false,
    };
  }

  // ---- new-device side ----
  let attempt: { requestId: string; member: string; tempBoxPub: string; tempPriv: string; off: () => void } | null = null;
  let completing = false;

  function stopAttempt() {
    attempt?.off();
    attempt = null;
  }

  async function collect() {
    const a = attempt;
    if (!a || completing) return;
    const byTrustee = new Map<string, Opened>();
    for (const o of await opened('approval')) {
      if (o.p.requestId !== a.requestId || o.p.member !== a.member) continue;
      if (typeof o.p.trusteeId !== 'string' || o.env.author !== o.p.trusteeId) continue;
      byTrustee.set(o.p.trusteeId, o);
    }
    let threshold = state.threshold;
    const pol = latest((await opened('policy')).filter((o) => o.p.member === a.member));
    if (pol) threshold = (pol.p.policy as TrusteePolicy).threshold;
    else for (const o of byTrustee.values()) threshold = Math.max(threshold, Number(o.p.threshold) || 0);
    if (attempt !== a) return;
    setProgress({ approvals: byTrustee.size, threshold });
    if (threshold < 1 || byTrustee.size < threshold || completing) return;

    completing = true;
    try {
      setProgress({ step: 'combining' });
      const aad = REQUEST_AAD(a.member, a.requestId, a.tempBoxPub);
      const shares: Uint8Array[] = [];
      for (const o of byTrustee.values()) {
        shares.push(await unwrapFrom(a.tempPriv, String(o.p.ephPub), String(o.p.wrapped), 'orion/v1/recovery-share', aad));
      }
      const mrs = await combineShares(shares);
      setProgress({ step: 'register-passkey' });
      await session.importMrs(mrs, session.displayName() ?? '', await restoreFor(a.member));
      stopAttempt();
      setProgress({ step: 'done' });
    } catch (e) {
      stopAttempt();
      fail(e);
    } finally {
      completing = false;
    }
  }

  async function restoreFor(member: string) {
    const envs = (await kernel.envelopes({ category: 'bundle' })).filter((e) => e.owner === member);
    envs.sort((a, b) => (a.hlc < b.hlc ? 1 : -1));
    for (const env of envs) {
      try {
        const p = (await kernel.open(env)) as { memberId?: string; sealed?: string };
        if (p.memberId === member && typeof p.sealed === 'string') return { memberId: member, sealedBundle: p.sealed };
      } catch {
        /* try next */
      }
    }
    return undefined;
  }

  return {
    async policy() {
      const mine = me();
      const o = latest((await opened('policy')).filter((x) => x.p.member === mine));
      return o ? (o.p.policy as TrusteePolicy) : null;
    },

    async setPolicy(policy) {
      validatePolicy(policy);
      const member = me();
      const boxPubs: Record<string, string> = {};
      for (const t of policy.trustees) {
        const pub = await kernel.boxPubOf(t);
        if (!pub) throw new Error(`unknown trustee ${t}`);
        boxPubs[t] = pub;
      }
      const shares = await session.withMrs((mrs) => splitToTrustees(mrs, policy, boxPubs, member));
      for (const s of shares) {
        await kernel.publish(
          await kernel.seal({
            category: 'recovery',
            plaintext: { kind: 'share', member, trusteeId: s.trusteeId, threshold: policy.threshold, ephPub: s.ephPub, wrapped: s.wrapped },
          }),
        );
      }
      await kernel.publish(await kernel.seal({ category: 'recovery', plaintext: { kind: 'policy', member, policy } }));
    },

    async pendingRequests() {
      const mine = kernel.memberId();
      const held = new Set((await opened('share')).filter((o) => o.p.trusteeId === mine).map((o) => String(o.p.member)));
      const done = new Set((await opened('approval')).filter((o) => o.env.author === mine).map((o) => String(o.p.requestId)));
      const out: { requestId: string; member: Member; at: number }[] = [];
      for (const o of await opened('request')) {
        const requestId = String(o.p.requestId);
        const member = String(o.p.member);
        if (!held.has(member) || done.has(requestId)) continue;
        out.push({ requestId, member: await memberOf(member), at: Number(o.env.hlc.split('-')[0]) });
      }
      return out;
    },

    async approve(requestId) {
      const mine = kernel.memberId();
      const req = (await opened('request')).find((o) => o.p.requestId === requestId);
      if (!req) throw new Error(`unknown recovery request ${requestId}`);
      const member = String(req.p.member);
      const tempBoxPub = String(req.p.tempBoxPub);
      const sh = latest((await opened('share')).filter((o) => o.p.trusteeId === mine && o.p.member === member));
      if (!sh) throw new Error('I hold no recovery share for this member');
      const share = await openShare(
        { trusteeId: mine, ephPub: String(sh.p.ephPub), wrapped: String(sh.p.wrapped) },
        kernel.bundle().boxPkcs8,
        member,
      );
      const re = await rewrapForRequest(share, tempBoxPub, member, requestId);
      share.fill(0);
      await kernel.publish(
        await kernel.seal({
          category: 'recovery',
          plaintext: { kind: 'approval', requestId, member, trusteeId: mine, threshold: sh.p.threshold, ephPub: re.ephPub, wrapped: re.wrapped },
        }),
      );
    },

    async startRecovery(inviteUrl) {
      try {
        stopAttempt();
        const invite = parseInviteUrl(inviteUrl);
        const member = me();
        const pair = await generateBoxPair();
        const requestId = crypto.randomUUID();
        const signPub = (await kernel.signPubOf(member)) ?? pair.publicSpki;
        const sas = await computeSas(invite.s, pair.publicSpki, signPub);
        const off = kernel.onEnvelope((env) => {
          if (env.category === 'recovery') void collect().catch(fail);
        });
        attempt = { requestId, member, tempBoxPub: pair.publicSpki, tempPriv: pair.privatePkcs8, off };
        setProgress({ step: 'awaiting-approvals', approvals: 0, threshold: 0, error: undefined });
        await kernel.publish(
          await kernel.seal({ category: 'recovery', plaintext: { kind: 'request', requestId, member, tempBoxPub: pair.publicSpki } }),
        );
        await collect();
        return { sas };
      } catch (e) {
        stopAttempt();
        fail(e);
        throw e;
      }
    },

    async recoverWithCode(code) {
      try {
        setProgress({ step: 'combining', approvals: 0, threshold: 0, error: undefined });
        const member = me();
        const blob = latest((await opened('code-blob')).filter((o) => o.p.member === member));
        if (!blob) throw new Error('no recovery code blob found for this member');
        const mrs = await unwrapMrsWithCode(code, String(blob.p.blob), member);
        setProgress({ step: 'register-passkey' });
        await session.importMrs(mrs, session.displayName() ?? '', await restoreFor(member));
        setProgress({ step: 'done' });
      } catch (e) {
        fail(e);
      }
    },

    async publishCodeBlob(code) {
      const member = me();
      const blob = await session.withMrs((mrs) => wrapMrsWithCode(code, mrs, member));
      await kernel.publish(await kernel.seal({ category: 'recovery', plaintext: { kind: 'code-blob', member, blob } }));
    },

    progress: () => state,
    onProgress(cb) {
      subs.add(cb);
      return () => subs.delete(cb);
    },
  };
}
