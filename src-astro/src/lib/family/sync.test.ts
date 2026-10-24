import 'fake-indexeddb/auto';
import { describe, it, expect } from 'vitest';
import * as Y from 'yjs';
import { circleRoom, transportPassword, createCircleReplica } from './sync';
import type { Envelope } from '../contracts/types';
import { utf8 } from '../crypto/index';

function createDummyEnvelope(id: string, owner: string): Envelope {
  return {
    v: 1,
    id,
    circle: 'c1',
    owner,
    author: owner,
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
    // Ensure deterministic
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

  it('createCircleReplica manages envelopes locally', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');
    const replica = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: () => true,
      connect: false
    });

    const env = createDummyEnvelope('e1', 'owner1');

    let notified: Envelope | null = null;
    replica.onEnvelope((e) => { notified = e; });

    replica.add(env);

    expect(replica.all().length).toBe(1);
    expect(replica.all()[0].id).toBe('e1');
    expect(notified).toBe(env);

    const env2 = createDummyEnvelope('e2', 'owner2');
    replica.add(env2);

    const byOwner = replica.byOwner();
    expect(byOwner['owner1'].length).toBe(1);
    expect(byOwner['owner2'].length).toBe(1);

    replica.destroy();
  });

  it('syncs manually and applies validation', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');
    const rejected: Envelope[] = [];

    const replica1 = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: () => true,
      connect: false
    });

    const replica2 = await createCircleReplica({
      circleId: 'c1',
      ck0,
      validate: (env) => env.id !== 'bad', // reject env with id 'bad'
      onRejected: (env) => rejected.push(env),
      connect: false
    });

    const goodEnv = createDummyEnvelope('good', 'owner1');
    const badEnv = createDummyEnvelope('bad', 'owner1');

    replica1.add(goodEnv);
    replica1.add(badEnv);

    // Sync replica1 to replica2
    const stateVector = Y.encodeStateVector(replica2.doc);
    const update = Y.encodeStateAsUpdate(replica1.doc, stateVector);
    Y.applyUpdate(replica2.doc, update);

    // Give asynchronous validation a tick to complete
    await new Promise(resolve => setTimeout(resolve, 10));

    const r2all = replica2.all();
    expect(r2all.length).toBe(1);
    expect(r2all[0].id).toBe('good');

    expect(rejected.length).toBe(1);
    expect(rejected[0].id).toBe('bad');

    replica1.destroy();
    replica2.destroy();
  });

  it('handles indexeddb persistence', async () => {
    const ck0 = utf8('test-ck0-key-12345678901234567890');

    const replica1 = await createCircleReplica({
      circleId: 'c2',
      ck0,
      validate: () => true,
      persist: true,
      connect: false
    });

    const env = createDummyEnvelope('e1', 'owner1');
    replica1.add(env);

    // Give IndexedDB persistence a tick to write
    await new Promise(resolve => setTimeout(resolve, 50));

    replica1.destroy();

    // Reopen replica with persistence
    const replica2 = await createCircleReplica({
      circleId: 'c2',
      ck0,
      validate: () => true,
      persist: true,
      connect: false
    });

    // Give IndexedDB persistence a tick to load
    await new Promise(resolve => setTimeout(resolve, 50));

    expect(replica2.all().length).toBe(1);
    expect(replica2.all()[0].id).toBe('e1');

    replica2.destroy();
  });
});
