export interface Segment { text: string; hit: boolean }

/** Split a snippet into plain/highlighted segments (rendered as text, never HTML). */
export function highlightSegments(snippet: string, terms: string[] = []): Segment[] {
  const ts = terms.map((x) => x.trim()).filter(Boolean);
  if (!ts.length) return [{ text: snippet, hit: false }];
  const re = new RegExp(`(${ts.map((x) => x.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')})`, 'gi');
  return snippet.split(re).filter((s) => s !== '').map((text, i) => ({ text, hit: i % 2 === 1 }));
}

/** Verbatim extract capped at `maxWords` words (adds "…" when truncated). Null when empty. */
export function clampQuote(q: string, maxWords = 50): string | null {
  const t = q.trim();
  if (!t) return null;
  const words = t.split(/\s+/);
  if (words.length <= maxWords) return t;
  return `${words.slice(0, maxWords).join(' ')}…`;
}

/** Split text into plain/highlighted segments from [start, end) ranges (text nodes only, never HTML). */
export function rangeSegments(text: string, ranges: ReadonlyArray<readonly [number, number]> = []): Segment[] {
  const n = text.length;
  const sorted = ranges
    .map(([s, e]) => [Math.max(0, Math.floor(s)), Math.min(n, Math.floor(e))] as [number, number])
    .filter(([s, e]) => e > s)
    .sort((a, b) => a[0] - b[0]);
  const merged: [number, number][] = [];
  for (const r of sorted) {
    const last = merged[merged.length - 1];
    if (last && r[0] <= last[1]) last[1] = Math.max(last[1], r[1]);
    else merged.push([r[0], r[1]]);
  }
  const out: Segment[] = [];
  let pos = 0;
  for (const [s, e] of merged) {
    if (s > pos) out.push({ text: text.slice(pos, s), hit: false });
    out.push({ text: text.slice(s, e), hit: true });
    pos = e;
  }
  if (pos < n) out.push({ text: text.slice(pos), hit: false });
  return out.length ? out : [{ text, hit: false }];
}
