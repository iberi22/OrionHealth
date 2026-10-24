import 'fake-indexeddb/auto';
import { describe, expect, it, vi } from 'vitest';
import { randomBytes } from '../../crypto/index';
import { createMemberBundle, sealBundle } from '../../vault/keyring';
import { openEnvelopeStore } from '../../vault/store';
import type { VaultState } from '../../contracts/services';

const created: { destroyed: boolean }[] = [];
vi.mock('../../family/sync', () => ({
  createCircleReplica: vi.fn(async () => {
    // y-webrtc throws when a second provider is opened for the same room
    await new Promise((r) => setTimeout(r, 5));
    const replica = { destroyed: false, room: 'r', add: async () => undefined, seed: () => undefined, destroy() { this.destroyed = true; }, doc: {} };
    created.push(replica);
    return replica;
  }),
}));

import { createKernel, type KernelSession } from './kernel.impl';

async function setup() {
  const mrs = randomBytes(32);
  const bundle = await createMemberBundle(mrs);
  let state: VaultState = 'unlocked';
  const subs = new Set<(s: VaultState) => void>();
  const meta = new Map<string, string>();
  const session: KernelSession = {
    state: () => state,
    onState: (cb) => (subs.add(cb), () => subs.delete(cb)),
    bundle: () => (state === 'unlocked' ? bundle : null),
    withMrs: async (fn) => fn(mrs.slice()),
    saveBundle: async (b) => sealBundle(mrs, b),
    putMeta: async (k, v) => void meta.set(k, v),
    getMeta: async (k) => meta.get(k),
  };
  const store = await openEnvelopeStore('kernel-replica-test');
  const kernel = await createKernel({ session, store, deviceId: 'dev-1' });
  return { kernel, lock: () => { state = 'locked'; subs.forEach((cb) => cb(state)); } };
}

describe('RealKernel replica', () => {
  it('opens one replica when setCircle and addCircleKey race', async () => {
    created.length = 0;
    const { kernel } = await setup();
    kernel.addCircleKey(0, randomBytes(32));
    await kernel.setCircle('circle-1', { memberId: kernel.memberId(), signPub: kernel.bundle().signPub });
    await new Promise((r) => setTimeout(r, 60));
    expect(created).toHaveLength(1);
  });

  it('discards a replica that finishes opening after lock', async () => {
    created.length = 0;
    const { kernel, lock } = await setup();
    kernel.addCircleKey(0, randomBytes(32));
    const p = kernel.setCircle('circle-2', { memberId: kernel.memberId(), signPub: kernel.bundle().signPub });
    lock();
    await p.catch(() => undefined);
    await new Promise((r) => setTimeout(r, 60));
    expect(created.every((r) => r.destroyed)).toBe(true);
  });
});
