// Real RecoveryService over the Kernel contract. Spec: docs/architecture/web-vault-family-health.md §9.
// Every payload is a `recovery` envelope (sealed with the circle key). A payload is used only when its author is
// bound to it (§9 table): policy/share/code-blob by the member themself, device-add-pending by an admin who is not
// that member, approval by a trustee of the member's own policy.

import type { Kernel } from './kernel';
import type { InviteTicket, PendingRecovery, PendingRecoveryJoin, RecoveryService } from '../../contracts/services';
import type { CircleState, Envelope, Member, MembershipEvent, RecoveryProgress, TrusteePolicy } from '../../contracts/types';
import { b64u, canonical, generateBoxPair, generateSigningPair, memberIdFromSpki, randomBytes, sign, unwrapFrom, utf8, verify } from '../../crypto/index';
import { createInvite, inviteRoom, parseInviteUrl, type Invite } from '../../family/invite';
import { InviteChannel, type InviteConnection, type InviteHello, type InviteTransport } from '../../family/inviteChannel';
import { reduceMembership, signEvent } from '../../family/membership';
import { combineShares, openShare, rewrapForRequest, splitToTrustees, validatePolicy } from '../../family/recovery';
import { openBundle } from '../../vault/keyring';
import { parseCode, unwrapMrsWithCode, wrapMrsWithCode } from '../../vault/recoveryCode';

/** The slice of the vault session the recovery service needs (vault/session.ts satisfies it). */
export interface RecoverySession {
  withMrs<T>(fn: (mrs: Uint8Array) => T | Promise<T>): Promise<T>;
  importMrs(mrs: Uint8Array, displayName: string, restore?: { memberId: string; sealedBundle: string }): Promise<void>;
  memberId(): string | null;
  displayName(): string | null;
  /** Fresh user-verified passkey assertion (spec §9.3, trustee approval). */
  reauth(): Promise<void>;
  storedMemberId(): Promise<string | null>;
  recoveryBlob(): Promise<string | undefined>;
  putRecoveryBlob(blob: string): Promise<void>;
  sealedBundle(): Promise<string | undefined>;
}

/** Guest mode of the real kernel (kernel.impl.ts): read/relay the circle on a device that is not unlocked yet. */
export interface RecoveryGuestKernel {
  enterGuest(circleId: string, genesis: { memberId: string; signPub: string }, keys: { epoch: number; raw: Uint8Array }[]): Promise<void>;
  leaveGuest(): void;
  load(): Promise<void>;
}

export interface RecoveryOptions {
  transport: InviteTransport;
  /** Origin of invitation links (default production). */
  origin?: string;
  now?: () => number;
}

export type RecoveryServiceWithCode = RecoveryService & {
  /** Publishes the code-wrapped MRS as a `code-blob` (spec §9.1). Without `code` it publishes the stored blob. */
  publishCodeBlob(code?: string): Promise<void>;
  /** Publishes the stored code blob once this member belongs to a circle (idempotent). True when it published. */
  ensureCodeBlobPublished(): Promise<boolean>;
};

type Payload = Record<string, unknown> & { kind: string };
interface Opened {
  env: Envelope;
  p: Payload;
}

/** What the temporary identity of a recovering device signs (spec §9.3 step 2). */
interface RecoveryRequest {
  v: 1;
  kind: 'recovery-request';
  circle: string;
  member: string;
  requestId: string;
  tempSignPub: string;
  tempBoxPub: string;
  deviceId: string;
}

interface Vouched {
  requestId: string;
  member: string;
  temp: { id: string; signPub: string; boxPub: string; deviceId: string };
  vouchedBy: string;
  sas: string;
  at: number;
  expiresAt: number;
}

interface RecoveryInvite extends Invite {
  /** memberId being recovered */
  m: string;
}

interface Handover {
  kind: 'orion/recovery-handover';
  circleId: string;
  member: string;
  requestId: string;
  to: string;
  genesis: { memberId: string; signPub: string };
  keys: { epoch: number; ephPub: string; wrapped: string }[];
}

interface RecoveryFile {
  v: 1;
  kind: 'orion-recovery';
  memberId: string;
  name?: string;
  blob: string;
  bundle: string;
}

const CK_INFO = 'orion/v1/circle-key';
const HELLO_KIND = 'orion/recovery-hello';
const HANDOVER_LINGER_MS = 5 * 60 * 1000;
export const RECOVERY_FILE_NAME = 'orion-recovery.json';

const keyAad = (circleId: string, tempId: string, epoch: number) => utf8(`orion/v1|${circleId}|recovery-key|${tempId}|${epoch}`);
const keyRoom = async (secret: string) => `${await inviteRoom(secret)}.recovery`;
const str = (x: unknown): x is string => typeof x === 'string' && x.length > 0;

export function recoveryInviteUrl(invite: RecoveryInvite, origin = 'https://orionhealth.swal.network'): string {
  return `${origin}/app/recovery#${b64u(utf8(JSON.stringify(invite)))}`;
}

export function parseRecoveryInviteUrl(url: string, now = Date.now()): RecoveryInvite {
  const inv = parseInviteUrl(url, now) as Partial<RecoveryInvite>;
  if (!str(inv.m)) throw new Error('INVITE_NOT_RECOVERY: this link is not a recovery invitation');
  return inv as RecoveryInvite;
}

function parseRecoveryFile(text: string): RecoveryFile {
  let f: Partial<RecoveryFile>;
  try {
    f = JSON.parse(text);
  } catch {
    throw new Error('BAD_RECOVERY_FILE: not a recovery file');
  }
  if (f?.v !== 1 || f.kind !== 'orion-recovery' || !str(f.memberId) || !str(f.blob) || !str(f.bundle)) {
    throw new Error('BAD_RECOVERY_FILE: not a recovery file');
  }
  return f as RecoveryFile;
}

export function createRecoveryService(
  kernel: Kernel & Partial<RecoveryGuestKernel>,
  session: RecoverySession,
  opts: RecoveryOptions,
): RecoveryServiceWithCode {
  const now = opts.now ?? Date.now;
  let state: RecoveryProgress = { step: 'idle', approvals: 0, threshold: 0 };
  const subs = new Set<(p: RecoveryProgress) => void>();
  const setProgress = (u: Partial<RecoveryProgress>) => {
    state = { ...state, ...u };
    subs.forEach((cb) => cb(state));
  };
  const fail = (e: unknown) => setProgress({ step: 'failed', error: e instanceof Error ? e.message : String(e) });
  let counter = 0;
  const hlc = () => `${String(now()).padStart(13, '0')}-${String(++counter).padStart(4, '0')}-${kernel.deviceId()}`;

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
  /** policy / share / code-blob: a member speaks only for themself. */
  const ownedBy = (o: Opened, member: string) => o.p.member === member && o.env.author === member && o.env.owner === member;

  async function memberOf(id: string, circle?: CircleState | null): Promise<Member> {
    const known = (circle ?? (await kernel.circle()))?.members[id];
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

  async function policyOf(member: string): Promise<TrusteePolicy | null> {
    const o = latest((await opened('policy')).filter((x) => ownedBy(x, member)));
    return o ? (o.p.policy as TrusteePolicy) : null;
  }

  /** Newest bundle the member published themself (spec §3, §9). */
  async function bundleFor(member: string) {
    const envs = (await kernel.envelopes({ category: 'bundle' })).filter((e) => e.owner === member && e.author === member);
    envs.sort((a, b) => (a.hlc < b.hlc ? 1 : -1));
    for (const env of envs) {
      try {
        const p = (await kernel.open(env)) as { memberId?: string; sealed?: string };
        if (p.memberId === member && str(p.sealed)) return { memberId: member, sealedBundle: p.sealed };
      } catch {
        /* try next */
      }
    }
    return undefined;
  }

  const codeBlobs = async (member: string) =>
    (await opened('code-blob').catch(() => [] as Opened[]))
      .filter((o) => ownedBy(o, member) && str(o.p.blob))
      .sort((a, b) => (a.env.hlc < b.env.hlc ? 1 : -1))
      .map((o) => String(o.p.blob));

  /** Publishes my current sealed bundle unless the newest one in the replica is identical. */
  async function publishBundle() {
    const me = kernel.memberId();
    const sealed = await session.sealedBundle();
    if (!sealed) return;
    if ((await bundleFor(me))?.sealedBundle === sealed) return;
    await kernel.publish(await kernel.seal({ category: 'bundle', plaintext: { memberId: me, sealed } }));
  }

  /** Signed request rebuilt from a device-add-pending payload; verifying it binds the temporary identity. */
  const requestOf = (circle: string, v: Pick<Vouched, 'member' | 'requestId' | 'temp'>): RecoveryRequest => ({
    v: 1,
    kind: 'recovery-request',
    circle,
    member: v.member,
    requestId: v.requestId,
    tempSignPub: v.temp.signPub,
    tempBoxPub: v.temp.boxPub,
    deviceId: v.temp.deviceId,
  });

  /** A device-add-pending accepted only from a current admin, for another live member, with a valid temp signature. */
  async function vouched(o: Opened, circle: CircleState): Promise<Vouched | null> {
    const p = o.p;
    const t = p.temp as Vouched['temp'] | undefined;
    if (!str(p.requestId) || !str(p.member) || !str(p.requestSig) || !str(p.sas) || typeof p.expiresAt !== 'number') return null;
    if (!t || !str(t.id) || !str(t.signPub) || !str(t.boxPub) || !str(t.deviceId)) return null;
    const admin = circle.members[o.env.author];
    if (!admin || admin.role !== 'admin' || admin.removed || o.env.author !== o.env.owner) return null;
    if (o.env.author === p.member) return null;
    const target = circle.members[p.member];
    if (!target || target.removed || target.dependent) return null;
    if (p.expiresAt <= now()) return null;
    if (t.id !== (await memberIdFromSpki(t.signPub))) return null;
    const v = { requestId: p.requestId, member: p.member, temp: t };
    if (!(await verify(t.signPub, canonical(requestOf(o.env.circle, v)), p.requestSig))) return null;
    return { ...v, vouchedBy: o.env.author, sas: p.sas, at: Number(o.env.hlc.split('-')[0]), expiresAt: p.expiresAt };
  }

  async function findVouched(requestId: string, circle: CircleState): Promise<Vouched | null> {
    for (const o of await opened('device-add-pending')) {
      if (o.p.requestId !== requestId) continue;
      const v = await vouched(o, circle);
      if (v) return v;
    }
    return null;
  }

  async function requireAdmin(): Promise<CircleState> {
    const circle = await kernel.circle();
    if (!circle) throw new Error('NO_CIRCLE');
    const me = circle.members[kernel.memberId()];
    if (!me || me.role !== 'admin' || me.removed) throw new Error('NOT_ADMIN');
    return circle;
  }

  /** The genesis the kernel pinned: the only `create` whose reduction yields the same circle. */
  async function genesisOf(circle: CircleState) {
    const events: MembershipEvent[] = [];
    for (const env of await kernel.envelopes({ category: 'membership' })) {
      try {
        events.push((await kernel.open(env)) as MembershipEvent);
      } catch {
        /* unreadable epoch */
      }
    }
    const ids = Object.keys(circle.members).sort().join(',');
    for (const ev of events.filter((e) => e.kind === 'create' && e.circle === circle.circleId && str(e.signPub))) {
      const { state: s } = await reduceMembership(circle.circleId, events, ev.actor);
      if (s && Object.keys(s.members).sort().join(',') === ids) return { memberId: ev.actor, signPub: ev.signPub! };
    }
    throw new Error('NO_GENESIS');
  }

  // ---- admin side: recovery invitations ----
  const joins = new Map<string, { req: RecoveryRequest; sig: string; sas: string; invite: RecoveryInvite; at: number }>();

  // ---- trustee side ----
  const declined = new Set<string>();

  // ---- new-device side ----
  interface Attempt {
    invite: RecoveryInvite;
    req: RecoveryRequest;
    tempId: string;
    tempBoxPriv: string;
    adminSignPub: string;
    adminId: string;
    joined: boolean;
    offs: (() => void)[];
  }
  let attempt: Attempt | null = null;
  let completing = false;

  function stopAttempt(keepGuest = false) {
    const a = attempt;
    attempt = null;
    a?.offs.forEach((off) => off());
    if (a && !keepGuest) kernel.leaveGuest?.();
  }

  async function onHandover(a: Attempt, msg: InviteHello, conn: InviteConnection) {
    if (attempt !== a || a.joined || msg.signPub !== a.adminSignPub) return;
    const { sig, ...h } = JSON.parse(msg.displayName) as Handover & { sig: string };
    if (h.kind !== 'orion/recovery-handover' || h.circleId !== a.invite.c || h.member !== a.req.member) return;
    if (h.requestId !== a.req.requestId || h.to !== a.tempId || !Array.isArray(h.keys) || !h.genesis) return;
    if (!(await verify(a.adminSignPub, canonical(h), sig))) return;
    const keys: { epoch: number; raw: Uint8Array }[] = [];
    for (const k of h.keys) keys.push({ epoch: k.epoch, raw: await unwrapFrom(a.tempBoxPriv, k.ephPub, k.wrapped, CK_INFO, keyAad(h.circleId, a.tempId, k.epoch)) });
    if (!keys.length || attempt !== a) return;
    if (!kernel.enterGuest) throw new Error('kernel has no recovery guest mode');
    a.joined = true;
    conn.close();
    await kernel.enterGuest(h.circleId, h.genesis, keys);
    keys.forEach((k) => k.raw.fill(0));
    a.offs.push(
      kernel.onEnvelope((env) => {
        if (env.category === 'recovery' || env.category === 'membership' || env.category === 'bundle') void collect().catch(fail);
      }),
    );
    setProgress({ step: 'awaiting-approvals' });
    await collect();
  }

  async function collect() {
    const a = attempt;
    if (!a || !a.joined || completing) return;
    const circle = await kernel.circle();
    // Trust only the admin seen in the SAS channel, once the reduced circle confirms it is an admin.
    const admin = circle?.members[a.adminId];
    const target = circle?.members[a.req.member];
    if (!circle || !admin || admin.role !== 'admin' || admin.removed || admin.signPub !== a.adminSignPub) return;
    if (!target || target.removed) return;
    const pol = await policyOf(a.req.member);
    if (!pol) return;
    const trustees = new Set(pol.trustees);
    const byTrustee = new Map<string, Opened>();
    for (const o of await opened('approval')) {
      if (o.p.requestId !== a.req.requestId || o.p.member !== a.req.member) continue;
      const t = o.p.trusteeId;
      if (!str(t) || o.env.author !== t || !trustees.has(t)) continue;
      byTrustee.set(t, o);
    }
    if (attempt !== a) return;
    setProgress({ approvals: byTrustee.size, threshold: pol.threshold });
    if (byTrustee.size < pol.threshold || completing) return;

    completing = true;
    try {
      setProgress({ step: 'combining' });
      const aad = utf8(`orion/v1/recovery-request|${a.req.member}|${a.req.requestId}|${a.req.tempBoxPub}`);
      const shares: Uint8Array[] = [];
      for (const o of byTrustee.values()) {
        shares.push(await unwrapFrom(a.tempBoxPriv, String(o.p.ephPub), String(o.p.wrapped), 'orion/v1/recovery-share', aad));
      }
      const mrs = await combineShares(shares);
      shares.forEach((s) => s.fill(0));
      const restore = await bundleFor(a.req.member);
      if (!restore) throw new Error('NO_BUNDLE: the circle replica has no bundle of this member yet');
      const bundle = await openBundle(mrs, a.req.member, restore.sealedBundle);
      if (bundle.signPub !== target.signPub) throw new Error('recovered keys do not match the member');
      await finish(mrs, restore, target.displayName, (await codeBlobs(a.req.member))[0]);
    } catch (e) {
      stopAttempt();
      fail(e);
    } finally {
      completing = false;
    }
  }

  /** Imports the MRS (new passkey), leaves guest mode keeping the circle, and announces this device. */
  async function finish(mrs: Uint8Array, restore: { memberId: string; sealedBundle: string } | undefined, name: string, blob?: string) {
    setProgress({ step: 'register-passkey' });
    try {
      await session.importMrs(mrs, name, restore);
    } finally {
      mrs.fill(0);
    }
    await kernel.load?.();
    stopAttempt(true);
    if (blob && !(await session.recoveryBlob())) await session.putRecoveryBlob(blob);
    await announceDevice().catch(() => undefined);
    setProgress({ step: 'done' });
  }

  /** device-add for this device and device-revoke for the member's other (lost) devices (spec §9.3 step 7). */
  async function announceDevice() {
    const circle = await kernel.circle();
    const me = kernel.memberId();
    const mine = circle?.members[me];
    if (!circle || !mine) return;
    const dev = kernel.deviceId();
    const sk = kernel.bundle().signPkcs8;
    const publish = async (kind: 'device-add' | 'device-revoke', deviceId: string) => {
      const ev = await signEvent({ v: 1, id: b64u(randomBytes(16)), circle: circle.circleId, kind, actor: me, subject: me, deviceId, hlc: hlc() }, sk);
      await kernel.publish(await kernel.seal({ category: 'membership', circle: circle.circleId, plaintext: ev }));
    };
    if (!mine.devices.includes(dev)) await publish('device-add', dev);
    for (const d of mine.devices) if (d !== dev) await publish('device-revoke', d);
  }

  let ensuring: Promise<boolean> = Promise.resolve(false);

  const service: RecoveryServiceWithCode = {
    async policy() {
      return policyOf(kernel.memberId());
    },

    async setPolicy(policy) {
      validatePolicy(policy);
      const member = kernel.memberId();
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
      // A bundle sealed before the circle existed was never replicated; a new device restores from this one.
      await publishBundle();
    },

    async pendingRequests(): Promise<PendingRecovery[]> {
      const mine = kernel.memberId();
      const circle = await kernel.circle();
      if (!circle) return [];
      const held = new Set(
        (await opened('share')).filter((o) => o.p.trusteeId === mine && ownedBy(o, String(o.p.member))).map((o) => String(o.p.member)),
      );
      const answered = new Set((await opened('approval')).filter((o) => o.env.author === mine).map((o) => String(o.p.requestId)));
      const out: PendingRecovery[] = [];
      const seen = new Set<string>();
      for (const o of await opened('device-add-pending')) {
        const v = await vouched(o, circle);
        if (!v || seen.has(v.requestId) || !held.has(v.member) || answered.has(v.requestId) || declined.has(v.requestId)) continue;
        seen.add(v.requestId);
        out.push({
          requestId: v.requestId,
          member: await memberOf(v.member, circle),
          requester: { id: v.temp.id, deviceId: v.temp.deviceId },
          vouchedBy: await memberOf(v.vouchedBy, circle),
          sas: v.sas,
          at: v.at,
          expiresAt: v.expiresAt,
        });
      }
      return out.sort((a, b) => a.at - b.at);
    },

    async approve(requestId, sasMatches) {
      if (!sasMatches) {
        declined.add(requestId);
        return;
      }
      const mine = kernel.memberId();
      const circle = await kernel.circle();
      if (!circle) throw new Error('NO_CIRCLE');
      const v = await findVouched(requestId, circle);
      if (!v) throw new Error('RECOVERY_REQUEST_UNBOUND: no recovery invitation vouched by an admin for this request');
      const sh = latest((await opened('share')).filter((o) => o.p.trusteeId === mine && ownedBy(o, v.member)));
      if (!sh) throw new Error('I hold no recovery share for this member');
      // The share leaves this device only after a fresh user verification by the trustee.
      await session.reauth();
      const share = await openShare({ trusteeId: mine, ephPub: String(sh.p.ephPub), wrapped: String(sh.p.wrapped) }, kernel.bundle().boxPkcs8, v.member);
      const re = await rewrapForRequest(share, v.temp.boxPub, v.member, requestId);
      share.fill(0);
      await kernel.publish(
        await kernel.seal({
          category: 'recovery',
          plaintext: { kind: 'approval', requestId, member: v.member, trusteeId: mine, threshold: sh.p.threshold, ephPub: re.ephPub, wrapped: re.wrapped },
        }),
      );
    },

    async createRecoveryInvite(memberId): Promise<InviteTicket> {
      const circle = await requireAdmin();
      const me = kernel.bundle();
      const target = circle.members[memberId];
      if (memberId === me.memberId || !target || target.removed || target.dependent) throw new Error('INVALID_TARGET');
      const invite: RecoveryInvite = { ...createInvite(circle.circleId, now()), m: memberId };
      const channel = new InviteChannel(opts.transport, {
        signPub: me.signPub,
        boxPub: me.boxPub,
        displayName: circle.members[me.memberId]?.displayName ?? '',
        deviceId: kernel.deviceId(),
      });
      channel
        .connect(invite, now())
        .then(async ({ sas, peer }) => {
          const hello = JSON.parse(peer.displayName) as { kind?: string; requestId?: string; member?: string; sig?: string };
          if (hello.kind !== HELLO_KIND || hello.member !== memberId || !str(hello.requestId) || !str(hello.sig)) return;
          const req: RecoveryRequest = {
            v: 1,
            kind: 'recovery-request',
            circle: invite.c,
            member: memberId,
            requestId: hello.requestId,
            tempSignPub: peer.signPub,
            tempBoxPub: peer.boxPub,
            deviceId: peer.deviceId,
          };
          if (!(await verify(peer.signPub, canonical(req), hello.sig))) return;
          joins.set(req.requestId, { req, sig: hello.sig, sas, invite, at: now() });
        })
        .catch(() => {
          /* expired without a device, or a malformed hello */
        });
      return { url: recoveryInviteUrl(invite, opts.origin), expiresAt: invite.e };
    },

    async pendingRecoveryJoins(): Promise<PendingRecoveryJoin[]> {
      const circle = await kernel.circle();
      const out: PendingRecoveryJoin[] = [];
      for (const j of joins.values()) out.push({ requestId: j.req.requestId, member: await memberOf(j.req.member, circle), sas: j.sas, at: j.at });
      return out;
    },

    async approveRecoveryJoin(requestId, sasMatches) {
      const j = joins.get(requestId);
      if (!j) throw new Error('REQUEST_NOT_FOUND');
      joins.delete(requestId);
      if (!sasMatches) return;
      const circle = await requireAdmin();
      const target = circle.members[j.req.member];
      if (!target || target.removed) throw new Error('INVALID_TARGET');
      const me = kernel.bundle();
      const tempId = await memberIdFromSpki(j.req.tempSignPub);
      // The pending device-add: the admin vouches that this temporary identity passed the SAS check.
      await kernel.publish(
        await kernel.seal({
          category: 'recovery',
          plaintext: {
            kind: 'device-add-pending',
            requestId,
            member: j.req.member,
            temp: { id: tempId, signPub: j.req.tempSignPub, boxPub: j.req.tempBoxPub, deviceId: j.req.deviceId },
            requestSig: j.sig,
            sas: j.sas,
            expiresAt: j.invite.e,
          },
        }),
      );
      const current = (await kernel.circleKey()).epoch;
      const keys: Handover['keys'] = [];
      for (let e = 0; e <= current; e++) {
        try {
          const w = await kernel.wrapKeyFor({ circleEpoch: e }, j.req.tempBoxPub, CK_INFO, keyAad(circle.circleId, tempId, e));
          keys.push({ epoch: e, ephPub: w.ephPub, wrapped: w.wrapped });
        } catch {
          /* epoch not held by this admin */
        }
      }
      const h: Handover = {
        kind: 'orion/recovery-handover',
        circleId: circle.circleId,
        member: j.req.member,
        requestId,
        to: tempId,
        genesis: await genesisOf(circle),
        keys,
      };
      const signed = { ...h, sig: await sign(me.signPkcs8, canonical(h)) };
      const conn = await opts.transport.join(await keyRoom(j.invite.s));
      await conn.send({ signPub: me.signPub, boxPub: me.boxPub, deviceId: kernel.deviceId(), displayName: JSON.stringify(signed) });
      // The device may not be linked to this room yet (WebRTC), so the connection lingers like a join handover.
      setTimeout(() => conn.close(), HANDOVER_LINGER_MS);
    },

    async startRecovery(inviteUrl) {
      try {
        stopAttempt();
        const invite = parseRecoveryInviteUrl(inviteUrl, now());
        const sp = await generateSigningPair();
        const bp = await generateBoxPair();
        const tempId = await memberIdFromSpki(sp.publicSpki);
        const req: RecoveryRequest = {
          v: 1,
          kind: 'recovery-request',
          circle: invite.c,
          member: invite.m,
          requestId: b64u(randomBytes(16)),
          tempSignPub: sp.publicSpki,
          tempBoxPub: bp.publicSpki,
          deviceId: b64u(randomBytes(12)),
        };
        const sig = await sign(sp.privatePkcs8, canonical(req));
        setProgress({ step: 'awaiting-invite', approvals: 0, threshold: 0, error: undefined });
        const channel = new InviteChannel(opts.transport, {
          signPub: sp.publicSpki,
          boxPub: bp.publicSpki,
          deviceId: req.deviceId,
          displayName: JSON.stringify({ kind: HELLO_KIND, requestId: req.requestId, member: req.member, sig }),
        });
        const { sas, peer } = await channel.connect(invite, now());
        const a: Attempt = {
          invite,
          req,
          tempId,
          tempBoxPriv: bp.privatePkcs8,
          adminSignPub: peer.signPub,
          adminId: await memberIdFromSpki(peer.signPub),
          joined: false,
          offs: [],
        };
        attempt = a;
        const conn = await opts.transport.join(await keyRoom(invite.s));
        const off = conn.onMessage((msg) => {
          void onHandover(a, msg, conn).catch(() => {
            /* forged or malformed handover */
          });
        });
        a.offs.push(off, () => conn.close());
        return { sas };
      } catch (e) {
        stopAttempt();
        fail(e);
        throw e;
      }
    },

    async recoverWithCode(code, file) {
      try {
        setProgress({ step: 'combining', approvals: 0, threshold: 0, error: undefined });
        await parseCode(code); // a mistyped code fails here with its checksum error
        const f = file ? parseRecoveryFile(file) : null;
        const stored = await session.storedMemberId();
        const member = f?.memberId ?? attempt?.req.member ?? stored;
        if (!member) throw new Error('NO_MEMBER: open the recovery file or a recovery invitation first');
        const candidates = await codeBlobs(member);
        if (f) candidates.push(f.blob);
        const local = stored === member ? await session.recoveryBlob() : undefined;
        if (local) candidates.push(local);
        if (!candidates.length) throw new Error('no recovery code blob found for this member');
        let mrs: Uint8Array | null = null;
        let blob: string | undefined;
        for (const c of candidates) {
          try {
            mrs = await unwrapMrsWithCode(code, c, member);
            blob = c;
            break;
          } catch {
            /* next candidate */
          }
        }
        if (!mrs) throw new Error('BAD_CODE: the recovery code does not open the recovery blob');
        // Newest bundle first: the replica, then this device's own copy, then the file.
        const restore = (await bundleFor(member)) ?? (stored === member ? undefined : f ? { memberId: member, sealedBundle: f.bundle } : undefined);
        const circle = attempt?.joined ? await kernel.circle() : null;
        const name = circle?.members[member]?.displayName ?? f?.name ?? session.displayName() ?? '';
        await finish(mrs, restore, name, blob);
      } catch (e) {
        if (attempt && !attempt.joined) stopAttempt();
        fail(e);
      }
    },

    async recoveryFile() {
      const memberId = session.memberId();
      if (!memberId) throw new Error('LOCKED');
      const blob = await session.recoveryBlob();
      const bundle = await session.sealedBundle();
      if (!blob || !bundle) throw new Error('NO_RECOVERY_BLOB');
      const f: RecoveryFile = { v: 1, kind: 'orion-recovery', memberId, name: session.displayName() ?? undefined, blob, bundle };
      return { filename: RECOVERY_FILE_NAME, content: JSON.stringify(f) };
    },

    async publishCodeBlob(code) {
      const member = kernel.memberId();
      if (!(await kernel.circle())) throw new Error('NO_CIRCLE');
      const blob = code ? await session.withMrs((mrs) => wrapMrsWithCode(code, mrs, member)) : await session.recoveryBlob();
      if (!blob) throw new Error('NO_RECOVERY_BLOB');
      if (code) await session.putRecoveryBlob(blob);
      await publishBundle();
      await kernel.publish(await kernel.seal({ category: 'recovery', plaintext: { kind: 'code-blob', member, blob } }));
    },

    ensureCodeBlobPublished() {
      ensuring = ensuring.then(async () => {
        try {
          const me = session.memberId();
          if (!me) return false;
          const circle = await kernel.circle();
          const mine = circle?.members[me];
          if (!mine || mine.removed) return false;
          if ((await codeBlobs(me)).length || !(await session.recoveryBlob())) return false;
          await service.publishCodeBlob();
          return true;
        } catch {
          return false;
        }
      });
      return ensuring;
    },

    progress: () => state,
    onProgress(cb) {
      subs.add(cb);
      return () => subs.delete(cb);
    },
  };

  return service;
}
