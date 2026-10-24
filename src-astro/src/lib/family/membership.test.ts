import { describe, expect, it } from 'vitest';
import { signEvent, reduceMembership, canActorDo } from './membership';
import type { MembershipEvent } from '../contracts/types';
import { generateSigningPair, verify, canonical } from '../crypto/index';

describe('membership', () => {
  it('creates and reduces correctly', async () => {
    const kp = await generateSigningPair();
    const kp2 = await generateSigningPair();
    const ev1: Omit<MembershipEvent, 'sig'> = {
      v: 1,
      id: 'e1',
      circle: 'c1',
      kind: 'create',
      actor: 'm1',
      signPub: kp.publicSpki,
      boxPub: 'box1',
      displayName: 'Alice',
      deviceId: 'd1',
      hlc: '001',
    };
    const signed1 = await signEvent(ev1, kp.privatePkcs8);

    const ev2: Omit<MembershipEvent, 'sig'> = {
      v: 1,
      id: 'e2',
      circle: 'c1',
      kind: 'approve',
      actor: 'm1',
      subject: 'm2',
      signPub: kp2.publicSpki,
      boxPub: 'box2',
      displayName: 'Bob',
      deviceId: 'd2',
      hlc: '002',
    };
    const signed2 = await signEvent(ev2, kp.privatePkcs8);

    const verifyFn = async (ev: MembershipEvent) => {
      // In real life, you'd lookup pubkey by actor. Here we just trust the sig.
      const pk = ev.actor === 'm1' ? kp.publicSpki : kp2.publicSpki;
      return verify(pk, canonical(ev, ['sig']), ev.sig);
    };

    const res = await reduceMembership('c1', [signed1, signed2], verifyFn);

    expect(res.rejected).toHaveLength(0);
    expect(res.state).not.toBeNull();
    expect(res.state?.members['m1']).toBeDefined();
    expect(res.state?.members['m2']).toBeDefined();
  });

  it('verifies order independence for valid events', async () => {
    const kp = await generateSigningPair();
    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: 'm1', signPub: kp.publicSpki, boxPub: 'b1', displayName: 'A', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);
    const ev2 = await signEvent({ v: 1, id: 'e2', circle: 'c1', kind: 'approve', actor: 'm1', subject: 'm2', signPub: 'sp2', boxPub: 'bp2', displayName: 'B', deviceId: 'd2', hlc: '002' }, kp.privatePkcs8);
    const ev3 = await signEvent({ v: 1, id: 'e3', circle: 'c1', kind: 'role', actor: 'm1', subject: 'm2', role: 'admin', hlc: '003' }, kp.privatePkcs8);
    const verifyFn = async () => true;

    const res1 = await reduceMembership('c1', [ev1, ev2, ev3], verifyFn);
    const res2 = await reduceMembership('c1', [ev3, ev1, ev2], verifyFn); // Different order

    expect(res1.state).toEqual(res2.state);
  });

  it('rejects invalid events without throwing', async () => {
    const kp = await generateSigningPair();
    const ev1 = await signEvent({ v: 1, id: 'e1', circle: 'c1', kind: 'create', actor: 'm1', signPub: kp.publicSpki, boxPub: 'b1', displayName: 'A', deviceId: 'd1', hlc: '001' }, kp.privatePkcs8);
    const evBad = await signEvent({ v: 1, id: 'e2', circle: 'c2', kind: 'approve', actor: 'm1', subject: 'm2', hlc: '002' }, kp.privatePkcs8); // Wrong circle

    const res = await reduceMembership('c1', [ev1, evBad], async () => true);
    expect(res.rejected).toHaveLength(1);
    expect(res.rejected[0].reason).toBe('wrong-circle');
    expect(res.state?.members['m2']).toBeUndefined();
  });

  it('canActorDo works correctly', () => {
    expect(canActorDo(null, 'm1', 'create')).toBe(true);
    expect(canActorDo(null, 'm1', 'approve')).toBe(false);
  });
});
