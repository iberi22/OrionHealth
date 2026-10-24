import 'fake-indexeddb/auto';
import { describe, expect, it, vi } from 'vitest';
import * as Y from 'yjs';
import type { Envelope } from '../../contracts/types';
import { b64u, randomBytes } from '../../crypto/index';
import { circleOf, newDevice, restart, type Device } from './kernel.testkit';
import type { RealKernel } from './kernel.impl';

// Replicas without y-webrtc: the tests move Yjs updates between docs, as the sync.ts tests do.
const LOCAL = { connect: true, transport: false } as const;

const docOf = async (k: RealKernel) => {
  await vi.waitFor(() => expect(k.replicaInfo()).not.toBeNull());
  return k.replicaInfo()!.doc;
};
const syncDocs = (from: Y.Doc, to: Y.Doc) => Y.applyUpdate(to, Y.encodeStateAsUpdate(from, Y.encodeStateVector(to)));
/** Delivers exactly these envelopes to a replica, as a peer that only had them would. */
const deliver = (to: Y.Doc, ...envs: Envelope[]) => {
  const peer = new Y.Doc();
  peer.transact(() => envs.forEach((e) => peer.getMap<Envelope>('env').set(e.id, e)));
  Y.applyUpdate(to, Y.encodeStateAsUpdate(peer));
};
const settle = () => new Promise((r) => setTimeout(r, 50));

describe('RealKernel replica sync (spec §8)', () => {
  it('A publishes while B is offline, both restart, B receives it', async () => {
    const ana: Device = await newDevice(LOCAL);
    const bob: Device = await newDevice(LOCAL);
    await circleOf([ana, bob]);
    await docOf(ana.kernel);
    await docOf(bob.kernel);

    // Bob is offline: nothing is exchanged while Ana writes.
    const env = await ana.kernel.seal({ category: 'vitals', plaintext: { value: 'WHILE-OFFLINE' } });
    await ana.kernel.publish(env);
    expect(await bob.store.get(env.id)).toBeUndefined();

    // Both apps restart: new kernels over the same stores, fresh (empty) Y.Docs.
    const ana2 = await restart(ana, LOCAL);
    const bob2 = await restart(bob, LOCAL);
    syncDocs(await docOf(ana2), await docOf(bob2));
    await vi.waitFor(async () => expect(await bob.store.get(env.id)).toEqual(env));
  });

  it('seeding is idempotent and keeps envelopes immutable by id', async () => {
    const ana = await newDevice(LOCAL);
    await circleOf([ana]);
    const env = await ana.kernel.seal({ category: 'vitals', plaintext: 1 });
    await ana.kernel.publish(env);
    const ana2 = await restart(ana, LOCAL);
    const doc = await docOf(ana2);
    await vi.waitFor(() => expect(doc.getMap<Envelope>('env').get(env.id)).toEqual(env));
    const size = doc.getMap('env').size;
    // An overwrite under a seeded id is restored to the stored envelope.
    deliver(doc, { ...env, ct: b64u(randomBytes(32)) });
    await settle();
    expect(doc.getMap<Envelope>('env').get(env.id)).toEqual(env);
    expect(doc.getMap('env').size).toBe(size);
  });

  it('an envelope that arrives before its approve is accepted after the approve', async () => {
    const ana = await newDevice(LOCAL);
    const rosa = await newDevice(LOCAL);
    const carlos = await newDevice(LOCAL);
    const { ck, membership } = await circleOf([ana, rosa]);
    // Carlos knows the circle and its genesis, but has not seen Rosa's approve yet.
    const a = ana.kernel.bundle();
    carlos.kernel.addCircleKey(0, ck);
    await carlos.kernel.setCircle('c1', { memberId: a.memberId, signPub: a.signPub });
    await carlos.kernel.publish(membership[0]!);
    const doc = await docOf(carlos.kernel);

    const early = await rosa.kernel.seal({ category: 'vitals', plaintext: { value: 'EARLY' } });
    await rosa.kernel.publish(early);
    const forged: Envelope = { ...(await rosa.kernel.seal({ category: 'vitals', plaintext: 2 })), sig: b64u(randomBytes(64)) };
    deliver(doc, early, forged);
    await settle();
    expect(await carlos.store.get(early.id)).toBeUndefined();

    deliver(doc, membership[1]!); // Rosa's approve
    await vi.waitFor(async () => expect(await carlos.store.get(early.id)).toEqual(early));
    // A pending envelope that still fails (bad signature once the author is known) is never stored.
    await settle();
    expect(await carlos.store.get(forged.id)).toBeUndefined();
  });
});
