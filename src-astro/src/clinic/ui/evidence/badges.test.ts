import { describe, it, expect } from 'vitest';
import { fundingBadge, coiBadge, levelLabel, ageWarning, externalLink, searchModeBadge, searchDegradedKey } from './badges';

describe('badges', () => {
  it('maps funding classes', () => {
    expect(fundingBadge('public')).toEqual({ key: 'funding.public', tone: 'ok' });
    expect(fundingBadge('nonprofit')).toEqual({ key: 'funding.nonprofit', tone: 'ok' });
    expect(fundingBadge('mixed')).toEqual({ key: 'funding.mixed', tone: 'amber' });
    expect(fundingBadge('unknown')).toEqual({ key: 'funding.unknown', tone: 'grey' });
    expect(fundingBadge('weird')).toEqual({ key: 'funding.unknown', tone: 'grey' });
  });
  it('never renders industry', () => {
    expect(fundingBadge('industry')).toBeNull();
  });
  it('maps coi', () => {
    expect(coiBadge('declared').tone).toBe('amber');
    expect(coiBadge('none_declared').key).toBe('coi.none');
    expect(coiBadge(undefined).key).toBe('coi.unknown');
  });
  it('labels levels', () => {
    expect(levelLabel({ scale: 'OCEBM-2011', level: 2, grade: 'B' })).toBe('L2 · GRADE B');
    expect(levelLabel({ scale: 'OCEBM-2011', level: 1, grade: null })).toBe('L1');
    expect(levelLabel({ scale: 'x', level: null, grade: null })).toBeNull();
    expect(levelLabel(null)).toBeNull();
  });
  it('age warning by doc type', () => {
    const now = new Date('2026-06-01');
    expect(ageWarning('guideline', '2020-01-01', now)).toBe(true);
    expect(ageWarning('guideline', '2022-01-01', now)).toBe(false);
    expect(ageWarning('rct', '2015-01-01', now)).toBe(true);
    expect(ageWarning('rct', '2020-01-01', now)).toBe(false);
    expect(ageWarning('rct', null, now)).toBe(false);
  });
  it('external links', () => {
    expect(externalLink({ pmid: '1' })).toBe('https://pubmed.ncbi.nlm.nih.gov/1/');
    expect(externalLink({ doi: '10.1/x' })).toBe('https://doi.org/10.1/x');
    expect(externalLink({ nct: 'NCT01' })).toBe('https://clinicaltrials.gov/study/NCT01');
    expect(externalLink({})).toBeNull();
  });
  it('maps search mode badge', () => {
    expect(searchModeBadge({ mode: 'lexical', degraded: null })).toEqual({ key: 'search.lexical', tone: 'grey' });
    expect(searchModeBadge({ mode: 'hybrid', degraded: null })).toEqual({ key: 'search.hybrid', tone: 'ok' });
    expect(searchModeBadge(undefined)).toBeNull();
  });
  it('flags degraded search only when set', () => {
    expect(searchDegradedKey({ mode: 'lexical', degraded: 'model-missing' })).toBe('search.degraded');
    expect(searchDegradedKey({ mode: 'lexical', degraded: null })).toBeNull();
    expect(searchDegradedKey(undefined)).toBeNull();
  });
});
