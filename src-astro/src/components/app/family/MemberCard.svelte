<script lang="ts">
  import type { Member } from '../../../lib/contracts/types';
  import { navigate } from '../routes';

  let { member, isMe, isAdmin, onRemove } = $props<{
    member: Member;
    isMe: boolean;
    isAdmin: boolean;
    onRemove: () => void
  }>();

</script>

<div class="card" {...(isMe ? { 'data-testid': 'member-self' } : {})}>
  <div class="info">
    <h3>
      {member.displayName}
      {#if isMe} <span class="badge">Yo</span> {/if}
      {#if member.role === 'admin'} <span class="badge admin">Admin</span> {/if}
      {#if member.dependent} <span class="badge dep">Dependiente</span> {/if}
    </h3>

    {#if member.guardianOf.length > 0}
      <p class="meta">Es acudiente de {member.guardianOf.length} miembro(s)</p>
    {/if}
  </div>

  <div class="actions">
    <button onclick={() => navigate(`/app/family/permissions?member=${member.memberId}`)}>
      Permisos
    </button>
    {#if !isMe}
      <button onclick={() => navigate(`/app/family/guardian?member=${member.memberId}`)}>
        Acudiente
      </button>
    {/if}
    {#if isAdmin && !isMe}
      <button class="danger" onclick={onRemove}>Eliminar</button>
    {/if}
  </div>
</div>

<style>
  .card {
    background: var(--oh-surface);
    padding: 1rem;
    border-radius: var(--oh-radius);
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    flex-wrap: wrap;
    gap: 1rem;
  }
  .info h3 {
    margin: 0 0 0.5rem 0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex-wrap: wrap;
  }
  .meta {
    margin: 0;
    font-size: 0.9rem;
    color: var(--oh-muted);
  }
  .badge {
    font-size: 0.75rem;
    padding: 0.2rem 0.5rem;
    border-radius: 12px;
    background: var(--oh-accent-light);
    color: #121212;
  }
  .badge.admin {
    background: var(--oh-secondary);
  }
  .badge.dep {
    background: var(--oh-muted);
    color: white;
  }
  .actions {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
  }
  button {
    padding: 0.4rem 0.8rem;
    font-size: 0.9rem;
    border: none;
    border-radius: 4px;
    background: var(--oh-bg);
    color: var(--oh-text);
    cursor: pointer;
    border: 1px solid var(--oh-muted);
  }
  button.danger {
    color: var(--oh-danger);
    border-color: var(--oh-danger);
  }
</style>
