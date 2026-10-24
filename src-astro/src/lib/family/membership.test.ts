import { describe, expect, it } from 'vitest';
import { signEvent, reduceMembership, canActorDo } from './membership';
import type { MembershipEvent } from '../contracts/types';
import { generateSigningPair, memberIdFromSpki } from '../crypto/index';

// Simple permutation generator
function permute<T>(arr: T[]): T[][] {
  if (arr.length <= 1) return [arr];
  const result: T[][] = [];
  for (let i = 0; i < arr.length; i++) {
    const current = arr[i];
    const remaining = arr.slice(0, i).concat(arr.slice(i + 1));
    const remainingPerms = permute(remaining);
    for (const perm of remainingPerms) {
      result.push([current, ...perm]);
    }
  }
  return result;
}

describe('membership', () => {
  it('creates and reduces correctly with real signatures', async () => {
    const kp = await generateSigningPair();
    const kp2 = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);
    const m2 = await memberIdFromSpki(kp2.publicSpki);

    const ev1: Omit<MembershipEvent, 'sig'> = {
      v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: m1,
      signPub: kp.publicSpki, boxPub: 'box1', displayName: 'Alice',
      deviceId: 'd1', hlc: '001',
    };
    const signed1 = await signEvent(ev1, kp.privatePkcs8);

    const ev2: Omit<MembershipEvent, 'sig'> = {
      v: 1, id: 'e2', circle: 'c1', kind: 'approve', actor: m1, subject: m2,
      signPub: kp2.publicSpki, boxPub: 'box2', displayName: 'Bob',
      deviceId: 'd2', hlc: '002',
    };
    const signed2 = await signEvent(ev2, kp.privatePkcs8);

    const res = await reduceMembership('c1', [signed1, signed2], m1);

    expect(res.rejected).toHaveLength(0);
    expect(res.state).not.toBeNull();
    expect(res.state?.members[m1]).toBeDefined();
    expect(res.state?.members[m2]).toBeDefined();
  });

  it('verifies order independence for valid events (exhaustive permutations)', async () => {
    const kp = await generateSigningPair();
    const kp2 = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);
    const m2 = await memberIdFromSpki(kp2.publicSpki);

    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: m1, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'A', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);
    const ev2 = await signEvent({ v: 1, id: 'e2', circle: 'c1', kind: 'join-request', actor: m2, signPub: kp2.publicSpki, boxPub: 'bp2', hlc: '002' }, kp2.privatePkcs8);
    const ev3 = await signEvent({ v: 1, id: 'e3', circle: 'c1', kind: 'approve', actor: m1, subject: m2, signPub: kp2.publicSpki, boxPub: 'bp2', displayName: 'B', deviceId: 'd2', hlc: '003' }, kp.privatePkcs8);
    const ev4 = await signEvent({ v: 1, id: 'e4', circle: 'c1', kind: 'role', actor: m1, subject: m2, role: 'admin', hlc: '004' }, kp.privatePkcs8);

    const events = [ev1, ev2, ev3, ev4];
    const permutations = permute(events);

    const resBase = await reduceMembership('c1', events, m1);
    expect(resBase.rejected).toHaveLength(0);
    expect(resBase.state?.members[m2].role).toBe('admin');

    for (const perm of permutations) {
      const res = await reduceMembership('c1', perm, m1);
      expect(res.state).toEqual(resBase.state);
      expect(res.rejected).toHaveLength(0);
    }
  });

  it('rejects a forged create with an earlier hlc', async () => {
    const kp = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);

    const kpForged = await generateSigningPair();
    const mForged = await memberIdFromSpki(kpForged.publicSpki);

    const evLegit = await signEvent({ v: 1, id: 'legit', circle: 'c1', kind: 'create', actor: m1, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'Admin', deviceId: 'd1', hlc: '002' }, kp.privatePkcs8);
    const evForged = await signEvent({ v: 1, id: 'forged', circle: 'c1', kind: 'create', actor: mForged, signPub: kpForged.publicSpki, boxPub: 'b2', displayName: 'Hacker', deviceId: 'd2', hlc: '001' }, kpForged.privatePkcs8);

    // The true genesisActor is m1. The reducer receives m1.
    const res = await reduceMembership('c1', [evLegit, evForged], m1);

    // The forged event should be rejected
    expect(res.rejected).toHaveLength(1);
    expect(res.rejected[0].id).toBe('forged');
    expect(res.rejected[0].reason).toBe('wrong-genesis-actor');

    // State should only have m1
    expect(res.state?.members[m1]).toBeDefined();
    expect(res.state?.members[mForged]).toBeUndefined();
  });

  it('rejects remove and role by a non-admin', async () => {
    const kp = await generateSigningPair();
    const kp2 = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);
    const m2 = await memberIdFromSpki(kp2.publicSpki);

    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: m1, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'Admin', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);
    const ev2 = await signEvent({ v: 1, id: 'e2', circle: 'c1', kind: 'approve', actor: m1, subject: m2, signPub: kp2.publicSpki, boxPub: 'b2', displayName: 'Member', deviceId: 'd2', role: 'member', hlc: '002' }, kp.privatePkcs8);

    const evBadRole = await signEvent({ v: 1, id: 'e3', circle: 'c1', kind: 'role', actor: m2, subject: m1, role: 'member', hlc: '003' }, kp2.privatePkcs8);
    const evBadRemove = await signEvent({ v: 1, id: 'e4', circle: 'c1', kind: 'remove', actor: m2, subject: m1, hlc: '004' }, kp2.privatePkcs8);

    const res = await reduceMembership('c1', [ev1, ev2, evBadRole, evBadRemove], m1);
    expect(res.rejected).toHaveLength(2);
    expect(res.rejected.find(r => r.id === 'e3')?.reason).toBe('not-admin');
    expect(res.rejected.find(r => r.id === 'e4')?.reason).toBe('not-admin');
    expect(res.state?.members[m1].role).toBe('admin');
    expect(res.state?.members[m1].removed).toBe(false);
  });

  it('allows only the owner (creator) of a dependent to set their guardian', async () => {
    const kp = await generateSigningPair();
    const kp2 = await generateSigningPair();
    const kpDep = await generateSigningPair();

    const admin1 = await memberIdFromSpki(kp.publicSpki);
    const admin2 = await memberIdFromSpki(kp2.publicSpki);
    const dep = await memberIdFromSpki(kpDep.publicSpki); // Dependent

    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: admin1, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'Admin1', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);
    const ev2 = await signEvent({ v: 1, id: 'e2', circle: 'c1', kind: 'approve', actor: admin1, subject: admin2, signPub: kp2.publicSpki, boxPub: 'b2', displayName: 'Admin2', deviceId: 'd2', role: 'admin', hlc: '002' }, kp.privatePkcs8);

    // Admin 1 creates a dependent (no deviceId)
    const ev3 = await signEvent({ v: 1, id: 'e3', circle: 'c1', kind: 'approve', actor: admin1, subject: dep, signPub: kpDep.publicSpki, boxPub: 'bDep', displayName: 'Child', hlc: '003' }, kp.privatePkcs8);

    // Admin 2 tries to set themselves as guardian for the dependent (should fail, admin 1 is the owner)
    const evBadGuard = await signEvent({ v: 1, id: 'e4', circle: 'c1', kind: 'guardian', actor: admin2, subject: dep, ref: admin2, hlc: '004' }, kp2.privatePkcs8);

    // Admin 1 sets Admin 2 as guardian for the dependent (should succeed, admin 1 is the owner)
    const evGoodGuard = await signEvent({ v: 1, id: 'e5', circle: 'c1', kind: 'guardian', actor: admin1, subject: dep, ref: admin2, hlc: '005' }, kp.privatePkcs8);

    const res = await reduceMembership('c1', [ev1, ev2, ev3, evBadGuard, evGoodGuard], admin1);

    expect(res.rejected.find(r => r.id === 'e4')?.reason).toBe('not-owner');
    expect(res.rejected.find(r => r.id === 'e5')).toBeUndefined();
    expect(res.state?.members[admin2].guardianOf).toContain(dep);
  });

  it('accepts a valid revoke event without error', async () => {
    const kp = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);

    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: m1, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'Alice', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);
    const evRevoke = await signEvent({ v: 1, id: 'e2', circle: 'c1', kind: 'revoke', actor: m1, ref: 'grant123', hlc: '002' }, kp.privatePkcs8);

    const res = await reduceMembership('c1', [ev1, evRevoke], m1);
    expect(res.rejected).toHaveLength(0);
  });

  it('rejects invalid ID mappings', async () => {
    const kp = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);
    const wrongId = 'not-the-id';

    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: wrongId, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'Alice', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);

    // Need to test with genesisActor = wrongId, otherwise it fails wrong-genesis-actor first
    const res = await reduceMembership('c1', [ev1], wrongId);
    expect(res.rejected).toHaveLength(1);
    expect(res.rejected[0].reason).toBe('id-mismatch');
  });

  it('canActorDo works correctly', () => {
    expect(canActorDo(null, 'm1', 'create')).toBe(true);
    expect(canActorDo(null, 'm1', 'approve')).toBe(false);
  });
});

  it('rejects an event with an invalid signature', async () => {
    const kp = await generateSigningPair();
    const m1 = await memberIdFromSpki(kp.publicSpki);

    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: m1, signPub: kp.publicSpki, boxPub: 'b1', displayName: 'Alice', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);

    const ev2 = await signEvent({ v: 1, id: 'e2', circle: 'c1', kind: 'role', actor: m1, subject: m1, role: 'admin', hlc: '002' }, kp.privatePkcs8);
    // Tamper the signature
    ev2.sig = ev1.sig;

    const res = await reduceMembership('c1', [ev1, ev2], m1);
    expect(res.rejected).toHaveLength(1);
    expect(res.rejected[0].reason).toBe('invalid-signature');
  });
