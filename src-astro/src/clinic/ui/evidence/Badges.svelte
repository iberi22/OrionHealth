<script lang="ts">
  import { fundingBadge, coiBadge, levelLabel } from './badges';
  import { t, type Lang } from './strings';
  import type { EvidenceCardData } from './types';

  let { card, lang = 'es' }: { card: EvidenceCardData; lang?: Lang } = $props();
  const funding = $derived(fundingBadge(card.funding_class));
  const coi = $derived(coiBadge(card.coi?.status));
  const level = $derived(levelLabel(card.evidence_level));
  let coiOpen = $state(false);
</script>

<div class="badges">
  {#if card.source_label ?? card.source}<span class="b grey">{card.source_label ?? card.source}</span>{/if}
  <span class="b grey">{card.doc_type}</span>
  {#if level}<span class="b ok" aria-label={`${t(lang, 'level')}: ${level}`}>{level}</span>{/if}
  {#if funding}<span class={`b ${funding.tone}`}>{t(lang, funding.key)}</span>{/if}
  {#if card.coi?.status === 'declared' && card.coi.text}
    <button type="button" class={`b ${coi.tone}`} aria-expanded={coiOpen} onclick={() => (coiOpen = !coiOpen)}>{t(lang, coi.key)}</button>
  {:else}
    <span class={`b ${coi.tone}`}>{t(lang, coi.key)}</span>
  {/if}
</div>
{#if coiOpen && card.coi?.text}<p class="coi">{card.coi.text}</p>{/if}

<style>
  .badges { display: flex; flex-wrap: wrap; gap: 0.5rem; }
  .b { display: inline-flex; align-items: center; min-height: 44px; padding: 0 0.75rem; border-radius: 999px; font-size: 1rem; border: 1px solid currentColor; background: transparent; }
  button.b { cursor: pointer; font: inherit; }
  .ok { color: var(--swal-success, #15803d); }
  .amber { color: var(--swal-warning, #b45309); }
  .grey { color: var(--swal-text-muted, #52525b); }
  .coi { font-size: 1rem; white-space: pre-wrap; }
</style>
