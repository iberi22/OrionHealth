<script lang="ts">
  import { onMount } from 'svelte';
  import { getServices } from '../../../lib/contracts/services';
  import { PERSONAL_CATEGORIES } from '../../../lib/contracts/types';
  import type { Member, Grant, PersonalCategory, AccessPreset, Access } from '../../../lib/contracts/types';
  import CategoryMatrix from './CategoryMatrix.svelte';
  import PresetPicker from './PresetPicker.svelte';
  import { CATEGORY_LABELS } from './categoryLabels';

  const services = getServices();

  let members = $state<Member[]>([]);
  let grantsGiven = $state<Grant[]>([]);
  let grantsReceived = $state<Grant[]>([]);
  let selectedMemberId = $state<string>('');

  let preset = $state<AccessPreset>('caregiver');
  let customCategories = $state<PersonalCategory[]>([]);
  let customAccess = $state<Access>('read');
  let expiresAt = $state<string>('');

  async function loadData() {
    const circle = await services.family.circle();
    if (circle) {
      const me = services.vault.memberId();
      members = Object.values(circle.members).filter((m) => m.memberId !== me && !m.removed);
    }
    grantsGiven = await services.family.grantsGiven();
    grantsReceived = await services.family.grantsReceived();
  }

  onMount(() => {
    loadData();
    const unsub = services.family.onChange(loadData);

    // Read pre-selected member from URL
    const params = new URLSearchParams(window.location.search);
    const memberParam = params.get('member');
    if (memberParam) {
      selectedMemberId = memberParam;
    }

    return unsub;
  });

  async function handleGrant(e: SubmitEvent) {
    e.preventDefault();
    if (!selectedMemberId) return;

    if (preset === 'guardian') {
      const confirmed = window.confirm(
        'El acudiente de primer nivel tendrá acceso de lectura y escritura a todo su historial, recibirá alertas, y podrá ayudarle a recuperar su cuenta. ¿Está seguro?'
      );
      if (!confirmed) return;
    }

    const expiryTime = expiresAt ? new Date(expiresAt).getTime() : undefined;

    if (preset === 'custom') {
      if (customCategories.length === 0) {
        alert('Debe seleccionar al menos una categoría.');
        return;
      }
      await services.family.grant(selectedMemberId, preset, { categories: customCategories, access: customAccess }, expiryTime);
    } else {
      await services.family.grant(selectedMemberId, preset, undefined, expiryTime);
    }

    if (preset === 'guardian') {
      await services.family.setGuardian(selectedMemberId);
    }

    // Reset form
    preset = 'caregiver';
    customCategories = [];
    customAccess = 'read';
    expiresAt = '';
  }

  async function handleRevoke(grantId: string) {
    const confirmed = window.confirm(
      'Desde ahora no verá datos nuevos. Lo que ya vio no se puede borrar de su memoria. ¿Continuar?'
    );
    if (!confirmed) return;
    await services.family.revoke(grantId);
  }

  function formatExpiry(ms?: number) {
    if (!ms) return 'Sin caducidad';
    return new Date(ms).toLocaleDateString('es');
  }

  function getMemberName(id: string) {
    return members.find((m) => m.memberId === id)?.displayName || 'Desconocido';
  }
</script>

<section data-testid="area-family-permissions" class="permissions-area">
  <h1>Permisos</h1>
  <p>Gestione quién puede ver o modificar su información de salud.</p>

  <section class="card matrix-section">
    <h2>Matriz de acceso</h2>
    <CategoryMatrix {members} {grantsGiven} categories={[...PERSONAL_CATEGORIES]} />
  </section>

  <section class="card">
    <h2>Otorgar acceso</h2>
    <form onsubmit={handleGrant} class="grant-form">
      <div class="form-group">
        <label for="member-select">Miembro familiar</label>
        <select id="member-select" bind:value={selectedMemberId} class="input" required>
          <option value="" disabled>Seleccione un miembro...</option>
          {#each members as member (member.memberId)}
            <option value={member.memberId}>{member.displayName}</option>
          {/each}
        </select>
      </div>

      <PresetPicker bind:preset bind:customCategories bind:customAccess />

      <div class="form-group">
        <label for="expiry-date">Caducidad (opcional)</label>
        <input type="date" id="expiry-date" bind:value={expiresAt} class="input" />
      </div>

      <button type="submit" class="btn primary" disabled={!selectedMemberId}>
        Otorgar acceso
      </button>
    </form>
  </section>

  <div class="lists-container">
    <section class="card">
      <h2>Permisos otorgados</h2>
      {#if grantsGiven.length === 0}
        <p class="empty">No ha otorgado permisos.</p>
      {:else}
        <ul class="grant-list">
          {#each grantsGiven as grant (grant.id)}
            <li class="grant-item">
              <div class="grant-info">
                <strong>{getMemberName(grant.to)}</strong>
                <span>{CATEGORY_LABELS[grant.category]?.label || grant.category} ({grant.access === 'write' ? 'Escritura' : 'Lectura'})</span>
                <span class="expiry">{formatExpiry(grant.expiresAt)}</span>
              </div>
              <button type="button" class="btn danger small" onclick={() => handleRevoke(grant.id)}>
                Revocar
              </button>
            </li>
          {/each}
        </ul>
      {/if}
    </section>

    <section class="card">
      <h2>Compartido conmigo</h2>
      {#if grantsReceived.length === 0}
        <p class="empty">Nadie ha compartido información con usted aún.</p>
      {:else}
        <ul class="grant-list">
          {#each grantsReceived as grant (grant.id)}
            <li class="grant-item">
              <div class="grant-info">
                <strong>{grant.from}</strong>
                <span>{CATEGORY_LABELS[grant.category]?.label || grant.category} ({grant.access === 'write' ? 'Escritura' : 'Lectura'})</span>
                <span class="expiry">{formatExpiry(grant.expiresAt)}</span>
              </div>
            </li>
          {/each}
        </ul>
      {/if}
    </section>
  </div>
</section>

<style>
  .permissions-area {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    padding: 1rem;
    max-width: 800px;
    margin: 0 auto;
  }
  .card {
    background: var(--oh-bg);
    border: 1px solid var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 1.5rem;
  }
  h1 {
    font-size: 1.75rem;
    margin-bottom: 0.5rem;
  }
  h2 {
    font-size: 1.25rem;
    margin-bottom: 1rem;
    color: var(--oh-text);
  }
  .grant-form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }
  .form-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  .input {
    padding: 0.75rem;
    border-radius: var(--oh-radius);
    border: 1px solid var(--oh-surface);
    background: var(--oh-bg);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
    font-size: 1rem;
  }
  .btn {
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: var(--oh-radius);
    font-weight: 600;
    cursor: pointer;
    font-family: var(--oh-font-sans);
  }
  .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .btn.primary {
    background: var(--oh-accent);
    color: white;
  }
  .btn.danger {
    background: var(--oh-danger);
    color: white;
  }
  .btn.small {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
  }
  .lists-container {
    display: grid;
    grid-template-columns: 1fr;
    gap: 2rem;
  }
  @media (min-width: 768px) {
    .lists-container {
      grid-template-columns: 1fr 1fr;
    }
  }
  .grant-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  .grant-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
  }
  .grant-info {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    font-size: 0.9rem;
  }
  .expiry {
    font-size: 0.8rem;
    color: var(--oh-muted);
  }
  .empty {
    color: var(--oh-muted);
    font-style: italic;
  }
</style>
