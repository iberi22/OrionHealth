import type { Card, SearchResponse } from '../../rag/types';

export type Tone = 'ok' | 'amber' | 'grey';
export interface BadgeSpec { key: string; tone: Tone }
export type CoiStatus = 'declared' | 'none_declared' | 'unknown';

/** Industry records never reach the UI: returns null so callers drop them. */
export function fundingBadge(cls: string): BadgeSpec | null {
  switch (cls) {
    case 'industry': return null;
    case 'public': return { key: 'funding.public', tone: 'ok' };
    case 'nonprofit': return { key: 'funding.nonprofit', tone: 'ok' };
    case 'mixed': return { key: 'funding.mixed', tone: 'amber' };
    default: return { key: 'funding.unknown', tone: 'grey' };
  }
}

export function coiBadge(s: string | undefined | null): BadgeSpec {
  if (s === 'declared') return { key: 'coi.declared', tone: 'amber' };
  if (s === 'none_declared') return { key: 'coi.none', tone: 'ok' };
  return { key: 'coi.unknown', tone: 'grey' };
}

export function levelLabel(e: Card['evidence_level'] | undefined): string | null {
  if (!e || e.level == null || e.level < 1 || e.level > 5) return null;
  return e.grade ? `L${e.level} · GRADE ${e.grade}` : `L${e.level}`;
}

/** Guideline older than 5 y or any other record older than 10 y. */
export function ageWarning(docType: string, published: string | null, now: Date = new Date()): boolean {
  if (!published) return false;
  const d = new Date(published);
  if (Number.isNaN(d.getTime())) return false;
  const years = (now.getTime() - d.getTime()) / (365.25 * 24 * 3600 * 1000);
  return years > (/guideline/i.test(docType) ? 5 : 10);
}

export function externalLink(ids: { pmid?: string; doi?: string; nct?: string }): string | null {
  if (ids.pmid) return `https://pubmed.ncbi.nlm.nih.gov/${encodeURIComponent(ids.pmid)}/`;
  if (ids.doi) return `https://doi.org/${ids.doi}`;
  if (ids.nct) return `https://clinicaltrials.gov/study/${encodeURIComponent(ids.nct)}`;
  return null;
}

/** Search mode from SearchResponse (lexical or hybrid). Null when no response is known. */
export function searchModeBadge(info: Pick<SearchResponse, 'mode' | 'degraded'> | null | undefined): BadgeSpec | null {
  if (!info) return null;
  return info.mode === 'hybrid' ? { key: 'search.hybrid', tone: 'ok' } : { key: 'search.lexical', tone: 'grey' };
}

/** Key of the degraded-search notice, only when the response reports a degradation. */
export function searchDegradedKey(info: Pick<SearchResponse, 'mode' | 'degraded'> | null | undefined): string | null {
  return info?.degraded ? 'search.degraded' : null;
}
