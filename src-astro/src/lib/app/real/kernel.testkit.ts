// Test helpers for RealKernel suites (imported by *.test.ts only): in-memory sessions over real bundles,
// kernels over fake-indexeddb stores, and a circle whose membership log is published on every device.

import { randomBytes } from '../../crypto/index';
import type { VaultState } from '../../contracts/services';
import { createMemberBundle, sealBundle, type MemberBundle } from '../../vault/keyring';
import { openEnvelopeStore } from '../../vault/store';
import { signEvent } from '../../family/membership';
import { createKernel, type EnvelopeStore, type KernelOptions, type KernelSession, type RealKernel } from './kernel.impl';

let n = 0;

export interface Device {
  session: KernelSession;
  store: EnvelopeStore;
  deviceId: string;
  kernel: RealKernel;
}

export function memSession(bundle: MemberBundle, mrs: Uint8Array): KernelSession {
  const meta = new Map<string, string>();
  return {
    state: () => 'unlocked' as VaultState,
    onState: () => () => {},
    bundle: () => bundle,
    withMrs: async (fn) => fn(mrs.slice()),
    saveBundle: async (b) => sealBundle(mrs, b),
    putMeta: async (k, v) => void meta.set(k, v),
    getMeta: async (k) => meta.get(k),
  };
}

export async function newDevice(opts: Partial<KernelOptions> = {}): Promise<Device> {
  const mrs = randomBytes(32);
  const session = memSession(await createMemberBundle(mrs), mrs);
  const store = await openEnvelopeStore(`kernel-kit-${++n}`);
  const deviceId = `d${n}`;
  const kernel = await createKernel({ session, store, deviceId, connect: false, ...opts });
  return { session, store, deviceId, kernel };
}

/** A second kernel over the same session, store and device id: the app restarted. */
export function restart(d: Device, opts: Partial<KernelOptions> = {}): Promise<RealKernel> {
  return createKernel({ session: d.session, store: d.store, deviceId: d.deviceId, connect: false, ...opts });
}

/** Circle `c1` with devices[0] as genesis admin and the others approved; every device holds CK0 and the log. */
export async function circleOf(devices: Device[], circleId = 'c1') {
  const ks = devices.map((d) => d.kernel);
  const a = ks[0]!.bundle();
  const ck = randomBytes(32);
  for (const k of ks) {
    k.addCircleKey(0, ck);
    await k.setCircle(circleId, { memberId: a.memberId, signPub: a.signPub });
  }
  const events = [
    await signEvent(
      { v: 1, id: 'm0', circle: circleId, kind: 'create', actor: a.memberId, signPub: a.signPub, boxPub: a.boxPub, displayName: 'M0', deviceId: 'd0', hlc: '0000000000001-0000-d0' },
      a.signPkcs8,
    ),
  ];
  for (let i = 1; i < ks.length; i++) {
    const b = ks[i]!.bundle();
    events.push(
      await signEvent(
        { v: 1, id: `m${i}`, circle: circleId, kind: 'approve', actor: a.memberId, subject: b.memberId, signPub: b.signPub, boxPub: b.boxPub, displayName: `M${i}`, deviceId: `d${i}`, hlc: `000000000000${i + 1}-0000-d0` },
        a.signPkcs8,
      ),
    );
  }
  const envs = [];
  for (const ev of events) {
    const env = await ks[0]!.seal({ category: 'membership', plaintext: ev });
    envs.push(env);
    for (const k of ks) await k.publish(env);
  }
  return { ck, membership: envs };
}

/** Copies every envelope of `from` to the other kernels (the direct path, no replica). */
export async function copyAll(from: RealKernel, to: RealKernel[]) {
  for (const env of await from.envelopes()) for (const k of to) await k.publish(env).catch(() => undefined);
}
