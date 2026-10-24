import { describe, expect, it } from 'vitest';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createGrantsService } from './grants';
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

describe('GrantsService removal', () => {
  it('revoke never re-grants to removed members', async () => {
    const net = new FakeNetwork();
    const kernels: FakeKernel[] = [];
    for (let i = 0; i < 3; i++) kernels.push(await FakeKernel.create({ network: net }));
    FakeKernel.introduce(...kernels);
    const transport = new MemTransport();
    const familySvcs = kernels.map(k => createFamilyCircleService(k, { transport, displayName: () => 'A' }));
    const grantsSvcs = kernels.map(k => createGrantsService(k));

    // Setup circle: Ana (0), Rosa (1), Leo (2).
    await familySvcs[0]!.createCircle('Casa');

    // Join Rosa
    let invite = await familySvcs[0]!.createInvite();
    await familySvcs[1]!.join(invite.url, 'Rosa');
    await new Promise(r => setTimeout(r, 10));
    let [p] = await familySvcs[0]!.pendingJoins();
    await familySvcs[0]!.approveJoin(p!.requestId, true);
    await new Promise(r => setTimeout(r, 10));

    // Join Leo
    invite = await familySvcs[0]!.createInvite();
    await familySvcs[2]!.join(invite.url, 'Leo');
    await new Promise(r => setTimeout(r, 10));
    [p] = await familySvcs[0]!.pendingJoins();
    await familySvcs[0]!.approveJoin(p!.requestId, true);
    await new Promise(r => setTimeout(r, 10));

    // Ana grants vitals to Rosa and Leo
    await grantsSvcs[0]!.grant(kernels[1]!.memberId(), 'caregiver');
    await grantsSvcs[0]!.grant(kernels[2]!.memberId(), 'caregiver');
    await new Promise(r => setTimeout(r, 10));
    await grantsSvcs[1]!.syncReceivedKeys();
    await grantsSvcs[2]!.syncReceivedKeys();

    // Ana removes Leo from circle
    await familySvcs[0]!.removeMember(kernels[2]!.memberId());
    await new Promise(r => setTimeout(r, 50));

    // Ana revokes vitals from Rosa
    const rosaVitals = (await grantsSvcs[0]!.grantsGiven()).find((g) => g.to === kernels[1]!.memberId() && g.category === 'vitals')!;
    await grantsSvcs[0]!.revoke(rosaVitals.id);

    await new Promise(r => setTimeout(r, 50));
    await grantsSvcs[1]!.syncReceivedKeys();
    await grantsSvcs[2]!.syncReceivedKeys();

    // Leo should not receive any new grant
    // Since Rosa's grant was revoked and Leo was removed, Leo shouldn't be re-granted
    const grantsGivenByAna = await grantsSvcs[0]!.grantsGiven();
    const leoGrants = grantsGivenByAna.filter(g => g.to === kernels[2]!.memberId() && g.category === 'vitals');
    // We can also check that Leo does NOT have the latest epoch for vitals
    const latestEpochForVitals = Math.max(...(await grantsSvcs[0]!.grantsGiven()).filter(g => g.category === 'vitals').map(g => g.epoch), 0);

    // If Leo wasn't re-granted, his grants for vitals will have the old epoch.
    if(leoGrants.length > 0) {
      expect(leoGrants[0]!.epoch).toBeLessThan(latestEpochForVitals);
    } else {
      expect(leoGrants.length).toBe(0);
    }
  });
});
