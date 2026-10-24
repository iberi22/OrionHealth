import { describe, expect, it } from 'vitest';
import { fromB64u, randomBytes } from '../../crypto/index';
import { cekFor } from '../../vault/keyring';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { KernelError } from './kernel';

describe('FakeKernel', () => {
  it('seals, publishes and opens my own records', async () => {
    const k = await FakeKernel.create();
    const env = await k.seal({ category: 'vitals', plaintext: { value: 120 } });
    await k.publish(env);
    expect(await k.open((await k.envelopes({ category: 'vitals' }))[0]!)).toEqual({ value: 120 });
  });

  it('replicates to a peer that can only read with a granted key', async () => {
    const net = new FakeNetwork();
    const ana = await FakeKernel.create({ network: net });
    const rosa = await FakeKernel.create({ network: net });
    FakeKernel.introduce(ana, rosa);
    const env = await rosa.seal({ category: 'vitals', plaintext: { value: 165 } });
    await rosa.publish(env);
    const [replica] = await ana.envelopes({ owner: rosa.memberId() });
    expect(replica?.id).toBe(env.id);
    await expect(ana.open(replica!)).rejects.toMatchObject({ code: 'NO_KEY' });
    ana.addForeignKey(rosa.memberId(), 'vitals', replica!.epoch, fromB64u(cekFor(rosa.bundle(), 'vitals', replica!.epoch)));
    expect(await ana.open(replica!)).toEqual({ value: 165 });
  });

  it('keeps envelopes immutable by id and rejects unknown authors', async () => {
    const k = await FakeKernel.create();
    const env = await k.seal({ category: 'vitals', plaintext: 1 });
    await k.publish(env);
    await k.publish(env);
    const other = await k.seal({ category: 'vitals', plaintext: 2 });
    await expect(k.publish({ ...other, id: env.id })).rejects.toBeInstanceOf(KernelError);
    const stranger = await FakeKernel.create();
    await expect(k.publish(await stranger.seal({ category: 'vitals', plaintext: 3 }))).rejects.toMatchObject({ code: 'INVALID' });
  });

  it('circle categories need a circle key and nothing is reachable after lock', async () => {
    const k = await FakeKernel.create();
    await expect(k.seal({ category: 'circle', plaintext: {} })).rejects.toMatchObject({ code: 'NO_CIRCLE' });
    k.addCircleKey(0, randomBytes(32));
    await k.publish(await k.seal({ category: 'circle', plaintext: { t: 'hola' } }));
    let fired = false;
    k.onLock(() => (fired = true));
    k.lock();
    expect(fired).toBe(true);
    expect(() => k.memberId()).toThrow(KernelError);
    await expect(k.circleKey()).rejects.toMatchObject({ code: 'LOCKED' });
  });

  it('wraps keys to a recipient without exposing them and rotates categories', async () => {
    const net = new FakeNetwork();
    const ana = await FakeKernel.create({ network: net });
    const rosa = await FakeKernel.create({ network: net });
    FakeKernel.introduce(ana, rosa);
    const aad = new TextEncoder().encode('g');
    const w = await rosa.wrapKeyFor({ category: 'vitals' }, ana.bundle().boxPub, 'orion/v1/grant', aad);
    const raw = await ana.unwrapForMe(w.ephPub, w.wrapped, 'orion/v1/grant', aad);
    ana.addForeignKey(rosa.memberId(), 'vitals', w.epoch, raw);
    const env = await rosa.seal({ category: 'vitals', plaintext: { v: 1 } });
    await rosa.publish(env);
    expect(await ana.open((await ana.envelopes({ owner: rosa.memberId() }))[0]!)).toEqual({ v: 1 });
    const next = await rosa.rotateCategory('vitals');
    expect(next).toBe(w.epoch + 1);
    const env2 = await rosa.seal({ category: 'vitals', plaintext: { v: 2 } });
    await rosa.publish(env2);
    await expect(ana.open(env2)).rejects.toMatchObject({ code: 'NO_KEY' });
  });
});
