<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { GuardedSummary } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';
  import { navigate } from '../routes';
  import GuardedMemberPanel from './GuardedMemberPanel.svelte';

  const services = getServices();
  let summaries = $state<GuardedSummary[]>([]);
  let loading = $state(true);

  function loadSummaries() {
    services.family.guardedSummaries().then(res => {
      summaries = res;
      loading = false;
    });
  }

  onMount(() => {
    loadSummaries();

    // We need to listen to both family and health changes to re-render
    // when an alert is acknowledged or rule added.
    const unsubFam = services.family.onChange(loadSummaries);
    const unsubHealth = services.health.onChange(loadSummaries);

    return () => {
      unsubFam();
      unsubHealth();
    };
  });

  function goToPermissions() {
    navigate('/app/family/permissions');
  }
</script>

<section data-testid="area-family-guardian">
  <h1>Acudiente</h1>

  {#if loading}
    <p>Cargando información...</p>
  {:else if summaries.length === 0}
    <div class="empty-state">
      <p>Actualmente no eres acudiente de ningún miembro de la familia.</p>
      <p>Para ser nombrado acudiente, el miembro (o su creador, si es un perfil dependiente) debe ir a la pantalla de <strong>Permisos</strong> y asignarte ese rol.</p>
      <button onclick={goToPermissions}>Ir a Permisos</button>
    </div>
  {:else}
    <div class="summaries">
      {#each summaries as summary (summary.member.memberId)}
        <GuardedMemberPanel {summary} />
      {/each}
    </div>
  {/if}
</section>

<style>
  section {
    padding: 1rem;
  }

  h1 {
    color: var(--oh-text);
  }

  .empty-state {
    background-color: var(--oh-surface);
    padding: 1.5rem;
    border-radius: var(--oh-radius);
    border: 1px solid var(--oh-muted);
  }

  .empty-state p {
    color: var(--oh-text);
    margin-bottom: 1rem;
  }

  button {
    background-color: var(--oh-accent);
    color: #fff;
    border: none;
    border-radius: var(--oh-radius);
    padding: 0.5rem 1rem;
    cursor: pointer;
  }
</style>
