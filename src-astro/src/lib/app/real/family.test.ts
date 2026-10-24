import { describe, expect, it, vi } from 'vitest';
import type { InviteConnection, InviteHello, InviteTransport } from '../../family/inviteChannel';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createFamilyCircleService } from './family';

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

async function setup(n = 2) {
  const net = new FakeNetwork();
  const transport = new MemTransport();
  const kernels: FakeKernel[] = [];
  for (let i = 0; i < n; i++) kernels.push(await FakeKernel.create({ network: net }));
  FakeKernel.introduce(...kernels);
  const names = ['Ana', 'Rosa', 'Leo'];
  const svcs = kernels.map((k, i) => createFamilyCircleService(k, { transport, displayName: () => names[i]! }));
  return { kernels, svcs };
}

/** Admin invites, `joiner` joins, SAS compared, approved. Returns the joiner member id. */
async function admit(admin: ReturnType<typeof createFamilyCircleService>, joiner: ReturnType<typeof createFamilyCircleService>, name: string) {
  const { url } = await admin.createInvite();
  const { sas } = await joiner.join(url, name);
  await vi.waitFor(async () => expect((await admin.pendingJoins()).length).toBe(1));
  const [p] = await admin.pendingJoins();
  expect(p!.sas).toBe(sas);
  await admin.approveJoin(p!.requestId, true);
  // The key handover travels asynchronously through the transport.
  await vi.waitFor(async () => expect(await joiner.circle()).not.toBeNull());
  return sas;
}

describe('createFamilyCircleService', () => {
  it('creates a circle with me as admin and the circle name', async () => {
    const { kernels, svcs } = await setup(1);
    const state = await svcs[0]!.createCircle('Casa');
    expect(state.name).toBe('Casa');
    const me = state.members[kernels[0]!.memberId()]!;
    expect(me.role).toBe('admin');
    expect(me.displayName).toBe('Ana');
    expect((await svcs[0]!.circle())?.circleId).toBe(state.circleId);
  });

  it('invite -> join -> equal SAS -> approve gives the joiner the circle and CK0', async () => {
    const { kernels, svcs } = await setup();
    const [ana, rosa] = [svcs[0]!, svcs[1]!];
    const created = await ana.createCircle('Casa');
    const sas = await admit(ana, rosa, 'Rosa');
    expect(sas).toMatch(/^\d{3} \d{3}$/);

    const seen = await rosa.circle();
    expect(seen?.circleId).toBe(created.circleId);
    expect(seen?.name).toBe('Casa');
    expect(Object.values(seen!.members).map((m) => m.displayName).sort()).toEqual(['Ana', 'Rosa']);
    expect((await ana.circle())!.members[kernels[1]!.memberId()]!.role).toBe('member');

    const env = await kernels[0]!.seal({ category: 'circle', plaintext: { hello: 'rosa' } });
    await kernels[0]!.publish(env);
    expect(await kernels[1]!.open(env)).toEqual({ hello: 'rosa' });
  });

  it('approveJoin(id, false) adds nobody and forgets the request', async () => {
    const { svcs } = await setup();
    const [ana, rosa] = [svcs[0]!, svcs[1]!];
    await ana.createCircle('Casa');
    const { url } = await ana.createInvite();
    await rosa.join(url, 'Rosa');
    await vi.waitFor(async () => expect((await ana.pendingJoins()).length).toBe(1));
    const [p] = await ana.pendingJoins();
    await ana.approveJoin(p!.requestId, false);
    expect(await ana.pendingJoins()).toEqual([]);
    expect(Object.keys((await ana.circle())!.members)).toHaveLength(1);
    expect(await rosa.circle()).toBeNull();
  });

  it('removeMember rotates CK: the removed member cannot read the new epoch, a remaining one can', async () => {
    const { kernels, svcs } = await setup(3);
    const [ana, rosa, leo] = [svcs[0]!, svcs[1]!, svcs[2]!];
    await ana.createCircle('Casa');
    await admit(ana, rosa, 'Rosa');
    await admit(ana, leo, 'Leo');
    const before = (await kernels[0]!.circleKey()).epoch;

    await ana.removeMember(kernels[2]!.memberId());
    const after = (await kernels[0]!.circleKey()).epoch;
    expect(after).toBe(before + 1);

    const env = await kernels[0]!.seal({ category: 'circle', plaintext: { secret: 1 } });
    expect(env.epoch).toBe(after);
    await kernels[0]!.publish(env);
    await vi.waitFor(async () => expect(await kernels[1]!.open(env)).toEqual({ secret: 1 }));
    await expect(kernels[2]!.open(env)).rejects.toMatchObject({ code: 'NO_KEY' });

    const state = (await ana.circle())!;
    expect(state.epoch).toBe(after);
    expect(state.members[kernels[2]!.memberId()]!.removed).toBe(true);
    expect((await rosa.circle())!.members[kernels[2]!.memberId()]!.removed).toBe(true);
  });

  it('only an admin can remove', async () => {
    const { kernels, svcs } = await setup();
    await svcs[0]!.createCircle('Casa');
    await admit(svcs[0]!, svcs[1]!, 'Rosa');
    await expect(svcs[1]!.removeMember(kernels[0]!.memberId())).rejects.toThrow('NOT_ADMIN');
  });

  it('dependent and guardian relations show in circle()', async () => {
    const { kernels, svcs } = await setup();
    const [ana, rosa] = [svcs[0]!, svcs[1]!];
    await ana.createCircle('Casa');
    await admit(ana, rosa, 'Rosa');
    const kid = await ana.addDependent('Nico');
    expect(kid.dependent).toBe(true);
    expect(kid.devices).toEqual([]);

    let state = (await ana.circle())!;
    expect(state.members[kid.memberId]!.dependent).toBe(true);
    expect(state.members[kernels[0]!.memberId()]!.guardianOf).toContain(kid.memberId);

    await rosa.setGuardian(kernels[0]!.memberId());
    state = (await rosa.circle())!;
    expect(state.members[kernels[0]!.memberId()]!.guardianOf).toContain(kernels[1]!.memberId());
  });

  it('onChange fires on membership changes', async () => {
    const { svcs } = await setup(1);
    const cb = vi.fn();
    const off = svcs[0]!.onChange(cb);
    await svcs[0]!.createCircle('Casa');
    expect(cb).toHaveBeenCalled();
    off();
  });
});
