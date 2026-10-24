<script lang="ts">
  import type { MedicalId } from '../../../lib/contracts/types';
  import { getServices } from '../../../lib/contracts/services';

  let { medicalId, onsave, oncancel }: {
    medicalId?: MedicalId;
    onsave: (m: MedicalId) => void;
    oncancel: () => void;
  } = $props();

  let fullName = $state(medicalId?.fullName ?? '');
  let birthDate = $state(medicalId?.birthDate ?? '');
  let bloodType = $state(medicalId?.bloodType ?? '');
  let allergies = $state(medicalId?.allergies?.join(', ') ?? '');
  let conditions = $state(medicalId?.conditions?.join(', ') ?? '');
  let medications = $state(medicalId?.medications?.join(', ') ?? '');
  let organDonor = $state(medicalId?.organDonor === true ? 'yes' : medicalId?.organDonor === false ? 'no' : 'unknown');

  // Emergency contacts
  let iceName = $state(medicalId?.emergencyContacts?.[0]?.name ?? '');
  let icePhone = $state(medicalId?.emergencyContacts?.[0]?.phone ?? '');
  let iceRelation = $state(medicalId?.emergencyContacts?.[0]?.relation ?? '');

  let notes = $state(medicalId?.notes ?? '');

  function parseCommaList(s: string): string[] {
    return s.split(',').map(x => x.trim()).filter(x => x.length > 0);
  }

  function handleSubmit(e: SubmitEvent) {
    e.preventDefault();

    if (!fullName) return;

    const services = getServices();

    // We assume the user creates their own medical ID here, using their own vault memberId
    const owner = services.vault.memberId() || '';

    const newRecord: MedicalId = {
      kind: 'medical-id',
      recordId: medicalId?.recordId ?? `mid-${Date.now()}`,
      owner: medicalId?.owner ?? owner,
      updatedAt: Date.now(),
      fullName,
      birthDate: birthDate || undefined,
      bloodType: bloodType || undefined,
      allergies: parseCommaList(allergies),
      conditions: parseCommaList(conditions),
      medications: parseCommaList(medications),
      emergencyContacts: iceName ? [{
        name: iceName,
        phone: icePhone,
        relation: iceRelation || undefined
      }] : [],
      organDonor: organDonor === 'yes' ? true : organDonor === 'no' ? false : undefined,
      notes: notes || undefined,
    };

    onsave(newRecord);
  }
</script>

<form onsubmit={handleSubmit} class="medical-id-form">
  <div class="field">
    <label for="fullName">Nombre completo *</label>
    <input id="fullName" type="text" bind:value={fullName} required />
  </div>

  <div class="field">
    <label for="birthDate">Fecha de nacimiento (YYYY-MM-DD)</label>
    <input id="birthDate" type="text" bind:value={birthDate} placeholder="1980-01-01" pattern="\d{4}-\d{2}-\d{2}" />
  </div>

  <div class="field">
    <label for="bloodType">Tipo de sangre</label>
    <select id="bloodType" bind:value={bloodType}>
      <option value="">Desconocido</option>
      <option value="A+">A+</option>
      <option value="A-">A-</option>
      <option value="B+">B+</option>
      <option value="B-">B-</option>
      <option value="AB+">AB+</option>
      <option value="AB-">AB-</option>
      <option value="O+">O+</option>
      <option value="O-">O-</option>
    </select>
  </div>

  <div class="field">
    <label for="allergies">Alergias (separadas por coma)</label>
    <div class="helper">Críticas para primeros respondedores</div>
    <textarea id="allergies" bind:value={allergies}></textarea>
  </div>

  <div class="field">
    <label for="conditions">Condiciones médicas (separadas por coma)</label>
    <textarea id="conditions" bind:value={conditions}></textarea>
  </div>

  <div class="field">
    <label for="medications">Medicamentos actuales (separados por coma)</label>
    <textarea id="medications" bind:value={medications}></textarea>
  </div>

  <fieldset>
    <legend>Contacto de emergencia (ICE)</legend>
    <div class="field">
      <label for="iceName">Nombre del contacto</label>
      <input id="iceName" type="text" bind:value={iceName} />
    </div>
    <div class="field">
      <label for="icePhone">Teléfono</label>
      <input id="icePhone" type="tel" bind:value={icePhone} />
    </div>
    <div class="field">
      <label for="iceRelation">Relación</label>
      <input id="iceRelation" type="text" bind:value={iceRelation} />
    </div>
  </fieldset>

  <div class="field">
    <label for="organDonor">Donante de órganos</label>
    <select id="organDonor" bind:value={organDonor}>
      <option value="unknown">Desconocido</option>
      <option value="yes">Sí</option>
      <option value="no">No</option>
    </select>
  </div>

  <div class="field">
    <label for="notes">Notas adicionales para respondedores</label>
    <textarea id="notes" bind:value={notes}></textarea>
  </div>

  <div class="actions">
    <button type="button" class="cancel-btn" onclick={oncancel}>Cancelar</button>
    <button type="submit" class="save-btn">Guardar Medical ID</button>
  </div>
</form>

<style>
  .medical-id-form {
    display: flex;
    flex-direction: column;
    gap: 16px;
    background: var(--oh-surface);
    padding: 16px;
    border-radius: var(--oh-radius);
  }

  fieldset {
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 16px;
    margin: 8px 0;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  legend {
    font-weight: 600;
    padding: 0 8px;
    color: var(--oh-text);
  }

  .field {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  label {
    font-weight: 500;
    font-size: 0.95rem;
    color: var(--oh-text);
  }

  .helper {
    font-size: 0.8rem;
    color: var(--oh-muted);
  }

  input, select, textarea {
    padding: 8px;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background: var(--oh-bg);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
    font-size: 1rem;
  }

  textarea {
    resize: vertical;
    min-height: 60px;
  }

  input:focus, select:focus, textarea:focus {
    outline: 2px solid var(--oh-accent);
    outline-offset: -1px;
  }

  .actions {
    display: flex;
    gap: 12px;
    margin-top: 16px;
    justify-content: flex-end;
  }

  button {
    padding: 8px 16px;
    border-radius: 4px;
    font-weight: 600;
    cursor: pointer;
    font-size: 1rem;
    border: none;
  }

  .cancel-btn {
    background: transparent;
    color: var(--oh-text);
    border: 1px solid var(--oh-muted);
  }

  .save-btn {
    background: var(--oh-accent);
    color: #fff;
  }

  .save-btn:hover {
    background: var(--oh-accent-dark);
  }
</style>
