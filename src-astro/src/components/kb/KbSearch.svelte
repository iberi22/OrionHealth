<script lang="ts">
  import { onMount, tick } from 'svelte';
  import { getServices, setServices } from '../../lib/contracts/services';
  import { loadServices } from '../../lib/app/services';
  import type { KbHit, KbSystem } from '../../lib/contracts/types';
  import KbEntryView from './KbEntryView.svelte';

  const SYSTEMS: { id: KbSystem; label: string }[] = [
    { id: 'icd10', label: 'ICD-10' },
    { id: 'loinc', label: 'LOINC' },
    { id: 'rxnorm', label: 'RxNorm' },
    { id: 'snomed', label: 'SNOMED' },
    { id: 'guideline', label: 'Guías' },
    { id: 'interaction', label: 'Interacciones' },
    { id: 'symptom', label: 'Síntomas' },
  ];

  let query = $state('');
  let results = $state<KbHit[]>([]);
  let selectedSystem = $state<KbSystem | null>(null);
  let loading = $state(false);
  let activeId = $state<string | null>(null);
  let initialized = $state(false);
  let focusedIndex = $state(-1);
  let searchTimeout: ReturnType<typeof setTimeout> | null = null;
  let searchInput: HTMLInputElement;

  async function init() {
    try {
      getServices();
    } catch {
      setServices(await loadServices());
    }
    initialized = true;
    checkHash();
  }

  function checkHash() {
    const hash = window.location.hash;
    if (hash && hash.startsWith('#')) {
      activeId = hash.substring(1);
    } else {
      activeId = null;
    }
  }

  onMount(() => {
    init();
    const onHashChange = () => checkHash();
    window.addEventListener('hashchange', onHashChange);
    return () => window.removeEventListener('hashchange', onHashChange);
  });

  async function performSearch() {
    if (!initialized || !query.trim()) {
      results = [];
      focusedIndex = -1;
      loading = false;
      return;
    }
    loading = true;
    try {
      const services = getServices();
      results = await services.kb.search(query, {
        systems: selectedSystem ? [selectedSystem] : undefined,
      });
      focusedIndex = -1;
    } catch (e) {
      console.error(e);
      results = [];
    } finally {
      loading = false;
    }
  }

  function onInput() {
    if (searchTimeout) clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      performSearch();
    }, 150);
  }

  function onSystemSelect(systemId: KbSystem | null) {
    selectedSystem = systemId;
    performSearch();
  }

  function onKeyDown(e: KeyboardEvent) {
    if (!results.length) return;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      focusedIndex = (focusedIndex + 1) % results.length;
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      focusedIndex = focusedIndex <= 0 ? results.length - 1 : focusedIndex - 1;
    } else if (e.key === 'Enter' && focusedIndex >= 0 && focusedIndex < results.length) {
      e.preventDefault();
      const hit = results[focusedIndex];
      if (hit) {
        window.location.hash = hit.entry.id;
      }
    }
  }

  function highlight(text: string, q: string) {
    if (!q.trim()) return text;
    const regex = new RegExp(`(${q.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    // Using a simple replace since this is just text content
    return text.replace(regex, '<mark>$1</mark>');
  }

</script>

{#if !initialized}
  <div class="loading-state">Cargando servicios...</div>
{:else if activeId}
  <KbEntryView id={activeId} />
{:else}
  <div class="kb-search-container" data-testid="kb-search">
    <div class="search-header">
      <input
        type="search"
        class="search-input"
        placeholder="Buscar CIE-10, LOINC, medicamentos..."
        bind:value={query}
        oninput={onInput}
        onkeydown={onKeyDown}
        bind:this={searchInput}
        aria-label="Buscar en la base de conocimiento"
      />
      <div class="filters">
        <button
          class="filter-chip {selectedSystem === null ? 'active' : ''}"
          onclick={() => onSystemSelect(null)}
        >
          Todos
        </button>
        {#each SYSTEMS as sys}
          <button
            class="filter-chip {selectedSystem === sys.id ? 'active' : ''}"
            onclick={() => onSystemSelect(sys.id)}
          >
            {sys.label}
          </button>
        {/each}
      </div>
    </div>

    <div class="search-results" aria-live="polite">
      {#if loading}
        <div class="loading-state">Buscando...</div>
      {:else if query.trim() && results.length === 0}
        <div class="empty-state">No se encontraron resultados para "{query}".</div>
      {:else if results.length > 0}
        <ul class="results-list" role="listbox">
          {#each results as hit, i}
            <li
              class="result-item {i === focusedIndex ? 'focused' : ''}"
              role="option"
              aria-selected={i === focusedIndex}
            >
              <a href="#{hit.entry.id}" class="result-link" tabindex="-1">
                <div class="result-header">
                  <span class="system-badge system-{hit.entry.system}">{hit.entry.system.toUpperCase()}</span>
                  <span class="result-code">{hit.entry.code}</span>
                </div>
                <h3 class="result-title">{@html highlight(hit.entry.title, query)}</h3>
                <p class="result-body">{@html highlight(hit.entry.body, query)}</p>
              </a>
            </li>
          {/each}
        </ul>
      {/if}
    </div>

    <div class="disclaimer">
      Información de referencia; no reemplaza el consejo médico.
    </div>
  </div>
{/if}

<style>
  .kb-search-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 1rem;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    font-family: var(--oh-font-sans);
    color: var(--oh-text);
  }

  .search-header {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .search-input {
    width: 100%;
    padding: 0.75rem 1rem;
    font-size: 1rem;
    border: 2px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    background-color: var(--oh-surface);
    color: var(--oh-text);
    outline: none;
    transition: border-color 0.2s;
  }

  .search-input:focus {
    border-color: var(--oh-accent);
  }

  .filters {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .filter-chip {
    padding: 0.4rem 0.8rem;
    border: 1px solid var(--oh-muted);
    border-radius: 20px;
    background: transparent;
    color: var(--oh-text);
    font-size: 0.875rem;
    cursor: pointer;
    transition: all 0.2s;
  }

  .filter-chip:hover {
    background-color: var(--oh-surface);
  }

  .filter-chip.active {
    background-color: var(--oh-accent);
    color: white;
    border-color: var(--oh-accent);
  }

  .results-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .result-item {
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    background-color: var(--oh-surface);
    overflow: hidden;
    transition: border-color 0.2s, box-shadow 0.2s;
  }

  .result-item:hover, .result-item.focused {
    border-color: var(--oh-accent);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  /* Fallback outline for accessibility if border change isn't enough */
  .result-item:focus-within {
    outline: 2px solid var(--oh-accent);
    outline-offset: 2px;
  }

  .result-link {
    display: block;
    padding: 1rem;
    text-decoration: none;
    color: inherit;
  }

  .result-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
  }

  .system-badge {
    font-size: 0.75rem;
    font-weight: bold;
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    background-color: var(--oh-muted);
    color: white;
  }

  .system-icd10 { background-color: #ef4444; }
  .system-loinc { background-color: #3b82f6; }
  .system-rxnorm { background-color: #10b981; }
  .system-snomed { background-color: #8b5cf6; }

  .result-code {
    font-family: var(--oh-font-mono);
    font-size: 0.875rem;
    color: var(--oh-muted);
  }

  .result-title {
    margin: 0 0 0.5rem 0;
    font-size: 1.125rem;
  }

  .result-body {
    margin: 0;
    font-size: 0.875rem;
    color: var(--oh-muted);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  :global(mark) {
    background-color: var(--oh-accent-light);
    color: #000;
    padding: 0 2px;
    border-radius: 2px;
  }

  .loading-state, .empty-state {
    text-align: center;
    padding: 2rem;
    color: var(--oh-muted);
    font-style: italic;
  }

  .disclaimer {
    margin-top: 2rem;
    text-align: center;
    font-size: 0.75rem;
    color: var(--oh-muted);
  }
</style>
