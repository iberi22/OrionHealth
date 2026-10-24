<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { Medication } from '../../../lib/contracts/types';
  import { onMount, onDestroy } from 'svelte';

  const services = getServices();
  let medications = $state<Medication[]>([]);
  let owner = services.vault.memberId();

  let showForm = $state(false);
  let editingId = $state<string | undefined>(undefined);
  let name = $state('');
  let dose = $state('');
  let schedule = $state('');

  async function load() {
    if (owner) {
      medications = await services.records.list('medication', owner);
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

  async function save(e: Event) {
    e.preventDefault();
    if (!name.trim() || !dose.trim() || !schedule.trim() || !owner) return;

    try {
      const existing = medications.find(m => m.recordId === editingId);
      await services.records.put({
        recordId: editingId || crypto.randomUUID(),
        owner,
        updatedAt: Date.now(),
        kind: 'medication',
        name: name.trim(),
        dose: dose.trim(),
        schedule: schedule.trim(),
        active: existing ? existing.active : true,
        takenLog: existing ? existing.takenLog : []
      });

      showForm = false;
      editingId = undefined;
      name = '';
      dose = '';
      schedule = '';
    } catch (err) {
      console.error(err);
    }
  }

  function editRecord(med: Medication) {
    editingId = med.recordId;
    name = med.name;
    dose = med.dose;
    schedule = med.schedule;
    showForm = true;
  }

  async function deleteRecord(med: Medication) {
    if (!owner) return;
    try {
      await services.records.remove('medication', med.recordId);
    } catch (err) {
      console.error(err);
    }
  }

  async function markTaken(med: Medication) {
    try {
      await services.records.put({
        ...med,
        takenLog: [...(med.takenLog || []), Date.now()],
        updatedAt: Date.now()
      });
    } catch (err) {
      console.error(err);
    }
  }

  function isTakenRecently(log?: number[]) {
    if (!log || log.length === 0) return false;
    const last = log[log.length - 1];
    // Consider taken recently if within the last 12 hours
    return Date.now() - last < 12 * 60 * 60 * 1000;
  }
</script>

<div class="tab-pane">
  <div class="header">
    <h2>Medicamentos</h2>
    <button class="btn-primary" onclick={() => (showForm = !showForm)}>
      {showForm ? 'Cancelar' : 'Añadir'}
    </button>
  </div>

  {#if showForm}
    <form class="add-form" onsubmit={save}>
      <div class="form-group">
        <label for="med-name">Nombre del medicamento *</label>
        <input id="med-name" type="text" bind:value={name} required />
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="med-dose">Dosis *</label>
          <input id="med-dose" type="text" bind:value={dose} placeholder="Ej. 50 mg" required />
        </div>
        <div class="form-group">
          <label for="med-schedule">Horario *</label>
          <input id="med-schedule" type="text" bind:value={schedule} placeholder="Ej. Cada 8 horas" required />
        </div>
      </div>

      <button type="submit" class="btn-submit">Guardar</button>
    </form>
  {/if}

  {#if medications.length === 0}
    <p class="empty">No hay medicamentos registrados.</p>
  {:else}
    <ul class="record-list">
      {#each medications as med}
        <li class="record-item">
          <div class="med-info">
            <div class="record-main">
              <strong>{med.name}</strong>
              {#if !med.active}
                <span class="badge inactive">Inactivo</span>
              {/if}
            </div>
            <div class="record-details">
              <span>Dosis: {med.dose}</span>
              <span>Horario: {med.schedule}</span>
            </div>
          </div>
          <div class="med-actions">
            <button
              class="btn-outline"
              disabled={isTakenRecently(med.takenLog)}
              onclick={() => markTaken(med)}
            >
              {isTakenRecently(med.takenLog) ? 'Tomado hoy' : 'Marcar como tomado'}
            </button>
            <div class="record-actions">
              <button data-testid="edit-medication-{med.recordId}" onclick={() => editRecord(med)}>Editar</button>
              <button data-testid="delete-medication-{med.recordId}" onclick={() => deleteRecord(med)}>Eliminar</button>
            </div>
          </div>
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

  .btn-outline {
    background-color: transparent;
    color: var(--oh-accent-dark);
    border: 1px solid var(--oh-accent-dark);
    padding: 0.5rem 1rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font-weight: 600;
  }

  .btn-outline:hover:not(:disabled) {
    background-color: var(--oh-surface);
  }

  .btn-outline:disabled {
    color: var(--oh-muted);
    border-color: var(--oh-muted);
    cursor: not-allowed;
    opacity: 0.7;
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

  input {
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
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 1rem;
    flex-wrap: wrap;
  }

  .record-main {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.25rem;
  }

  .badge.inactive {
    background-color: var(--oh-muted);
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

  .med-actions {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .record-actions {
    display: flex;
    gap: 0.5rem;
  }

  .record-actions button {
    background: none;
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 0.25rem 0.5rem;
    cursor: pointer;
    font-size: 0.75rem;
    color: var(--oh-text);
  }
</style>
