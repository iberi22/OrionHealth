import type { Card } from '../../rag/types';

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
  content_hash?: string;
  screenshot_url?: string;
}
