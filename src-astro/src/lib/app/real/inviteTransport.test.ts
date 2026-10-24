import { describe, it, expect, vi } from 'vitest';
import { createWebrtcInviteTransport, createBroadcastInviteTransport } from './inviteTransport';
import * as Y from 'yjs';
import type { InviteHello } from '../../family/inviteChannel';
import { b64u, hkdf, utf8 } from '../../crypto/index';

const dummyHello1: InviteHello = { signPub: 'sp1', boxPub: 'bp1', displayName: 'User 1', deviceId: 'd1' };
const dummyHello2: InviteHello = { signPub: 'sp2', boxPub: 'bp2', displayName: 'User 2', deviceId: 'd2' };
const dummyHello3: InviteHello = { signPub: 'sp3', boxPub: 'bp3', displayName: 'User 3', deviceId: 'd3' };

describe('createWebrtcInviteTransport', () => {
  it('derives the password and uses the provider', async () => {
    let capturedRoom = '';
    let capturedOpts: any = null;

    const transport = createWebrtcInviteTransport({
      createProvider: (room, doc, opts) => {
        capturedRoom = room;
        capturedOpts = opts;
        return { destroy: () => {} };
      }
    });

    const conn = await transport.join('my-room-id');
    const expectedPasswordBytes = await hkdf(utf8('my-room-id'), new Uint8Array(0), 'orion/v1/invite-transport');
    const expectedPassword = b64u(expectedPasswordBytes);

    expect(capturedRoom).toBe('my-room-id');
    expect(capturedOpts.password).toBe(expectedPassword);

    conn.close();
  });

  it('exchanges messages and ignores own messages', async () => {
    const docs: Y.Doc[] = [];
    const transport1 = createWebrtcInviteTransport({
      createProvider: (room, doc) => {
        docs.push(doc);
        doc.on('update', (update) => {
          docs.forEach(d => {
            if (d !== doc) Y.applyUpdate(d, update);
          });
        });
        return { destroy: () => {} };
      }
    });

    const transport2 = createWebrtcInviteTransport({
      createProvider: (room, doc) => {
        docs.push(doc);
        doc.on('update', (update) => {
          docs.forEach(d => {
            if (d !== doc) Y.applyUpdate(d, update);
          });
        });
        return { destroy: () => {} };
      }
    });

    const conn1 = await transport1.join('room1');
    const conn2 = await transport2.join('room1');

    const msgs1: InviteHello[] = [];
    const msgs2: InviteHello[] = [];

    conn1.onMessage(m => msgs1.push(m));
    conn2.onMessage(m => msgs2.push(m));

    await conn1.send(dummyHello1);

    await new Promise(r => setTimeout(r, 10));

    expect(msgs1).toHaveLength(0); // Should ignore own message
    expect(msgs2).toEqual([dummyHello1]);

    await conn2.send(dummyHello2);

    await new Promise(r => setTimeout(r, 10));

    expect(msgs1).toEqual([dummyHello2]);
    expect(msgs2).toEqual([dummyHello1]); // still just the first one

    conn1.close();
    conn2.close();
  });

  it('delivers messages to late subscribers', async () => {
    const docs: Y.Doc[] = [];
    const transport1 = createWebrtcInviteTransport({
      createProvider: (room, doc) => {
        docs.push(doc);
        doc.on('update', (update) => {
          docs.forEach(d => {
            if (d !== doc) Y.applyUpdate(d, update);
          });
        });
        return { destroy: () => {} };
      }
    });

    const conn1 = await transport1.join('room2');
    await conn1.send(dummyHello1);

    const transport2 = createWebrtcInviteTransport({
      createProvider: (room, doc) => {
        docs.push(doc);
        doc.on('update', (update) => {
          docs.forEach(d => {
            if (d !== doc) Y.applyUpdate(d, update);
          });
        });
        // manually sync existing state from doc 1 to doc 2
        Y.applyUpdate(doc, Y.encodeStateAsUpdate(docs[0]!));
        return { destroy: () => {} };
      }
    });

    const conn2 = await transport2.join('room2');

    const msgs2: InviteHello[] = [];
    conn2.onMessage(m => msgs2.push(m));

    expect(msgs2).toEqual([dummyHello1]);

    conn1.close();
    conn2.close();
  });
});

describe('createBroadcastInviteTransport', () => {
  it('exchanges messages and ignores own messages', async () => {
    const t1 = createBroadcastInviteTransport('test1');
    const t2 = createBroadcastInviteTransport('test1');

    const c1 = await t1.join('roomA');
    const c2 = await t2.join('roomA');

    const m1: InviteHello[] = [];
    const m2: InviteHello[] = [];

    c1.onMessage(m => m1.push(m));
    c2.onMessage(m => m2.push(m));

    await c1.send(dummyHello1);

    await new Promise(r => setTimeout(r, 10));

    expect(m1).toHaveLength(0); // ignores own message
    expect(m2).toEqual([dummyHello1]);

    await c2.send(dummyHello2);

    await new Promise(r => setTimeout(r, 10));

    expect(m1).toEqual([dummyHello2]);
    expect(m2).toEqual([dummyHello1]); // keeps history correctly

    c1.close();
    c2.close();
  });

  it('delivers messages to late subscribers on same connection', async () => {
    const t1 = createBroadcastInviteTransport('test2');
    const t2 = createBroadcastInviteTransport('test2');

    const c1 = await t1.join('roomB');
    const c2 = await t2.join('roomB');

    await c1.send(dummyHello1);
    await new Promise(r => setTimeout(r, 10));

    // late subscriber on c2
    const m2: InviteHello[] = [];
    c2.onMessage(m => m2.push(m));

    expect(m2).toEqual([dummyHello1]);

    c1.close();
    c2.close();
  });
});
