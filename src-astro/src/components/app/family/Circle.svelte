<script lang="ts">
  import { onMount } from 'svelte';
  import { getServices } from '../../../lib/contracts/services';
  import type { CircleState, Member, PendingJoin } from '../../../lib/contracts/types';
  import InviteDialog from './InviteDialog.svelte';
  import MemberCard from './MemberCard.svelte';
  import { navigate } from '../routes';

  const services = getServices();
  let circle = $state<CircleState | null>(null);
  let pendingJoins = $state<PendingJoin[]>([]);
  let isInviting = $state(false);
  let loading = $state(true);

  let newDependentName = $state('');
  let isAddingDependent = $state(false);
  let newCircleName = $state('');

  let currentMemberId = $state<string | null>(null);

  async function load() {
    loading = true;
    currentMemberId = services.vault.memberId();
    circle = await services.family.circle();
    if (circle) {
      pendingJoins = await services.family.pendingJoins();
    }
    loading = false;
  }

  onMount(() => {
    load();
    const unsub = services.family.onChange(() => {
      load();
    });
    return unsub;
  });

  async function createCircle() {
    if (!newCircleName) return;
    await services.family.createCircle(newCircleName);
    newCircleName = '';
    await load();
  }

  async function addDependent() {
    if (!newDependentName) return;
    await services.family.addDependent(newDependentName);
    newDependentName = '';
    isAddingDependent = false;
  }

  async function removeMember(id: string) {
    if (confirm('Eliminar a este miembro revocará su acceso a todos los datos y regenerará las claves del círculo. Los datos que ya haya sincronizado permanecerán en su dispositivo. ¿Continuar?')) {
      await services.family.removeMember(id);
    }
  }

  async function approveJoin(req: PendingJoin) {
    const match = confirm(`¿Coinciden los números en ambos dispositivos?\n\nNúmero: ${req.sas}`);
    if (match) {
      await services.family.approveJoin(req.requestId, true);
    } else {
      await services.family.approveJoin(req.requestId, false);
      alert('No apruebes: alguien podría estar interceptando la invitación.');
    }
  }

  function getIsAdmin() {
    if (!circle || !currentMemberId) return false;
    const me = circle.members[currentMemberId];
    return me?.role === 'admin';
  }

  let isAdmin = $derived(getIsAdmin());

</script>

<section data-testid="area-family-circle">
  {#if loading}
    <p>Cargando...</p>
  {:else if !circle}
    <div class="empty-state">
      <h1>Mi familia</h1>
      <p>Crea un círculo familiar para compartir tu información de salud y gestionar cuidadores.</p>
      <div>
        <label for="circleName">Nombre del círculo</label>
        <input id="circleName" type="text" bind:value={newCircleName} placeholder="Ej. Familia López" />
      </div>
      <button onclick={createCircle} disabled={!newCircleName}>Crear círculo</button>
    </div>
  {:else}
    <div class="header">
      <h1>{circle.name}</h1>
      <div class="actions">
        <button onclick={() => isInviting = true}>Invitar</button>
        <button onclick={() => isAddingDependent = true}>Añadir dependiente</button>
      </div>
    </div>

    {#if pendingJoins.length > 0 && isAdmin}
      <div class="pending-joins">
        <h2>Solicitudes pendientes</h2>
        {#each pendingJoins as req}
          <div class="pending-card">
            <span>{req.displayName} quiere unirse</span>
            <button onclick={() => approveJoin(req)}>Revisar</button>
          </div>
        {/each}
      </div>
    {/if}

    <div class="members-list">
      <h2>Miembros</h2>
      {#each Object.values(circle.members).filter(m => !m.removed) as member (member.memberId)}
        <MemberCard
          {member}
          isMe={member.memberId === currentMemberId}
          {isAdmin}
          onRemove={() => removeMember(member.memberId)}
        />
      {/each}
    </div>

    {#if isInviting}
      <InviteDialog onClose={() => isInviting = false} />
    {/if}

    {#if isAddingDependent}
      <div class="dialog">
        <div class="dialog-content">
          <h2>Añadir dependiente</h2>
          <p>Un dependiente (niño o adulto mayor) no tiene su propio dispositivo. Tú gestionarás sus datos.</p>
          <label for="depName">Nombre</label>
          <input id="depName" type="text" bind:value={newDependentName} />
          <div class="dialog-actions">
            <button onclick={() => isAddingDependent = false}>Cancelar</button>
            <button onclick={addDependent} disabled={!newDependentName}>Añadir</button>
          </div>
        </div>
      </div>
    {/if}
  {/if}
</section>

<style>
  section {
    padding: 1rem;
    max-width: 600px;
    margin: 0 auto;
  }
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    flex-wrap: wrap;
    gap: 1rem;
  }
  .actions {
    display: flex;
    gap: 0.5rem;
  }
  .members-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  .pending-joins {
    background: var(--oh-surface);
    padding: 1rem;
    border-radius: var(--oh-radius);
    margin-bottom: 2rem;
  }
  .pending-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.5rem 0;
    border-bottom: 1px solid var(--oh-bg);
  }
  .pending-card:last-child {
    border-bottom: none;
  }
  .dialog {
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
  }
  .dialog-content {
    background: var(--oh-bg);
    padding: 2rem;
    border-radius: var(--oh-radius);
    max-width: 400px;
    width: 90%;
  }
  .dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 1rem;
  }
  input {
    width: 100%;
    padding: 0.5rem;
    margin-top: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background: var(--oh-surface);
    color: var(--oh-text);
  }
  button {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    background: var(--oh-accent);
    color: white;
    cursor: pointer;
  }
  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .empty-state {
    text-align: center;
    padding: 2rem 0;
  }
  .empty-state div {
    text-align: left;
    margin: 1.5rem 0;
  }
</style>
