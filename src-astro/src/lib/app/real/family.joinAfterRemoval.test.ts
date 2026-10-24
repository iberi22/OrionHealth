import { describe, expect, it } from 'vitest';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createFamilyCircleService } from './family';
import type { InviteTransport, InviteHello, InviteConnection } from '../../family/inviteChannel';

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

async function setup(n: number) {
  const net = new FakeNetwork();
  const transport = new MemTransport();
  const kernels: FakeKernel[] = [];
  for (let i = 0; i < n; i++) kernels.push(await FakeKernel.create({ network: net }));
  FakeKernel.introduce(...kernels);
  const svcs = kernels.map((k, i) => createFamilyCircleService(k, { transport, displayName: () => `Member${i}` }));
  return { kernels, svcs, transport };
}

describe('family join after removal', () => {
  it('A creates, adds B, removes B, then adds D; D gets circle keys correctly', async () => {
    const { kernels, svcs } = await setup(3);
    const A = svcs[0]!;
    const B = svcs[1]!;
    const D = svcs[2]!;

    await A.createCircle('Family');

    // A adds B
    let inv = await A.createInvite();
    await B.join(inv.url, 'B');
    let p = (await A.pendingJoins())[0];
    await A.approveJoin(p!.requestId, true);

    await new Promise((resolve) => setTimeout(resolve, 50));
    let c = await B.circle();
    expect(c).not.toBeNull();

    // A removes B
    const memberB = Object.values(c!.members).find(m => m.displayName === 'B');
    await A.removeMember(memberB!.memberId);

    // wait for B's removal
    await new Promise((resolve) => setTimeout(resolve, 50));

    // A adds D
    inv = await A.createInvite();
    await D.join(inv.url, 'D');
    p = (await A.pendingJoins())[0];
    await A.approveJoin(p!.requestId, true);

    // wait for D to get keys
    await new Promise((resolve) => setTimeout(resolve, 50));

    c = await D.circle();
    expect(c).not.toBeNull();

    const members = Object.values(c!.members);
    const active = members.filter(m => !m.removed).map(m => m.displayName).sort();
    expect(active).toEqual(['D', 'Member0']);
  });
});
