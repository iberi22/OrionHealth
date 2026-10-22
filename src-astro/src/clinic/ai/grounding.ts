import type { Answer, AnswerFlag, Passage } from './types';

export const INSUFFICIENT_ES = 'Evidencia insuficiente en la biblioteca local';
export const INSUFFICIENT_EN = 'Insufficient evidence in the offline library';
export const GENERATION_TIMEOUT_MS = 20_000;
const MIN_SURVIVAL = 0.6;

export function withTimeout<T>(p: Promise<T>, ms: number = GENERATION_TIMEOUT_MS): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const t = setTimeout(() => reject(new Error('timeout')), ms);
    p.then(
      (v) => (clearTimeout(t), resolve(v)),
      (e) => (clearTimeout(t), reject(e)),
    );
  });
}

function splitSentences(raw: string): string[] {
  return raw
    .replace(/\s+/g, ' ')
    .trim()
    .split(/(?<=\])[.!?]?\s+|(?<=[.!?])\s+(?=[^\s\[])/)
    .map((s) => s.trim())
    .filter(Boolean);
}

const UNITS = '%|mcg|µg|μg|mg|kg|g|ml|dl|l|mmol|mol|iu|ui|units?|mm?hg|bpm';
const DENOM = 'kg|m2|m²|día|dia|day|d|h|min';
const NUM = new RegExp(
  `(?<!\\d[.,]?)(\\d+(?:[.,]\\d+)?)(?![.,]?\\d)(?:\\s?(${UNITS})(?:\\s?/\\s?(?:${DENOM})(?![a-zµμáéíóú\\d]))?(?![a-zµμ]))?`,
  'gi',
);

interface NumClaim {
  value: string;
  unit: string;
}

function unitOf(m: RegExpMatchArray): string {
  if (!m[2]) return '';
  const full = m[0].slice(m[1].length).replace(/\s+/g, '').toLowerCase();
  return full;
}

function numClaims(t: string): NumClaim[] {
  return [...t.matchAll(NUM)].map((m) => ({
    value: m[1].replace(',', '.'),
    unit: unitOf(m),
  }));
}

function numberSupported(c: NumClaim, passageText: string): boolean {
  return numClaims(passageText).some((p) => p.value === c.value && (c.unit === '' || p.unit === c.unit));
}

export function applyGrounding(raw: string, passages: Passage[]): Answer {
  const text = raw.trim();
  const low = text.toLowerCase();
  if (!text || low.includes(INSUFFICIENT_ES.toLowerCase()) || low.includes(INSUFFICIENT_EN.toLowerCase())) {
    return { kind: 'retrieval-only', reason: 'ungrounded' };
  }
  const all = splitSentences(text);
  const kept: { text: string; cites: number[]; flags: AnswerFlag[] }[] = [];
  for (const s of all) {
    const m = [...s.matchAll(/\[(\d+)\]/g)].map((x) => Number(x[1]));
    const endsCited = /\[\d+\][.!?]?$/.test(s);
    const cites = [...new Set(m)];
    if (!endsCited || cites.length === 0 || cites.some((n) => n < 1 || n > passages.length)) continue;
    const cited = cites.map((n) => passages[n - 1]);
    const body = s.replace(/\[\d+\]/g, '');
    const flags: AnswerFlag[] = [];
    const nums = numClaims(body);
    if (nums.some((n) => !cited.some((p) => numberSupported(n, p.text)))) flags.push('numeric-unverified');
    if (cited.every((p) => p.funding_class === 'mixed')) flags.push('mixed-only');
    kept.push({ text: s, cites, flags });
  }
  if (all.length === 0 || kept.length / all.length < MIN_SURVIVAL || kept.length === 0) {
    return { kind: 'retrieval-only', reason: 'ungrounded' };
  }
  return { kind: 'generated', tier: 'prompt-api', sentences: kept };
}
