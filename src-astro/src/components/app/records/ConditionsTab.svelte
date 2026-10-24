<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { Condition, KbHit } from '../../../lib/contracts/types';
  import { onMount, onDestroy } from 'svelte';

  const services = getServices();
  let conditions = $state<Condition[]>([]);
  let owner = services.vault.memberId();

  // Form state
  let showForm = $state(false);
  let name = $state('');
  let since = $state('');
  let notes = $state('');
  let query = $state('');
  let hits = $state<KbHit[]>([]);
  let selectedIcd10 = $state<string | undefined>(undefined);

  async function load() {
    if (owner) {
      conditions = await services.records.list('condition', owner);
    }
  }

  let unsub: () => void;
  onMount(() => {
    load();
    unsub = services.records.onChange(() => {
      load();
    });
  });
  onDestroy(() => {
    if (unsub) unsub();
  });

  async function searchKb() {
    if (query.trim().length < 3) {
      hits = [];
      return;
    }
    hits = await services.kb.search(query, { systems: ['icd10'] });
  }

  function selectHit(hit: KbHit) {
    name = hit.entry.title;
    selectedIcd10 = hit.entry.code;
    query = '';
    hits = [];
  }

  async function save(e: Event) {
    e.preventDefault();
    if (!name.trim() || !owner) return;

    try {
      await services.records.put({
        recordId: crypto.randomUUID(),
        owner,
        updatedAt: Date.now(),
        kind: 'condition',
        name: name.trim(),
        icd10: selectedIcd10,
        since: since.trim() || undefined,
        notes: notes.trim() || undefined
      });

      showForm = false;
      name = '';
      since = '';
      notes = '';
      selectedIcd10 = undefined;
      query = '';
      hits = [];
    } catch (err) {
      console.error(err);
    }
  }
</script>

<div class="tab-pane">
  <div class="header">
    <h2>Condiciones médicas</h2>
    <button class="btn-primary" onclick={() => (showForm = !showForm)}>
      {showForm ? 'Cancelar' : 'Añadir'}
    </button>
  </div>

  {#if showForm}
    <form class="add-form" onsubmit={save}>
      <div class="form-group">
        <label for="kb-search">Buscar diagnóstico (ICD-10)</label>
        <input
          id="kb-search"
          type="text"
          bind:value={query}
          oninput={searchKb}
          placeholder="Ej. Hipertensión"
        />
        {#if hits.length > 0}
          <ul class="kb-results">
            {#each hits as hit}
              <li>
                <button type="button" onclick={() => selectHit(hit)}>
                  {hit.entry.title} ({hit.entry.code})
                </button>
              </li>
            {/each}
          </ul>
        {/if}
      </div>

      <div class="form-group">
        <label for="cond-name">Nombre de la condición *</label>
        <input id="cond-name" type="text" bind:value={name} required />
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="cond-since">Desde (año o fecha)</label>
          <input id="cond-since" type="text" bind:value={since} />
        </div>
      </div>

      <div class="form-group">
        <label for="cond-notes">Notas</label>
        <textarea id="cond-notes" bind:value={notes}></textarea>
      </div>

      <button type="submit" class="btn-submit">Guardar</button>
    </form>
  {/if}

  {#if conditions.length === 0}
    <p class="empty">No hay condiciones registradas.</p>
  {:else}
    <ul class="record-list">
      {#each conditions as cond}
        <li class="record-item">
          <div class="record-main">
            <strong>{cond.name}</strong>
            {#if cond.icd10}
              <span class="badge">{cond.icd10}</span>
            {/if}
          </div>
          {#if cond.since || cond.notes}
            <div class="record-details">
              {#if cond.since}<span>Desde: {cond.since}</span>{/if}
              {#if cond.notes}<span>{cond.notes}</span>{/if}
            </div>
          {/if}
        </li>
      {/each}
    </ul>
  {/if}
</div>

<style>
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }

  h2 {
    font-size: 1.25rem;
    color: var(--oh-text);
  }

  .btn-primary, .btn-submit {
    background-color: var(--oh-accent);
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font-weight: 600;
  }

  .btn-primary:hover, .btn-submit:hover {
    background-color: var(--oh-accent-dark);
  }

  .add-form {
    background-color: var(--oh-bg);
    padding: 1rem;
    border-radius: var(--oh-radius);
    margin-bottom: 1.5rem;
  }

  .form-group {
    margin-bottom: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .form-row {
    display: flex;
    gap: 1rem;
  }

  .form-row .form-group {
    flex: 1;
  }

  label {
    font-size: 0.875rem;
    color: var(--oh-muted);
  }

  input, textarea {
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background-color: var(--oh-surface);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
  }

  .kb-results {
    list-style: none;
    padding: 0;
    margin: 0.5rem 0 0 0;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    max-height: 150px;
    overflow-y: auto;
    background-color: var(--oh-surface);
  }

  .kb-results li button {
    width: 100%;
    text-align: left;
    padding: 0.5rem;
    border: none;
    background: none;
    color: var(--oh-text);
    cursor: pointer;
  }

  .kb-results li button:hover {
    background-color: var(--oh-bg);
  }

  .empty {
    color: var(--oh-muted);
    font-style: italic;
  }

  .record-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .record-item {
    background-color: var(--oh-bg);
    padding: 1rem;
    border-radius: var(--oh-radius);
  }

  .record-main {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.25rem;
  }

  .badge {
    background-color: var(--oh-secondary);
    color: white;
    font-size: 0.75rem;
    padding: 0.125rem 0.375rem;
    border-radius: 9999px;
  }

  .record-details {
    display: flex;
    flex-direction: column;
    font-size: 0.875rem;
    color: var(--oh-muted);
  }
</style>
