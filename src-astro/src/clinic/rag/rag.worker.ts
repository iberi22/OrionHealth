import { createEmbedder, transformersLoader } from './embed';
import { hybridSearch } from './hybrid';
import { installCorpus } from './installer';
import { createLexicalIndex, defaultMiniSearchLoader, type LexicalIndex } from './lexical';
import { CorpusStore, OpfsFileStore } from './opfs-store';
import { parseBits, parseVec, searchFlat, type FlatShard } from './search-flat';
import type { Card, RpcRequest, RpcResponse, SearchHit, StatusInfo } from './types';

interface Loaded {
  version: string;
  shards: Array<{ flat: FlatShard; chunks: Array<{ chunk: string; entry: string }>; lex: LexicalIndex }>;
  cards: Map<string, Card>;
}

const store = new CorpusStore(new OpfsFileStore());
const embedder = createEmbedder(transformersLoader('/clinic-models/'));
let loaded: Loaded | null = null;

async function gunzip(b: Uint8Array): Promise<string> {
  const copy = new Uint8Array(b.length); copy.set(b);
  const s = new Blob([copy]).stream().pipeThrough(new DecompressionStream('gzip'));
  return new Response(s).text();
}

async function load(): Promise<Loaded | null> {
  const version = await store.activeVersion();
  if (!version) return null;
  if (loaded?.version === version) return loaded;
  const idxRaw = await store.readFile(version, 'corpus-index.json');
  if (!idxRaw) return null;
  const idx = JSON.parse(new TextDecoder().decode(idxRaw)) as { shards: Array<{ id: string }> };
  const cards = new Map<string, Card>();
  const cardsRaw = await store.readFile(version, 'cards.json.gz');
  if (cardsRaw) for (const c of JSON.parse(await gunzip(cardsRaw)) as Card[]) cards.set(c.id, c);
  const shards: Loaded['shards'] = [];
  for (const s of idx.shards) {
    const vec = parseVec((await store.readFile(version, `${s.id}.vec`))!);
    const bits = parseBits((await store.readFile(version, `${s.id}.bits`))!, vec.n);
    const meta = JSON.parse(await gunzip((await store.readFile(version, `${s.id}.meta.json.gz`))!)) as { chunks: Array<{ chunk: string; entry: string }> };
    const lex = await createLexicalIndex(defaultMiniSearchLoader, { json: await gunzip((await store.readFile(version, `${s.id}.lex.json.gz`))!) });
    shards.push({ flat: { vec, bits }, chunks: meta.chunks, lex });
  }
  loaded = { version, shards, cards };
  return loaded;
}

async function status(): Promise<StatusInfo> {
  const version = await store.activeVersion();
  const l = version ? await load() : null;
  return { installed: !!l, version, shards: l ? l.shards.length ? [...new Set(l.shards.map((_, i) => String(i)))] : [] : [] };
}

async function search(query: string, k = 10): Promise<SearchHit[]> {
  const l = await load();
  if (!l) return [];
  const q = await embedder.embedQuery(query);
  const dense: Array<{ entryId: string; chunkId: string; score: number }> = [];
  const lexical: Array<{ entryId: string; score: number }> = [];
  for (const sh of l.shards) {
    for (const h of searchFlat(sh.flat, q)) {
      const c = sh.chunks[h.idx];
      if (c) dense.push({ entryId: c.entry, chunkId: c.chunk, score: h.score });
    }
    lexical.push(...(await sh.lex.search(query)));
  }
  dense.sort((a, b) => b.score - a.score);
  lexical.sort((a, b) => b.score - a.score);
  return hybridSearch({ dense: dense.slice(0, 200), lexical: lexical.slice(0, 200), cards: l.cards, limit: k });
}

type WorkerScope = { postMessage(m: RpcResponse): void; onmessage: ((e: MessageEvent<RpcRequest>) => void) | null };
const ctx = self as unknown as WorkerScope;

ctx.onmessage = async (e) => {
  const req = e.data;
  try {
    switch (req.type) {
      case 'install':
        await installCorpus({
          index: req.index, baseUrl: req.baseUrl, shardIds: req.shardIds, store,
          onProgress: (progress) => ctx.postMessage({ id: req.id, progress }),
        });
        loaded = null;
        ctx.postMessage({ id: req.id, ok: true, type: 'install', result: await status() });
        break;
      case 'status':
        ctx.postMessage({ id: req.id, ok: true, type: 'status', result: await status() });
        break;
      case 'search':
        ctx.postMessage({ id: req.id, ok: true, type: 'search', result: await search(req.query, req.k) });
        break;
      case 'delete': {
        const v = req.version ?? (await store.activeVersion());
        if (v) await store.removeVersion(v);
        loaded = null;
        ctx.postMessage({ id: req.id, ok: true, type: 'delete', result: { installed: false, version: null, shards: [] } });
        break;
      }
    }
  } catch (err) {
    ctx.postMessage({ id: req.id, ok: false, error: err instanceof Error ? err.message : String(err) });
  }
};
