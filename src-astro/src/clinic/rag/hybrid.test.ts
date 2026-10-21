import { describe, expect, it } from 'vitest';
import { hybridSearch } from './hybrid';
import type { Card } from './types';

const now = new Date('2026-06-01');
const card = (id: string, o: Partial<Card> = {}): Card => ({
  id, title: id, doc_type: 'trial_results', published: '2025-01-01', funding_class: 'public',
  retracted: false, supersedes: null, ...o,
});

describe('hybrid RRF', () => {
  it('fuses dense and lexical with k=60 and groups by entry', () => {
    const cards = new Map([card('a'), card('b'), card('c')].map((c) => [c.id, c]));
    const dense = [{ entryId: 'a', chunkId: 'a1' }, { entryId: 'a', chunkId: 'a2' }, { entryId: 'b', chunkId: 'b1' }];
    const lexical = [{ entryId: 'b' }, { entryId: 'c' }];
    const out = hybridSearch({ dense, lexical, cards, now });
    expect(out.map((h) => h.entryId)).toEqual(['b', 'a', 'c']);
    expect(out[0].score).toBeCloseTo(1 / 62 + 1 / 61, 10);
    expect(out[1].chunkIds).toEqual(['a1', 'a2']);
  });

  it('applies weights', () => {
    const cards = new Map([
      card('p'), card('m', { funding_class: 'mixed' }), card('u', { funding_class: 'unknown' }),
      card('g', { doc_type: 'guideline', published: '2015-01-01' }),
    ].map((c) => [c.id, c]));
    const lexical = ['p', 'm', 'u', 'g'].map((entryId) => ({ entryId }));
    const out = hybridSearch({ dense: [], lexical, cards, now });
    const s = Object.fromEntries(out.map((h) => [h.entryId, h.score]));
    expect(s.m).toBeCloseTo((1 / 62) * 0.85, 10);
    expect(s.u).toBeCloseTo((1 / 63) * 0.9, 10);
    expect(s.g).toBeCloseTo((1 / 64) * 0.9, 10);
  });

  it('drops retracted and superseded entries', () => {
    const cards = new Map([
      card('old'), card('new', { supersedes: 'old' }), card('bad', { retracted: true }), card('ok'),
    ].map((c) => [c.id, c]));
    const lexical = ['old', 'new', 'bad', 'ok'].map((entryId) => ({ entryId }));
    const out = hybridSearch({ dense: [], lexical, cards, now });
    expect(out.map((h) => h.entryId).sort()).toEqual(['new', 'ok']);
  });

  it('returns at most 10 cards', () => {
    const ids = Array.from({ length: 30 }, (_, i) => `e${i}`);
    const cards = new Map(ids.map((i) => [i, card(i)]));
    expect(hybridSearch({ dense: [], lexical: ids.map((entryId) => ({ entryId })), cards, now })).toHaveLength(10);
  });
});
