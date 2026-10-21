import { describe, expect, it, vi } from 'vitest';
import { installCorpus } from './installer';
import { CorpusStore, MemoryFileStore } from './opfs-store';
import { sha256Hex } from './hash';
import type { CorpusIndex } from './types';

const enc = (s: string) => new TextEncoder().encode(s);
const cat = (...p: Uint8Array[]) => {
  const o = new Uint8Array(p.reduce((n, x) => n + x.length, 0));
  let k = 0;
  for (const x of p) { o.set(x, k); k += x.length; }
  return o;
};

async function fixture(modelSha?: string, shardBody = 'one') {
  const files = new Map<string, Uint8Array>();
  const p1 = enc('model-'), p2 = enc('bytes');
  files.set('/models/p1', p1);
  files.set('/models/p2', p2);
  const parts = [p1, p2];
  const sf = ['vec', 'bits', 'meta.json.gz', 'lex.json.gz'].map((e, i) => [e, enc(`${shardBody}${i}`)] as const);
  for (const [e, b] of sf) files.set(`/corpus/s1.${e}`, b);
  const whole = cat(...sf.map(([, b]) => b));
  const index: CorpusIndex = {
    corpus_version: 'v1',
    model: { id: 'm', revision: 'r', file_sha256: await sha256Hex(cat(...parts)), dtype: 'q8', dim: 384,
      parts: await Promise.all(parts.map(async (b, i) => ({ url: `/models/p${i + 1}`, sha256: await sha256Hex(b), bytes: b.length }))) },
    shards: [{ id: 's1', chapter: 'I', bytes: whole.length, sha256: await sha256Hex(whole), chunks: 1, model_sha256: modelSha }],
  };
  if (!modelSha) index.shards[0].model_sha256 = index.model.file_sha256;
  const fetcher = vi.fn(async (url: string) => {
    const b = files.get(url);
    if (!b) return new Response(null, { status: 404 });
    return new Response(b as BodyInit, { status: 200 });
  });
  return { index, files, fetcher };
}

describe('installer', () => {
  it('installs, verifies, activates and requests persistence', async () => {
    const { index, fetcher } = await fixture();
    const store = new CorpusStore(new MemoryFileStore());
    const persist = vi.fn(async () => true);
    const progress: number[] = [];
    await installCorpus({ index, baseUrl: '/corpus/', shardIds: ['s1'], store, fetcher, persist, onProgress: (p) => progress.push(p.done) });
    expect(await store.activeVersion()).toBe('v1');
    expect(persist).toHaveBeenCalled();
    expect(new TextDecoder().decode((await store.readFile('v1', 'model.onnx'))!)).toBe('model-bytes');
    expect(progress.length).toBeGreaterThan(0);
  });

  it('rejects a sha mismatch and keeps previous active', async () => {
    const { index, files, fetcher } = await fixture();
    files.set('/corpus/s1.vec', enc('tampered'));
    const store = new CorpusStore(new MemoryFileStore());
    await expect(installCorpus({ index, baseUrl: '/corpus/', shardIds: ['s1'], store, fetcher, persist: async () => true })).rejects.toThrow(/sha256/);
    expect(await store.activeVersion()).toBeNull();
  });

  it('refuses a shard built with a different model sha', async () => {
    const { index, fetcher } = await fixture('OTHER');
    const store = new CorpusStore(new MemoryFileStore());
    await expect(installCorpus({ index, baseUrl: '/corpus/', shardIds: ['s1'], store, fetcher, persist: async () => true })).rejects.toThrow(/model/);
  });

  it('on update downloads only shards whose hash changed', async () => {
    const a = await fixture();
    const store = new CorpusStore(new MemoryFileStore());
    await installCorpus({ index: a.index, baseUrl: '/corpus/', shardIds: ['s1'], store, fetcher: a.fetcher, persist: async () => true });
    const next = { ...a.index, corpus_version: 'v2' };
    const f2 = vi.fn(async (u: string) => a.fetcher(u));
    await installCorpus({ index: next, baseUrl: '/corpus/', shardIds: ['s1'], store, fetcher: f2, persist: async () => true });
    expect(f2).not.toHaveBeenCalled();
    expect(await store.activeVersion()).toBe('v2');
  });
});
