import { describe, expect, it } from 'vitest';
import { b64u, canonical, randomBytes, sign, utf8 } from '../../crypto/index';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createFamilyCircleService } from './family';
import type { InviteConnection, InviteHello, InviteTransport } from '../../family/inviteChannel';

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

const ckAad = (circleId: string, to: string, epoch: number) => utf8(`orion/v1|${circleId}|circle-key|${to}|${epoch}`);
const CK_INFO = 'orion/v1/circle-key';

describe('Family key grants (rotation)', () => {
  it('a circle-key rotation published by a non-admin is ignored', async () => {
    const net = new FakeNetwork();
    const kernels: FakeKernel[] = [];
    for (let i = 0; i < 3; i++) kernels.push(await FakeKernel.create({ network: net }));
    FakeKernel.introduce(...kernels);
    const transport = new MemTransport();
    const svcs = kernels.map(k => createFamilyCircleService(k, { transport, displayName: () => 'A' }));

    // Setup circle: kernels[0] (Ana) is admin, kernels[1] (Rosa) is member, kernels[2] (Leo) is member.
    await svcs[0]!.createCircle('Casa');

    // Join Rosa
    const { url: urlRosa } = await svcs[0]!.createInvite();
    await svcs[1]!.join(urlRosa, 'Rosa');
    await new Promise(r => setTimeout(r, 10));
    const [pRosa] = await svcs[0]!.pendingJoins();
    await svcs[0]!.approveJoin(pRosa!.requestId, true);
    await new Promise(r => setTimeout(r, 10));

    // Join Leo
    const { url: urlLeo } = await svcs[0]!.createInvite();
    await svcs[2]!.join(urlLeo, 'Leo');
    await new Promise(r => setTimeout(r, 10));
    const [pLeo] = await svcs[0]!.pendingJoins();
    await svcs[0]!.approveJoin(pLeo!.requestId, true);
    await new Promise(r => setTimeout(r, 10));

    // Let Rosa (non-admin) try to rotate key for Leo
    const rosaBundle = kernels[1]!.bundle();
    const leoId = kernels[2]!.memberId();
    const leoBox = (await svcs[2]!.circle())!.members[leoId]!.boxPub;
    const circleId = (await svcs[1]!.circle())!.circleId;
    const epoch = 1;
    const ck = randomBytes(32);

    // Add fake circle key so wrapKeyFor works
    kernels[1]!.addCircleKey(epoch, ck);
    const w = await kernels[1]!.wrapKeyFor({ circleEpoch: epoch }, leoBox, CK_INFO, ckAad(circleId, leoId, epoch));
    const h = { circleId, to: leoId, epoch, ephPub: w.ephPub, wrapped: w.wrapped };
    const pt = { kind: 'circle-key', ...h, sig: await sign(rosaBundle.signPkcs8, canonical(h, ['sig'])) };

    const env = await kernels[1]!.seal({ category: 'grant', circle: circleId, plaintext: pt });
    await kernels[1]!.publish(env);

    await new Promise(r => setTimeout(r, 10));

    // Leo should not have the new key (epoch 1)
    await svcs[2]!.circle();
    const k2 = kernels[2] as unknown as { circleKeys: Map<number, unknown> };
    expect(k2.circleKeys.has(epoch)).toBe(false);
  });

  it('a rotation with a bad signature is ignored', async () => {
    const net = new FakeNetwork();
    const kernels: FakeKernel[] = [];
    for (let i = 0; i < 2; i++) kernels.push(await FakeKernel.create({ network: net }));
    FakeKernel.introduce(...kernels);
    const transport = new MemTransport();
    const svcs = kernels.map(k => createFamilyCircleService(k, { transport, displayName: () => 'A' }));

    // Setup circle: kernels[0] (Ana) is admin, kernels[1] (Rosa) is member.
    await svcs[0]!.createCircle('Casa');

    // Join Rosa
    const { url: urlRosa } = await svcs[0]!.createInvite();
    await svcs[1]!.join(urlRosa, 'Rosa');
    await new Promise(r => setTimeout(r, 10));
    const [pRosa] = await svcs[0]!.pendingJoins();
    await svcs[0]!.approveJoin(pRosa!.requestId, true);
    await new Promise(r => setTimeout(r, 10));

    // Admin tries to rotate key for Rosa but with forged signature
    const rosaId = kernels[1]!.memberId();
    const rosaBox = (await svcs[1]!.circle())!.members[rosaId]!.boxPub;
    const circleId = (await svcs[0]!.circle())!.circleId;
    const epoch = 1;
    const ck = randomBytes(32);

    // Add fake circle key so wrapKeyFor works
    kernels[0]!.addCircleKey(epoch, ck);
    const w = await kernels[0]!.wrapKeyFor({ circleEpoch: epoch }, rosaBox, CK_INFO, ckAad(circleId, rosaId, epoch));
    const h = { circleId, to: rosaId, epoch, ephPub: w.ephPub, wrapped: w.wrapped };
    const pt = { kind: 'circle-key', ...h, sig: b64u(randomBytes(64)) }; // bad signature

    const env = await kernels[0]!.seal({ category: 'grant', circle: circleId, plaintext: pt });
    await kernels[0]!.publish(env);

    await new Promise(r => setTimeout(r, 10));

    // Rosa should not have the new key
    await svcs[1]!.circle();
    const k1 = kernels[1] as unknown as { circleKeys: Map<number, unknown> };
    expect(k1.circleKeys.has(epoch)).toBe(false);
  });
});
