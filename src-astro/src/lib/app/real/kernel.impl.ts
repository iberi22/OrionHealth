// Real Kernel (spec §3–§9) over the vault session, the envelope store and the family libraries.
// Raw keys (CEKs, circle keys, received keys) live only in this object while the vault is unlocked;
// they are persisted sealed with a key derived from the MRS and dropped (zero-filled) on lock.

import { aesKey, b64u, canonical, fromB64u, fromUtf8, hkdf, openBlob, randomBytes, sealBlob, unwrapFrom, utf8, wrapTo } from '../../crypto/index';
import type { VaultState } from '../../contracts/services';
import type { CircleState, Category, Envelope, Grant, MembershipEvent, PersonalCategory } from '../../contracts/types';
import { cekFor, currentEpoch, rotateCategory as rotateInBundle, type MemberBundle } from '../../vault/keyring';
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
  now?: () => number;
}

/** Envelopes whose content is validated by its own protocol (membership reducer), not by grants. */
const SELF_VALIDATED: readonly Category[] = ['membership'];

interface Keystore {
  circle?: { id: string; genesis: { memberId: string; signPub: string } };
  circleKeys: Record<string, string>;
  foreign: Record<string, string>;
  revoked: string[];
}

const same = (a: Envelope, b: Envelope) => fromUtf8(canonical(a)) === fromUtf8(canonical(b));

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
  private replica: CircleReplica | null = null;
  private hlc: Hlc;
  private envSubs = new Set<(e: Envelope) => void>();
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

  private async persist() {
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
    this.circleInfo = undefined;
    this.guest = false;
    this.loading = null;
    this.generation++;
    this.replica?.destroy();
    this.replica = null;
    this.loaded = false;
    this.lockSubs.forEach((cb) => cb());
  }

  private guard() {
    if (this.opts.session.state() !== 'unlocked' || !this.opts.session.bundle()) {
      throw new KernelError('LOCKED', 'vault is locked');
    }
  }

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

  /**
   * Re-offers to validation the envelopes of the replica doc that are not stored yet. The replica validates a
   * remote envelope once, on arrival; in the initial sync an envelope can arrive before the membership log that
   * makes it valid and is then dropped. The recovering device calls this until its view is complete.
   */
  async resync(): Promise<number> {
    if (!this.replica) return 0;
    let added = 0;
    for (const env of [...this.replica.doc.getMap<Envelope>('env').values()]) {
      if (await this.opts.store.get(env.id)) continue;
      try {
        if (await this.accept(env)) added++;
      } catch {
        /* still invalid */
      }
    }
    return added;
  }

  /** Reading and relaying circle envelopes is also allowed in guest mode. */
  private guardRead() {
    if (this.guest && this.circleInfo) return;
    this.guard();
  }

  private starting: Promise<void> | null = null;
  /** Bumped on every lock so a replica that finishes opening after lock() is discarded. */
  private generation = 0;

  /** Idempotent and serialized: load(), setCircle() and addCircleKey() can race, and y-webrtc throws
   *  when a second provider is opened for a room that already has one. */
  private startReplica(): Promise<void> {
    this.starting ??= this.openReplica().finally(() => {
      this.starting = null;
    });
    return this.starting;
  }

  private async openReplica() {
    const gen = this.generation;
    const ck0 = this.circleKeys.get(0);
    if (this.replica || !this.circleInfo || !ck0 || this.opts.connect === false) return;
    const replica = await createCircleReplica({
      circleId: this.circleInfo.id,
      ck0,
      validate: async (env) => {
        try {
          await this.accept(env);
          return true;
        } catch {
          return false;
        }
      },
      // accept() already stored it
      sink: () => {},
    });
    if (gen !== this.generation) {
      // locked while the replica was opening: do not keep it around
      replica.destroy();
      return;
    }
    this.replica = replica;
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

  private async ensureCategory(category: PersonalCategory) {
    const b = this.bundle();
    if (!b.ceks[category]) {
      rotateInBundle(b, category);
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
      } catch {
        throw new KernelError('NO_KEY', `no key for ${category} epoch ${epoch}`);
      }
      return { key: await aesKey(fromB64u(raw)), epoch };
    }
    const prefix = `${owner}|${category}|`;
    const epochs = [...this.foreign.keys()].filter((k) => k.startsWith(prefix)).map((k) => Number(k.slice(prefix.length)));
    const epoch = opts.epoch ?? (epochs.length ? Math.max(...epochs) : -1);
    const raw = this.foreign.get(`${prefix}${epoch}`);
    if (!raw) throw new KernelError('NO_KEY', `no key for ${owner}/${category}`);
    return { key: await aesKey(raw), epoch };
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
    void this.persist().then(() => this.startReplica());
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
    rotateInBundle(b, category);
    await this.saveAndPublishBundle(b);
    return currentEpoch(b, category);
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

  /** Signed grants of the circle (spec §6), read from `grant` envelopes this member can open. */
  private async grants(): Promise<Grant[]> {
    const out: Grant[] = [];
    for (const env of await this.opts.store.listByCategory('grant')) {
      try {
        const g = (await this.open(env)) as Grant;
        if (g && g.v === 1 && typeof g.sig === 'string') out.push(g);
      } catch {
        /* unreadable */
      }
    }
    return out;
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
      if (!pub || !(await verifyEnvelope(env, pub))) throw new KernelError('INVALID', 'invalid-signature');
    } else {
      const res = await validateEnvelope(env, {
        state: await this.circle(),
        grants: await this.grants(),
        revoked: this.revoked,
        signPubOf: (id) => this.signPubOf(id),
        now: this.now(),
      });
      if (!res.ok) throw new KernelError('INVALID', res.reason);
    }
    await this.opts.store.put(env);
    this.hlc.receive(env.hlc);
    this.envSubs.forEach((cb) => cb(env));
    return true;
  }

  async publish(env: Envelope) {
    this.guardRead();
    await this.accept(env);
    await this.replica?.add(env);
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

  onEnvelope(cb: (env: Envelope) => void) {
    this.envSubs.add(cb);
    return () => this.envSubs.delete(cb);
  }

  onLock(cb: () => void) {
    this.lockSubs.add(cb);
    return () => this.lockSubs.delete(cb);
  }

  /** For revocation (spec §6): grants with these ids no longer authorize writes. */
  async revokeGrant(grantId: string) {
    this.revoked.add(grantId);
    await this.persist();
  }

  get isLoaded() {
    return this.loaded;
  }
}
