import { describe, expect, it, vi } from 'vitest';
import MiniSearch from 'minisearch';
import { extractive } from './extractive';
import { tokenize } from './tokenize';
import { LEXICAL_OPTIONS } from './lexical';
import { installCorpus } from './installer';
import { CorpusStore, MemoryFileStore } from './opfs-store';
import { sha256Hex } from './hash';
import type { CorpusIndex } from './types';

describe('extractive sentence splitting', () => {
  it('keeps decimal doses whole', () => {
    const r = extractive('Give 2.5 mg twice daily in CKD. Other text.', ['mg']);
    expect(r[0].text).toBe('Give 2.5 mg twice daily in CKD.');
  });
  it('keeps i.v. and Spanish decimals whole', () => {
    const r = extractive('Usar 0,5 mg/kg i.v. cada 8 h. Siguiente frase.', ['mg']);
    expect(r[0].text).toBe('Usar 0,5 mg/kg i.v. cada 8 h.');
  });
  it('does not split on abbreviations', () => {
    const r = extractive('Dr. Smith said dose vs. placebo, e.g. approx. 5 mg. Next Thing.', ['dose']);
    expect(r[0].text).toBe('Dr. Smith said dose vs. placebo, e.g. approx. 5 mg.');
  });
  it('still splits normal sentences', () => {
    const r = extractive('First sentence here. Second sentence aspirin.', ['aspirin']);
    expect(r[0].text).toBe('Second sentence aspirin.');
  });
});

describe('WHO stopword', () => {
  it('tokenizes WHO', () => expect(tokenize('WHO')).toEqual(['who']));
  it('finds a card issued by WHO', () => {
    const ms = new MiniSearch(LEXICAL_OPTIONS as never);
    ms.addAll([{ id: 'a', title: 'Guideline', tags: 'WHO' }, { id: 'b', title: 'Other', tags: 'CDC' }]);
    expect(ms.search('WHO').map((h) => h.id)).toEqual(['a']);
  });
});

const enc = (s: string) => new TextEncoder().encode(s);
async function fx(withTextSha: boolean) {
  const files = new Map<string, Uint8Array>();
  const cards = enc('cards');
  files.set('/c/cards.json.gz', cards);
  files.set('/c/s1.text.json.gz', enc('text'));
  const parts = ['vec', 'bits', 'meta.json.gz', 'lex.json.gz'].map((e, i) => [e, enc(`b${i}`)] as const);
  for (const [e, b] of parts) files.set(`/c/s1.${e}`, b);
  const whole = new Uint8Array(parts.reduce((n, [, b]) => n + b.length, 0));
  let k = 0;
  for (const [, b] of parts) { whole.set(b, k); k += b.length; }
  const index: CorpusIndex = {
    corpus_version: 'v1', cards_sha256: await sha256Hex(cards),
    shards: [{ id: 's1', chapter: 'I', bytes: whole.length, sha256: await sha256Hex(whole), chunks: 1,
      ...(withTextSha ? { text_sha256: await sha256Hex(enc('text')) } : {}) }],
  } as CorpusIndex;
  const fetcher = vi.fn(async (u: string) => files.has(u) ? new Response(files.get(u) as BodyInit) : new Response(null, { status: 404 }));
  return { index, fetcher };
}

describe('installer text shard verification', () => {
  it('installs text when text_sha256 is present', async () => {
    const { index, fetcher } = await fx(true);
    const store = new CorpusStore(new MemoryFileStore());
    await installCorpus({ index, baseUrl: '/c/', shardIds: ['s1'], installModel: false, store, fetcher, persist: async () => true });
    expect(await store.readFile('v1', 's1.text.json.gz')).not.toBeNull();
  });
  it('skips unverified text when text_sha256 is missing', async () => {
    const { index, fetcher } = await fx(false);
    const store = new CorpusStore(new MemoryFileStore());
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    await installCorpus({ index, baseUrl: '/c/', shardIds: ['s1'], installModel: false, store, fetcher, persist: async () => true });
    expect(await store.readFile('v1', 's1.text.json.gz')).toBeNull();
    expect(await store.activeVersion()).toBe('v1');
    expect(warn).toHaveBeenCalled();
    expect(fetcher).not.toHaveBeenCalledWith('/c/s1.text.json.gz');
    warn.mockRestore();
  });
});
