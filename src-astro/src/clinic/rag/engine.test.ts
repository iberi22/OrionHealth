import { gzipSync } from 'node:zlib';
import { describe, expect, it } from 'vitest';
import { createEngine } from './engine';
import { extractive } from './extractive';
import { sha256Hex } from './hash';
import { installCorpus } from './installer';
import { CorpusStore, MemoryFileStore } from './opfs-store';
import { tokenize } from './tokenize';
import { expandTokens } from './expand';
import type { CorpusIndex } from './types';

const enc = (s: string) => new TextEncoder().encode(s);
const gz = (o: unknown) => new Uint8Array(gzipSync(Buffer.from(JSON.stringify(o))));
const cat = (...p: Uint8Array[]) => { const o = new Uint8Array(p.reduce((n, x) => n + x.length, 0)); let k = 0; for (const x of p) { o.set(x, k); k += x.length; } return o; };

async function corpus() {
  const files = new Map<string, Uint8Array>();
  const cards = [
    { id: 'e1', title: 'Heart failure management', doc_type: 'guideline', published: '2025-01-01', funding_class: 'public', retracted: false, supersedes: null },
    { id: 'e2', title: 'Renal outcomes', doc_type: 'trial_results', published: '2025-01-01', funding_class: 'public', retracted: false, supersedes: null },
  ];
  files.set('/c/cards.json.gz', gz(cards));
  const sf = [enc(''), enc(''), gz({ chunks: [{ chunk: 'e1#0', entry: 'e1' }, { chunk: 'e2#0', entry: 'e2' }] }), gz({})];
  ['vec', 'bits', 'meta.json.gz', 'lex.json.gz'].forEach((e, i) => files.set(`/c/s1.${e}`, sf[i]));
  files.set('/c/s1.text.json.gz', gz({ texts: { 'e1#0': { text: 'Beta blockers reduce mortality in reduced ejection fraction.' }, 'e2#0': { text: 'Zorblatt syndrome is rare.' } } }));
  const index: CorpusIndex = {
    corpus_version: 'v1', model: null, cards_sha256: await sha256Hex(files.get('/c/cards.json.gz')!),
    shards: [{ id: 's1', chapter: 'I', bytes: 1, sha256: await sha256Hex(cat(...sf)), chunks: 2, text_sha256: await sha256Hex(files.get('/c/s1.text.json.gz')!) }],
  };
  const fetcher = async (u: string) => (files.has(u) ? new Response(files.get(u) as BodyInit) : new Response(null, { status: 404 }));
  const store = new CorpusStore(new MemoryFileStore());
  await installCorpus({ index, baseUrl: '/c/', shardIds: ['s1'], store, fetcher, persist: async () => true });
  return { store, index };
}

describe('offline lexical RAG (no model)', () => {
  it('returns cards with mode lexical and degraded null', async () => {
    const { store } = await corpus();
    const r = await createEngine(store).search('heart failure');
    expect(r.mode).toBe('lexical');
    expect(r.degraded).toBeNull();
    expect(r.hits.map((h) => h.entryId)).toEqual(['e1']);
  });
  it('finds an English-only chunk from a Spanish query through expansion', async () => {
    const { store } = await corpus();
    const r = await createEngine(store).search('insuficiencia cardíaca');
    expect(r.hits[0]?.entryId).toBe('e1');
  });
  it('finds a term only present in chunk text', async () => {
    const { store } = await corpus();
    expect((await createEngine(store).search('zorblatt')).hits.map((h) => h.entryId)).toEqual(['e2']);
  });
  it('flags model-missing when the index expects a model that is gone', async () => {
    const { store, index } = await corpus();
    const v = 'v1';
    const raw = JSON.parse(new TextDecoder().decode((await store.readFile(v, 'corpus-index.json'))!));
    raw.model = { ...index, id: 'm' };
    await store.writeFile(v, 'corpus-index.json', enc(JSON.stringify(raw)));
    const r = await createEngine(store).search('zorblatt');
    expect(r.degraded).toBe('model-missing');
    expect(r.mode).toBe('lexical');
    expect(r.hits).toHaveLength(1);
  });
});

describe('tokenize/expand/extractive', () => {
  it('normalizes, drops stopwords and short tokens', () => {
    expect(tokenize('La Hipertensión de los niños, a 5 x')).toEqual(['hipertension', 'ninos', '5']);
  });
  it('has a curated dictionary', () => {
    expect(expandTokens(tokenize('EPOC'))).toContain('copd');
    expect(expandTokens(tokenize('chronic kidney disease'))).toContain('erc');
  });
  it('extracts the 2 best sentences with highlight ranges', () => {
    const r = extractive('Intro text. Heart failure is common. Nothing here. Failure of the heart rises.', ['heart', 'failure']);
    expect(r).toHaveLength(2);
    expect(r[0].text.slice(...r[0].highlights[0])).toBe('Heart');
  });
});
