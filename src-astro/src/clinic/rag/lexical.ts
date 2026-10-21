import MiniSearch from 'minisearch';
import { tokenize } from './tokenize';

export interface MiniSearchLike {
  search(query: string, options?: Record<string, unknown>): Array<{ id: string; score: number }>;
}
export interface MiniSearchCtor {
  new (options: Record<string, unknown>): MiniSearchLike & { addAll(docs: unknown[]): void };
  loadJSON(json: string, options: Record<string, unknown>): MiniSearchLike;
}
export type MiniSearchLoader = () => Promise<MiniSearchCtor>;
/** Extra terms for a raw query term; `all` is the full lowercased term list (phrase context). */
export type ExpandHook = (term: string, all: string[]) => string[];

export const LEXICAL_FIELDS = ['title', 'headings', 'tags', 'text'];
export const LEXICAL_OPTIONS = {
  fields: LEXICAL_FIELDS,
  idField: 'id',
  tokenize,
  processTerm: (t: string) => t,
  searchOptions: {
    boost: { title: 3, headings: 2, tags: 2 },
    prefix: (t: string) => t.length >= 4,
    fuzzy: (t: string) => (t.length >= 5 ? 0.2 : false),
    combineWith: 'OR',
    tokenize,
    processTerm: (t: string) => t,
  },
};

export const defaultMiniSearchLoader: MiniSearchLoader = async () => MiniSearch as unknown as MiniSearchCtor;

export function expandQuery(query: string, expand?: ExpandHook): string {
  const terms = query.split(/\s+/).filter(Boolean);
  if (!expand) return terms.join(' ');
  const lower = terms.map((t) => t.toLowerCase());
  const extra: string[] = [];
  for (const t of lower) for (const e of expand(t, lower)) if (!terms.includes(e) && !extra.includes(e)) extra.push(e);
  return [...terms, ...extra].join(' ');
}

export interface LexicalHit { entryId: string; score: number }
export interface LexicalDoc { id: string; entryId?: string; title: string; headings?: string; tags?: string; text?: string }

export interface LexicalIndex { search(query: string, limit?: number): Promise<LexicalHit[]> }

export async function createLexicalIndex(
  loader: MiniSearchLoader,
  source: { json: string } | { docs: LexicalDoc[] },
  expand?: ExpandHook,
): Promise<LexicalIndex> {
  const Ctor = await loader();
  let ms: MiniSearchLike;
  const owner = new Map<string, string>();
  if ('json' in source) ms = Ctor.loadJSON(source.json, LEXICAL_OPTIONS);
  else {
    for (const d of source.docs) if (d.entryId) owner.set(d.id, d.entryId);
    const m = new Ctor(LEXICAL_OPTIONS);
    m.addAll(source.docs.map(({ entryId: _e, ...d }) => d));
    ms = m;
  }
  return {
    async search(query, limit = 200) {
      const seen = new Set<string>();
      const out: LexicalHit[] = [];
      for (const h of ms.search(expandQuery(query, expand), { combineWith: 'OR' })) {
        const entryId = owner.get(String(h.id)) ?? String(h.id);
        if (seen.has(entryId)) continue;
        seen.add(entryId);
        out.push({ entryId, score: h.score });
        if (out.length >= limit) break;
      }
      return out;
    },
  };
}
