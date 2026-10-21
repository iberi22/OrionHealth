export interface MiniSearchLike {
  search(query: string, options?: Record<string, unknown>): Array<{ id: string; score: number }>;
}
export interface MiniSearchCtor {
  new (options: Record<string, unknown>): MiniSearchLike & { addAll(docs: unknown[]): void };
  loadJSON(json: string, options: Record<string, unknown>): MiniSearchLike;
}
export type MiniSearchLoader = () => Promise<MiniSearchCtor>;
export type ExpandHook = (term: string) => string[];

export const LEXICAL_FIELDS = ['title', 'mesh', 'headings', 'icd'];
export const LEXICAL_OPTIONS = { fields: LEXICAL_FIELDS, idField: 'id', searchOptions: { prefix: true, fuzzy: 0.1 } };

/** Real loader: dynamic import with a variable specifier so the package is optional at build time. */
export const defaultMiniSearchLoader: MiniSearchLoader = async () => {
  const spec = 'minisearch';
  const mod = (await import(/* @vite-ignore */ spec)) as { default: MiniSearchCtor };
  return mod.default;
};

export function expandQuery(query: string, expand?: ExpandHook): string {
  const terms = query.split(/\s+/).filter(Boolean);
  if (!expand) return terms.join(' ');
  const extra: string[] = [];
  for (const t of terms) for (const e of expand(t.toLowerCase())) if (!terms.includes(e) && !extra.includes(e)) extra.push(e);
  return [...terms, ...extra].join(' ');
}

export interface LexicalHit { entryId: string; score: number }

export interface LexicalIndex { search(query: string, limit?: number): Promise<LexicalHit[]> }

export async function createLexicalIndex(
  loader: MiniSearchLoader,
  source: { json: string } | { docs: Array<{ id: string; title: string; mesh?: string; headings?: string; icd?: string }> },
  expand?: ExpandHook,
): Promise<LexicalIndex> {
  const Ctor = await loader();
  let ms: MiniSearchLike;
  if ('json' in source) ms = Ctor.loadJSON(source.json, LEXICAL_OPTIONS);
  else { const m = new Ctor(LEXICAL_OPTIONS); m.addAll(source.docs); ms = m; }
  return {
    async search(query, limit = 200) {
      return ms.search(expandQuery(query, expand), { combineWith: 'OR' }).slice(0, limit).map((h) => ({ entryId: String(h.id), score: h.score }));
    },
  };
}
