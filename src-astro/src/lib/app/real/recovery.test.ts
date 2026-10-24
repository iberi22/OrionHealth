// Recovery over the REAL kernel (validation, guest mode) and, for the new device, the REAL vault session on an
// empty IndexedDB. Spec §9.
import 'fake-indexeddb/auto';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import type { Envelope, MembershipEvent } from '../../contracts/types';
import type { VaultState } from '../../contracts/services';
import { b64u, canonical, generateBoxPair, generateSigningPair, memberIdFromSpki, randomBytes, sign, unwrapFrom, utf8 } from '../../crypto/index';
import type { InviteConnection, InviteHello, InviteTransport } from '../../family/inviteChannel';
import { signEvent } from '../../family/membership';
import { RecoveryError, combineShares, rewrapForRequest as rewrap } from '../../family/recovery';
import { createMemberBundle, sealBundle, type MemberBundle } from '../../vault/keyring';
import { formatCode, newRecoveryCode } from '../../vault/recoveryCode';
import { createVaultSession } from '../../vault/session';
import { openEnvelopeStore } from '../../vault/store';
import { createKernel, type KernelSession, type RealKernel } from './kernel.impl';
import { createRecoveryService, type RecoveryServiceWithCode, type RecoverySession } from './recovery';

/** In-memory rooms shared by every endpoint; late listeners get the messages sent before. */
class MemTransport implements InviteTransport {
  private rooms = new Map<string, { listeners: Map<number, (m: InviteHello) => void>; log: { from: number; msg: InviteHello }[] }>();
  private ids = 0;
  async join(roomId: string): Promise<InviteConnection> {
    let room = this.rooms.get(roomId);
    if (!room) {
      room = { listeners: new Map(), log: [] };
      this.rooms.set(roomId, room);
    }
    const r = room;
    const me = ++this.ids;
    return {
      send: async (msg) => {
        r.log.push({ from: me, msg });
        for (const [id, cb] of r.listeners) if (id !== me) queueMicrotask(() => cb(msg));
      },
      onMessage: (cb) => {
        r.listeners.set(me, cb);
        for (const { from, msg } of r.log) if (from !== me) queueMicrotask(() => cb(msg));
        return () => r.listeners.delete(me);
      },
      close: () => {
        r.listeners.delete(me);
      },
    };
  }
}

let n = 0;
const passkey = { getPrfOutput: async () => new Uint8Array(32).fill(9) };

interface Peer {
  name: string;
  k: RealKernel;
  b: MemberBundle;
  mrs: Uint8Array;
  rec: RecoveryServiceWithCode;
  session: RecoverySession;
  reauth: ReturnType<typeof vi.fn<() => Promise<void>>>;
}

/** A member device that is already unlocked (fake session, real kernel). */
async function peer(transport: InviteTransport, name: string): Promise<Peer> {
  const mrs = randomBytes(32);
  const b = await createMemberBundle(mrs);
  const meta = new Map<string, string>();
  let blob: string | undefined;
  const ks: KernelSession = {
    state: () => 'unlocked' as VaultState,
    onState: () => () => {},
    bundle: () => b,
    withMrs: async (fn) => fn(mrs.slice()),
    saveBundle: async (x) => sealBundle(mrs, x),
    putMeta: async (key, v) => void meta.set(key, v),
    getMeta: async (key) => meta.get(key),
  };
  const k = await createKernel({ session: ks, store: await openEnvelopeStore(`rec-${++n}`), deviceId: `d-${name}`, connect: false });
  const reauth = vi.fn(async () => {});
  const rs: RecoverySession = {
    withMrs: ks.withMrs,
    importMrs: async () => {
      throw new Error('not a new device');
    },
    memberId: () => b.memberId,
    displayName: () => name,
    reauth,
    storedMemberId: async () => b.memberId,
    recoveryBlob: async () => blob,
    putRecoveryBlob: async (x) => {
      blob = x;
    },
    sealedBundle: async () => sealBundle(mrs, b),
  };
  return { name, k, b, mrs, reauth, session: rs, rec: createRecoveryService(k, rs, { transport, origin: 'https://test.local' }) };
}

/** A brand-new device: real vault session over an EMPTY IndexedDB, real kernel, no circle. */
async function newDevice(transport: InviteTransport) {
  const session = createVaultSession({ passkey, dbName: `newdev-${++n}` });
  await session.ready();
  const k = await createKernel({ session, store: await openEnvelopeStore(`newdev-store-${n}`), deviceId: `new-${n}`, connect: false });
  return { session, k, rec: createRecoveryService(k, session, { transport, origin: 'https://test.local' }) };
}

/** peers[0] creates circle "c1" (admin, genesis) and approves the others. */
async function formCircle(peers: Peer[]) {
  const ck = randomBytes(32);
  const A = peers[0]!.b;
  for (const p of peers) {
    p.k.addCircleKey(0, ck);
    await p.k.setCircle('c1', { memberId: A.memberId, signPub: A.signPub });
  }
  const hlc = (i: number) => `${String(1_000 + i).padStart(13, '0')}-0000-d1`;
  const evs: MembershipEvent[] = [
    await signEvent({ v: 1, id: 'm0', circle: 'c1', kind: 'create', actor: A.memberId, signPub: A.signPub, boxPub: A.boxPub, displayName: peers[0]!.name, deviceId: `d-${peers[0]!.name}`, hlc: hlc(0) }, A.signPkcs8),
  ];
  for (let i = 1; i < peers.length; i++) {
    const B = peers[i]!.b;
    evs.push(await signEvent({ v: 1, id: `m${i}`, circle: 'c1', kind: 'approve', actor: A.memberId, subject: B.memberId, signPub: B.signPub, boxPub: B.boxPub, displayName: peers[i]!.name, deviceId: `d-${peers[i]!.name}`, hlc: hlc(i) }, A.signPkcs8));
  }
  for (const ev of evs) {
    const env = await peers[0]!.k.seal({ category: 'membership', plaintext: ev });
    for (const p of peers) await p.k.publish(env);
  }
}

/** Replicates every envelope between the kernels (what the mesh does), membership first. */
async function sync(ks: RealKernel[]) {
  const rank = (e: Envelope) => (e.category === 'membership' ? 0 : 1);
  for (let pass = 0; pass < 2; pass++) {
    for (const x of ks) {
      const envs = (await x.envelopes()).sort((a, b) => rank(a) - rank(b));
      for (const env of envs) for (const y of ks) if (y !== x) await y.publish(env).catch(() => undefined);
    }
  }
}

async function family() {
  const transport = new MemTransport();
  const names = ['Ana', 'Bea', 'Rosa', 'Bruno', 'Carla', 'Mallory'];
  const ps: Peer[] = [];
  for (const nm of names) ps.push(await peer(transport, nm));
  await formCircle(ps);
  const [ana, bea, rosa, bruno, carla, mallory] = ps as [Peer, Peer, Peer, Peer, Peer, Peer];
  const policy = { threshold: 2, trustees: [rosa.b.memberId, bruno.b.memberId, carla.b.memberId] };
  return { transport, ps, ana, bea, rosa, bruno, carla, mallory, policy, kernels: ps.map((p) => p.k) };
}

/** Admin `ana` invites a new device for `member`, both compare the SAS, ana vouches. */
async function inviteNewDevice(ana: Peer, member: string, dev: Awaited<ReturnType<typeof newDevice>>) {
  const { url } = await ana.rec.createRecoveryInvite(member);
  expect(url).toMatch(/^https:\/\/test\.local\/app\/recovery#/);
  const { sas } = await dev.rec.startRecovery(url);
  expect(dev.rec.progress().step).toBe('awaiting-invite');
  await vi.waitFor(async () => expect(await ana.rec.pendingRecoveryJoins()).toHaveLength(1));
  const [join] = await ana.rec.pendingRecoveryJoins();
  expect(join!.sas).toBe(sas);
  expect(join!.member.memberId).toBe(member);
  await ana.rec.approveRecoveryJoin(join!.requestId, true);
  await vi.waitFor(() => expect(dev.rec.progress().step).toBe('awaiting-approvals'));
  return sas;
}

beforeAll(() => {
  (globalThis as { PublicKeyCredential?: unknown }).PublicKeyCredential ??= {};
});
afterAll(() => {
  delete (globalThis as { PublicKeyCredential?: unknown }).PublicKeyCredential;
});

describe('RecoveryService (spec §9)', () => {
  it('round-trips the policy, rejects threshold 1 of 3, and ignores a policy published by someone else', async () => {
    const { bea, mallory, policy, kernels } = await family();
    expect(await bea.rec.policy()).toBeNull();
    await expect(bea.rec.setPolicy({ ...policy, threshold: 1 })).rejects.toBeInstanceOf(RecoveryError);
    await bea.rec.setPolicy(policy);
    // Mallory publishes a newer "policy" for Bea naming herself
    await mallory.k.publish(
      await mallory.k.seal({ category: 'recovery', plaintext: { kind: 'policy', member: bea.b.memberId, policy: { threshold: 2, trustees: [mallory.b.memberId, mallory.b.memberId] } } }),
    );
    await sync(kernels);
    expect(await bea.rec.policy()).toEqual(policy);
  });

  it('a brand-new EMPTY device recovers with 2 of 3 trustees: same memberId, old records readable', async () => {
    const { transport, ana, bea, rosa, bruno, kernels, policy } = await family();
    const record = await bea.k.seal({ category: 'vitals', plaintext: { recordId: 'v1', value: 'BP 120/80' } });
    await bea.k.publish(record);
    await bea.rec.setPolicy(policy);
    await sync(kernels);

    const dev = await newDevice(transport);
    expect(dev.session.state()).toBe('empty');
    const sas = await inviteNewDevice(ana, bea.b.memberId, dev);
    // guest mode: the device reads/relays the circle but has no identity to seal with
    await expect(dev.k.seal({ category: 'recovery', plaintext: {} })).rejects.toThrow(/locked/);
    const all = [...kernels, dev.k];
    await sync(all);

    const pending = await rosa.rec.pendingRequests();
    expect(pending).toHaveLength(1);
    const p = pending[0]!;
    expect(p.member.memberId).toBe(bea.b.memberId);
    expect(p.vouchedBy.memberId).toBe(ana.b.memberId);
    expect(p.sas).toBe(sas);
    expect(p.requester.id).not.toBe(bea.b.memberId);
    expect(p.expiresAt).toBeGreaterThan(Date.now());

    await rosa.rec.approve(p.requestId, true);
    expect(rosa.reauth).toHaveBeenCalledTimes(1);
    expect(await rosa.rec.pendingRequests()).toHaveLength(0);
    await sync(all);
    await vi.waitFor(() => expect(dev.rec.progress()).toMatchObject({ step: 'awaiting-approvals', approvals: 1, threshold: 2 }));
    expect(dev.session.state()).toBe('empty'); // k-1 shares: nothing imported

    await bruno.rec.approve((await bruno.rec.pendingRequests())[0]!.requestId, true);
    await sync(all);
    await vi.waitFor(() => expect(dev.rec.progress().step).toBe('done'));

    expect(dev.session.state()).toBe('unlocked');
    expect(dev.session.memberId()).toBe(bea.b.memberId);
    expect(dev.k.memberId()).toBe(bea.b.memberId);
    expect(await dev.k.open(record)).toEqual({ recordId: 'v1', value: 'BP 120/80' });
    // left guest mode keeping the circle, and announced the new device / revoked the lost one
    const circle = await dev.k.circle();
    expect(circle?.members[bea.b.memberId]?.devices).toEqual([dev.k.deviceId()]);
  });

  it('requests not vouched by an admin are never approved and leak no share', async () => {
    const { bea, rosa, bruno, mallory, kernels, policy } = await family();
    await bea.rec.setPolicy(policy);
    await sync(kernels);
    const B = bea.b.memberId;

    // 1) the original attack: an ordinary member publishes a `request` for Bea with her own temp key
    const pair = await generateBoxPair();
    await mallory.k.publish(await mallory.k.seal({ category: 'recovery', plaintext: { kind: 'request', requestId: 'req-x', member: B, tempBoxPub: pair.publicSpki } }));
    // 2) same attack in the new format: Mallory "vouches" for her own temporary identity
    const sp = await generateSigningPair();
    const temp = { id: await memberIdFromSpki(sp.publicSpki), signPub: sp.publicSpki, boxPub: pair.publicSpki, deviceId: 'dev-m' };
    const req = { v: 1, kind: 'recovery-request', circle: 'c1', member: B, requestId: 'req-y', tempSignPub: temp.signPub, tempBoxPub: temp.boxPub, deviceId: temp.deviceId };
    await mallory.k.publish(
      await mallory.k.seal({
        category: 'recovery',
        plaintext: { kind: 'device-add-pending', requestId: 'req-y', member: B, temp, requestSig: await sign(sp.privatePkcs8, canonical(req)), sas: '123 456', expiresAt: Date.now() + 3_600_000 },
      }),
    );
    await sync(kernels);

    for (const t of [rosa, bruno]) {
      expect(await t.rec.pendingRequests()).toEqual([]);
      await expect(t.rec.approve('req-x', true)).rejects.toThrow(/UNBOUND/);
      await expect(t.rec.approve('req-y', true)).rejects.toThrow(/UNBOUND/);
      expect(t.reauth).not.toHaveBeenCalled();
    }
    await sync(kernels);

    const shares: Uint8Array[] = [];
    for (const env of await mallory.k.envelopes({ category: 'recovery' })) {
      const p = (await mallory.k.open(env).catch(() => null)) as { kind?: string; requestId?: string; ephPub?: string; wrapped?: string } | null;
      if (p?.kind !== 'approval') continue;
      for (const id of ['req-x', 'req-y']) {
        if (p.requestId !== id) continue;
        shares.push(await unwrapFrom(pair.privatePkcs8, p.ephPub!, p.wrapped!, 'orion/v1/recovery-share', utf8(`orion/v1/recovery-request|${B}|${id}|${pair.publicSpki}`)));
      }
    }
    expect(shares).toHaveLength(0);
    const stolen = shares.length >= 2 ? b64u(await combineShares(shares)) : null;
    expect(stolen).not.toBe(b64u(bea.mrs));
  });

  it('an admin cannot vouch for their own recovery, and a vouch whose temp keys were swapped is refused', async () => {
    const { ana, rosa, bruno, kernels } = await family();
    await ana.rec.setPolicy({ threshold: 2, trustees: [rosa.b.memberId, bruno.b.memberId] });
    const sp = await generateSigningPair();
    const box = await generateBoxPair();
    const temp = { id: await memberIdFromSpki(sp.publicSpki), signPub: sp.publicSpki, boxPub: box.publicSpki, deviceId: 'dev-t' };
    const vouch = async (requestId: string, member: string, t: typeof temp) => {
      const req = { v: 1, kind: 'recovery-request', circle: 'c1', member, requestId, tempSignPub: temp.signPub, tempBoxPub: temp.boxPub, deviceId: temp.deviceId };
      await ana.k.publish(
        await ana.k.seal({
          category: 'recovery',
          plaintext: { kind: 'device-add-pending', requestId, member, temp: t, requestSig: await sign(sp.privatePkcs8, canonical(req)), sas: '111 222', expiresAt: Date.now() + 3_600_000 },
        }),
      );
    };
    await vouch('self', ana.b.memberId, temp); // the admin vouches for herself
    await sync(kernels);
    expect(await rosa.rec.pendingRequests()).toEqual([]);
    await expect(rosa.rec.approve('self', true)).rejects.toThrow(/UNBOUND/);
  });

  it('a vouched request whose box key does not match the signed request is refused', async () => {
    const { ana, bea, rosa, kernels, policy } = await family();
    await bea.rec.setPolicy(policy);
    const sp = await generateSigningPair();
    const box = await generateBoxPair();
    const other = await generateBoxPair();
    const temp = { id: await memberIdFromSpki(sp.publicSpki), signPub: sp.publicSpki, boxPub: box.publicSpki, deviceId: 'dev-t' };
    const req = { v: 1, kind: 'recovery-request', circle: 'c1', member: bea.b.memberId, requestId: 'swap', tempSignPub: temp.signPub, tempBoxPub: temp.boxPub, deviceId: temp.deviceId };
    await ana.k.publish(
      await ana.k.seal({
        category: 'recovery',
        plaintext: { kind: 'device-add-pending', requestId: 'swap', member: bea.b.memberId, temp: { ...temp, boxPub: other.publicSpki }, requestSig: await sign(sp.privatePkcs8, canonical(req)), sas: '111 222', expiresAt: Date.now() + 3_600_000 },
      }),
    );
    await sync(kernels);
    expect(await rosa.rec.pendingRequests()).toEqual([]);
    await expect(rosa.rec.approve('swap', true)).rejects.toThrow(/UNBOUND/);
  });

  it('approvals from members outside the policy do not count toward the threshold', async () => {
    const { transport, ana, bea, rosa, mallory, kernels, policy } = await family();
    await bea.rec.setPolicy(policy);
    await sync(kernels);
    const dev = await newDevice(transport);
    await inviteNewDevice(ana, bea.b.memberId, dev);
    const all = [...kernels, dev.k];
    await sync(all);
    const [p] = await rosa.rec.pendingRequests();
    await rosa.rec.approve(p!.requestId, true);
    // Mallory (not a trustee of Bea) adds an "approval" with junk wrapped to the request's temp key
    let tempBoxPub = '';
    for (const env of await mallory.k.envelopes({ category: 'recovery' })) {
      const x = (await mallory.k.open(env)) as { kind?: string; requestId?: string; temp?: { boxPub: string } };
      if (x.kind === 'device-add-pending' && x.requestId === p!.requestId) tempBoxPub = x.temp!.boxPub;
    }
    const junk = await rewrap(randomBytes(33), tempBoxPub, bea.b.memberId, p!.requestId);
    await mallory.k.publish(
      await mallory.k.seal({ category: 'recovery', plaintext: { kind: 'approval', requestId: p!.requestId, member: bea.b.memberId, trusteeId: mallory.b.memberId, threshold: 2, ...junk } }),
    );
    await sync(all);
    await vi.waitFor(() => expect(dev.rec.progress()).toMatchObject({ step: 'awaiting-approvals', approvals: 1, threshold: 2 }));
    await new Promise((r) => setTimeout(r, 50));
    expect(dev.rec.progress().step).toBe('awaiting-approvals');
    expect(dev.session.state()).toBe('empty');
  });

  it('a share published by someone other than the member is ignored (no request, approve refuses)', async () => {
    const { transport, ana, rosa, mallory, carla, kernels } = await family();
    // Mallory fabricates a "share" of Carla addressed to Rosa; Carla never set a policy.
    const fake = await generateBoxPair();
    await mallory.k.publish(
      await mallory.k.seal({ category: 'recovery', plaintext: { kind: 'share', member: carla.b.memberId, trusteeId: rosa.b.memberId, threshold: 2, ephPub: fake.publicSpki, wrapped: 'x' } }),
    );
    const dev = await newDevice(transport);
    await inviteNewDevice(ana, carla.b.memberId, dev);
    await sync([...kernels, dev.k]);
    expect(await rosa.rec.pendingRequests()).toEqual([]);
    // the vouched request exists, but Rosa holds no share authored by Carla
    const vouched = [];
    for (const env of await rosa.k.envelopes({ category: 'recovery' })) {
      const p = (await rosa.k.open(env)) as { kind?: string; requestId?: string };
      if (p.kind === 'device-add-pending') vouched.push(p.requestId!);
    }
    expect(vouched).toHaveLength(1);
    await expect(rosa.rec.approve(vouched[0]!, true)).rejects.toThrow(/no recovery share/);
    expect(rosa.reauth).not.toHaveBeenCalled();
  });

  it('approval needs the passkey re-authentication; a declined SAS hides the request', async () => {
    const { transport, ana, bea, rosa, bruno, kernels, policy } = await family();
    await bea.rec.setPolicy(policy);
    await sync(kernels);
    const dev = await newDevice(transport);
    await inviteNewDevice(ana, bea.b.memberId, dev);
    await sync([...kernels, dev.k]);

    const [p] = await rosa.rec.pendingRequests();
    rosa.reauth.mockRejectedValueOnce(Object.assign(new Error('cancelled'), { code: 'CANCELLED' }));
    await expect(rosa.rec.approve(p!.requestId, true)).rejects.toThrow('cancelled');
    const approvals = async () => {
      const out = [];
      for (const env of await rosa.k.envelopes({ category: 'recovery' })) if (((await rosa.k.open(env)) as { kind?: string }).kind === 'approval') out.push(env);
      return out;
    };
    expect(await approvals()).toHaveLength(0);

    await bruno.rec.approve(p!.requestId, false);
    expect(bruno.reauth).not.toHaveBeenCalled();
    expect(await bruno.rec.pendingRequests()).toEqual([]);
    expect(await approvals()).toHaveLength(0);
  });

  it('recovery invitations are admin-only and never for oneself', async () => {
    const { ana, bea } = await family();
    await expect(bea.rec.createRecoveryInvite(ana.b.memberId)).rejects.toThrow('NOT_ADMIN');
    await expect(ana.rec.createRecoveryInvite(ana.b.memberId)).rejects.toThrow('INVALID_TARGET');
    await expect(ana.rec.createRecoveryInvite('nobody')).rejects.toThrow('INVALID_TARGET');
  });

  it('a family join link is not a recovery invitation', async () => {
    const { transport } = await family();
    const dev = await newDevice(transport);
    const join = `https://test.local/app/join#${b64u(utf8(JSON.stringify({ c: 'c1', s: b64u(randomBytes(32)), e: Date.now() + 60_000 })))}`;
    await expect(dev.rec.startRecovery(join)).rejects.toThrow(/INVITE_NOT_RECOVERY/);
    expect(dev.rec.progress().step).toBe('failed');
  });
});

describe('Recovery code (spec §9.1, decision D4)', () => {
  it('code + orion-recovery.json on an EMPTY device recovers the same member and keys', async () => {
    const transport = new MemTransport();
    const orig = createVaultSession({ passkey, dbName: `orig-${++n}` });
    await orig.ready();
    const { memberId, recoveryCode } = await orig.create('Bea');
    const k0 = await createKernel({ session: orig, store: await openEnvelopeStore(`orig-store-${n}`), deviceId: 'd0', connect: false });
    const file = await createRecoveryService(k0, orig, { transport }).recoveryFile();
    expect(file.filename).toBe('orion-recovery.json');
    const bundle = orig.bundle()!;
    for (const secret of [bundle.signPkcs8, bundle.boxPkcs8]) expect(file.content).not.toContain(secret);

    const dev = await newDevice(transport);
    expect(dev.session.state()).toBe('empty');
    await dev.rec.recoverWithCode(await formatCode(newRecoveryCode()), file.content);
    expect(dev.rec.progress().step).toBe('failed');
    expect(dev.session.state()).toBe('empty');

    await dev.rec.recoverWithCode(recoveryCode, file.content);
    expect(dev.rec.progress().step).toBe('done');
    expect(dev.session.state()).toBe('unlocked');
    expect(dev.session.memberId()).toBe(memberId);
    expect(dev.session.bundle()!.signPub).toBe(bundle.signPub);
    // the device can offer the file again
    expect(JSON.parse((await dev.rec.recoveryFile()).content).memberId).toBe(memberId);
  });

  it('code alone works on a new device that joined through a recovery invitation (blob in the replica)', async () => {
    const { transport, ana, bea, kernels } = await family();
    const code = await formatCode(newRecoveryCode());
    await bea.rec.publishCodeBlob(code);
    await sync(kernels);
    const dev = await newDevice(transport);
    await inviteNewDevice(ana, bea.b.memberId, dev);
    await sync([...kernels, dev.k]);
    await dev.rec.recoverWithCode(code);
    expect(dev.rec.progress().step).toBe('done');
    expect(dev.session.memberId()).toBe(bea.b.memberId);
  });

  it('a code blob published by another member is ignored', async () => {
    const { transport, ana, bea, mallory, kernels } = await family();
    const code = await formatCode(newRecoveryCode());
    // Mallory wraps HER OWN secret with a code she knows and labels it as Bea's
    const { wrapMrsWithCode } = await import('../../vault/recoveryCode');
    await mallory.k.publish(
      await mallory.k.seal({ category: 'recovery', plaintext: { kind: 'code-blob', member: bea.b.memberId, blob: await wrapMrsWithCode(code, randomBytes(32), bea.b.memberId) } }),
    );
    await sync(kernels);
    const dev = await newDevice(transport);
    await inviteNewDevice(ana, bea.b.memberId, dev);
    await sync([...kernels, dev.k]);
    await dev.rec.recoverWithCode(code);
    expect(dev.rec.progress()).toMatchObject({ step: 'failed', error: expect.stringMatching(/no recovery code blob/) });
    expect(dev.session.state()).toBe('empty');
  });

  it('publishes the stored code blob once the member is in a circle, only once', async () => {
    const { bea } = await family();
    expect(await bea.rec.ensureCodeBlobPublished()).toBe(false); // nothing stored yet
    const { wrapMrsWithCode } = await import('../../vault/recoveryCode');
    await bea.session.putRecoveryBlob(await wrapMrsWithCode(await formatCode(newRecoveryCode()), bea.mrs, bea.b.memberId));
    const [a, b] = await Promise.all([bea.rec.ensureCodeBlobPublished(), bea.rec.ensureCodeBlobPublished()]);
    expect([a, b]).toEqual([true, false]);
    const blobs = [];
    for (const env of await bea.k.envelopes({ category: 'recovery' })) if (((await bea.k.open(env)) as { kind?: string }).kind === 'code-blob') blobs.push(env);
    expect(blobs).toHaveLength(1);
  });
});

describe('Kernel guest mode (spec §9.3)', () => {
  it('unlocking keeps the circle of the invitation even when an older keystore has none', async () => {
    const session = createVaultSession({ passkey, dbName: `guest-${++n}` });
    await session.ready();
    await session.create('Bea');
    const k = await createKernel({ session, store: await openEnvelopeStore(`guest-store-${n}`), deviceId: 'g', connect: false });
    await k.revokeGrant('g-0'); // persists a keystore without any circle
    session.lock();
    const admin = await createMemberBundle();
    await k.enterGuest('c9', { memberId: admin.memberId, signPub: admin.signPub }, [{ epoch: 0, raw: randomBytes(32) }]);
    expect(await k.signPubOf(admin.memberId)).toBe(admin.signPub);
    await session.unlock();
    await k.load();
    expect(await k.signPubOf(admin.memberId)).toBe(admin.signPub);
    expect((await k.circleKey()).epoch).toBe(0);
  });
});
