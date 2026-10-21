import { createEmbedder, transformersLoader } from './embed';
import { builtinExpand } from './expand';
import { hybridSearch } from './hybrid';
import { createLexicalIndex, defaultMiniSearchLoader, type LexicalDoc, type LexicalIndex } from './lexical';
import type { CorpusStore } from './opfs-store';
import { parseBits, parseVec, searchFlat, type FlatShard } from './search-flat';
import type { Card, CorpusIndex, SearchResponse, StatusInfo } from './types';

interface ChunkMeta { chunk: string; entry: string }
interface Loaded {
  version: string;
  index: CorpusIndex;
  shards: Array<{ flat: FlatShard | null; chunks: ChunkMeta[]; lex: LexicalIndex }>;
  cards: Map<string, Card>;
}
export interface Embedder { embedQuery(q: string): Promise<Float32Array> }

async function gunzip(b: Uint8Array): Promise<string> {
  const copy = new Uint8Array(b.length); copy.set(b);
  const s = new Response(copy as BodyInit).body!.pipeThrough(new DecompressionStream('gzip'));
  return new Response(s).text();
}

export function createEngine(store: CorpusStore, makeEmbedder?: (readFile: (n: string) => Promise<Uint8Array | null>) => Embedder) {
  let loaded: Loaded | null = null;
  let embedder: Embedder | null = null;
  let embedderVersion: string | null = null;

  async function load(): Promise<Loaded | null> {
    const version = await store.activeVersion();
    if (!version) return null;
    if (loaded?.version === version) return loaded;
    const idxRaw = await store.readFile(version, 'corpus-index.json');
    if (!idxRaw) return null;
    const index = JSON.parse(new TextDecoder().decode(idxRaw)) as CorpusIndex;
    const cards = new Map<string, Card>();
    const cardsRaw = await store.readFile(version, 'cards.json.gz');
    if (cardsRaw) for (const c of JSON.parse(await gunzip(cardsRaw)) as Card[]) cards.set(c.id, c);
    const shards: Loaded['shards'] = [];
    for (const s of index.shards) {
      const metaRaw = await store.readFile(version, `${s.id}.meta.json.gz`);
      if (!metaRaw) continue;
      const meta = JSON.parse(await gunzip(metaRaw)) as { chunks: ChunkMeta[] };
      const textRaw = await store.readFile(version, `${s.id}.text.json.gz`);
      const texts = textRaw
        ? (JSON.parse(await gunzip(textRaw)) as { texts: Record<string, { text?: string; headings?: string }> }).texts ?? {}
        : {};
      const docs: LexicalDoc[] = meta.chunks.map((c) => {
        const card = cards.get(c.entry);
        const t = texts[c.chunk];
        return {
          id: c.chunk, entryId: c.entry, title: card?.title ?? '',
          headings: t?.headings ?? '',
          tags: [...(card?.icd10 ?? []), ...(card?.mesh ?? []), card?.source ?? '', (card as { issuer?: string } | undefined)?.issuer ?? '', (card as { country?: string } | undefined)?.country ?? ''].join(' '),
          text: t?.text ?? '',
        };
      });
      const lex = await createLexicalIndex(defaultMiniSearchLoader, { docs }, builtinExpand);
      let flat: FlatShard | null = null;
      const vecRaw = await store.readFile(version, `${s.id}.vec`);
      const bitsRaw = await store.readFile(version, `${s.id}.bits`);
      if (index.model && vecRaw && bitsRaw && vecRaw.length > 0 && bitsRaw.length > 0) {
        try { const vec = parseVec(vecRaw); flat = { vec, bits: parseBits(bitsRaw, vec.n) }; } catch { flat = null; }
      }
      shards.push({ flat, chunks: meta.chunks, lex });
    }
    loaded = { version, index, shards, cards };
    return loaded;
  }

  async function status(): Promise<StatusInfo> {
    const version = await store.activeVersion();
    const l = version ? await load() : null;
    return { installed: !!l, version, shards: l ? l.index.shards.map((s) => s.id) : [] };
  }

  async function search(query: string, k = 10): Promise<SearchResponse> {
    const l = await load();
    if (!l) return { mode: 'lexical', degraded: null, hits: [] };
    let degraded: SearchResponse['degraded'] = null;
    let q: Float32Array | null = null;
    if (l.index.model) {
      const hasVec = l.shards.some((s) => s.flat);
      const modelFile = await store.readFile(l.version, 'model.onnx');
      if (!modelFile) degraded = 'model-missing';
      else if (!hasVec) degraded = 'vectors-missing';
      else {
        try {
          if (!embedder || embedderVersion !== l.version) {
            const rf = (n: string) => store.readFile(l.version, n);
            embedder = makeEmbedder ? makeEmbedder(rf) : createEmbedder(transformersLoader(rf));
            embedderVersion = l.version;
          }
          q = await embedder.embedQuery(query);
        } catch {
          degraded = 'model-error';
        }
      }
    }
    const dense: Array<{ entryId: string; chunkId: string; score: number }> = [];
    const lexical: Array<{ entryId: string; score: number }> = [];
    for (const sh of l.shards) {
      if (q && sh.flat) {
        for (const h of searchFlat(sh.flat, q)) {
          const c = sh.chunks[h.idx];
          if (c) dense.push({ entryId: c.entry, chunkId: c.chunk, score: h.score });
        }
      }
      lexical.push(...(await sh.lex.search(query)));
    }
    dense.sort((a, b) => b.score - a.score);
    lexical.sort((a, b) => b.score - a.score);
    const hits = hybridSearch({ dense: dense.slice(0, 200), lexical: lexical.slice(0, 200), cards: l.cards, limit: k });
    return { mode: q ? 'hybrid' : 'lexical', degraded, hits };
  }

  return { status, search, invalidate() { loaded = null; embedder = null; embedderVersion = null; } };
}
