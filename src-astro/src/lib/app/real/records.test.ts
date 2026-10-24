import { describe, expect, it, vi } from 'vitest';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createRecordsService } from './records';
import type { VitalReading } from '../../contracts/types';
import { fromB64u } from '../../crypto';
import { cekFor } from '../../vault/keyring';

describe('RecordsService', () => {
  it('puts and lists personal records', async () => {
    const kernel = await FakeKernel.create();
    const svc = createRecordsService(kernel);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'v-1',
      owner: kernel.memberId(),
      type: 'bp',
      value: 120,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    await svc.put(vital);

    const records = await svc.list('vital');
    expect(records).toHaveLength(1);
    expect(records[0]).toEqual(vital);
  });

  it('removes records using tombstones', async () => {
    const kernel = await FakeKernel.create();
    const svc = createRecordsService(kernel);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'v-1',
      owner: kernel.memberId(),
      type: 'bp',
      value: 120,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    await svc.put(vital);
    expect(await svc.list('vital')).toHaveLength(1);

    await svc.remove('vital', 'v-1');
    expect(await svc.list('vital')).toHaveLength(0);
  });

  it('resolves conflicts using last-writer-wins by hlc', async () => {
    const kernel = await FakeKernel.create();
    const svc = createRecordsService(kernel);

    const vital1: VitalReading = {
      kind: 'vital',
      recordId: 'v-1',
      owner: kernel.memberId(),
      type: 'bp',
      value: 120,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    const vital2: VitalReading = {
      kind: 'vital',
      recordId: 'v-1', // same recordId
      owner: kernel.memberId(),
      type: 'bp',
      value: 125,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    // Seal both but publish in reverse hlc order if we want, or just publish them normally and see.
    // FakeKernel uses a counter for hlc, so the second sealed env has a higher hlc.
    const env1 = await kernel.seal({ category: 'vitals', owner: kernel.memberId(), plaintext: vital1 });
    const env2 = await kernel.seal({ category: 'vitals', owner: kernel.memberId(), plaintext: vital2 });

    await kernel.publish(env1);
    await kernel.publish(env2); // higher hlc

    let records = await svc.list('vital');
    expect(records).toHaveLength(1);
    expect(records[0]!.value).toBe(125);

    // What if we publish them out of order?
    const kernel2 = await FakeKernel.create();
    const svc2 = createRecordsService(kernel2);

    const env3 = await kernel2.seal({ category: 'vitals', owner: kernel2.memberId(), plaintext: vital1 });
    const env4 = await kernel2.seal({ category: 'vitals', owner: kernel2.memberId(), plaintext: vital2 });

    // env4 has higher hlc, publish it first
    await kernel2.publish(env4);
    await kernel2.publish(env3);

    records = await svc2.list('vital');
    expect(records).toHaveLength(1);
    expect(records[0]!.value).toBe(125); // env4 still wins
  });

  it('reads records from other owners when key is present, skips NO_KEY silently', async () => {
    const net = new FakeNetwork();
    const kernelA = await FakeKernel.create({ network: net });
    const kernelB = await FakeKernel.create({ network: net });
    FakeKernel.introduce(kernelA, kernelB);
    const svcA = createRecordsService(kernelA);
    const svcB = createRecordsService(kernelB);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'v-b1',
      owner: kernelB.memberId(),
      type: 'bp',
      value: 130,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    await svcB.put(vital);

    // kernelA does not have kernelB's key, should skip without error
    let recordsA = await svcA.list('vital');
    expect(recordsA).toHaveLength(0);

    // Provide the key to kernelA
    const envs = await kernelB.envelopes({ category: 'vitals' });
    const epoch = envs[0]!.epoch;
    kernelA.addForeignKey(kernelB.memberId(), 'vitals', epoch, fromB64u(cekFor(kernelB.bundle(), 'vitals', epoch)));

    // Now kernelA should read it
    recordsA = await svcA.list('vital');
    expect(recordsA).toHaveLength(1);
    expect(recordsA[0]!.value).toBe(130);
  });

  it('triggers onChange for personal record categories', async () => {
    const kernel = await FakeKernel.create();
    const svc = createRecordsService(kernel);

    const cb = vi.fn();
    const unsubscribe = svc.onChange(cb);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'v-1',
      owner: kernel.memberId(),
      type: 'bp',
      value: 120,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    await svc.put(vital);
    expect(cb).toHaveBeenCalledTimes(1);

    // non-personal category
    kernel.addCircleKey(0, new Uint8Array(32));
    const envCircle = await kernel.seal({ category: 'circle', plaintext: { some: 'data' } });
    await kernel.publish(envCircle);
    expect(cb).toHaveBeenCalledTimes(1); // not called again

    unsubscribe();
    await svc.put({ ...vital, recordId: 'v-2' });
    expect(cb).toHaveBeenCalledTimes(1); // not called after unsubscribe
  });
  it('skips corrupt envelopes and logs warning without throwing, returning valid ones', async () => {
    const kernel = await FakeKernel.create();
    const svc = createRecordsService(kernel);

    const vital1: VitalReading = {
      kind: 'vital',
      recordId: 'v-1',
      owner: kernel.memberId(),
      type: 'bp',
      value: 120,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    const vital2: VitalReading = {
      kind: 'vital',
      recordId: 'v-2',
      owner: kernel.memberId(),
      type: 'bp',
      value: 130,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    const env1 = await kernel.seal({ category: 'vitals', owner: kernel.memberId(), plaintext: vital1 });
    const env2 = await kernel.seal({ category: 'vitals', owner: kernel.memberId(), plaintext: vital2 });

    await kernel.publish(env1);
    await kernel.publish(env2);

    const originalOpen = kernel.open.bind(kernel);
    const openSpy = vi.spyOn(kernel, 'open').mockImplementation(async (e) => {
      if (e.id === env1.id) throw { code: 'CORRUPT' };
      return originalOpen(e);
    });

    const warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});

    const records = await svc.list('vital');
    expect(openSpy).toHaveBeenCalled();
    expect(records).toHaveLength(1);
    expect(records[0]!.value).toBe(130);
    expect(warnSpy).toHaveBeenCalledWith('CORRUPT');

    warnSpy.mockRestore();
    openSpy.mockRestore();
  });
  it('re-throws if the vault is LOCKED', async () => {
    const kernel = await FakeKernel.create();
    const svc = createRecordsService(kernel);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'v-1',
      owner: kernel.memberId(),
      type: 'bp',
      value: 120,
      unit: 'mmHg',
      updatedAt: Date.now(),
      at: Date.now(),
    };

    const env = await kernel.seal({ category: 'vitals', owner: kernel.memberId(), plaintext: vital });
    await kernel.publish(env);

    const originalOpen = kernel.open.bind(kernel);
    const openSpy = vi.spyOn(kernel, 'open').mockImplementation(async (e) => {
      throw { code: 'LOCKED' };
    });

    await expect(svc.list('vital')).rejects.toMatchObject({ code: 'LOCKED' });

    openSpy.mockRestore();
  });
});
