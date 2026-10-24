import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import 'fake-indexeddb/auto';
import type { PasskeyPrfProvider } from '@swal/vault/web';
import type { InviteConnection, InviteTransport } from '../family/inviteChannel';
import type { VitalReading } from '../contracts/types';
import { RealKernel } from './real/kernel.impl';
import { loadServices } from './services';
import { createRealServices } from './real';

const passkey: PasskeyPrfProvider = {
  async getPrfOutput() {
    return new Uint8Array(32).fill(42);
  },
};

const transport: InviteTransport = {
  async join(): Promise<InviteConnection> {
    return { send: async () => undefined, onMessage: () => () => undefined, close: () => undefined };
  },
};

const MARKER = 'ZXQ-PLAINTEXT-MARKER-9137';
let n = 0;
const opts = () => ({ passkey, transport, connect: false, dbPrefix: `t${++n}` });

async function dumpAllDatabases(): Promise<string> {
  let out = '';
  const dbs = await indexedDB.databases();
  for (const info of dbs) {
    const db = await new Promise<IDBDatabase>((res, rej) => {
      const r = indexedDB.open(info.name!);
      r.onsuccess = () => res(r.result);
      r.onerror = () => rej(r.error);
    });
    for (const name of Array.from(db.objectStoreNames)) {
      const rows = await new Promise<unknown[]>((res, rej) => {
        const r = db.transaction(name).objectStore(name).getAll();
        r.onsuccess = () => res(r.result);
        r.onerror = () => rej(r.error);
      });
      out += JSON.stringify(rows, (_k, v) => (v instanceof Uint8Array || v instanceof ArrayBuffer ? Array.from(new Uint8Array(v as ArrayBuffer)) : v));
    }
    db.close();
  }
  return out;
}

beforeEach(() => {
  (globalThis as Record<string, unknown>).PublicKeyCredential = {};
});
afterEach(() => {
  delete (globalThis as Record<string, unknown>).PublicKeyCredential;
  vi.restoreAllMocks();
});

describe('loadServices', () => {
  it('returns the mock with demo: true when PublicKeyCredential is undefined', async () => {
    delete (globalThis as Record<string, unknown>).PublicKeyCredential;
    const s = await loadServices();
    expect(s.demo).toBe(true);
    expect(s.vault.state()).toBeDefined();
  });

  it('returns the real services (demo: false) when IndexedDB and WebAuthn exist', async () => {
    const s = await loadServices();
    expect(s.demo).toBe(false);
  });
});

describe('createRealServices', () => {
  it('notifies family listeners when a grant is given or revoked', async () => {
    const svc = await createRealServices(opts());
    await svc.vault.create('Ana');
    await svc.family.createCircle('Casa');
    const dep = await svc.family.addDependent('Bebe');
    const onChange = vi.fn();
    svc.family.onChange(onChange);
    await svc.family.grant(dep.memberId, 'caregiver');
    const afterGrant = onChange.mock.calls.length;
    expect(afterGrant).toBeGreaterThan(0);
    const [g] = await svc.family.grantsGiven();
    await svc.family.revoke(g!.id);
    expect(onChange.mock.calls.length).toBeGreaterThan(afterGrant);
  });

  it('builds invite links on the origin serving the app', async () => {
    const svc = await createRealServices(opts());
    await svc.vault.create('Ana');
    await svc.family.createCircle('Casa');
    const { url } = await svc.family.createInvite();
    expect(url.startsWith(`${location.origin}/app/join#`)).toBe(true);
  });

  const vital = (owner: string): VitalReading => ({
    kind: 'vital',
    recordId: 'v-1',
    owner,
    type: 'bp',
    value: 120,
    value2: 80,
    unit: MARKER,
    updatedAt: Date.now(),
    at: Date.now(),
  });

  it('persists a record encrypted and reads it back after lock/unlock', async () => {
    const svc = await createRealServices(opts());
    expect(svc.demo).toBe(false);
    expect(svc.vault.state()).toBe('empty');
    const { memberId } = await svc.vault.create('Ana');
    await svc.records.put(vital(memberId));
    svc.vault.lock();
    await expect(svc.records.list('vital')).rejects.toThrow();
    await svc.vault.unlock();
    const list = await svc.records.list('vital');
    expect(list).toHaveLength(1);
    expect(list[0]!.unit).toBe(MARKER);

    const dump = await dumpAllDatabases();
    expect(dump.length).toBeGreaterThan(100);
    expect(dump).not.toContain(MARKER);
  });

  it('keeps the same device id across compositions of the same database', async () => {
    const o = opts();
    const a = await createRealServices(o);
    const b = await createRealServices(o);
    expect(await (a.vault as unknown as { getMeta(k: string): Promise<string> }).getMeta('device-id')).toBe(
      await (b.vault as unknown as { getMeta(k: string): Promise<string> }).getMeta('device-id'),
    );
  });

  it('family.revoke also calls kernel.revokeGrant', async () => {
    const spy = vi.spyOn(RealKernel.prototype, 'revokeGrant');
    const svc = await createRealServices(opts());
    const { memberId } = await svc.vault.create('Ana');
    await svc.family.createCircle('Casa');
    await svc.family.grant(memberId, 'caregiver');
    const [g] = await svc.family.grantsGiven();
    expect(g).toBeDefined();
    await svc.family.revoke(g!.id);
    expect(spy).toHaveBeenCalledWith(g!.id);
  });
});
