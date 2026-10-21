import { normalize, tokenize } from './tokenize';

export interface ExtractiveSentence { text: string; start: number; end: number; highlights: Array<[number, number]> }

const ABBREVIATIONS = new Set(['dr', 'dra', 'sr', 'sra', 'vs', 'approx', 'etc', 'fig', 'no', 'mr', 'mrs', 'ms', 'prof', 'cf', 'aprox', 'ej', 'pág', 'pag']);

/** Data only: top sentences by overlap with the (expanded) query terms; highlight ranges are relative to sentence.text. */
export function extractive(text: string, terms: string[], maxSentences = 2): ExtractiveSentence[] {
  const set = new Set(terms.flatMap((t) => tokenize(t)));
  if (set.size === 0) return [];
  const sentences: Array<{ text: string; start: number; end: number; idx: number }> = [];
  const ranges: Array<[number, number]> = [];
  let from = 0;
  const push = (end: number) => { if (end > from) ranges.push([from, end]); from = end; };
  for (const m of text.matchAll(/[.!?]+(?=\s+\p{Lu}|\s*$)|\n/gu)) {
    const end = m.index! + m[0].length;
    if (m[0] !== '\n' && m[0].endsWith('.')) {
      const word = /(\S*)$/.exec(text.slice(from, m.index! + m[0].length - 1))![1];
      if (ABBREVIATIONS.has(word.toLowerCase()) || /^(\p{L}\.)+\p{L}$/iu.test(word)) continue;
    }
    push(end);
  }
  push(text.length);
  for (const [s0, e0] of ranges) {
    const raw = text.slice(s0, e0);
    const lead = raw.length - raw.trimStart().length;
    const t = raw.trim();
    if (t) sentences.push({ text: t, start: s0 + lead, end: s0 + lead + t.length, idx: sentences.length });
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
