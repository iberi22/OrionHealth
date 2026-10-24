import 'fake-indexeddb/auto';
import { describe, expect, it, vi } from 'vitest';
import * as Y from 'yjs';
import type { InviteTransport } from '../../family/inviteChannel';
import { signEvent } from '../../family/membership';
import { createFamilyCircleService } from './family';
import { createGrantsService } from './grants';
import type { RealKernel } from './kernel.impl';
import { circleOf, copyAll, newDevice } from './kernel.testkit';

const LOCAL = { connect: true, transport: false } as const;
const offline: InviteTransport = { join: async () => { throw new Error('offline'); } };
const docOf = async (k: RealKernel) => {
  await vi.waitFor(() => expect(k.replicaInfo()).not.toBeNull());
  return k.replicaInfo()!.doc;
};
const exchange = (a: Y.Doc, b: Y.Doc) => {
  Y.applyUpdate(b, Y.encodeStateAsUpdate(a, Y.encodeStateVector(b)));
  Y.applyUpdate(a, Y.encodeStateAsUpdate(b, Y.encodeStateVector(a)));
};

describe('member removal (spec §7, §8)', () => {
  // Judge repro K2.
  it('a removed member cannot read personal data written after the removal', async () => {
    const [ana, rosa] = [await newDevice(), await newDevice()];
    await circleOf([ana, rosa]);
    const r = rosa.kernel.bundle();
    const gA = createGrantsService(ana.kernel), gR = createGrantsService(rosa.kernel);
    await gA.grant(r.memberId, 'custom', { categories: ['vitals'], access: 'read' });
    await copyAll(ana.kernel, [rosa.kernel]);
    await gR.syncReceivedKeys();
    const before = await ana.kernel.seal({ category: 'vitals', plaintext: { value: 'BEFORE' } });
    expect(await rosa.kernel.open(before)).toEqual({ value: 'BEFORE' });

    const fam = createFamilyCircleService(ana.kernel, { transport: offline, displayName: () => 'Ana' });
    await fam.removeMember(r.memberId);
    const after = await ana.kernel.seal({ category: 'vitals', plaintext: { value: 'AFTER-REMOVAL' } });
    await ana.kernel.publish(after);
    await copyAll(ana.kernel, [rosa.kernel]);
    await gR.syncReceivedKeys();

    expect((await ana.kernel.circle())!.members[r.memberId]!.removed).toBe(true);
    expect(after.epoch).toBeGreaterThan(before.epoch);
    await expect(rosa.kernel.open(after)).rejects.toMatchObject({ code: 'NO_KEY' });
    expect(await rosa.kernel.open(before)).toEqual({ value: 'BEFORE' }); // what was seen stays seen
    expect(await gA.grantsGiven()).toHaveLength(0);
  });

  it('the circle moves to a room of the new CK; the removed member is left in the old one; an offline member follows', async () => {
    const [ana, rosa, carlos] = [await newDevice(LOCAL), await newDevice(LOCAL), await newDevice(LOCAL)];
    await circleOf([ana, rosa, carlos]);
    const [A, R, C] = [ana.kernel, rosa.kernel, carlos.kernel];
    const r = R.bundle().memberId, c = C.bundle().memberId;
    const famA = createFamilyCircleService(A, { transport: offline, displayName: () => 'Ana' });
    createFamilyCircleService(C, { transport: offline, displayName: () => 'Carlos' });
    const gA = createGrantsService(A), gR = createGrantsService(R), gC = createGrantsService(C);
    await gA.grant(r, 'custom', { categories: ['vitals'], access: 'read' });
    await gA.grant(c, 'custom', { categories: ['vitals'], access: 'read' });
    await gC.grant(r, 'custom', { categories: ['vitals'], access: 'read' });
    await copyAll(A, [R, C]);
    await copyAll(C, [A, R]);
    await gR.syncReceivedKeys();
    await gC.syncReceivedKeys();
    const room0 = (await docOf(A), A.replicaInfo()!.room);
    expect([(await docOf(R), R.replicaInfo()!.room), (await docOf(C), C.replicaInfo()!.room)]).toEqual([room0, room0]);
    const carlosVitals0 = (await C.categoryKey('vitals')).epoch;

    // Carlos is offline while Ana removes Rosa.
    await famA.removeMember(r);
    await vi.waitFor(() => expect(A.replicaRooms().map((x) => [x.epoch, x.full])).toEqual([[1, true], [0, false]]));
    const [fresh, old] = A.replicaRooms();
    expect(fresh!.room).not.toBe(room0);
    expect(old!.room).toBe(room0);

    const after = await A.seal({ category: 'vitals', plaintext: { value: 'AFTER-REMOVAL' } });
    await A.publish(after);
    const note = await A.seal({ category: 'circle', plaintext: { kind: 'note', text: 'NEW-EPOCH' } });
    await A.publish(note);
    expect(note.epoch).toBe(1);
    // The old room carries the removal and the key handovers, never anything sealed with a newer key.
    const oldMap = old!.doc.getMap('env');
    expect(oldMap.has(after.id) || oldMap.has(note.id)).toBe(false);
    expect([...oldMap.values()].every((e: any) => e.epoch === 0 && e.category !== 'vitals')).toBe(true);
    expect(fresh!.doc.getMap('env').has(after.id)).toBe(true);

    // Rosa meets Ana in the old room: she learns about the removal and receives nothing new.
    exchange(old!.doc, R.replicaInfo()!.doc);
    await vi.waitFor(async () => expect((await R.circle())!.members[r]!.removed).toBe(true));
    expect(await rosa.store.get(after.id)).toBeUndefined();
    expect(await rosa.store.get(note.id)).toBeUndefined();
    expect(R.replicaInfo()!.room).toBe(room0);
    // Nor can she push a backdated membership event through the old room.
    const rb = R.bundle();
    const backdated = await signEvent(
      { v: 1, id: 'late', circle: 'c1', kind: 'guardian', actor: r, subject: r, ref: c, hlc: '0000000000002-0001-d9' },
      rb.signPkcs8,
    );
    const late = await R.seal({ category: 'membership', plaintext: backdated });
    await R.publish(late);
    exchange(old!.doc, R.replicaInfo()!.doc);
    await new Promise((res) => setTimeout(res, 50));
    expect(await ana.store.get(late.id)).toBeUndefined();

    // Carlos comes back: the old room hands him CK1, he moves to the new room and gets the new data.
    exchange(old!.doc, C.replicaInfo()!.doc);
    await vi.waitFor(() => expect(C.replicaInfo()?.room).toBe(fresh!.room));
    exchange(fresh!.doc, C.replicaInfo()!.doc);
    await vi.waitFor(async () => expect(await C.open(after)).toEqual({ value: 'AFTER-REMOVAL' }));
    await vi.waitFor(async () => expect(await C.open(note)).toEqual({ kind: 'note', text: 'NEW-EPOCH' }));

    // Carlos had granted vitals to Rosa as well: his device rotated them when the removal arrived.
    await vi.waitFor(async () => expect((await C.categoryKey('vitals')).epoch).toBeGreaterThan(carlosVitals0));
    const carlosAfter = await C.seal({ category: 'vitals', plaintext: { value: 'CARLOS-AFTER' } });
    await R.publish(carlosAfter).catch(() => undefined);
    await gR.syncReceivedKeys();
    await expect(R.open(carlosAfter)).rejects.toMatchObject({ code: 'NO_KEY' });
  });
});
