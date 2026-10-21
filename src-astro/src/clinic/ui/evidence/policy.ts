import type { EvidenceCardData } from './types';
import { externalLink } from './badges';

export type LicenceFamily = 'public_domain' | 'open' | 'restricted';

/** Coarse licence family from the free-text licence label. Unknown labels are restricted (safe default). */
export function licenceFamily(licence: string | null | undefined): LicenceFamily {
  const l = (licence ?? '').trim().toLowerCase();
  if (/public[\s_-]?domain|\bpd\b/.test(l)) return 'public_domain';
  if (/\bcc0\b|\bcc[\s-]?by\b/.test(l)) return 'open';
  return 'restricted';
}

/**
 * True when only metadata may be shown. An explicit text policy wins;
 * otherwise the licence family decides (public domain and open licences permit text).
 */
export function isMetaOnly(card: Pick<EvidenceCardData, 'text_policy' | 'licence'>): boolean {
  if (card.text_policy) return card.text_policy !== 'full';
  return licenceFamily(card.licence) === 'restricted';
}

/** Source URL shown in the card: the record URL, else the external record link derived from ids. */
export function sourceHref(card: Pick<EvidenceCardData, 'url' | 'pmid' | 'doi' | 'nct'>): string | null {
  return card.url ?? externalLink(card);
}
