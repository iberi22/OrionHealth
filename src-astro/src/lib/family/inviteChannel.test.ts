import { describe, it, expect, vi } from 'vitest';
import { createInvite, InviteError } from './invite';
import { CLOSE_GRACE_MS, InviteChannel, type InviteHello, type InviteConnection, type InviteTransport } from './inviteChannel';

class BroadcastTransport implements InviteTransport {
  private rooms = new Map<string, Set<(msg: InviteHello, senderId: string) => void>>();
  private recentMessages = new Map<string, { msg: InviteHello, senderId: string }[]>();
  private connIdCounter = 0;

  async join(roomId: string): Promise<InviteConnection> {
    const connId = `conn-${++this.connIdCounter}`;
    let room = this.rooms.get(roomId);
    if (!room) {
      room = new Set();
      this.rooms.set(roomId, room);
      this.recentMessages.set(roomId, []);
    }

    const listeners = new Set<(msg: InviteHello) => void>();

    const roomListener = (msg: InviteHello, senderId: string) => {
      // Don't send messages back to the sender
      if (senderId !== connId) {
        listeners.forEach((cb) => cb(msg));
      }
    };
    room.add(roomListener);

    const conn: InviteConnection = {
      send: async (message: InviteHello) => {
        const msgs = this.recentMessages.get(roomId)!;
        msgs.push({ msg: message, senderId: connId });
        room!.forEach(listener => {
          queueMicrotask(() => listener(message, connId));
        });
      },
      onMessage: (cb: (message: InviteHello) => void) => {
        listeners.add(cb);
        // Dispatch recent messages to new listeners
        const msgs = this.recentMessages.get(roomId)!;
        msgs.forEach(({ msg, senderId }) => {
          if (senderId !== connId) {
             queueMicrotask(() => cb(msg));
          }
        });
        return () => listeners.delete(cb);
      },
      close: () => {
        listeners.clear();
        room?.delete(roomListener);
      }
    };
    return conn;
  }
}

class MitmTransport implements InviteTransport {
  private rooms = new Map<string, Set<(msg: InviteHello, senderId: string) => void>>();
  private recentMessages = new Map<string, { msg: InviteHello, senderId: string }[]>();
  private connIdCounter = 0;

  constructor(private mitmHello: InviteHello) {}

  async join(roomId: string): Promise<InviteConnection> {
    const connId = `conn-${++this.connIdCounter}`;
    let room = this.rooms.get(roomId);
    if (!room) {
      room = new Set();
      this.rooms.set(roomId, room);
      this.recentMessages.set(roomId, []);
    }

    const listeners = new Set<(msg: InviteHello) => void>();

    const roomListener = (msg: InviteHello, senderId: string) => {
      if (senderId !== connId) {
        listeners.forEach((cb) => cb(msg));
      }
    };
    room.add(roomListener);

    const conn: InviteConnection = {
      send: async (_message: InviteHello) => { // Fixed unused parameter warning
        // MITM swaps the sender's hello with mitmHello
        const msgs = this.recentMessages.get(roomId)!;
        msgs.push({ msg: this.mitmHello, senderId: connId });
        room!.forEach(listener => {
          queueMicrotask(() => listener(this.mitmHello, connId));
        });
      },
      onMessage: (cb: (message: InviteHello) => void) => {
        listeners.add(cb);
        const msgs = this.recentMessages.get(roomId)!;
        msgs.forEach(({ msg, senderId }) => {
          if (senderId !== connId) {
            queueMicrotask(() => cb(msg));
          }
        });
        return () => listeners.delete(cb);
      },
      close: () => {
        listeners.clear();
        room?.delete(roomListener);
      }
    };
    return conn;
  }
}

describe('InviteChannel', () => {
  const aliceHello: InviteHello = {
    signPub: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEalice123',
    boxPub: 'aliceBoxPub',
    displayName: 'Alice',
    deviceId: 'aliceDev1',
  };

  const bobHello: InviteHello = {
    signPub: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEbob12345',
    boxPub: 'bobBoxPub',
    displayName: 'Bob',
    deviceId: 'bobDev1',
  };

  const mitmHello: InviteHello = {
    signPub: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEeve12345',
    boxPub: 'eveBoxPub',
    displayName: 'Eve',
    deviceId: 'eveDev1',
  };

  it('connects peers and computes the same SAS', async () => {
    const transport = new BroadcastTransport();
    const aliceChannel = new InviteChannel(transport, aliceHello);
    const bobChannel = new InviteChannel(transport, bobHello);

    const now = Date.now();
    const invite = createInvite('circle-1', now);

    const [aliceResult, bobResult] = await Promise.all([
      aliceChannel.connect(invite, now),
      bobChannel.connect(invite, now),
    ]);

    expect(aliceResult.peer).toEqual(bobHello);
    expect(bobResult.peer).toEqual(aliceHello);
    expect(aliceResult.sas).toBe(bobResult.sas);
    expect(aliceResult.sas).toMatch(/^\d{3} \d{3}$/);
  });

  it('fails with different SAS when MITM swaps keys', async () => {
    const transport = new MitmTransport(mitmHello);
    const aliceChannel = new InviteChannel(transport, aliceHello);
    const bobChannel = new InviteChannel(transport, bobHello);

    const now = Date.now();
    const invite = createInvite('circle-1', now);

    const [aliceResult, bobResult] = await Promise.all([
      aliceChannel.connect(invite, now),
      bobChannel.connect(invite, now),
    ]);

    expect(aliceResult.peer).toEqual(mitmHello);
    expect(bobResult.peer).toEqual(mitmHello);
    expect(aliceResult.sas).not.toBe(bobResult.sas);
  });

  it('rejects if the invite is already expired', async () => {
    const transport = new BroadcastTransport();
    const aliceChannel = new InviteChannel(transport, aliceHello);

    const now = Date.now();
    const invite = createInvite('circle-1', now - 24 * 60 * 60 * 1000 - 1);

    await expect(aliceChannel.connect(invite, now)).rejects.toThrow(
      new InviteError('Invite has expired', 'INVITE_EXPIRED')
    );
  });

  it('times out if the peer does not join before invite expires', async () => {
    const transport = new BroadcastTransport();
    const aliceChannel = new InviteChannel(transport, aliceHello);

    const now = Date.now();
    const invite = createInvite('circle-1', now);

    const nearExpirationNow = invite.e - 10;

    await expect(aliceChannel.connect(invite, nearExpirationNow)).rejects.toThrow(
      new InviteError('Invite has expired', 'INVITE_EXPIRED')
    );
  });

  it('keeps the room open for a grace period after the peer hello, so its own hello can still be delivered', async () => {
    vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout'] });
    try {
      const inner = new BroadcastTransport();
      const closed: string[] = [];
      let n = 0;
      const transport: InviteTransport = {
        async join(roomId) {
          const id = `c${++n}`;
          const conn = await inner.join(roomId);
          return { ...conn, close: () => (closed.push(id), conn.close()) };
        },
      };
      const invite = createInvite('circle-1');
      const alice = new InviteChannel(transport, aliceHello).connect(invite);
      const bob = new InviteChannel(transport, bobHello).connect(invite);
      await Promise.all([alice, bob]);
      expect(closed).toEqual([]);
      vi.advanceTimersByTime(CLOSE_GRACE_MS);
      expect(closed.sort()).toEqual(['c1', 'c2']);
    } finally {
      vi.useRealTimers();
    }
  });
});
