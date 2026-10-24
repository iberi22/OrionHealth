<script lang="ts">
  import { getServices, type PendingRecovery, type PendingRecoveryJoin } from '../../../lib/contracts/services';
  import type { CircleState, VaultState } from '../../../lib/contracts/types';
  import TrusteePicker from './TrusteePicker.svelte';
  import RestoreWizard from './RestoreWizard.svelte';
  import RecoveryInviteDialog from './RecoveryInviteDialog.svelte';
  import { onMount } from 'svelte';

  const services = getServices();

  let vaultState = $state<VaultState>(services.vault.state());
  let currentTab = $state<'plan' | 'requests' | 'restore'>('plan');

  let pendingRequests = $state<PendingRecovery[]>([]);
  let requestConfirmed = $state<Record<string, boolean>>({});
  let requestError = $state<string | null>(null);

  // Admin side: recovery invitations for a member's new device (spec §9.3)
  let circle = $state<CircleState | null>(null);
  let inviteFor = $state('');
  let recoveryInviteUrl = $state('');
  let inviteForMemberName = $state('');
  let pendingJoins = $state<PendingRecoveryJoin[]>([]);
  const me = $derived(services.vault.memberId());
  const isAdmin = $derived(!!circle && !!me && circle.members[me]?.role === 'admin');
  const others = $derived(circle ? Object.values(circle.members).filter((m) => m.memberId !== me && !m.removed && !m.dependent) : []);

  $effect(() => {
    const unsub = services.vault.onState((s) => {
      vaultState = s;
      if (vaultState !== 'unlocked') {
        currentTab = 'restore';
      }
    });
    return unsub;
  });

  async function refresh() {
    if (vaultState !== 'unlocked') return;
    pendingRequests = await services.recovery.pendingRequests();
    pendingJoins = await services.recovery.pendingRecoveryJoins();
  }

  $effect(() => {
    if (currentTab !== 'requests' || vaultState !== 'unlocked') return;
    const unsub = services.family.onChange(() => void refresh().catch(() => undefined));
    // The recovery contract has no change feed and pending recovery joins live in memory: keep polling too.
    const t = setInterval(() => void refresh().catch(() => undefined), 2000);
    return () => {
      unsub();
      clearInterval(t);
    };
  });

  onMount(async () => {
    if (vaultState !== 'unlocked') {
      currentTab = 'restore';
    }

    if (vaultState === 'unlocked') {
      circle = await services.family.circle();
      await refresh();
    }
  });

  async function answer(requestId: string, approve: boolean) {
    requestError = null;
    if (approve && !requestConfirmed[requestId]) return;
    try {
      // approve(…, true) asks for a fresh passkey verification before the share leaves this device
      await services.recovery.approve(requestId, approve);
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      if (msg.includes('CANCELLED')) {
        requestError = 'Operación cancelada por el usuario.';
      } else if (msg.includes('NO_UV')) {
        requestError = 'No se pudo verificar la identidad del usuario (passkey).';
      } else {
        requestError = msg;
      }
    }
    await refresh();
  }

  async function createRecoveryInvite() {
    if (!inviteFor) return;
    inviteForMemberName = others.find((m) => m.memberId === inviteFor)?.displayName || '';
    recoveryInviteUrl = (await services.recovery.createRecoveryInvite(inviteFor)).url;
  }

  async function answerJoin(requestId: string, matches: boolean) {
    await services.recovery.approveRecoveryJoin(requestId, matches);
    await refresh();
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
        {#if requestError}
          <p class="error">{requestError}</p>
        {/if}
        {#if pendingRequests.length === 0}
          <p>No hay solicitudes pendientes.</p>
        {:else}
          {#each pendingRequests as req (req.requestId)}
            <div class="request-card">
              <p>Solicitud de recuperación para la cuenta de <strong>{req.member.displayName}</strong>.</p>
              {#if pendingRequests.filter(r => r.member.memberId === req.member.memberId).length > 1}
                <p class="error warning">¡Atención! Hay múltiples solicitudes de recuperación activas para este miembro.</p>
              {/if}
              <p class="provenance">
                Desde un dispositivo nuevo (<code>{req.requester.id.slice(0, 8)}</code>, ID: {req.requester.deviceId}), verificado por
                <strong>{req.vouchedBy.displayName}</strong>.
              </p>
              <p>Código en la pantalla del dispositivo: <span class="sas">{req.sas}</span></p>
              <p class="provenance">Vence: {new Date(req.expiresAt).toLocaleString()}</p>
              <label>
                <input type="checkbox" bind:checked={requestConfirmed[req.requestId]} />
                Llamé o vi en persona a {req.member.displayName} y su pantalla muestra este mismo código.
              </label>
              <button disabled={!requestConfirmed[req.requestId]} onclick={() => answer(req.requestId, true)}>Aprobar con mi passkey</button>
              <button class="secondary" onclick={() => answer(req.requestId, false)}>Rechazar</button>
            </div>
          {/each}
        {/if}

        {#if isAdmin}
          <h2>Dispositivo nuevo de un miembro</h2>
          <p>Si un miembro perdió su teléfono, crea una invitación de recuperación y comparte el enlace con esa persona.</p>
          <div class="invite-row">
            <select bind:value={inviteFor} aria-label="Miembro a recuperar">
              <option value="">Elige un miembro</option>
              {#each others as m (m.memberId)}
                <option value={m.memberId}>{m.displayName}</option>
              {/each}
            </select>
            <button disabled={!inviteFor} onclick={createRecoveryInvite}>Crear invitación de recuperación</button>
          </div>
          {#if recoveryInviteUrl}
            <RecoveryInviteDialog 
              inviteUrl={recoveryInviteUrl} 
              memberName={inviteForMemberName} 
              onClose={() => { recoveryInviteUrl = ''; inviteForMemberName = ''; inviteFor = ''; }} 
            />
          {/if}
          {#each pendingJoins as j (j.requestId)}
            <div class="request-card">
              <p>Un dispositivo dice ser de <strong>{j.member.displayName}</strong>. Código: <span class="sas">{j.sas}</span></p>
              <p>Confirma solo si su pantalla muestra el mismo código.</p>
              <button onclick={() => answerJoin(j.requestId, true)}>Coincide</button>
              <button class="secondary" onclick={() => answerJoin(j.requestId, false)}>No coincide</button>
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
  button.secondary {
    background: transparent;
    color: var(--oh-text);
    border: 1px solid var(--oh-muted);
    margin-left: 0.5rem;
  }
  .sas {
    font-family: var(--oh-font-mono);
    font-weight: bold;
    letter-spacing: 0.1em;
  }
  .provenance {
    font-size: 0.9em;
  }
  .invite-row {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }
  .recovery-invite-url {
    width: 100%;
    margin-bottom: 1rem;
  }
  .error {
    color: var(--oh-danger);
  }
  button:disabled {
    background: var(--oh-muted);
    cursor: not-allowed;
  }
</style>
