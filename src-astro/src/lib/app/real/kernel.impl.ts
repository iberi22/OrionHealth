// Real Kernel (spec §3–§9) over the vault session, the envelope store and the family libraries.
// Raw keys (CEKs, circle keys, received keys) live only in this object while the vault is unlocked;
// they are persisted sealed with a key derived from the MRS and dropped (zero-filled) on lock.

import { aesKey, b64u, canonical, fromB64u, fromUtf8, hkdf, openBlob, randomBytes, sealBlob, unwrapFrom, utf8, wrapTo } from '../../crypto/index';
import type { VaultState } from '../../contracts/services';
import type { CircleState, Category, Envelope, Grant, MembershipEvent, PersonalCategory } from '../../contracts/types';
import { cekFor, currentEpoch, deriveCek, type MemberBundle } from '../../vault/keyring';
import type { openEnvelopeStore } from '../../vault/store';
import { openEnvelope, sealEnvelope, verifyEnvelope } from '../../family/envelope';
import { createHlc, type Hlc } from '../../family/hlc';
import { reduceMembership } from '../../family/membership';
import { validateEnvelope } from '../../family/validate';
import { createCircleReplica, type CircleReplica } from '../../family/sync';
import { CIRCLE_KEYED, KernelError, type Kernel, type SealRequest } from './kernel';

/** The subset of the vault session (vault/session.ts) the kernel needs. */
export interface KernelSession {
  state(): VaultState;
  onState(cb: (s: VaultState) => void): () => void;
  bundle(): MemberBundle | null;
  withMrs<T>(fn: (mrs: Uint8Array) => T | Promise<T>): Promise<T>;
  saveBundle(bundle: MemberBundle): Promise<string>;
  putMeta(key: string, value: string): Promise<void>;
  getMeta(key: string): Promise<string | undefined>;
}

export type EnvelopeStore = Awaited<ReturnType<typeof openEnvelopeStore>>;

export interface KernelOptions {
  session: KernelSession;
  store: EnvelopeStore;
  deviceId: string;
  /** Open the WebRTC replica when a circle key is known (default true; tests pass false). */
  connect?: boolean;
  /** With connect, false keeps the replica's Y.Doc in memory without y-webrtc (tests sync docs by hand). */
  transport?: boolean;
  now?: () => number;
}

/** Envelopes whose content is validated by its own protocol (membership reducer), not by grants. */
const SELF_VALIDATED: readonly Category[] = ['membership'];

/**
 * Rejection reasons that can turn valid once more of the log arrives (spec §8: replicas deliver in any order):
 * the author's approve or the owner's grant may still be on its way. Remote envelopes rejected for these
 * reasons wait in a pending queue and are re-validated after every accepted membership or grant envelope.
 */
const RETRYABLE = new Set(['unknown-author', 'author-not-member', 'unknown-owner', 'unauthorized-write']);
/** Bound of the pending queue (per unlocked session); when full, the oldest entry is dropped. */
export const MAX_PENDING = 500;

const retryable = (e: unknown) => e instanceof KernelError && e.code === 'INVALID' && RETRYABLE.has(e.message);

interface Keystore {
  circle?: { id: string; genesis: { memberId: string; signPub: string } };
  circleKeys: Record<string, string>;
  foreign: Record<string, string>;
  revoked: string[];
}

const same = (a: Envelope, b: Envelope) => fromUtf8(canonical(a)) === fromUtf8(canonical(b));

/**
 * An open circle replica (spec §8). The full one lives in the room of the newest circle key and carries every
 * envelope. Each older epoch this device holds keeps a handover room that carries only circle-keyed envelopes
 * sealed with that epoch, so a member offline during a removal still gets the rotated key; nothing sealed with a
 * newer key or a personal CEK is ever pushed into a room a removed member can derive.
 */
interface OpenReplica {
  epoch: number;
  full: boolean;
  replica: CircleReplica;
}

export async function createKernel(opts: KernelOptions): Promise<RealKernel> {
  const k = new RealKernel(opts);
  opts.session.onState((s) => {
    if (s === 'unlocked') void k.load();
    else k.drop();
  });
  if (opts.session.state() === 'unlocked') await k.load();
  return k;
}

export class RealKernel implements Kernel {
  private foreign = new Map<string, Uint8Array>();
  private circleKeys = new Map<number, Uint8Array>();
  private revoked = new Set<string>();
  private circleInfo: Keystore['circle'];
  private replicas = new Map<number, OpenReplica>();
  private pending = new Map<string, Envelope>();
  private revalidating = false;
  private revalidateAgain = false;
  private hlc: Hlc;
  private envSubs = new Set<(e: Envelope) => void | Promise<void>>();
  private lockSubs = new Set<() => void>();
  private loaded = false;
  private now: () => number;

  constructor(private opts: KernelOptions) {
    this.hlc = createHlc(opts.deviceId);
    this.now = opts.now ?? Date.now;
  }

  // ---------- lifecycle ----------

  private keystoreKey(mrs: Uint8Array, memberId: string) {
    return hkdf(mrs, utf8(memberId), 'orion/v1/keystore').then(aesKey);
  }

  private loading: Promise<void> | null = null;
  /** Restores persisted keys after unlock. Memoized until the next lock, so callers can await the same run. */
  load(): Promise<void> {
    if (!this.opts.session.bundle()) return Promise.resolve();
    this.loading ??= this.doLoad().catch((e) => {
      this.loading = null;
      throw e;
    });
    return this.loading;
  }

  private async doLoad() {
    const b = this.opts.session.bundle()!;
    // Leaving recovery guest mode (spec §9.3): the circle and keys of the invitation are kept and persisted.
    const guestCircle = this.guest ? this.circleInfo : undefined;
    this.guest = false;
    const blob = await this.opts.session.getMeta('keystore');
    if (blob) {
      const ks: Keystore = await this.opts.session.withMrs(async (mrs) =>
        JSON.parse(fromUtf8(await openBlob(await this.keystoreKey(mrs, b.memberId), blob, utf8(`orion/v1/keystore|${b.memberId}`)))),
      );
      this.circleInfo = guestCircle ?? ks.circle;
      for (const [e, raw] of Object.entries(ks.circleKeys)) this.circleKeys.set(Number(e), fromB64u(raw));
      for (const [k, raw] of Object.entries(ks.foreign)) this.foreign.set(k, fromB64u(raw));
      this.revoked = new Set(ks.revoked);
    }
    if (guestCircle) await this.persist();
    this.loaded = true;
    await this.startReplica();
  }

  private persisting: Promise<void> = Promise.resolve();
  /** Serialized: each write snapshots the keys when it runs, so the last write holds the latest state
   *  (addCircleKey() and setCircle() persist back to back). */
  private persist(): Promise<void> {
    const run = this.persisting.then(() => this.persistNow());
    this.persisting = run.catch(() => undefined);
    return run;
  }

  private async persistNow() {
    const b = this.bundle();
    const ks: Keystore = {
      circle: this.circleInfo,
      circleKeys: Object.fromEntries([...this.circleKeys].map(([e, raw]) => [String(e), b64u(raw)])),
      foreign: Object.fromEntries([...this.foreign].map(([k, raw]) => [k, b64u(raw)])),
      revoked: [...this.revoked],
    };
    const blob = await this.opts.session.withMrs(async (mrs) =>
      sealBlob(await this.keystoreKey(mrs, b.memberId), utf8(JSON.stringify(ks)), utf8(`orion/v1/keystore|${b.memberId}`)),
    );
    await this.opts.session.putMeta('keystore', blob);
  }

  /** Called on lock: nothing key-related stays referenced. */
  drop() {
    for (const raw of this.foreign.values()) raw.fill(0);
    for (const raw of this.circleKeys.values()) raw.fill(0);
    this.foreign.clear();
    this.circleKeys.clear();
    this.revoked.clear();
    this.pending.clear();
    this.circleInfo = undefined;
    this.guest = false;
    this.loading = null;
    this.generation++;
    for (const r of this.replicas.values()) r.replica.destroy();
    this.replicas.clear();
    this.loaded = false;
    this.lockSubs.forEach((cb) => cb());
  }

  private guard() {
    if (this.opts.session.state() !== 'unlocked' || !this.opts.session.bundle()) {
      throw new KernelError('LOCKED', 'vault is locked');
    }
  }

  private replicaChain: Promise<void> = Promise.resolve();

  // ---------- recovery guest mode (spec §9.3) ----------
  // A brand-new device recovering a member has no bundle yet. The recovery invitation gives it the circle and its
  // keys; in guest mode the kernel validates, stores, relays and opens circle envelopes, but it never seals or signs
  // (seal/bundle/memberId keep the strict guard). Unlocking with the recovered MRS leaves guest mode (doLoad).
  private guest = false;

  async enterGuest(circleId: string, genesis: { memberId: string; signPub: string }, keys: { epoch: number; raw: Uint8Array }[]) {
    if (this.opts.session.state() === 'unlocked') throw new KernelError('INVALID', 'guest mode is only for a vault that is not unlocked');
    this.guest = true;
    this.circleInfo = { id: circleId, genesis };
    for (const k of keys) this.circleKeys.set(k.epoch, k.raw.slice());
    await this.startReplica();
  }

  /** Abandons guest mode without unlocking (failed or cancelled recovery): nothing stays referenced. */
  leaveGuest() {
    if (this.guest && this.opts.session.state() !== 'unlocked') this.drop();
  }

  /** Reading and relaying circle envelopes is also allowed in guest mode. */
  private guardRead() {
    if (this.guest && this.circleInfo) return;
    this.guard();
  }

  /** Bumped on every lock so a replica that finishes opening after lock() is discarded. */
  private generation = 0;

  /** Serialized: load(), setCircle() and addCircleKey() can race, and y-webrtc throws when a second provider
   *  is opened for a room that already has one. Each call re-checks the rooms once the previous one is done. */
  private startReplica(): Promise<void> {
    const run = this.replicaChain.then(() => this.syncReplicas());
    this.replicaChain = run.catch(() => undefined);
    return run;
  }

  /** Does replica `r` carry `env`? Decided against the newest key held now, so a full replica whose room is
   *  about to be abandoned (a rotated CK was just registered) already behaves as a handover room. */
  private carries(r: OpenReplica, env: Envelope) {
    const circleId = this.circleInfo?.id;
    if (r.full && this.circleKeys.size && r.epoch === Math.max(...this.circleKeys.keys())) {
      if (env.circle === circleId) return true;
      // my personal envelopes written before the circle existed
      const me = this.opts.session.bundle()?.memberId;
      return env.circle === 'local' && env.owner === me && env.author === me;
    }
    return env.circle === circleId && CIRCLE_KEYED.includes(env.category) && env.epoch === r.epoch;
  }

  /**
   * Brings the open replicas in line with the circle keys (spec §8): the full replica moves to the room of the
   * newest CK (after a removal the old room is abandoned by the remaining members), and every older epoch keeps
   * a handover room. Every replica is seeded from the store when it opens, because its Y.Doc is ephemeral.
   */
  private async syncReplicas() {
    const gen = this.generation;
    const info = this.circleInfo;
    if (!info || !this.circleKeys.size || this.opts.connect === false) return;
    const newest = Math.max(...this.circleKeys.keys());
    for (const [epoch, r] of [...this.replicas]) {
      if (r.full && epoch !== newest) {
        r.replica.destroy();
        this.replicas.delete(epoch);
      }
    }
    for (const epoch of [...this.circleKeys.keys()].sort((a, b) => b - a)) {
      if (this.replicas.has(epoch)) continue;
      const key = this.circleKeys.get(epoch);
      if (!key) continue;
      const replica = await createCircleReplica({
        circleId: info.id,
        ck0: key,
        connect: this.opts.transport !== false,
        validate: (env) => this.acceptRemote(env, epoch),
        // acceptRemote() already stored it
        sink: () => {},
      });
      if (gen !== this.generation) {
        // locked while the replica was opening: do not keep it around
        replica.destroy();
        return;
      }
      // Registered before reading the store: a publish racing with the seed either is in the listing or
      // reaches the replica through publish().
      const r: OpenReplica = { epoch, full: epoch === newest, replica };
      this.replicas.set(epoch, r);
      const stored = [...(await this.opts.store.listByCircle(info.id)), ...(await this.opts.store.listByCircle('local'))];
      if (gen !== this.generation) return;
      replica.seed(stored.filter((e) => this.carries(r, e)));
    }
  }

  /** Validation hook of the replica of `source`: a newly accepted envelope is relayed to the other rooms. */
  private async acceptRemote(env: Envelope, source: number): Promise<boolean> {
    try {
      // A handover room is shared with removed members: only current members are heard there, so a removed
      // member cannot push (backdated) events through it. Final, not retried through the pending queue.
      if (this.circleKeys.size && source !== Math.max(...this.circleKeys.keys())) {
        const m = (await this.circle())?.members[env.author];
        if (!m || m.removed) throw new KernelError('INVALID', 'not-a-current-member');
      }
      if (await this.accept(env)) await this.replicate(env, source).catch(() => undefined);
      return true;
    } catch (e) {
      this.queuePending(env, e);
      return false;
    }
  }

  private async replicate(env: Envelope, skip?: number) {
    for (const r of [...this.replicas.values()]) {
      if (r.epoch !== skip && this.carries(r, env)) await r.replica.add(env);
    }
  }

  /** Room and doc of the full replica (tests and diagnostics). */
  replicaInfo(): { room: string; doc: CircleReplica['doc'] } | null {
    const r = [...this.replicas.values()].find((x) => x.full);
    return r ? { room: r.replica.room, doc: r.replica.doc } : null;
  }

  /** Every open replica, newest epoch first (tests and diagnostics). */
  replicaRooms(): { epoch: number; full: boolean; room: string; doc: CircleReplica['doc'] }[] {
    return [...this.replicas.values()]
      .sort((a, b) => b.epoch - a.epoch)
      .map((r) => ({ epoch: r.epoch, full: r.full, room: r.replica.room, doc: r.replica.doc }));
  }

  private queuePending(env: Envelope, e: unknown) {
    if (!retryable(e) || this.pending.has(env.id)) return;
    if (this.pending.size >= MAX_PENDING) this.pending.delete(this.pending.keys().next().value as string);
    this.pending.set(env.id, env);
  }

  /** Re-validates the pending queue; re-entrant calls (an accepted pending membership envelope) loop once more. */
  private async revalidatePending() {
    if (!this.pending.size) return;
    if (this.revalidating) {
      this.revalidateAgain = true;
      return;
    }
    this.revalidating = true;
    const gen = this.generation;
    try {
      do {
        this.revalidateAgain = false;
        for (const [id, env] of [...this.pending]) {
          if (gen !== this.generation) return;
          if (!this.pending.has(id)) continue;
          try {
            const fresh = await this.accept(env);
            this.pending.delete(id);
            // Into the replica's valid set, so overwrites of this id are restored like any other.
            if (fresh) await this.replicate(env).catch(() => undefined);
          } catch (e) {
            if (!retryable(e)) this.pending.delete(id);
          }
        }
      } while (this.revalidateAgain && this.pending.size);
    } finally {
      this.revalidating = false;
    }
  }

  // ---------- identity ----------

  memberId() {
    return this.bundle().memberId;
  }
  deviceId() {
    this.guard();
    return this.opts.deviceId;
  }
  bundle(): MemberBundle {
    this.guard();
    return this.opts.session.bundle()!;
  }

  // ---------- keys ----------

  private async maxOwnEpochInStore(category: PersonalCategory): Promise<number> {
    const envs = await this.opts.store.listByOwnerCategory(this.memberId(), category);
    return envs.length > 0 ? Math.max(...envs.map(e => e.epoch)) : 0;
  }

  private async ensureCategory(category: PersonalCategory) {
    const b = this.bundle();
    const hasAnyEpoch = b.ceks[category] && Object.keys(b.ceks[category]!).length > 0;
    if (!hasAnyEpoch) {
      const maxInStore = await this.maxOwnEpochInStore(category);
      const epoch = Math.max(Date.now(), currentEpoch(b, category) + 1, maxInStore + 1);
      const raw = await this.opts.session.withMrs(mrs => deriveCek(mrs, b.memberId, category, epoch));
      if (!b.ceks[category]) b.ceks[category] = {};
      b.ceks[category]![epoch] = b64u(raw);
      await this.saveAndPublishBundle(b);
    }
    return b;
  }

  private async saveAndPublishBundle(b: MemberBundle) {
    const sealed = await this.opts.session.saveBundle(b);
    if (this.circleInfo && this.circleKeys.size) {
      await this.publish(await this.seal({ category: 'bundle', plaintext: { memberId: b.memberId, sealed } }));
    }
  }

  async categoryKey(category: PersonalCategory, opts: { owner?: string; epoch?: number } = {}) {
    this.guard();
    const owner = opts.owner ?? this.memberId();
    if (owner === this.memberId()) {
      const b = await this.ensureCategory(category);
      const epoch = opts.epoch ?? currentEpoch(b, category);
      let raw: string;
      try {
        raw = cekFor(b, category, epoch);
      } catch (e: any) {
        if (e.code === 'KEY_NOT_FOUND') {
          const derived = await this.opts.session.withMrs(mrs => deriveCek(mrs, b.memberId, category, epoch));
          raw = b64u(derived);
          if (!b.ceks[category]) b.ceks[category] = {};
          b.ceks[category][epoch] = raw;
          await this.saveAndPublishBundle(b);
        } else {
          throw e;
        }
      }
      return { key: await aesKey(fromB64u(raw)), epoch };
    }
    const prefix = `${owner}|${category}|`;
    const epochs = [...this.foreign.keys()].filter((k) => k.startsWith(prefix)).map((k) => Number(k.slice(prefix.length)));
    const epoch = opts.epoch ?? (epochs.length ? Math.max(...epochs) : -1);
    const rawLocal = this.foreign.get(`${prefix}${epoch}`);
    if (!rawLocal) throw new KernelError('NO_KEY', `no key for ${owner}/${category}`);
    return { key: await aesKey(rawLocal), epoch };
  }

  async circleKey(epoch?: number) {
    this.guardRead();
    if (!this.circleKeys.size) throw new KernelError('NO_CIRCLE', 'no circle key');
    const e = epoch ?? Math.max(...this.circleKeys.keys());
    const raw = this.circleKeys.get(e);
    if (!raw) throw new KernelError('NO_KEY', `no circle key epoch ${e}`);
    return { key: await aesKey(raw), epoch: e };
  }

  addForeignKey(owner: string, category: PersonalCategory, epoch: number, raw: Uint8Array) {
    this.guard();
    this.foreign.set(`${owner}|${category}|${epoch}`, raw.slice());
    void this.persist();
  }

  addCircleKey(epoch: number, raw: Uint8Array) {
    this.guard();
    this.circleKeys.set(epoch, raw.slice());
    void this.persist()
      .then(() => this.startReplica())
      .then(() => this.revalidatePending())
      .catch(() => undefined);
  }

  async wrapKeyFor(
    target: { category: PersonalCategory; epoch?: number } | { circleEpoch: number },
    recipientBoxPub: string,
    info: string,
    aad: Uint8Array,
  ) {
    this.guard();
    let raw: Uint8Array;
    let epoch: number;
    if ('circleEpoch' in target) {
      epoch = target.circleEpoch;
      const ck = this.circleKeys.get(epoch);
      if (!ck) throw new KernelError('NO_KEY', `no circle key epoch ${epoch}`);
      raw = ck;
    } else {
      const b = await this.ensureCategory(target.category);
      epoch = target.epoch ?? currentEpoch(b, target.category);
      raw = fromB64u(cekFor(b, target.category, epoch));
    }
    return { ...(await wrapTo(recipientBoxPub, raw, info, aad)), epoch };
  }

  async unwrapForMe(ephPub: string, wrapped: string, info: string, aad: Uint8Array) {
    return unwrapFrom(this.bundle().boxPkcs8, ephPub, wrapped, info, aad);
  }

  async rotateCategory(category: PersonalCategory) {
    const b = await this.ensureCategory(category);
    const maxInStore = await this.maxOwnEpochInStore(category);
    const epoch = Math.max(Date.now(), currentEpoch(b, category) + 1, maxInStore + 1);
    const raw = await this.opts.session.withMrs(mrs => deriveCek(mrs, b.memberId, category, epoch));
    if (!b.ceks[category]) b.ceks[category] = {};
    b.ceks[category][epoch] = b64u(raw);
    await this.saveAndPublishBundle(b);
    return epoch;
  }

  // ---------- circle ----------

  async setCircle(circleId: string, genesis: { memberId: string; signPub: string }) {
    this.guard();
    this.circleInfo = { id: circleId, genesis };
    await this.persist();
    await this.startReplica();
  }

  async circle(): Promise<CircleState | null> {
    if (!this.circleInfo || !this.circleKeys.size) return null;
    const events: MembershipEvent[] = [];
    for (const env of await this.opts.store.listByCategory('membership')) {
      if (env.circle !== this.circleInfo.id) continue;
      try {
        events.push((await this.open(env)) as MembershipEvent);
      } catch {
        /* membership envelope of an epoch we cannot read */
      }
    }
    const { state } = await reduceMembership(this.circleInfo.id, events, this.circleInfo.genesis.memberId);
    return state;
  }

  async signPubOf(memberId: string) {
    const b = this.opts.session.bundle();
    if (b && memberId === b.memberId) return b.signPub;
    if (this.circleInfo?.genesis.memberId === memberId) return this.circleInfo.genesis.signPub;
    return (await this.circle())?.members[memberId]?.signPub ?? null;
  }

  async boxPubOf(memberId: string) {
    const b = this.opts.session.bundle();
    if (b && memberId === b.memberId) return b.boxPub;
    return (await this.circle())?.members[memberId]?.boxPub ?? null;
  }

  // ---------- envelopes ----------

  private keyFor(category: Category, owner: string, epoch?: number) {
    return CIRCLE_KEYED.includes(category) ? this.circleKey(epoch) : this.categoryKey(category as PersonalCategory, { owner, epoch });
  }

  async seal(req: SealRequest): Promise<Envelope> {
    this.guard();
    const owner = req.owner ?? this.memberId();
    const { key, epoch } = await this.keyFor(req.category, owner);
    return sealEnvelope({
      id: b64u(randomBytes(16)),
      circle: req.circle ?? this.circleInfo?.id ?? 'local',
      owner,
      author: this.memberId(),
      device: this.opts.deviceId,
      category: req.category,
      epoch,
      hlc: this.hlc.tick(),
      plaintext: req.plaintext,
      categoryKey: key,
      authorSignPkcs8: this.bundle().signPkcs8,
    });
  }

  async open(env: Envelope): Promise<unknown> {
    this.guardRead();
    const { key } = await this.keyFor(env.category, env.owner, env.epoch);
    return openEnvelope(env, key);
  }

  /**
   * Signed grants of the circle and the revoked set (spec §6), read from the `grant` envelopes this member
   * can open. A revocation is a `{ kind: 'revoke', grantId }` marker; it counts only when the marker
   * envelope's author (authenticated by the envelope signature at acceptance) is the grant's `from`.
   * Every device derives the same set from the replicated markers; `revokeGrant` only adds local ids.
   */
  private async grantState(): Promise<{ grants: Grant[]; revoked: Set<string> }> {
    const grants: Grant[] = [];
    const markers: { grantId: string; author: string }[] = [];
    for (const env of await this.opts.store.listByCategory('grant')) {
      let pt: unknown;
      try {
        pt = await this.open(env);
      } catch {
        continue; // unreadable
      }
      if (!pt || typeof pt !== 'object') continue;
      const o = pt as Partial<Grant> & { kind?: unknown; grantId?: unknown };
      if (o.kind === 'revoke' && typeof o.grantId === 'string') markers.push({ grantId: o.grantId, author: env.author });
      else if (o.v === 1 && typeof o.sig === 'string') grants.push(o as Grant);
    }
    const revoked = new Set(this.revoked);
    for (const m of markers) if (grants.some((g) => g.id === m.grantId && g.from === m.author)) revoked.add(m.grantId);
    return { grants, revoked };
  }

  /** Validates and stores an envelope. Returns false for an identical duplicate. */
  private async accept(env: Envelope): Promise<boolean> {
    const existing = await this.opts.store.get(env.id);
    if (existing) {
      if (same(existing, env)) return false;
      throw new KernelError('ID_CONFLICT', `envelope ${env.id} already stored with other content`);
    }
    if (SELF_VALIDATED.includes(env.category)) {
      const pub = await this.signPubOf(env.author);
      if (!pub) throw new KernelError('INVALID', 'unknown-author');
      if (!(await verifyEnvelope(env, pub))) throw new KernelError('INVALID', 'invalid-signature');
    } else {
      const { grants, revoked } = await this.grantState();
      const res = await validateEnvelope(env, {
        state: await this.circle(),
        grants,
        revoked,
        signPubOf: (id) => this.signPubOf(id),
        now: this.now(),
      });
      if (!res.ok) throw new KernelError('INVALID', res.reason);
    }
    await this.opts.store.put(env);
    this.hlc.receive(env.hlc);
    // Listeners may return a promise (e.g. the rotation after a removal, spec §7); publish() waits for it.
    await Promise.allSettled([...this.envSubs].map(async (cb) => cb(env)));
    if (env.category === 'membership' || env.category === 'grant') void this.revalidatePending();
    return true;
  }

  async publish(env: Envelope) {
    this.guardRead();
    await this.accept(env);
    await this.replicate(env);
  }

  async envelopes(filter: { owner?: string; category?: Category } = {}) {
    const { owner, category } = filter;
    if (owner && category) return this.opts.store.listByOwnerCategory(owner, category);
    if (owner) return this.opts.store.listByOwner(owner);
    if (category) return this.opts.store.listByCategory(category);
    const all: Envelope[] = [];
    for (const c of [this.circleInfo?.id, 'local']) if (c) all.push(...(await this.opts.store.listByCircle(c)));
    return all;
  }

  onEnvelope(cb: (env: Envelope) => void | Promise<void>) {
    this.envSubs.add(cb);
    return () => this.envSubs.delete(cb);
  }

  onLock(cb: () => void) {
    this.lockSubs.add(cb);
    return () => this.lockSubs.delete(cb);
  }

  /** For revocation (spec §6): grants with these ids no longer authorize writes on this device. The
   *  circle-wide source is the signed revoke markers (grantState); this only adds to it. */
  async revokeGrant(grantId: string) {
    this.revoked.add(grantId);
    await this.persist();
  }

  get isLoaded() {
    return this.loaded;
  }
}
