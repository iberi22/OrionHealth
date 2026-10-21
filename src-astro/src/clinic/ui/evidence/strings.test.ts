import { describe, it, expect } from 'vitest';
import { STRINGS, t } from './strings';

describe('strings', () => {
  it('es and en have identical keys', () => {
    expect(Object.keys(STRINGS.es).sort()).toEqual(Object.keys(STRINGS.en).sort());
  });
  it('no empty values', () => {
    for (const l of ['es', 'en'] as const) for (const v of Object.values(STRINGS[l])) expect(v.length).toBeGreaterThan(0);
  });
  it('t falls back to key', () => {
    expect(t('en', 'funding.public')).toBe('Public funding');
    expect(t('es', 'nope')).toBe('nope');
  });
});
