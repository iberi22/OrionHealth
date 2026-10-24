<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { CircleState, Initiative, CheckIn, CircleNote } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';
  import InitiativeForm from './InitiativeForm.svelte';
  import InitiativeCard from './InitiativeCard.svelte';
  import HabitsPanel from './HabitsPanel.svelte';

  let circle = $state<CircleState | null>(null);
  let initiatives = $state<Initiative[]>([]);
  let checkIns = $state<CheckIn[]>([]);
  let notes = $state<CircleNote[]>([]);

  let showForm = $state(false);

  async function loadData() {
    circle = await getServices().family.circle();
    if (!circle) return;

    initiatives = await getServices().health.list('initiative');
    checkIns = await getServices().health.list('checkin');
    notes = await getServices().health.list('note');
  }

  onMount(() => {
    loadData();
    const unsubHealth = getServices().health.onChange(loadData);
    const unsubFamily = getServices().family.onChange(loadData);
    return () => {
      unsubHealth();
      unsubFamily();
    };
  });
</script>

<section data-testid="area-family-health" class="health-circle-area">
  <header>
    <h1>Salud familiar</h1>
    <button class="add-btn" onclick={() => (showForm = !showForm)}>
      {showForm ? 'Cancelar' : '+ Nueva Iniciativa'}
    </button>
  </header>

  {#if !circle}
    <p>Cargando círculo familiar...</p>
  {:else}
    {#if showForm}
      <InitiativeForm circle={circle} onCreated={() => (showForm = false)} />
    {/if}

    <div class="initiatives-list">
      {#if initiatives.length === 0}
        <p class="empty">No hay iniciativas activas.</p>
      {/if}
      {#each initiatives as ini}
        <InitiativeCard initiative={ini} circle={circle} allCheckIns={checkIns} allNotes={notes} />
      {/each}
    </div>

    <HabitsPanel />
  {/if}
</section>

<style>
  .health-circle-area {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    padding-bottom: 2rem;
  }
  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  h1 {
    margin: 0;
  }
  .add-btn {
    background: var(--oh-accent);
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font-weight: 500;
  }
  .empty {
    color: var(--oh-muted);
  }
</style>
