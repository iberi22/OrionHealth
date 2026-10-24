<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { Member, VaultState } from '../../../lib/contracts/types';
  import TrusteePicker from './TrusteePicker.svelte';
  import RestoreWizard from './RestoreWizard.svelte';
  import { onMount } from 'svelte';
  import { navigate } from '../routes';

  const services = getServices();

  let vaultState = $state<VaultState>(services.vault.state());
  let currentTab = $state<'plan' | 'requests' | 'restore'>('plan');

  let pendingRequests = $state<{ requestId: string; member: Member; at: number }[]>([]);
  let requestConfirmed = $state<Record<string, boolean>>({});

  $effect(() => {
    const unsub = services.vault.onState((s) => {
      vaultState = s;
      if (vaultState !== 'unlocked') {
        currentTab = 'restore';
      }
    });
    return unsub;
  });

  onMount(async () => {
    if (vaultState !== 'unlocked') {
      currentTab = 'restore';
    }

    if (vaultState === 'unlocked') {
      pendingRequests = await services.recovery.pendingRequests();
    }
  });

  async function approve(requestId: string) {
    if (!requestConfirmed[requestId]) return;
    await services.recovery.approve(requestId);
    pendingRequests = await services.recovery.pendingRequests();
  }
</script>

<section data-testid="area-recovery">
  <div class="tabs">
    {#if vaultState === 'unlocked'}
      <button class:active={currentTab === 'plan'} onclick={() => currentTab = 'plan'}>Mi plan</button>
      <button class:active={currentTab === 'requests'} onclick={() => currentTab = 'requests'}>Solicitudes</button>
    {/if}
    <button class:active={currentTab === 'restore'} onclick={() => currentTab = 'restore'}>Recuperar en este dispositivo</button>
  </div>

  <div class="tab-content">
    {#if currentTab === 'plan'}
      <TrusteePicker />
    {:else if currentTab === 'requests'}
      <div class="requests">
        <h2>Solicitudes esperando mi aprobación</h2>
        {#if pendingRequests.length === 0}
          <p>No hay solicitudes pendientes.</p>
        {:else}
          {#each pendingRequests as req}
            <div class="request-card">
              <p><strong>{req.member.displayName}</strong> quiere recuperar el acceso en un nuevo dispositivo.</p>
              <label>
                <input type="checkbox" bind:checked={requestConfirmed[req.requestId]} />
                Confirma por llamada o en persona que es {req.member.displayName} quien lo pide.
              </label>
              <button disabled={!requestConfirmed[req.requestId]} onclick={() => approve(req.requestId)}>Aprobar con mi passkey</button>
            </div>
          {/each}
        {/if}
      </div>
    {:else if currentTab === 'restore'}
      <RestoreWizard />
    {/if}
  </div>
</section>

<style>
  .tabs {
    display: flex;
    gap: 1rem;
    border-bottom: 1px solid var(--oh-muted);
    margin-bottom: 1rem;
  }
  .tabs button {
    background: none;
    border: none;
    padding: 0.5rem 1rem;
    cursor: pointer;
    font: inherit;
    color: var(--oh-text);
    border-bottom: 2px solid transparent;
  }
  .tabs button.active {
    border-bottom-color: var(--oh-accent);
    font-weight: bold;
  }
  .request-card {
    border: 1px solid var(--oh-muted);
    padding: 1rem;
    border-radius: var(--oh-radius);
    margin-bottom: 1rem;
  }
  .request-card label {
    display: flex;
    gap: 0.5rem;
    align-items: center;
    margin: 1rem 0;
  }
  button {
    background: var(--oh-accent);
    color: #fff;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
  }
  button:disabled {
    background: var(--oh-muted);
    cursor: not-allowed;
  }
</style>
