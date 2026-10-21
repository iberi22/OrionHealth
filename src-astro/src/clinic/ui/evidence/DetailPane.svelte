<script lang="ts">
  import { t, type Lang } from './strings';
  import type { EvidenceCardData } from './types';

  let { card, lang = 'es', onclose }: { card: EvidenceCardData; lang?: Lang; onclose?: () => void } = $props();
</script>

<aside class="pane" aria-label={card.title}>
  <header>
    <h2>{card.title}</h2>
    {#if onclose}<button type="button" onclick={onclose}>{t(lang, 'detail.close')}</button>{/if}
  </header>
  {#if card.retracted}<p class="alert" role="alert">⛔ {t(lang, 'detail.retracted')}</p>{/if}
  {#if card.supersedes}<p class="note">{t(lang, 'detail.supersedes')}: {card.supersedes}</p>{/if}
  {#if card.superseded_by}<p class="alert" role="alert">⚠ {t(lang, 'detail.superseded')}: {card.superseded_by}</p>{/if}
  <section>
    <h3>{t(lang, 'detail.text')}</h3>
    {#if card.text}<p class="text">{card.text}</p>{:else}<p class="note">{t(lang, 'detail.metaonly')}</p>{/if}
  </section>
  <section>
    <h3>{t(lang, 'detail.provenance')}</h3>
    <dl>
      {#if card.url}<dt>{t(lang, 'detail.url')}</dt><dd>{card.url}</dd>{/if}
      {#if card.retrieved_at}<dt>{t(lang, 'retrieved')}</dt><dd>{card.retrieved_at}</dd>{/if}
      {#if card.content_hash}<dt>{t(lang, 'detail.hash')}</dt><dd class="mono">{card.content_hash}</dd>{/if}
      {#if card.screenshot_url}<dt>{t(lang, 'detail.screenshot')}</dt><dd>{card.screenshot_url}</dd>{/if}
    </dl>
  </section>
</aside>

<style>
  .pane { display: grid; gap: 1rem; padding: 1rem; font-size: 1rem; }
  header { display: flex; justify-content: space-between; gap: 0.5rem; align-items: start; }
  header button { min-height: 44px; min-width: 44px; }
  h2, h3 { margin: 0; }
  .text { white-space: pre-wrap; }
  .alert { color: var(--swal-danger, #b91c1c); font-weight: 600; margin: 0; }
  .note { margin: 0; }
  dt { font-weight: 600; }
  dd { margin: 0 0 0.5rem; overflow-wrap: anywhere; }
  .mono { font-family: monospace; }
</style>
