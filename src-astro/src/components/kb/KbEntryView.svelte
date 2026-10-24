<script lang="ts">
  import { onMount } from 'svelte';
  import { getServices } from '../../lib/contracts/services';
  import type { KbEntry } from '../../lib/contracts/types';

  let { id } = $props<{ id: string }>();

  let entry = $state<KbEntry | null>(null);
  let loading = $state(true);
  let error = $state(false);

  $effect(() => {
    let currentId = id;
    if (currentId) {
      loadEntry(currentId);
    }
  });

  async function loadEntry(entryId: string) {
    loading = true;
    error = false;
    entry = null;
    try {
      const services = getServices();
      const loaded = await services.kb.get(entryId);
      if (loaded) {
        entry = loaded;
      } else {
        error = true;
      }
    } catch (e) {
      console.error('Failed to load entry:', e);
      error = true;
    } finally {
      loading = false;
    }
  }

  function goBack() {
    window.location.hash = '';
  }
</script>

<div class="kb-entry-view" data-testid="kb-entry-view">
  <button class="back-button" onclick={goBack} aria-label="Volver a los resultados">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="19" y1="12" x2="5" y2="12"></line>
      <polyline points="12 19 5 12 12 5"></polyline>
    </svg>
    Volver
  </button>

  {#if loading}
    <div class="loading-state">Cargando...</div>
  {:else if error || !entry}
    <div class="error-state">No se pudo cargar la entrada de la base de conocimiento.</div>
  {:else}
    <article class="entry-content">
      <header class="entry-header">
        <div class="meta">
          <span class="system-badge system-{entry.system}">{entry.system.toUpperCase()}</span>
          <span class="code">{entry.code}</span>
        </div>
        <h1 class="title">{entry.title}</h1>
      </header>

      <div class="body">
        {entry.body}
      </div>

      {#if entry.related && entry.related.length > 0}
        <section class="related">
          <h2>Relacionados</h2>
          <ul class="related-list">
            {#each entry.related as rel}
              <li>
                <a href="#{rel}">{rel}</a>
              </li>
            {/each}
          </ul>
        </section>
      {/if}
    </article>
  {/if}
</div>

<style>
  .kb-entry-view {
    max-width: 800px;
    margin: 0 auto;
    padding: 1rem;
    font-family: var(--oh-font-sans);
    color: var(--oh-text);
  }

  .back-button {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: transparent;
    border: none;
    color: var(--oh-accent);
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    margin-bottom: 2rem;
    border-radius: var(--oh-radius);
    transition: background-color 0.2s;
  }

  .back-button:hover, .back-button:focus-visible {
    background-color: var(--oh-surface);
    outline: none;
  }

  .back-button:focus-visible {
    box-shadow: 0 0 0 2px var(--oh-accent);
  }

  .entry-header {
    margin-bottom: 2rem;
  }

  .meta {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
  }

  .system-badge {
    font-size: 0.875rem;
    font-weight: bold;
    padding: 0.25rem 0.75rem;
    border-radius: 4px;
    background-color: var(--oh-muted);
    color: white;
  }

  .system-icd10 { background-color: #ef4444; }
  .system-loinc { background-color: #3b82f6; }
  .system-rxnorm { background-color: #10b981; }
  .system-snomed { background-color: #8b5cf6; }

  .code {
    font-family: var(--oh-font-mono);
    font-size: 1rem;
    color: var(--oh-muted);
  }

  .title {
    font-size: 2rem;
    margin: 0;
    line-height: 1.2;
  }

  .body {
    font-size: 1.125rem;
    line-height: 1.6;
    margin-bottom: 2.5rem;
  }

  .related {
    border-top: 1px solid var(--oh-muted);
    padding-top: 1.5rem;
  }

  .related h2 {
    font-size: 1.25rem;
    margin: 0 0 1rem 0;
  }

  .related-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .related-list a {
    color: var(--oh-secondary);
    text-decoration: none;
    font-family: var(--oh-font-mono);
  }

  .related-list a:hover {
    text-decoration: underline;
  }

  .loading-state, .error-state {
    text-align: center;
    padding: 3rem;
    color: var(--oh-muted);
    font-style: italic;
  }

  .error-state {
    color: var(--oh-danger);
    font-style: normal;
  }
</style>
