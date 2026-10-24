<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { MedicalId } from '../../../lib/contracts/types';
  import MedicalIdForm from './MedicalIdForm.svelte';
  import EmergencyQr from './EmergencyQr.svelte';
  import { emergencySummary } from './summary';

  let medicalId = $state<MedicalId | undefined>(undefined);
  let loading = $state(true);
  let editing = $state(false);
  let emergencyMode = $state(false);

  $effect(() => {
    async function loadData() {
      try {
        const services = getServices();
        const records = await services.records.list('medical-id');
        if (records.length > 0) {
          // Find the one belonging to this member, or just take the first
          const owner = services.vault.memberId();
          const ownRecord = records.find(r => r.owner === owner);
          medicalId = ownRecord ?? records[0];
        } else {
          medicalId = undefined;
        }
      } catch (err) {
        console.error('Failed to load Medical ID', err);
      } finally {
        loading = false;
      }
    }
    loadData();
  });

  async function handleSave(m: MedicalId) {
    loading = true;
    try {
      const services = getServices();
      await services.records.put(m);
      medicalId = m;
      editing = false;
    } catch (err) {
      console.error('Failed to save Medical ID', err);
    } finally {
      loading = false;
    }
  }

  function handleCancel() {
    editing = false;
  }

  function toggleEmergencyMode() {
    emergencyMode = !emergencyMode;
  }
</script>

<section data-testid="area-emergency" class:emergency-mode={emergencyMode}>
  <div class="header">
    <h1>Ficha médica de emergencia</h1>
    {#if !loading && medicalId && !editing && !emergencyMode}
      <button class="emergency-btn" onclick={toggleEmergencyMode}>Modo Emergencia</button>
    {/if}
    {#if emergencyMode}
      <button class="close-btn" onclick={toggleEmergencyMode}>Cerrar</button>
    {/if}
  </div>

  {#if loading}
    <p class="loading">Cargando...</p>
  {:else if emergencyMode && medicalId}
    <div class="emergency-view">
      <div class="big-text">
        <pre>{emergencySummary(medicalId)}</pre>
      </div>
      <EmergencyQr {medicalId} />
    </div>
  {:else if editing}
    <MedicalIdForm {medicalId} onsave={handleSave} oncancel={handleCancel} />
  {:else if medicalId}
    <div class="view-mode">
      <div class="card">
        <h2>{medicalId.fullName}</h2>

        <dl>
          {#if medicalId.birthDate}
            <div class="item">
              <dt>Nacimiento</dt>
              <dd>{medicalId.birthDate}</dd>
            </div>
          {/if}

          {#if medicalId.bloodType}
            <div class="item">
              <dt>Sangre</dt>
              <dd>{medicalId.bloodType}</dd>
            </div>
          {/if}

          {#if medicalId.allergies?.length}
            <div class="item">
              <dt>Alergias</dt>
              <dd class="danger-text">{medicalId.allergies.join(', ')}</dd>
            </div>
          {/if}

          {#if medicalId.conditions?.length}
            <div class="item">
              <dt>Condiciones</dt>
              <dd>{medicalId.conditions.join(', ')}</dd>
            </div>
          {/if}

          {#if medicalId.medications?.length}
            <div class="item">
              <dt>Medicamentos</dt>
              <dd>{medicalId.medications.join(', ')}</dd>
            </div>
          {/if}

          {#if medicalId.emergencyContacts?.length}
            <div class="item">
              <dt>Contactos de emergencia</dt>
              <dd>
                <ul class="contacts">
                  {#each medicalId.emergencyContacts as contact}
                    <li>
                      <strong>{contact.name}</strong>
                      {#if contact.relation}({contact.relation}){/if}
                      <br />
                      <a href="tel:{contact.phone}">{contact.phone}</a>
                    </li>
                  {/each}
                </ul>
              </dd>
            </div>
          {/if}

          {#if medicalId.organDonor !== undefined}
            <div class="item">
              <dt>Donante de órganos</dt>
              <dd>{medicalId.organDonor ? 'Sí' : 'No'}</dd>
            </div>
          {/if}

          {#if medicalId.notes}
            <div class="item full">
              <dt>Notas</dt>
              <dd>{medicalId.notes}</dd>
            </div>
          {/if}
        </dl>
      </div>

      <div class="actions">
        <button class="edit-btn" onclick={() => editing = true}>Editar Ficha</button>
      </div>
    </div>
  {:else}
    <div class="empty-state">
      <p>No tienes una ficha médica de emergencia configurada.</p>
      <button class="create-btn" onclick={() => editing = true}>Crear Ficha Médica</button>
    </div>
  {/if}
</section>

<style>
  section {
    max-width: 800px;
    margin: 0 auto;
    padding: 16px;
    color: var(--oh-text);
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    gap: 16px;
  }

  h1 {
    font-size: 1.5rem;
    margin: 0;
  }

  /* Emergency mode styles */
  .emergency-mode {
    background-color: var(--oh-bg);
    min-height: 100vh;
  }

  .emergency-mode h1 {
    color: var(--oh-danger);
  }

  .emergency-view {
    display: flex;
    flex-direction: column;
    gap: 32px;
  }

  .big-text {
    background: #000;
    color: #fff;
    padding: 24px;
    border-radius: var(--oh-radius);
    font-size: 1.25rem;
    line-height: 1.6;
    overflow-wrap: break-word;
  }

  .big-text pre {
    white-space: pre-wrap;
    font-family: var(--oh-font-sans);
    margin: 0;
  }

  /* Standard view styles */
  .card {
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 24px;
    margin-bottom: 24px;
  }

  h2 {
    margin-top: 0;
    margin-bottom: 16px;
    font-size: 1.25rem;
  }

  dl {
    display: grid;
    grid-template-columns: 1fr;
    gap: 16px;
    margin: 0;
  }

  @media (min-width: 600px) {
    dl {
      grid-template-columns: 1fr 1fr;
    }
  }

  .item {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .item.full {
    grid-column: 1 / -1;
  }

  dt {
    font-size: 0.85rem;
    color: var(--oh-muted);
    font-weight: 600;
    text-transform: uppercase;
  }

  dd {
    margin: 0;
    font-size: 1rem;
    font-weight: 500;
  }

  .danger-text {
    color: var(--oh-danger);
    font-weight: 700;
  }

  .contacts {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .contacts a {
    color: var(--oh-secondary);
    text-decoration: none;
    font-weight: 600;
  }

  .actions {
    display: flex;
    justify-content: flex-end;
  }

  .empty-state {
    text-align: center;
    padding: 48px 16px;
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
  }

  /* Buttons */
  button {
    padding: 10px 20px;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    font-size: 1rem;
    border: none;
  }

  .emergency-btn {
    background: var(--oh-danger);
    color: #fff;
  }

  .close-btn {
    background: transparent;
    color: var(--oh-text);
    border: 2px solid var(--oh-text);
  }

  .edit-btn {
    background: transparent;
    color: var(--oh-text);
    border: 2px solid var(--oh-muted);
  }

  .create-btn {
    background: var(--oh-accent);
    color: #fff;
    margin-top: 16px;
  }

  .loading {
    text-align: center;
    color: var(--oh-muted);
    padding: 32px;
  }
</style>
