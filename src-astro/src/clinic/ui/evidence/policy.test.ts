import { describe, it, expect } from 'vitest';
import { isMetaOnly, licenceFamily, sourceHref } from './policy';

describe('licenceFamily', () => {
  it('classifies public domain and open licences', () => {
    expect(licenceFamily('Public domain')).toBe('public_domain');
    expect(licenceFamily('CC0 1.0')).toBe('open');
    expect(licenceFamily('CC-BY-4.0')).toBe('open');
  });
  it('treats unknown or restricted licences as restricted', () => {
    expect(licenceFamily('Publisher licence')).toBe('restricted');
    expect(licenceFamily(undefined)).toBe('restricted');
  });
});

describe('isMetaOnly', () => {
  it('uses the text policy when present, regardless of card.text', () => {
    expect(isMetaOnly({ text_policy: 'full', licence: 'Publisher licence' })).toBe(false);
    expect(isMetaOnly({ text_policy: 'metadata', licence: 'CC-BY-4.0' })).toBe(true);
    expect(isMetaOnly({ text_policy: 'quote' })).toBe(true);
  });
  it('falls back to the licence family when there is no text policy', () => {
    expect(isMetaOnly({ licence: 'Public domain' })).toBe(false);
    expect(isMetaOnly({ licence: 'CC-BY-4.0' })).toBe(false);
    expect(isMetaOnly({ licence: 'Publisher licence' })).toBe(true);
    expect(isMetaOnly({})).toBe(true);
  });
});

describe('sourceHref', () => {
  it('prefers the card URL and falls back to the external record link', () => {
    expect(sourceHref({ url: 'https://example.org/a' })).toBe('https://example.org/a');
    expect(sourceHref({ pmid: '123' })).toBe('https://pubmed.ncbi.nlm.nih.gov/123/');
    expect(sourceHref({})).toBeNull();
  });
});
