<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { Member, TrusteePolicy } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';

  const services = getServices();

  let members = $state<Member[]>([]);
  let selectedTrustees = $state<string[]>([]);
  let threshold = $state<number>(2);
  let loading = $state(true);

  onMount(async () => {
    const circle = await services.family.circle();
    const me = services.vault.memberId();
    if (circle && me) {
      members = Object.values(circle.members).filter(m => m.memberId !== me && !m.removed);
    }

    const policy = await services.recovery.policy();
    if (policy) {
      selectedTrustees = policy.trustees;
      threshold = policy.threshold;
    }

    loading = false;
  });

  function toggleTrustee(memberId: string) {
    if (selectedTrustees.includes(memberId)) {
      selectedTrustees = selectedTrustees.filter(id => id !== memberId);
      if (threshold > selectedTrustees.length) {
        threshold = Math.max(1, selectedTrustees.length);
      }
    } else {
      selectedTrustees = [...selectedTrustees, memberId];
    }
  }

  async function savePolicy() {
    const policy: TrusteePolicy = {
      trustees: selectedTrustees,
      threshold: threshold
    };
    await services.recovery.setPolicy(policy);
    alert('Plan de recuperación guardado.');
  }

  $effect(() => {
    if (threshold > selectedTrustees.length) {
      threshold = Math.max(1, selectedTrustees.length);
    }
  });

</script>

<div class="trustee-picker">
  <h2>Elegir custodios</h2>
  <p>Selecciona los miembros de tu círculo en los que confías para recuperar el acceso a tu cuenta.</p>

  {#if loading}
    <p>Cargando miembros...</p>
  {:else if members.length === 0}
    <p>No hay otros miembros en tu círculo.</p>
  {:else}
    <div class="member-list">
      {#each members as member}
        <label class="member-item">
          <input
            type="checkbox"
            checked={selectedTrustees.includes(member.memberId)}
            onclick={() => toggleTrustee(member.memberId)}
          />
          {member.displayName}
        </label>
      {/each}
    </div>

    {#if selectedTrustees.length > 0}
      <div class="threshold">
        <label for="threshold-select">Nivel de seguridad (mínimo de aprobaciones necesarias):</label>
        <select id="threshold-select" bind:value={threshold}>
          {#each Array.from({ length: selectedTrustees.length }, (_, i) => i + 1) as i}
            <option value={i}>{i} de {selectedTrustees.length}</option>
          {/each}
        </select>

        {#if threshold === 1 && selectedTrustees.length === 1}
          <div class="warning">
            <svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none">
              <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <p>Advertencia: Con un solo custodio (1 de 1), si esta persona pierde su cuenta, también podrías perder la tuya. Se recomienda agregar más miembros.</p>
          </div>
        {/if}
      </div>

      <button class="save-btn" onclick={savePolicy}>Guardar plan</button>
    {/if}
  {/if}
</div>

<style>
  .trustee-picker {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  .member-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  .member-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    cursor: pointer;
  }
  .threshold {
    margin-top: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  select {
    padding: 0.5rem;
    border-radius: var(--oh-radius);
    border: 1px solid var(--oh-muted);
    font: inherit;
  }
  .warning {
    display: flex;
    gap: 0.5rem;
    align-items: flex-start;
    color: var(--oh-danger);
    background: rgba(248, 113, 113, 0.1);
    padding: 1rem;
    border-radius: var(--oh-radius);
    margin-top: 0.5rem;
  }
  .save-btn {
    align-self: flex-start;
    background: var(--oh-accent);
    color: #fff;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
    margin-top: 1rem;
  }
</style>
