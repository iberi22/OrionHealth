<script lang="ts">
  import Badges from './Badges.svelte';
  import { ageWarning, externalLink } from './badges';
  import { vancouver } from './citation';
  import { highlightSegments } from './snippet';
  import { t, type Lang } from './strings';
  import type { EvidenceCardData } from './types';

  let { card, lang = 'es', online = true, onselect }: {
    card: EvidenceCardData; lang?: Lang; online?: boolean; onselect?: (id: string) => void;
  } = $props();

  const old = $derived(ageWarning(card.doc_type, card.published));
  const link = $derived(externalLink(card));
  const citation = $derived(vancouver({
    authors: card.authors, title: card.title, journal: card.journal,
    year: card.published?.slice(0, 4), volume: card.volume, issue: card.issue, pages: card.pages,
    pmid: card.pmid, doi: card.doi, nct: card.nct,
  }));
  const segs = $derived(card.snippet ? highlightSegments(card.snippet, card.highlights) : []);
  let copied = $state(false);

  async function copy() {
    try { await navigator.clipboard.writeText(citation); copied = true; setTimeout(() => (copied = false), 1500); } catch { /* clipboard unavailable */ }
  }
</script>

{#if card.funding_class !== 'industry'}
<article class="card">
  <h3><button type="button" class="title" onclick={() => onselect?.(card.id)}>{card.title}</button></h3>
  <Badges {card} {lang} />
  <p class="meta">
    {#if card.published}{t(lang, 'published')}: {card.published}{/if}
    {#if card.retrieved_at} · {t(lang, 'retrieved')}: {card.retrieved_at.slice(0, 10)}{/if}
    {#if card.licence} · <span class="chip">{t(lang, 'licence')}: {card.licence}</span>{/if}
  </p>
  {#if old}<p class="warn">⚠ {t(lang, /guideline/i.test(card.doc_type) ? 'age.guideline' : 'age.study')}</p>{/if}
  {#if segs.length}
    <p class="snippet">{#each segs as s}{#if s.hit}<mark>{s.text}</mark>{:else}{s.text}{/if}{/each}</p>
  {/if}
  {#if card.why}<p class="why"><strong>{t(lang, 'why')}:</strong> {card.why}</p>{/if}
  <p class="cite"><strong>{t(lang, 'citation')}:</strong> {citation}</p>
  <div class="actions">
    <button type="button" onclick={copy}>{copied ? t(lang, 'copied') : t(lang, 'copy')}</button>
    {#if link}
      {#if online}
        <a href={link} target="_blank" rel="noopener noreferrer">{t(lang, 'link')}</a>
      {:else}
        <button type="button" disabled title={t(lang, 'link.offline')}>{t(lang, 'link.offline')}</button>
      {/if}
    {/if}
  </div>
</article>
{/if}

<style>
  .card { border: 1px solid var(--swal-border, #d4d4d8); border-radius: 0.75rem; padding: 1rem; display: grid; gap: 0.5rem; font-size: 1rem; }
  h3 { margin: 0; }
  .title { all: unset; cursor: pointer; font-weight: 600; min-height: 44px; display: inline-flex; align-items: center; }
  .meta, .snippet, .why, .cite { margin: 0; }
  .warn { margin: 0; color: var(--swal-warning, #b45309); }
  .chip { border: 1px solid currentColor; border-radius: 999px; padding: 0.1rem 0.5rem; }
  mark { background: var(--swal-highlight, #fde68a); color: inherit; }
  .actions { display: flex; gap: 0.5rem; flex-wrap: wrap; }
  .actions button, .actions a { min-height: 44px; min-width: 44px; display: inline-flex; align-items: center; padding: 0 1rem; }
</style>
