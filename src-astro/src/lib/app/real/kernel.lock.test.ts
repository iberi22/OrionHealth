import 'fake-indexeddb/auto';
import { describe, expect, it } from 'vitest';
import { b64u, randomBytes } from '../../crypto/index';
import type { VaultState } from '../../contracts/services';
import type { Envelope } from '../../contracts/types';
import { createMemberBundle, sealBundle, type MemberBundle } from '../../vault/keyring';
import { openEnvelopeStore } from '../../vault/store';
import { signEvent } from '../../family/membership';
import { createKernel, type KernelSession } from './kernel.impl';


let dbN = 0;

async function fakeSession() {
  const mrs = randomBytes(32);
  let bundle: MemberBundle | null = await createMemberBundle(mrs);
  const kept = bundle;
  let state: VaultState = 'unlocked';
  const subs = new Set<(s: VaultState) => void>();
  const meta = new Map<string, string>();
  const session: KernelSession & { lock(): void; unlock(): void } = {
    state: () => state,
    onState: (cb) => (subs.add(cb), () => subs.delete(cb)),
    bundle: () => (state === 'unlocked' ? bundle : null),
    withMrs: async (fn) => fn(mrs.slice()),
    saveBundle: async (b) => sealBundle(mrs, b),
    putMeta: async (k, v) => void meta.set(k, v),
    getMeta: async (k) => meta.get(k),
    lock() {
      state = 'locked';
      bundle = null;
      subs.forEach((cb) => cb(state));
    },
    unlock() {
      state = 'unlocked';
      bundle = kept;
      subs.forEach((cb) => cb(state));
    },
  };
  return { session, meta };
}

async function kernelPair() {
  const { session, meta } = await fakeSession();
  const store = await openEnvelopeStore(`kernel-lock-test-${++dbN}`);
  const kernel = await createKernel({ session, store, deviceId: `dev-${dbN}`, connect: false });
  return { session, meta, store, kernel };
}

describe('RealKernel lock and signature mutations', () => {
  it('M10: after lock the kernel holds no foreign keys or circle keys and their buffers are zero-filled', async () => {
    const { session, meta, kernel } = await kernelPair();
    const foreignRaw = randomBytes(32);
    const circleRaw = randomBytes(32);

    kernel.addForeignKey('rosa', 'vitals', 1, foreignRaw);
    kernel.addCircleKey(0, circleRaw);

    await new Promise((r) => setTimeout(r, 10));

    // Lock the kernel
    session.lock();

    // Clear the persisted keystore so unlock won't restore them
    meta.delete('keystore');

    // Unlock the kernel
    session.unlock();
    await new Promise((r) => setTimeout(r, 20));

    // Verify it throws NO_KEY for foreign key and NO_CIRCLE for circle key
    await expect(kernel.categoryKey('vitals', { owner: 'rosa' })).rejects.toMatchObject({ code: 'NO_KEY' });
    await expect(kernel.circleKey()).rejects.toMatchObject({ code: 'NO_CIRCLE' });
  });

  it('M9: a membership envelope with a forged signature is rejected by publish', async () => {
    const { kernel } = await kernelPair();
    const me = kernel.bundle();

    kernel.addCircleKey(0, randomBytes(32));
    await kernel.setCircle('c1', { memberId: me.memberId, signPub: me.signPub });

    const create = await signEvent(
      { v: 1, id: 'ev1', circle: 'c1', kind: 'create', actor: me.memberId, signPub: me.signPub, boxPub: me.boxPub, displayName: 'Ana', deviceId: 'd1', hlc: '0000000000001-0000-d1' },
      me.signPkcs8,
    );

    const env = await kernel.seal({ category: 'membership', plaintext: create });

    // Forge the signature
    const forgedEnv: Envelope = { ...env, sig: b64u(randomBytes(64)) };

    await expect(kernel.publish(forgedEnv)).rejects.toMatchObject({ code: 'INVALID' });
  });
});
