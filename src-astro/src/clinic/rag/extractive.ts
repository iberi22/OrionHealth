import { normalize, tokenize } from './tokenize';

export interface ExtractiveSentence { text: string; start: number; end: number; highlights: Array<[number, number]> }

/** Data only: top sentences by overlap with the (expanded) query terms; highlight ranges are relative to sentence.text. */
export function extractive(text: string, terms: string[], maxSentences = 2): ExtractiveSentence[] {
  const set = new Set(terms.flatMap((t) => tokenize(t)));
  if (set.size === 0) return [];
  const sentences: Array<{ text: string; start: number; end: number; idx: number }> = [];
  const re = /[^.!?\n]+[.!?]*/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(text))) {
    const raw = m[0];
    const lead = raw.length - raw.trimStart().length;
    const t = raw.trim();
    if (t) sentences.push({ text: t, start: m.index + lead, end: m.index + lead + t.length, idx: sentences.length });
  }
  const scored = sentences.map((s) => {
    const highlights: Array<[number, number]> = [];
    const hit = new Set<string>();
    for (const w of s.text.matchAll(/[\p{L}\p{N}]+/gu)) {
      const n = normalize(w[0]);
      if (set.has(n)) { hit.add(n); highlights.push([w.index!, w.index! + w[0].length]); }
    }
    return { ...s, highlights, score: hit.size };
  }).filter((s) => s.score > 0);
  scored.sort((a, b) => b.score - a.score || a.idx - b.idx);
  return scored.slice(0, maxSentences).sort((a, b) => a.idx - b.idx)
    .map(({ text: t, start, end, highlights }) => ({ text: t, start, end, highlights }));
}
