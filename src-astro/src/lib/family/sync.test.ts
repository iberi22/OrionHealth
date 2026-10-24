import { describe, it, expect } from 'vitest';
import * as Y from 'yjs';
import { circleRoom, transportPassword, createCircleReplica } from './sync';
import type { Envelope } from '../contracts/types';
import { utf8 } from '../crypto/index';

function createDummyEnvelope(id: string, author: string = 'owner1'): Envelope {
  return {
    v: 1,
    id,
    circle: 'c1',
    owner: 'owner1',
    author,
    device: 'd1',
    category: 'vitals',
    epoch: 1,
    hlc: '1-0-d1',
    nonce: 'n',
    ct: 'ct',
    sig: 'sig'
  };
}

describe('sync module', () => {
  it('derives room from ck0', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');
    const room = await circleRoom(ck0);
    expect(room).toBeTypeOf('string');
    expect(room.length).toBeLessThanOrEqual(22);
    const room2 = await circleRoom(ck0);
    expect(room).toBe(room2);
  });

  it('derives transport password from ck0', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');
    const pwd = await transportPassword(ck0);
    expect(pwd).toBeTypeOf('string');
    const pwd2 = await transportPassword(ck0);
    expect(pwd).toBe(pwd2);
  });

  it('handles remote delete correctly', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');
    const storeA: Envelope[] = [];
    const storeB: Envelope[] = [];

    const replicaA = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: () => true,
      sink: (env) => { storeA.push(env); },
      connect: false
    });

    const replicaB = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: () => true,
      sink: (env) => { storeB.push(env); },
      connect: false
    });

    const env = createDummyEnvelope('e1');
    await replicaA.add(env);

    // Sync A to B
    let sv = Y.encodeStateVector(replicaB.doc);
    let update = Y.encodeStateAsUpdate(replicaA.doc, sv);
    Y.applyUpdate(replicaB.doc, update);

    await new Promise(r => setTimeout(r, 20)); // wait for processing

    expect(storeB.length).toBe(1);
    expect(replicaB.doc.getMap('env').get('e1')).toBeDefined();

    // Attacker B deletes 'e1' remotely without validation mechanism
    replicaB.doc.getMap('env').delete('e1');

    // Sync B to A (malicious delete)
    sv = Y.encodeStateVector(replicaA.doc);
    update = Y.encodeStateAsUpdate(replicaB.doc, sv);
    Y.applyUpdate(replicaA.doc, update);

    await new Promise(r => setTimeout(r, 20)); // wait for processing

    // A should have restored 'e1' to Y.Map
    expect(replicaA.doc.getMap('env').get('e1')).toBeDefined();

    // Sync back A to B to restore 'e1' in B's view
    sv = Y.encodeStateVector(replicaB.doc);
    update = Y.encodeStateAsUpdate(replicaA.doc, sv);
    Y.applyUpdate(replicaB.doc, update);

    await new Promise(r => setTimeout(r, 20));

    expect(replicaB.doc.getMap('env').get('e1')).toBeDefined();

    replicaA.destroy();
    replicaB.destroy();
  });

  it('handles remote overwrite correctly', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');
    const storeA: Envelope[] = [];

    const replicaA = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: (env) => env.author !== 'attacker',
      sink: (env) => { storeA.push(env); },
      connect: false
    });

    const replicaB = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: () => true, // Attacker doesn't care
      sink: () => {},
      connect: false
    });

    const env = createDummyEnvelope('e1');
    await replicaA.add(env);

    let sv = Y.encodeStateVector(replicaB.doc);
    let update = Y.encodeStateAsUpdate(replicaA.doc, sv);
    Y.applyUpdate(replicaB.doc, update);

    await new Promise(r => setTimeout(r, 20));

    // B overwrites with invalid envelope
    const badEnv = createDummyEnvelope('e1', 'attacker');
    replicaB.doc.getMap('env').set('e1', badEnv);

    // Sync B to A
    sv = Y.encodeStateVector(replicaA.doc);
    update = Y.encodeStateAsUpdate(replicaB.doc, sv);
    Y.applyUpdate(replicaA.doc, update);

    await new Promise(r => setTimeout(r, 20));

    // A should have restored the original env
    const current = replicaA.doc.getMap('env').get('e1') as Envelope;
    expect(current).toBeDefined();
    expect(current.author).toBe('owner1');

    replicaA.destroy();
    replicaB.destroy();
  });
});
