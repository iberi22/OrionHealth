import type { Card, SearchResponse } from '../../rag/types';

/** Search mode of the response that produced a card (from SearchResponse). */
export type SearchModeInfo = Pick<SearchResponse, 'mode' | 'degraded'>;

/** Card plus the optional display fields the evidence UI can show. */
export interface EvidenceCardData extends Card {
  source_label?: string;
  coi?: { status: 'declared' | 'none_declared' | 'unknown'; text?: string };
  retrieved_at?: string;
  licence?: string;
  authors?: string[];
  journal?: string;
  volume?: string;
  issue?: string;
  pages?: string;
  pmid?: string;
  doi?: string;
  nct?: string;
  snippet?: string;
  /** Substrings of the snippet to highlight. */
  highlights?: string[];
  why?: string;
  superseded_by?: string | null;
  /** Permitted full text; absent when the licence is metadata-only. */
  text?: string;
  /** Text policy of the record: full text, quote only, or metadata only. Falls back to the licence family when absent. */
  text_policy?: 'full' | 'quote' | 'metadata';
  content_hash?: string;
  screenshot_url?: string;
  /** Publisher or agency that issued the record. */
  issuer?: string;
  /** ISO 3166-1 alpha-2 country code of the issuer. */
  country?: string;
  /** Verbatim extract (capped to 50 words); shown instead of the snippet for metadata-only cards. */
  quote?: string;
  /** Character ranges [start, end) of `snippet` to highlight (preferred over `highlights` terms). */
  highlightRanges?: [number, number][];
}
