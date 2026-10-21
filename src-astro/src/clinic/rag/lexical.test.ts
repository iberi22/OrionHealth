import { describe, expect, it } from 'vitest';
import { createLexicalIndex, expandQuery, type MiniSearchCtor } from './lexical';

class FakeMini {
  static fromDocs: unknown[] = [];
  constructor(public opts: unknown) {}
  addAll(d: unknown[]) { FakeMini.fromDocs = d; }
  static loadJSON(_j: string, opts: unknown) { return new FakeMini(opts); }
  search(q: string) { return [{ id: q.includes('heart') ? 'e1' : 'e2', score: 3 }, { id: 'e3', score: 1 }]; }
}

describe('lexical', () => {
  it('expands es->en terms through the hook', () => {
    const q = expandQuery('insuficiencia cardiaca', (t) => (t === 'cardiaca' ? ['heart'] : []));
    expect(q).toBe('insuficiencia cardiaca heart');
  });
  it('searches with an injected MiniSearch and caps to 200', async () => {
    const idx = await createLexicalIndex(async () => FakeMini as unknown as MiniSearchCtor, { json: '{}' }, (t) => (t === 'cardiaca' ? ['heart'] : []));
    expect((await idx.search('cardiaca')).map((h) => h.entryId)).toEqual(['e1', 'e3']);
  });
});
