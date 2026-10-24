import 'fake-indexeddb/auto';
import { describe, expect, it } from 'vitest';
import { b64u, randomBytes } from '../../crypto/index';
import type { VaultState } from '../../contracts/services';
import type { Envelope, MembershipEvent } from '../../contracts/types';
import { createMemberBundle, sealBundle, type MemberBundle } from '../../vault/keyring';
import { openEnvelopeStore } from '../../vault/store';
import { signEvent } from '../../family/membership';
import { createGrant } from '../../family/grants';
import { createKernel, type KernelSession } from './kernel.impl';
import { KernelError } from './kernel';
import { createGrantsService } from './grants';
import { circleOf, copyAll, memSession, newDevice } from './kernel.testkit';

let dbN = 0;

/** Minimal in-memory session: real bundle and MRS, toggleable lock. */
async function fakeSession() {
  const mrs = randomBytes(32);
  let bundle: MemberBundle | null = await createMemberBundle(mrs);
  const kept = bundle;
  let state: VaultState = 'unlocked';
  const subs = new Set<(s: VaultState) => void>();
  const meta = new Map<string, string>();
  const session: KernelSession & { lock(): void; unlock(): void } = {
    state: () => state,
    onState: (cb) => (subs.add(cb), () => subs.delete(cb)),
    bundle: () => (state === 'unlocked' ? bundle : null),
    withMrs: async (fn) => fn(mrs.slice()),
    saveBundle: async (b) => sealBundle(mrs, b),
    putMeta: async (k, v) => void meta.set(k, v),
    getMeta: async (k) => meta.get(k),
    lock() {
      state = 'locked';
      bundle = null;
      subs.forEach((cb) => cb(state));
    },
    unlock() {
      state = 'unlocked';
      bundle = kept;
      subs.forEach((cb) => cb(state));
    },
  };
  return session;
}

async function kernelPair() {
  const session = await fakeSession();
  const store = await openEnvelopeStore(`kernel-test-${++dbN}`);
  const kernel = await createKernel({ session, store, deviceId: `dev-${dbN}`, connect: false });
  return { session, store, kernel };
}

describe('RealKernel', () => {
  it('seals, publishes and opens personal records', async () => {
    const { kernel } = await kernelPair();
    const env = await kernel.seal({ category: 'vitals', plaintext: { value: 120 } });
    expect(env.circle).toBe('local');
    await kernel.publish(env);
    const [stored] = await kernel.envelopes({ owner: kernel.memberId(), category: 'vitals' });
    expect(await kernel.open(stored!)).toEqual({ value: 120 });
  });

  it('keeps envelopes immutable by id and rejects forged signatures', async () => {
    const { kernel } = await kernelPair();
    const env = await kernel.seal({ category: 'vitals', plaintext: 1 });
    await kernel.publish(env);
    await kernel.publish(env);
    const other = await kernel.seal({ category: 'vitals', plaintext: 2 });
    await expect(kernel.publish({ ...other, id: env.id })).rejects.toMatchObject({ code: 'ID_CONFLICT' });
    const forged: Envelope = { ...(await kernel.seal({ category: 'vitals', plaintext: 3 })), sig: b64u(randomBytes(64)) };
    await expect(kernel.publish(forged)).rejects.toMatchObject({ code: 'INVALID' });
  });

  it('after lock nothing is reachable, and received keys come back after unlock', async () => {
    const { session, kernel } = await kernelPair();
    const raw = randomBytes(32);
    kernel.addForeignKey('rosa', 'vitals', 1, raw);
    kernel.addCircleKey(0, randomBytes(32));
    await new Promise((r) => setTimeout(r, 10));
    let locked = false;
    kernel.onLock(() => (locked = true));
    session.lock();
    expect(locked).toBe(true);
    expect(() => kernel.memberId()).toThrow(KernelError);
    await expect(kernel.categoryKey('vitals')).rejects.toMatchObject({ code: 'LOCKED' });
    await expect(kernel.circleKey()).rejects.toMatchObject({ code: 'LOCKED' });
    session.unlock();
    await new Promise((r) => setTimeout(r, 20));
    await expect(kernel.categoryKey('vitals', { owner: 'rosa' })).resolves.toMatchObject({ epoch: 1 });
    await expect(kernel.circleKey()).resolves.toMatchObject({ epoch: 0 });
  });

  it('reduces the circle from membership envelopes with the pinned genesis only', async () => {
    const { kernel } = await kernelPair();
    const me = kernel.bundle();
    kernel.addCircleKey(0, randomBytes(32));
    await kernel.setCircle('c1', { memberId: me.memberId, signPub: me.signPub });
    const create = await signEvent(
      { v: 1, id: 'ev1', circle: 'c1', kind: 'create', actor: me.memberId, signPub: me.signPub, boxPub: me.boxPub, displayName: 'Ana', deviceId: 'd1', hlc: '0000000000001-0000-d1' },
      me.signPkcs8,
    );
    await kernel.publish(await kernel.seal({ category: 'membership', plaintext: create }));
    const rosa = await createMemberBundle();
    const approve = await signEvent(
      { v: 1, id: 'ev2', circle: 'c1', kind: 'approve', actor: me.memberId, subject: rosa.memberId, signPub: rosa.signPub, boxPub: rosa.boxPub, displayName: 'Rosa', deviceId: 'd2', hlc: '0000000000002-0000-d1' },
      me.signPkcs8,
    );
    await kernel.publish(await kernel.seal({ category: 'membership', plaintext: approve }));
    // A forged genesis by another key with an earlier hlc must not take the circle.
    const intruder = await createMemberBundle();
    const fake: MembershipEvent = await signEvent(
      { v: 1, id: 'ev0', circle: 'c1', kind: 'create', actor: intruder.memberId, signPub: intruder.signPub, boxPub: intruder.boxPub, displayName: 'X', deviceId: 'dx', hlc: '0000000000000-0000-dx' },
      intruder.signPkcs8,
    );
    await kernel.publish(await kernel.seal({ category: 'membership', plaintext: fake }));
    const state = await kernel.circle();
    expect(Object.keys(state!.members).sort()).toEqual([me.memberId, rosa.memberId].sort());
    expect(state!.members[me.memberId]!.role).toBe('admin');
    expect(await kernel.signPubOf(rosa.memberId)).toBe(rosa.signPub);
  });

  it('accepts a write on behalf of another member only with a signed write grant', async () => {
    const { kernel: ana } = await kernelPair();
    const { kernel: rosaK } = await kernelPair();
    const a = ana.bundle();
    const r = rosaK.bundle();
    const ck = randomBytes(32);
    for (const k of [ana, rosaK]) {
      k.addCircleKey(0, ck);
      await k.setCircle('c1', { memberId: a.memberId, signPub: a.signPub });
    }
    const events = [
      await signEvent({ v: 1, id: 'm1', circle: 'c1', kind: 'create', actor: a.memberId, signPub: a.signPub, boxPub: a.boxPub, displayName: 'Ana', deviceId: 'd1', hlc: '0000000000001-0000-d1' }, a.signPkcs8),
      await signEvent({ v: 1, id: 'm2', circle: 'c1', kind: 'approve', actor: a.memberId, subject: r.memberId, signPub: r.signPub, boxPub: r.boxPub, displayName: 'Rosa', deviceId: 'd2', hlc: '0000000000002-0000-d1' }, a.signPkcs8),
    ];
    for (const ev of events) {
      const env = await ana.seal({ category: 'membership', plaintext: ev });
      await ana.publish(env);
      await rosaK.publish(env);
    }
    // Rosa writes a vital into Ana's vitals with Ana's CEK, without a grant: rejected by Ana.
    const w = await ana.wrapKeyFor({ category: 'vitals' }, r.boxPub, 'orion/v1/grant', new Uint8Array(0));
    rosaK.addForeignKey(a.memberId, 'vitals', w.epoch, await rosaK.unwrapForMe(w.ephPub, w.wrapped, 'orion/v1/grant', new Uint8Array(0)));
    const write = await rosaK.seal({ category: 'vitals', owner: a.memberId, plaintext: { value: 170 } });
    await expect(ana.publish(write)).rejects.toMatchObject({ code: 'INVALID' });
    // With a signed write grant from Ana, the same kind of write is accepted.
    const grant = await createGrant({
      circle: 'c1', from: a.memberId, to: r.memberId, category: 'vitals', epoch: w.epoch, access: 'write',
      cek: randomBytes(32), granteeBoxSpki: r.boxPub, ownerSignPkcs8: a.signPkcs8,
    });
    await ana.publish(await ana.seal({ category: 'grant', plaintext: grant }));
    const write2 = await rosaK.seal({ category: 'vitals', owner: a.memberId, plaintext: { value: 171 } });
    await expect(ana.publish(write2)).resolves.toBeUndefined();
    expect(await ana.open(write2)).toEqual({ value: 171 });
  });
});

describe('RealKernel revocation (spec §5, §6)', () => {
  // Judge repro K1: the revoke markers replicated by grants.ts must bind every device, not only the owner's.
  it('a third member rejects a write made with a revoked write grant', async () => {
    const [ana, rosa, carlos] = [await newDevice(), await newDevice(), await newDevice()];
    await circleOf([ana, rosa, carlos]);
    const a = ana.kernel.bundle(), r = rosa.kernel.bundle(), c = carlos.kernel.bundle();
    const gA = createGrantsService(ana.kernel), gR = createGrantsService(rosa.kernel), gC = createGrantsService(carlos.kernel);
    await gA.grant(r.memberId, 'custom', { categories: ['vitals'], access: 'write' });
    await gA.grant(c.memberId, 'custom', { categories: ['vitals'], access: 'read' });
    await copyAll(ana.kernel, [rosa.kernel, carlos.kernel]);
    await gR.syncReceivedKeys();
    await gC.syncReceivedKeys();

    // Before the revocation Rosa's write is valid everywhere.
    const before = await rosa.kernel.seal({ category: 'vitals', owner: a.memberId, plaintext: { value: 1 } });
    await expect(carlos.kernel.publish(before)).resolves.toBeUndefined();

    const rosaGrant = (await gA.grantsGiven()).find((g) => g.to === r.memberId)!;
    await gA.revoke(rosaGrant.id);
    await ana.kernel.revokeGrant(rosaGrant.id); // what real.ts does on the owner device only
    await copyAll(ana.kernel, [rosa.kernel, carlos.kernel]);
    expect((await gC.grantsReceived()).length).toBeGreaterThan(0);

    // Rosa keeps the old epoch key and signs another write with it.
    const forged = await rosa.kernel.seal({ category: 'vitals', owner: a.memberId, plaintext: { value: 999 } });
    expect(forged.epoch).toBe(before.epoch);
    await expect(carlos.kernel.publish(forged)).rejects.toMatchObject({ code: 'INVALID', message: 'unauthorized-write' });
    await expect(ana.kernel.publish(forged)).rejects.toMatchObject({ code: 'INVALID' });
    expect(await carlos.kernel.envelopes({ owner: a.memberId, category: 'vitals' })).toHaveLength(1);
  });

  it('a revoke marker by anyone other than the grant owner revokes nothing', async () => {
    const [ana, rosa, carlos] = [await newDevice(), await newDevice(), await newDevice()];
    await circleOf([ana, rosa, carlos]);
    const a = ana.kernel.bundle(), r = rosa.kernel.bundle();
    const gA = createGrantsService(ana.kernel), gR = createGrantsService(rosa.kernel);
    await gA.grant(r.memberId, 'custom', { categories: ['vitals'], access: 'write' });
    await copyAll(ana.kernel, [rosa.kernel, carlos.kernel]);
    await gR.syncReceivedKeys();
    const [g] = await gA.grantsGiven();
    // Carlos (a member, not the owner) publishes a marker for Ana's grant.
    const marker = await carlos.kernel.seal({ category: 'grant', plaintext: { kind: 'revoke', grantId: g!.id } });
    await carlos.kernel.publish(marker);
    const write = await rosa.kernel.seal({ category: 'vitals', owner: a.memberId, plaintext: { value: 2 } });
    await expect(carlos.kernel.publish(write)).resolves.toBeUndefined();
  });
});

describe('RealKernel keystore', () => {
  it('keeps the circle after a restart when addCircleKey and setCircle persist back to back', async () => {
    const mrs = randomBytes(32);
    const base = memSession(await createMemberBundle(mrs), mrs);
    // The first keystore write (from addCircleKey, without the circle yet) lands last.
    let writes = 0;
    const session: KernelSession = {
      ...base,
      putMeta: async (k, v) => {
        const delay = ++writes === 1 ? 30 : 0;
        await new Promise((r) => setTimeout(r, delay));
        await base.putMeta(k, v);
      },
    };
    const store = await openEnvelopeStore(`kernel-test-${++dbN}`);
    const k1 = await createKernel({ session, store, deviceId: 'dk', connect: false });
    k1.addCircleKey(0, randomBytes(32));
    await k1.setCircle('c1', { memberId: k1.memberId(), signPub: k1.bundle().signPub });
    await new Promise((r) => setTimeout(r, 60));
    const k2 = await createKernel({ session: base, store, deviceId: 'dk', connect: false });
    await expect(k2.circleKey()).resolves.toMatchObject({ epoch: 0 });
    expect(await k2.signPubOf(k1.memberId())).toBe(k1.bundle().signPub);
    expect((await k2.seal({ category: 'circle', plaintext: 1 })).circle).toBe('c1');
  });
});


describe('Deterministic CEK and max epoch tests', () => {
  it('creates a vault, writes, recovers on stale bundle, writes, both records readable and epoch is greater', async () => {
    const { session: s1, kernel: k1 } = await newDevice({ connect: true });

    // Write "Gripe"
    const write1 = await k1.seal({ category: 'conditions', plaintext: { kind: 'condition', name: 'Gripe' } });
    await k1.publish(write1);

    const epoch1 = write1.epoch;

    const b1 = s1.bundle();
    const mrs = await s1.withMrs(m => m.slice());

    // Recover on a fresh session with STALE bundle (without epoch1)
    // Pretend the onboarding file had an empty bundle for this category
    const staleBundle = JSON.parse(JSON.stringify(b1)); staleBundle.ceks.conditions = {};

    const s2 = memSession(staleBundle, mrs);
    // Pretend the store has the record
    const store2 = await openEnvelopeStore('kernel-test-recover-' + ++dbN);
    await store2.put(write1);

    const k2 = await createKernel({ session: s2, store: store2, deviceId: 'd2', connect: false });

    // Write "Nueva"
    const write2 = await k2.seal({ category: 'conditions', plaintext: { kind: 'condition', name: 'Nueva' } });
    await k2.publish(write2);

    const epoch2 = write2.epoch;

    expect(epoch2).toBeGreaterThan(epoch1);

    // Both readable
    expect((await k2.open(write1)) as any).toMatchObject({ name: 'Gripe' });
    expect((await k2.open(write2)) as any).toMatchObject({ name: 'Nueva' });
  });
});
