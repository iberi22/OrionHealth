<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { Allergy, Appointment } from '../../../lib/contracts/types';
  import { onMount, onDestroy } from 'svelte';

  let { tab } = $props<{ tab: 'allergies' | 'appointments' }>();

  const services = getServices();
  let allergies = $state<Allergy[]>([]);
  let appointments = $state<Appointment[]>([]);
  let owner = services.vault.memberId();

  let showForm = $state(false);

  // Allergy form state
  let substance = $state('');
  let severity = $state<'mild' | 'moderate' | 'severe'>('mild');
  let reaction = $state('');

  // Appointment form state
  let title = $state('');
  let atStr = $state('');
  let place = $state('');
  let appNotes = $state('');

  async function load() {
    if (owner) {
      if (tab === 'allergies') {
        allergies = await services.records.list('allergy', owner);
      } else {
        appointments = await services.records.list('appointment', owner);
        appointments.sort((a, b) => b.at - a.at);
      }
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

  // Re-load if tab changes
  $effect(() => {
    tab;
    showForm = false;
    load();
  });

  async function saveAllergy(e: Event) {
    e.preventDefault();
    if (!substance.trim() || !owner) return;
    try {
      await services.records.put({
        recordId: crypto.randomUUID(),
        owner,
        updatedAt: Date.now(),
        kind: 'allergy',
        substance: substance.trim(),
        severity,
        reaction: reaction.trim() || undefined
      });
      showForm = false;
      substance = '';
      severity = 'mild';
      reaction = '';
    } catch (err) {
      console.error(err);
    }
  }

  async function saveAppointment(e: Event) {
    e.preventDefault();
    if (!title.trim() || !atStr || !owner) return;

    const timestamp = new Date(atStr).getTime();
    if (isNaN(timestamp)) {
      alert('Fecha inválida');
      return;
    }

    try {
      await services.records.put({
        recordId: crypto.randomUUID(),
        owner,
        updatedAt: Date.now(),
        kind: 'appointment',
        title: title.trim(),
        at: timestamp,
        place: place.trim() || undefined,
        notes: appNotes.trim() || undefined
      });
      showForm = false;
      title = '';
      atStr = '';
      place = '';
      appNotes = '';
    } catch (err) {
      console.error(err);
    }
  }

  const severityLabels: Record<Allergy['severity'], string> = {
    mild: 'Leve',
    moderate: 'Moderada',
    severe: 'Severa'
  };
</script>

<div class="tab-pane">
  <div class="header">
    <h2>{tab === 'allergies' ? 'Alergias' : 'Citas médicas'}</h2>
    <button class="btn-primary" onclick={() => (showForm = !showForm)}>
      {showForm ? 'Cancelar' : 'Añadir'}
    </button>
  </div>

  {#if tab === 'allergies'}
    {#if showForm}
      <form class="add-form" onsubmit={saveAllergy}>
        <div class="form-group">
          <label for="al-substance">Sustancia o alérgeno *</label>
          <input id="al-substance" type="text" bind:value={substance} required />
        </div>
        <div class="form-row">
          <div class="form-group">
            <label for="al-severity">Severidad</label>
            <select id="al-severity" bind:value={severity}>
              <option value="mild">Leve</option>
              <option value="moderate">Moderada</option>
              <option value="severe">Severa</option>
            </select>
          </div>
          <div class="form-group">
            <label for="al-reaction">Reacción</label>
            <input id="al-reaction" type="text" bind:value={reaction} placeholder="Ej. Urticaria" />
          </div>
        </div>
        <button type="submit" class="btn-submit">Guardar</button>
      </form>
    {/if}

    {#if allergies.length === 0}
      <p class="empty">No hay alergias registradas.</p>
    {:else}
      <ul class="record-list">
        {#each allergies as al}
          <li class="record-item">
            <div class="record-main">
              <strong>{al.substance}</strong>
              <span class="badge" class:severe={al.severity === 'severe'} class:moderate={al.severity === 'moderate'}>
                {severityLabels[al.severity]}
              </span>
            </div>
            {#if al.reaction}
              <div class="record-details">Reacción: {al.reaction}</div>
            {/if}
          </li>
        {/each}
      </ul>
    {/if}
  {:else if tab === 'appointments'}
    {#if showForm}
      <form class="add-form" onsubmit={saveAppointment}>
        <div class="form-group">
          <label for="app-title">Motivo de consulta / Título *</label>
          <input id="app-title" type="text" bind:value={title} required />
        </div>
        <div class="form-row">
          <div class="form-group">
            <label for="app-at">Fecha y hora *</label>
            <input id="app-at" type="datetime-local" bind:value={atStr} required />
          </div>
          <div class="form-group">
            <label for="app-place">Lugar</label>
            <input id="app-place" type="text" bind:value={place} />
          </div>
        </div>
        <div class="form-group">
          <label for="app-notes">Notas</label>
          <textarea id="app-notes" bind:value={appNotes}></textarea>
        </div>
        <button type="submit" class="btn-submit">Guardar</button>
      </form>
    {/if}

    {#if appointments.length === 0}
      <p class="empty">No hay citas registradas.</p>
    {:else}
      <ul class="record-list">
        {#each appointments as app}
          <li class="record-item">
            <div class="record-main">
              <strong>{app.title}</strong>
              <span class="badge info">{new Date(app.at).toLocaleString()}</span>
            </div>
            {#if app.place || app.notes}
              <div class="record-details">
                {#if app.place}<span>Lugar: {app.place}</span>{/if}
                {#if app.notes}<span>{app.notes}</span>{/if}
              </div>
            {/if}
          </li>
        {/each}
      </ul>
    {/if}
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

  input, select, textarea {
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background-color: var(--oh-surface);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
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
    flex-wrap: wrap;
  }

  .badge {
    background-color: var(--oh-accent-light);
    color: #000;
    font-size: 0.75rem;
    padding: 0.125rem 0.375rem;
    border-radius: 9999px;
  }

  .badge.moderate {
    background-color: orange;
    color: white;
  }

  .badge.severe {
    background-color: var(--oh-danger);
    color: white;
  }

  .badge.info {
    background-color: var(--oh-secondary);
    color: white;
  }

  .record-details {
    display: flex;
    flex-direction: column;
    font-size: 0.875rem;
    color: var(--oh-muted);
  }
</style>
