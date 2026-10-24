import { describe, expect, it, vi } from 'vitest';
import type { InviteConnection, InviteHello, InviteTransport } from '../../family/inviteChannel';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createFamilyCircleService } from './family';


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

async function setup() {
  const net = new FakeNetwork();
  const transport = new MemTransport();
  const kernels: FakeKernel[] = [];
  for (let i = 0; i < 2; i++) kernels.push(await FakeKernel.create({ network: net }));
  FakeKernel.introduce(...kernels);
  const svcs = kernels.map((k, i) => createFamilyCircleService(k, { transport, displayName: () => (i === 0 ? 'Ana' : 'Rosa') }));
  return { kernels, svcs, transport };
}

describe('family handover', () => {
  it('ignores handover with forged signature', async () => {
    const { svcs, transport } = await setup();
    const ana = svcs[0]!;
    const rosa = svcs[1]!;

    const originalJoin = transport.join.bind(transport);
    vi.spyOn(transport, 'join').mockImplementation(async (roomId) => {
      const conn = await originalJoin(roomId);
      const originalSend = conn.send.bind(conn);

      conn.send = async (msg) => {
         if (msg.displayName) {
             try {
                 const payload = JSON.parse(msg.displayName);
                 if (payload.circleId && payload.keys && payload.sig) {
                     // Corrupt the signature to forge it
                     payload.sig = 'forged_signature';
                     msg.displayName = JSON.stringify(payload);
                 }
             } catch(e) {}
         }
         return originalSend(msg);
      };
      return conn;
    });

    await ana.createCircle('Casa');
    const { url } = await ana.createInvite();
    const { sas } = await rosa.join(url, 'Rosa');

    const [p] = await ana.pendingJoins();
    expect(p!.sas).toBe(sas);

    await ana.approveJoin(p!.requestId, true);

    // Wait for the handover logic, since it's forged, it should not grant the key, so Rosa shouldn't get the circle
    await new Promise((resolve) => setTimeout(resolve, 100));
    expect(await rosa.circle()).toBeNull();
  });

  it('ignores handover carrying a circle key not wrapped to the joiner', async () => {
    const { kernels, svcs, transport } = await setup();
    const ana = svcs[0]!;
    const rosa = svcs[1]!;

    const originalJoin = transport.join.bind(transport);
    vi.spyOn(transport, 'join').mockImplementation(async (roomId) => {
      const conn = await originalJoin(roomId);
      const originalSend = conn.send.bind(conn);

      conn.send = async (msg) => {
         if (msg.displayName) {
             try {
                 const payload = JSON.parse(msg.displayName);
                 if (payload.circleId && payload.sig) {
                     // Change the destination to the wrong member
                     payload.to = kernels[0]!.memberId(); // Point back to Ana instead of Rosa

                     msg.displayName = JSON.stringify(payload);
                 }
             } catch(e) {}
         }
         return originalSend(msg);
      };
      return conn;
    });

    await ana.createCircle('Casa');
    const { url } = await ana.createInvite();
    const { sas } = await rosa.join(url, 'Rosa');

    const [p] = await ana.pendingJoins();
    expect(p!.sas).toBe(sas);

    await ana.approveJoin(p!.requestId, true);

    // Wait for the handover logic
    await new Promise((resolve) => setTimeout(resolve, 100));
    expect(await rosa.circle()).toBeNull();
  });
});
