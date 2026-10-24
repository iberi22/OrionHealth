// Circle / membership half of the real FamilyService (spec §7). The grants half lives in grants.ts;
// the composition task merges both. Works on the Kernel interface only: the membership log is reduced
// here with reduceMembership against the pinned genesis, so it behaves the same on the fake and the real kernel.

import type { FamilyService, InviteTicket, PendingJoin } from '../../contracts/services';
import type { CircleState, Envelope, Member, MembershipEvent } from '../../contracts/types';
import { b64u, canonical, memberIdFromSpki, randomBytes, sign, utf8, verify, wrapTo } from '../../crypto/index';
import { createInvite, inviteRoom, inviteUrl, parseInviteUrl, type Invite } from '../../family/invite';
import { InviteChannel, type InviteHello, type InviteTransport } from '../../family/inviteChannel';
import { reduceMembership, signEvent } from '../../family/membership';
import { createMemberBundle, type MemberBundle } from '../../vault/keyring';
import type { Kernel } from './kernel';

const CK_INFO = 'orion/v1/circle-key';

type CircleApi = Pick<
  FamilyService,
  'circle' | 'createCircle' | 'createInvite' | 'join' | 'pendingJoins' | 'approveJoin' | 'removeMember' | 'addDependent' | 'setGuardian' | 'onChange'
>;

interface Genesis {
  memberId: string;
  signPub: string;
}

interface Handover {
  circleId: string;
  to: string;
  keys: { epoch: number; ephPub: string; wrapped: string }[];
}
type SignedJoinHandover = Handover & { sig: string };

interface Request {
  requestId: string;
  hello: InviteHello;
  sas: string;
  invite: Invite;
}

/** How long the admin keeps the key-room connection open after sending the handover. */
const HANDOVER_LINGER_MS = 5 * 60 * 1000;

const ckAad = (circleId: string, to: string, epoch: number) => utf8(`orion/v1|${circleId}|circle-key|${to}|${epoch}`);

export function createFamilyCircleService(
  kernel: Kernel,
  opts: { transport: InviteTransport; origin?: string; displayName: () => string },
): CircleApi {
  let genesis: Genesis | null = null;
  let circleId: string | null = null;
  const requests = new Map<string, Request>();
  // Limitation: dependent key bundles are kept only in memory of this session (the circle key is shared,
  // so sealing them in a circle envelope would expose them to every member). Persisting them needs a
  // personal-category envelope, which the frozen Kernel contract does not offer.
  const dependents = new Map<string, MemberBundle>();
  const subs = new Set<() => void>();
  const notify = () => subs.forEach((cb) => cb());
  let counter = 0;

  const hlc = () =>
    `${String(Date.now()).padStart(13, '0')}-${String(++counter).padStart(4, '0')}-${kernel.deviceId()}`;
  const roomOf = async (secret: string) => `${await inviteRoom(secret)}.keys`;

  const hasKey = async (epoch: number) => {
    try {
      await kernel.circleKey(epoch);
      return true;
    } catch {
      return false;
    }
  };
  const currentEpoch = async () => {
    try {
      return (await kernel.circleKey()).epoch;
    } catch {
      return null;
    }
  };

  const publishEvent = async (ev: Omit<MembershipEvent, 'sig'>) => {
    const signed = await signEvent(ev, kernel.bundle().signPkcs8);
    await kernel.publish(await kernel.seal({ category: 'membership', circle: ev.circle, plaintext: signed }));
  };

  const joinHandoverBytes = (h: Handover) => canonical(h, ['sig']);

  /** Reduces the membership log (and reads the circle name) without applying any key. */
  const reduce = async (): Promise<CircleState | null> => {
    const events: MembershipEvent[] = [];
    for (const env of await kernel.envelopes({ category: 'membership' })) {
      try {
        events.push((await kernel.open(env)) as MembershipEvent);
      } catch {
        /* no key for this epoch yet */
      }
    }
    let state: CircleState | null;
    if (genesis && circleId) {
      state = (await reduceMembership(circleId, events, genesis.memberId)).state;
    } else {
      // Pin unknown (e.g. fresh service over a real kernel): trust the kernel's own reduction.
      state = await kernel.circle();
    }
    if (!state) return null;
    const names: { hlc: string; name: string }[] = [];
    for (const env of await kernel.envelopes({ category: 'circle' })) {
      if (state.members[env.author]?.role !== 'admin') continue;
      try {
        const pt = (await kernel.open(env)) as { kind?: string; name?: unknown };
        if (pt.kind === 'circle-name' && typeof pt.name === 'string') names.push({ hlc: env.hlc, name: pt.name });
      } catch {
        /* unreadable */
      }
    }
    names.sort((a, b) => (a.hlc < b.hlc ? -1 : a.hlc > b.hlc ? 1 : 0));
    const last = names[names.length - 1];
    const epoch = await currentEpoch();
    return { ...state, name: last ? last.name : state.name, epoch: epoch ?? state.epoch };
  };

  /** Applies circle-key grants addressed to me (rotation after a removal). */
  const applyKeyGrants = async (): Promise<boolean> => {
    let any = false;
    let progress = true;
    while (progress) {
      progress = false;
      const state = await reduce();
      if (!state) return any;
      const me = kernel.memberId();
      const envs = (await kernel.envelopes({ category: 'grant' })).sort((a, b) => (a.hlc < b.hlc ? -1 : a.hlc > b.hlc ? 1 : 0));
      for (const env of envs) {
        let pt: Partial<SignedHandover> & { kind?: string };
        try {
          pt = (await kernel.open(env)) as typeof pt;
        } catch {
          continue;
        }
        if (pt.kind !== 'circle-key' || pt.to !== me || typeof pt.epoch !== 'number') continue;
        if (await hasKey(pt.epoch)) continue;
        const author = state.members[env.author];
        if (!author || author.role !== 'admin' || author.removed) continue;
        try {
          const h: KeyHandover = { circleId: state.circleId, to: me, epoch: pt.epoch, ephPub: pt.ephPub!, wrapped: pt.wrapped! };
          if (!(await verify(author.signPub, handoverBytes(h), pt.sig ?? ''))) continue;
          const raw = await kernel.unwrapForMe(h.ephPub, h.wrapped, CK_INFO, ckAad(h.circleId, me, h.epoch));
          kernel.addCircleKey(h.epoch, raw);
          any = true;
          progress = true;
        } catch {
          /* not for me / tampered */
        }
      }
    }
    return any;
  };

  const requireAdmin = async (): Promise<CircleState> => {
    const state = await reduce();
    if (!state) throw new Error('NO_CIRCLE');
    if (state.members[kernel.memberId()]?.role !== 'admin') throw new Error('NOT_ADMIN');
    return state;
  };

  // Remaining members pick rotated keys up as soon as the grant envelope arrives.
  kernel.onEnvelope((env: Envelope) => {
    if (env.category === 'grant') {
      void applyKeyGrants().then((got) => got && notify()).catch(() => {});
    } else if (env.category === 'membership' || env.category === 'circle') {
      notify();
    }
  });

  /** Signs the CK handover to `to` (admin side) and sends it over the invite's key room. */
  const handOver = async (req: Request, subjectId: string) => {
    const me = kernel.bundle();
    const current = await currentEpoch();
    if (current === null || !circleId) throw new Error('NO_CIRCLE');
    const keys: Handover['keys'] = [];
    for (let e = 0; e <= current; e++) {
      try {
        const w = await kernel.wrapKeyFor({ circleEpoch: e }, req.hello.boxPub, CK_INFO, ckAad(circleId, subjectId, e));
        keys.push({ epoch: e, ephPub: w.ephPub, wrapped: w.wrapped });
      } catch {
        /* epoch not held by this admin */
      }
    }
    const h: Handover = { circleId, to: subjectId, keys };
    const payload: SignedJoinHandover = { ...h, sig: await sign(me.signPkcs8, joinHandoverBytes(h)) };
    // Contract gap: the invite transport only carries InviteHello, so the payload rides in displayName
    // of a message on a second room (<inviteRoom>.keys). It is wrapped to the joiner and signed by the admin.
    const conn = await opts.transport.join(await roomOf(req.invite.s));
    await conn.send({ signPub: me.signPub, boxPub: me.boxPub, deviceId: kernel.deviceId(), displayName: JSON.stringify(payload) });
    // The joiner may not be connected to this room yet (WebRTC needs a moment to link the peers and
    // sync the doc), so the connection stays open for a grace period instead of closing right away.
    setTimeout(() => conn.close(), HANDOVER_LINGER_MS);
  };

  return {
    async circle() {
      await applyKeyGrants().catch(() => false);
      return reduce();
    },

    async createCircle(name) {
      const me = kernel.bundle();
      const id = b64u(randomBytes(16));
      kernel.addCircleKey(0, randomBytes(32));
      await kernel.setCircle(id, { memberId: me.memberId, signPub: me.signPub });
      genesis = { memberId: me.memberId, signPub: me.signPub };
      circleId = id;
      await publishEvent({
        v: 1,
        id: b64u(randomBytes(16)),
        circle: id,
        kind: 'create',
        actor: me.memberId,
        signPub: me.signPub,
        boxPub: me.boxPub,
        displayName: opts.displayName(),
        deviceId: kernel.deviceId(),
        hlc: hlc(),
      });
      await kernel.publish(await kernel.seal({ category: 'circle', circle: id, plaintext: { kind: 'circle-name', name } }));
      const state = await reduce();
      if (!state) throw new Error('NO_CIRCLE');
      return state;
    },

    async createInvite(): Promise<InviteTicket> {
      await requireAdmin();
      const me = kernel.bundle();
      const invite = createInvite(circleId!);
      const channel = new InviteChannel(opts.transport, {
        signPub: me.signPub,
        boxPub: me.boxPub,
        displayName: opts.displayName(),
        deviceId: kernel.deviceId(),
      });
      channel
        .connect(invite)
        .then(({ sas, peer }) => {
          const requestId = b64u(randomBytes(12));
          requests.set(requestId, { requestId, hello: peer, sas, invite });
          notify();
        })
        .catch(() => {
          /* invite expired without a joiner */
        });
      return { url: inviteUrl(invite, opts.origin), expiresAt: invite.e };
    },

    async join(url, displayName) {
      const invite = parseInviteUrl(url);
      const me = kernel.bundle();
      const channel = new InviteChannel(opts.transport, {
        signPub: me.signPub,
        boxPub: me.boxPub,
        displayName,
        deviceId: kernel.deviceId(),
      });
      const { sas, peer } = await channel.connect(invite);
      const adminId = await memberIdFromSpki(peer.signPub);
      await kernel.setCircle(invite.c, { memberId: adminId, signPub: peer.signPub });
      genesis = { memberId: adminId, signPub: peer.signPub };
      circleId = invite.c;

      // Wait for the admin's key handover (after SAS approval) on the key room.
      const conn = await opts.transport.join(await roomOf(invite.s));
      const off = conn.onMessage((msg) => {
        void (async () => {
          try {
            if (msg.signPub !== peer.signPub) return;
            const p = JSON.parse(msg.displayName) as SignedJoinHandover;
            const myId = kernel.memberId();
            const h: Handover = { circleId: p.circleId, to: p.to, keys: p.keys };
            if (h.circleId !== invite.c || h.to !== myId || !Array.isArray(h.keys)) return;
            if (!(await verify(peer.signPub, joinHandoverBytes(h), p.sig))) return;
            for (const k of h.keys) {
              const raw = await kernel.unwrapForMe(k.ephPub, k.wrapped, CK_INFO, ckAad(h.circleId, myId, k.epoch));
              kernel.addCircleKey(k.epoch, raw);
            }
            off();
            conn.close();
            notify();
          } catch {
            /* ignore forged or malformed handover */
          }
        })();
      });
      return { sas };
    },

    async pendingJoins(): Promise<PendingJoin[]> {
      return [...requests.values()].map((r) => ({ requestId: r.requestId, displayName: r.hello.displayName, sas: r.sas }));
    },

    async approveJoin(requestId, sasMatches) {
      const req = requests.get(requestId);
      if (!req) throw new Error('REQUEST_NOT_FOUND');
      requests.delete(requestId);
      if (!sasMatches) {
        notify();
        return;
      }
      const state = await requireAdmin();
      const subject = await memberIdFromSpki(req.hello.signPub);
      await publishEvent({
        v: 1,
        id: b64u(randomBytes(16)),
        circle: state.circleId,
        kind: 'approve',
        actor: kernel.memberId(),
        subject,
        role: 'member',
        signPub: req.hello.signPub,
        boxPub: req.hello.boxPub,
        displayName: req.hello.displayName,
        deviceId: req.hello.deviceId,
        hlc: hlc(),
      });
      await handOver(req, subject);
      notify();
    },

    async removeMember(memberId) {
      const state = await requireAdmin();
      const me = kernel.memberId();
      if (memberId === me || !state.members[memberId]) throw new Error('INVALID_TARGET');
      await publishEvent({
        v: 1,
        id: b64u(randomBytes(16)),
        circle: state.circleId,
        kind: 'remove',
        actor: me,
        subject: memberId,
        hlc: hlc(),
      });
      const oldEpoch = state.epoch;
      const newEpoch = oldEpoch + 1;
      const ck = randomBytes(32);
      const sk = kernel.bundle().signPkcs8;

      // The Kernel seals with its newest key, so the handovers are sealed first (still the CURRENT key,
      // readable by remaining members) and the new epoch is registered afterwards. The raw CK is mine
      // (just generated), hence it is wrapped with crypto.wrapTo instead of kernel.wrapKeyFor.
      const envs: Envelope[] = [];
      for (const m of Object.values(state.members)) {
        if (m.removed || m.dependent || m.memberId === memberId || m.memberId === me) continue;
        const w = await wrapTo(m.boxPub, ck, CK_INFO, ckAad(state.circleId, m.memberId, newEpoch));
        const h: KeyHandover = { circleId: state.circleId, to: m.memberId, epoch: newEpoch, ...w };
        const plaintext = { kind: 'circle-key', ...h, sig: await sign(sk, handoverBytes(h)) };
        envs.push(await kernel.seal({ category: 'grant', circle: state.circleId, plaintext }));
      }
      kernel.addCircleKey(newEpoch, ck);
      for (const env of envs) await kernel.publish(env);
      notify();
    },

    async addDependent(displayName): Promise<Member> {
      const state = await requireAdmin();
      const me = kernel.memberId();
      const bundle = await createMemberBundle();
      dependents.set(bundle.memberId, bundle);
      await publishEvent({
        v: 1,
        id: b64u(randomBytes(16)),
        circle: state.circleId,
        kind: 'approve',
        actor: me,
        subject: bundle.memberId,
        role: 'member',
        signPub: bundle.signPub,
        boxPub: bundle.boxPub,
        displayName,
        hlc: hlc(),
      });
      await publishEvent({
        v: 1,
        id: b64u(randomBytes(16)),
        circle: state.circleId,
        kind: 'guardian',
        actor: me,
        subject: bundle.memberId,
        ref: me,
        hlc: hlc(),
      });
      const fresh = await reduce();
      const member = fresh?.members[bundle.memberId];
      if (!member) throw new Error('DEPENDENT_REJECTED');
      return member;
    },

    async setGuardian(guardianId) {
      const state = await reduce();
      if (!state) throw new Error('NO_CIRCLE');
      const me = kernel.memberId();
      await publishEvent({
        v: 1,
        id: b64u(randomBytes(16)),
        circle: state.circleId,
        kind: 'guardian',
        actor: me,
        subject: me,
        ref: guardianId,
        hlc: hlc(),
      });
    },

    onChange(cb) {
      subs.add(cb);
      return () => {
        subs.delete(cb);
      };
    },
  };
}
