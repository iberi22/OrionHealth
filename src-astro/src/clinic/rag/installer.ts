import { concatBytes, sha256Hex } from './hash';
import type { CorpusStore } from './opfs-store';
import type { CorpusIndex, InstallProgress } from './types';

export const CARDS_FILE = 'cards.json.gz';
export const SHARD_EXTS = ['vec', 'bits', 'meta.json.gz', 'lex.json.gz'] as const;
const INDEX_FILE = 'corpus-index.json';
const MODEL_FILE = 'model.onnx';

export interface InstallDeps {
  index: CorpusIndex;
  baseUrl: string;
  shardIds: string[];
  /** Opt-in: download the embedding model too (default false: lexical-only corpus). */
  installModel?: boolean;
  store: CorpusStore;
  fetcher?: (url: string) => Promise<Response>;
  persist?: () => Promise<boolean>;
  onProgress?: (p: InstallProgress) => void;
}

async function download(fetcher: (u: string) => Promise<Response>, url: string): Promise<Uint8Array> {
  const res = await fetcher(url);
  if (!res.ok) throw new Error(`download failed ${res.status} for ${url}`);
  return new Uint8Array(await res.arrayBuffer());
}

function shardFiles(id: string) { return SHARD_EXTS.map((e) => `${id}.${e}`); }

export async function installCorpus(d: InstallDeps): Promise<void> {
  const { index, store } = d;
  const fetcher = d.fetcher ?? ((u: string) => fetch(u));
  const persist = d.persist ?? (async () => (typeof navigator !== 'undefined' && navigator.storage?.persist ? navigator.storage.persist() : false));
  const version = index.corpus_version;
  const base = d.baseUrl.endsWith('/') ? d.baseUrl : `${d.baseUrl}/`;
  const wanted = index.shards.filter((s) => d.shardIds.includes(s.id));
  const model = d.installModel ? index.model : null;
  if (d.installModel && !index.model) throw new Error('installModel requested but the corpus index has no model');
  if (model) {
    for (const s of wanted) {
      if (s.model_sha256 && s.model_sha256 !== model.file_sha256) {
        throw new Error(`shard ${s.id} was built with a different model sha`);
      }
    }
  }
  await persist();

  const prevVersion = await store.activeVersion();
  let prev: CorpusIndex | null = null;
  if (prevVersion) {
    const raw = await store.readFile(prevVersion, INDEX_FILE);
    if (raw) prev = JSON.parse(new TextDecoder().decode(raw)) as CorpusIndex;
  }
  const modelBytes = model ? model.parts.reduce((n, p) => n + p.bytes, 0) : 0;
  const total = modelBytes + wanted.reduce((n, s) => n + s.bytes, 0);
  let done = 0;
  const tick = (phase: InstallProgress['phase'], file: string, n: number) => { done += n; d.onProgress?.({ phase, file, done, total }); };
  const expected: Record<string, string> = {};

  try {
    if (model) {
      // model: reuse when the previous version has the same file hash
      let bytes: Uint8Array | null = null;
      if (prev?.model && prevVersion && prev.model.file_sha256 === model.file_sha256) {
        bytes = await store.readFile(prevVersion, MODEL_FILE);
        if (bytes && (await sha256Hex(bytes)) !== model.file_sha256) bytes = null;
        if (bytes) tick('model', MODEL_FILE, modelBytes);
      }
      if (!bytes) {
        const parts: Uint8Array[] = [];
        for (const p of model.parts) {
          const b = await download(fetcher, p.url);
          if ((await sha256Hex(b)) !== p.sha256) throw new Error(`sha256 mismatch for model part ${p.url}`);
          parts.push(b);
          tick('model', p.url, p.bytes);
        }
        bytes = concatBytes(parts);
        if ((await sha256Hex(bytes)) !== model.file_sha256) throw new Error('sha256 mismatch for assembled model');
      }
      await store.writeFile(version, MODEL_FILE, bytes);
      expected[MODEL_FILE] = model.file_sha256;
    }

    // cards (required: hits without a card are dropped)
    let cards: Uint8Array | null = null;
    if (prevVersion && index.cards_sha256 && prev?.cards_sha256 === index.cards_sha256) {
      cards = await store.readFile(prevVersion, CARDS_FILE);
      if (cards && (await sha256Hex(cards)) !== index.cards_sha256) cards = null;
    }
    if (!cards) {
      cards = await download(fetcher, `${base}${CARDS_FILE}`);
      if (index.cards_sha256 && (await sha256Hex(cards)) !== index.cards_sha256) throw new Error('sha256 mismatch for cards.json.gz');
    }
    await store.writeFile(version, CARDS_FILE, cards);
    expected[CARDS_FILE] = await sha256Hex(cards);

    for (const s of wanted) {
      const names = shardFiles(s.id);
      let bodies: Uint8Array[] | null = null;
      const old = prev?.shards.find((x) => x.id === s.id);
      if (prevVersion && old && old.sha256 === s.sha256) {
        const reused = await Promise.all(names.map((n) => store.readFile(prevVersion, n)));
        if (reused.every((r): r is Uint8Array => r !== null) && (await sha256Hex(concatBytes(reused))) === s.sha256) {
          bodies = reused;
          tick('shards', s.id, s.bytes);
        }
      }
      if (!bodies) {
        bodies = [];
        for (const n of names) bodies.push(await download(fetcher, `${base}${n}`));
        if ((await sha256Hex(concatBytes(bodies))) !== s.sha256) throw new Error(`sha256 mismatch for shard ${s.id}`);
        tick('shards', s.id, s.bytes);
      }
      for (let i = 0; i < names.length; i++) {
        await store.writeFile(version, names[i], bodies[i]);
        expected[names[i]] = await sha256Hex(bodies[i]);
      }
      // chunk texts (lexical quality): verified when the index declares a hash, best-effort otherwise
      const textName = `${s.id}.text.json.gz`;
      let text: Uint8Array | null = null;
      if (prevVersion && old && old.sha256 === s.sha256 && (!s.text_sha256 || old.text_sha256 === s.text_sha256)) {
        text = await store.readFile(prevVersion, textName);
        if (text && s.text_sha256 && (await sha256Hex(text)) !== s.text_sha256) text = null;
      }
      if (!text) {
        try { text = await download(fetcher, `${base}${textName}`); } catch (e) { if (s.text_sha256) throw e; }
        if (text && s.text_sha256 && (await sha256Hex(text)) !== s.text_sha256) throw new Error(`sha256 mismatch for ${textName}`);
      }
      if (text) {
        await store.writeFile(version, textName, text);
        expected[textName] = await sha256Hex(text);
      }
    }
    const idxBytes = new TextEncoder().encode(JSON.stringify({ ...index, model, shards: wanted }));
    await store.writeFile(version, INDEX_FILE, idxBytes);
    expected[INDEX_FILE] = await sha256Hex(idxBytes);
    await store.activate(version, expected);
  } catch (e) {
    if (version !== prevVersion) await store.removeVersion(version);
    throw e;
  }
  if (prevVersion && prevVersion !== version) await store.removeVersion(prevVersion);
}
