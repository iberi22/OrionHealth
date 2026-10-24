<script lang="ts">
  import ConditionsTab from './ConditionsTab.svelte';
  import MedicationsTab from './MedicationsTab.svelte';
  import VitalsTab from './VitalsTab.svelte';
  import OtherTabs from './OtherTabs.svelte';

  let activeTab = $state<'conditions' | 'medications' | 'vitals' | 'allergies' | 'appointments'>('conditions');

  const tabs = [
    { id: 'conditions', label: 'Condiciones' },
    { id: 'medications', label: 'Medicamentos' },
    { id: 'vitals', label: 'Signos vitales' },
    { id: 'allergies', label: 'Alergias' },
    { id: 'appointments', label: 'Citas' }
  ] as const;
</script>

<section data-testid="area-records" class="records-area">
  <h1>Mi historial</h1>

  <div class="tabs" role="tablist">
    {#each tabs as tab}
      <button
        role="tab"
        aria-selected={activeTab === tab.id}
        class="tab-btn"
        class:active={activeTab === tab.id}
        onclick={() => (activeTab = tab.id)}
      >
        {tab.label}
      </button>
    {/each}
  </div>

  <div class="tab-content" role="tabpanel">
    {#if activeTab === 'conditions'}
      <ConditionsTab />
    {:else if activeTab === 'medications'}
      <MedicationsTab />
    {:else if activeTab === 'vitals'}
      <VitalsTab />
    {:else if activeTab === 'allergies'}
      <OtherTabs tab="allergies" />
    {:else if activeTab === 'appointments'}
      <OtherTabs tab="appointments" />
    {/if}
  </div>
</section>

<style>
  .records-area {
    padding: 1rem;
    max-width: 800px;
    margin: 0 auto;
  }

  h1 {
    font-family: var(--oh-font-sans);
    color: var(--oh-text);
    margin-bottom: 1.5rem;
  }

  .tabs {
    display: flex;
    gap: 0.5rem;
    overflow-x: auto;
    border-bottom: 1px solid var(--oh-muted);
    padding-bottom: 0.5rem;
    margin-bottom: 1.5rem;
  }

  .tab-btn {
    background: none;
    border: none;
    padding: 0.5rem 1rem;
    font-family: var(--oh-font-sans);
    color: var(--oh-muted);
    cursor: pointer;
    border-radius: var(--oh-radius);
    white-space: nowrap;
  }

  .tab-btn:hover {
    background-color: var(--oh-surface);
  }

  .tab-btn.active {
    color: var(--oh-text);
    font-weight: 600;
    background-color: var(--oh-surface);
  }

  .tab-content {
    background-color: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 1.5rem;
  }
</style>
