import { describe, expect, it, vi } from 'vitest';
import { applyGrounding } from './grounding';
import { browserTiers } from './tiers';

const flagged = (claim: string, passage: string) => {
  const a = applyGrounding(`${claim} [1]`, [{ text: passage, funding_class: 'public' }]);
  if (a.kind !== 'generated') throw new Error('not generated');
  return a.sentences[0].flags.includes('numeric-unverified');
};

describe('dose literal numbers', () => {
  it('5,5 equals 5.5', () => expect(flagged('Give 5,5 mg', 'Dose 5.5 mg daily')).toBe(false));
  it('1,000 mg vs 1 mg flagged', () => expect(flagged('Give 1,000 mg', 'Dose 1 mg')).toBe(true));
  it('1 mg vs 1.000 mg flagged', () => expect(flagged('Give 1 mg', 'Dose 1.000 mg')).toBe(true));
  it('2.50 vs 2.5 flagged (safe)', () => expect(flagged('Give 2.50 mg', 'Dose 2.5 mg')).toBe(true));
  it('same number supported', () => expect(flagged('Give 500 mg', 'Dose 500 mg')).toBe(false));
});

describe('dose denominators', () => {
  it('mg/kg vs mg/day flagged', () => expect(flagged('Give 5 mg/kg', 'Give 5 mg/day')).toBe(true));
  it('mg/kg matches mg/kg', () => expect(flagged('Give 5 mg/kg', 'Give 5 mg/kg')).toBe(false));
  it('mg/día matches mg/ día', () => expect(flagged('Dar 5 mg/día', 'Dar 5 mg/ día')).toBe(false));
  it('mg/h vs mg/min flagged', () => expect(flagged('5 mg/h', '5 mg/min')).toBe(true));
});

describe('browserTiers kill switch', () => {
  it('does not call requestAdapter when AI off', async () => {
    const requestAdapter = vi.fn();
    vi.stubGlobal('navigator', { gpu: { requestAdapter } });
    const off = { getItem: () => null, setItem: () => {} };
    const t = await browserTiers('en', off);
    expect(requestAdapter).not.toHaveBeenCalled();
    expect(t.webllm?.capable).toBe(false);
    vi.unstubAllGlobals();
  });
});
