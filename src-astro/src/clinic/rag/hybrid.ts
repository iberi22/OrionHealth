import type { Card, SearchHit } from './types';

export interface DenseHit { entryId: string; chunkId: string }
export interface LexHit { entryId: string }

const K = 60;
const FIVE_YEARS_MS = 5 * 365.25 * 24 * 3600 * 1000;

function weight(card: Card, now: Date): number {
  let w = 1;
  if (card.funding_class === 'mixed') w *= 0.85;
  else if (card.funding_class === 'unknown') w *= 0.9;
  if (card.doc_type === 'guideline' && card.published) {
    const t = Date.parse(card.published);
    if (!Number.isNaN(t) && now.getTime() - t > FIVE_YEARS_MS) w *= 0.9;
  }
  return w;
}

export function hybridSearch(a: { dense: DenseHit[]; lexical: LexHit[]; cards: Map<string, Card>; now?: Date; limit?: number }): SearchHit[] {
  const now = a.now ?? new Date();
  const superseded = new Set<string>();
  for (const c of a.cards.values()) if (c.supersedes) superseded.add(c.supersedes);

  const score = new Map<string, number>();
  const chunks = new Map<string, string[]>();
  // dense list collapses to entry rank (first/best chunk per entry)
  let rank = 0;
  const seenDense = new Set<string>();
  for (const h of a.dense) {
    const list = chunks.get(h.entryId) ?? [];
    list.push(h.chunkId);
    chunks.set(h.entryId, list);
    if (seenDense.has(h.entryId)) continue;
    seenDense.add(h.entryId);
    rank++;
    score.set(h.entryId, (score.get(h.entryId) ?? 0) + 1 / (K + rank));
  }
  rank = 0;
  const seenLex = new Set<string>();
  for (const h of a.lexical) {
    if (seenLex.has(h.entryId)) continue;
    seenLex.add(h.entryId);
    rank++;
    score.set(h.entryId, (score.get(h.entryId) ?? 0) + 1 / (K + rank));
  }

  const out: SearchHit[] = [];
  for (const [entryId, s] of score) {
    const card = a.cards.get(entryId);
    if (!card || card.retracted || superseded.has(entryId)) continue;
    out.push({ entryId, card, score: s * weight(card, now), chunkIds: chunks.get(entryId) ?? [] });
  }
  out.sort((x, y) => y.score - x.score || x.entryId.localeCompare(y.entryId));
  return out.slice(0, a.limit ?? 10);
}
