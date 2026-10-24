// In-memory Kernel for service tests. Real crypto (seal/sign/open), no IndexedDB, no network.
// Several fakes can share one FakeNetwork to simulate circle peers.

import { aesKey, b64u, fromB64u, randomBytes } from '../../crypto/index';
import type { CircleState, Category, Envelope, PersonalCategory } from '../../contracts/types';
import { createMemberBundle, cekFor, currentEpoch, rotateCategory, type MemberBundle } from '../../vault/keyring';
import { openEnvelope, sealEnvelope, verifyEnvelope } from '../../family/envelope';
import { CIRCLE_KEYED, KernelError, type Kernel, type SealRequest } from './kernel';

export class FakeNetwork {
  private peers = new Set<FakeKernel>();
  join(k: FakeKernel) {
    this.peers.add(k);
  }
  /** Resolves once every peer has processed the envelope, so tests are deterministic. */
  async broadcast(from: FakeKernel, env: Envelope) {
    await Promise.all([...this.peers].filter((p) => p !== from).map((p) => p.receive(env)));
  }
}

export class FakeKernel implements Kernel {
  private locked = false;
  private store = new Map<string, Envelope>();
  private foreign = new Map<string, Uint8Array>();
  private circleKeys = new Map<number, Uint8Array>();
  private envSubs = new Set<(e: Envelope) => void>();
  private lockSubs = new Set<() => void>();
  private counter = 0;
  circleState: CircleState | null = null;
  /** Public keys of other members known to this fake (memberId → {sign, box}). */
  directory = new Map<string, { signPub: string; boxPub: string }>();

  private constructor(
    private b: MemberBundle,
    private device: string,
    private net?: FakeNetwork,
  ) {
    net?.join(this);
  }

  static async create(opts: { network?: FakeNetwork; deviceId?: string } = {}): Promise<FakeKernel> {
    const bundle = await createMemberBundle();
    const k = new FakeKernel(bundle, opts.deviceId ?? `dev-${bundle.memberId.slice(0, 6)}`, opts.network);
    k.directory.set(bundle.memberId, { signPub: bundle.signPub, boxPub: bundle.boxPub });
    return k;
  }

  /** Test helper: make two fakes know each other's public keys. */
  static introduce(...ks: FakeKernel[]) {
    for (const a of ks) for (const b of ks) a.directory.set(b.b.memberId, { signPub: b.b.signPub, boxPub: b.b.boxPub });
  }

  lock() {
    this.locked = true;
    this.foreign.clear();
    this.circleKeys.clear();
    this.lockSubs.forEach((cb) => cb());
  }

  private guard() {
    if (this.locked) throw new KernelError('LOCKED', 'vault is locked');
  }

  memberId() {
    this.guard();
    return this.b.memberId;
  }
  deviceId() {
    this.guard();
    return this.device;
  }
  bundle() {
    this.guard();
    return this.b;
  }

  async categoryKey(category: PersonalCategory, opts: { owner?: string; epoch?: number } = {}) {
    this.guard();
    const owner = opts.owner ?? this.b.memberId;
    if (owner === this.b.memberId) {
      if (!this.b.ceks[category]) rotateCategory(this.b, category);
      const epoch = opts.epoch ?? currentEpoch(this.b, category);
      return { key: await aesKey(fromB64u(cekFor(this.b, category, epoch))), epoch };
    }
    const epochs = [...this.foreign.keys()].filter((k) => k.startsWith(`${owner}|${category}|`)).map((k) => Number(k.split('|')[2]));
    const epoch = opts.epoch ?? (epochs.length ? Math.max(...epochs) : -1);
    const raw = this.foreign.get(`${owner}|${category}|${epoch}`);
    if (!raw) throw new KernelError('NO_KEY', `no key for ${owner}/${category}`);
    return { key: await aesKey(raw), epoch };
  }

  async circleKey(epoch?: number) {
    this.guard();
    if (!this.circleKeys.size) throw new KernelError('NO_CIRCLE', 'no circle');
    const e = epoch ?? Math.max(...this.circleKeys.keys());
    const raw = this.circleKeys.get(e);
    if (!raw) throw new KernelError('NO_KEY', `no circle key epoch ${e}`);
    return { key: await aesKey(raw), epoch: e };
  }

  addForeignKey(owner: string, category: PersonalCategory, epoch: number, raw: Uint8Array) {
    this.guard();
    this.foreign.set(`${owner}|${category}|${epoch}`, raw);
  }

  addCircleKey(epoch: number, raw: Uint8Array) {
    this.guard();
    this.circleKeys.set(epoch, raw);
  }

  async circle() {
    return this.circleState;
  }
  async signPubOf(memberId: string) {
    return this.directory.get(memberId)?.signPub ?? null;
  }
  async boxPubOf(memberId: string) {
    return this.directory.get(memberId)?.boxPub ?? null;
  }

  private keyFor(category: Category, owner: string, epoch?: number) {
    return CIRCLE_KEYED.includes(category) ? this.circleKey(epoch) : this.categoryKey(category as PersonalCategory, { owner, epoch });
  }

  async seal(req: SealRequest): Promise<Envelope> {
    this.guard();
    const owner = req.owner ?? this.b.memberId;
    const { key, epoch } = await this.keyFor(req.category, owner);
    this.counter += 1;
    return sealEnvelope({
      id: b64u(randomBytes(16)),
      circle: req.circle ?? this.circleState?.circleId ?? 'local',
      owner,
      author: this.b.memberId,
      device: this.device,
      category: req.category,
      epoch,
      hlc: `${String(Date.now()).padStart(13, '0')}-${String(this.counter).padStart(4, '0')}-${this.device}`,
      plaintext: req.plaintext,
      categoryKey: key,
      authorSignPkcs8: this.b.signPkcs8,
    });
  }

  async open(env: Envelope) {
    this.guard();
    const { key } = await this.keyFor(env.category, env.owner, env.epoch);
    return openEnvelope(env, key);
  }

  private async accept(env: Envelope): Promise<boolean> {
    const existing = this.store.get(env.id);
    if (existing) {
      if (existing.sig === env.sig) return false;
      throw new KernelError('ID_CONFLICT', `envelope ${env.id} already stored with other content`);
    }
    const pub = await this.signPubOf(env.author);
    if (!pub || !(await verifyEnvelope(env, pub))) throw new KernelError('INVALID', `bad signature on ${env.id}`);
    this.store.set(env.id, env);
    this.envSubs.forEach((cb) => cb(env));
    return true;
  }

  async publish(env: Envelope) {
    this.guard();
    if (await this.accept(env)) await this.net?.broadcast(this, env);
  }

  /** Called by FakeNetwork for envelopes of other peers; invalid ones are dropped silently. */
  async receive(env: Envelope) {
    try {
      await this.accept(env);
    } catch {
      /* rejected */
    }
  }

  async envelopes(filter: { owner?: string; category?: Category } = {}) {
    return [...this.store.values()].filter((e) => (!filter.owner || e.owner === filter.owner) && (!filter.category || e.category === filter.category));
  }

  onEnvelope(cb: (env: Envelope) => void) {
    this.envSubs.add(cb);
    return () => this.envSubs.delete(cb);
  }

  onLock(cb: () => void) {
    this.lockSubs.add(cb);
    return () => this.lockSubs.delete(cb);
  }
}
