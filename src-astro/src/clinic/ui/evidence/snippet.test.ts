import { describe, it, expect } from 'vitest';
import { clampQuote, rangeSegments } from './snippet';

describe('clampQuote', () => {
  it('keeps short quotes verbatim (trimmed)', () => {
    expect(clampQuote('  Aspirin reduces risk.  ')).toBe('Aspirin reduces risk.');
  });
  it('truncates beyond 50 words with an ellipsis', () => {
    const q = Array.from({ length: 60 }, (_, i) => `w${i}`).join(' ');
    const out = clampQuote(q)!;
    expect(out.split(' ')).toHaveLength(50);
    expect(out.endsWith('w49…')).toBe(true);
  });
  it('returns null for empty input', () => {
    expect(clampQuote('   ')).toBeNull();
  });
});

describe('rangeSegments', () => {
  it('splits a single range', () => {
    expect(rangeSegments('abcdef', [[1, 3]])).toEqual([
      { text: 'a', hit: false }, { text: 'bc', hit: true }, { text: 'def', hit: false },
    ]);
  });
  it('merges overlapping and unsorted ranges', () => {
    expect(rangeSegments('abcdef', [[3, 5], [1, 4]])).toEqual([
      { text: 'a', hit: false }, { text: 'bcde', hit: true }, { text: 'f', hit: false },
    ]);
  });
  it('clamps out-of-range and ignores invalid ranges', () => {
    expect(rangeSegments('abcdef', [[4, 99], [5, 5], [NaN, 2]])).toEqual([
      { text: 'abcd', hit: false }, { text: 'ef', hit: true },
    ]);
  });
  it('returns the whole text when there are no ranges', () => {
    expect(rangeSegments('abc')).toEqual([{ text: 'abc', hit: false }]);
  });
});
