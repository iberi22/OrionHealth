<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { VitalReading, VitalType } from '../../../lib/contracts/types';
  import { onMount, onDestroy } from 'svelte';

  const services = getServices();
  let vitals = $state<VitalReading[]>([]);
  let owner = services.vault.memberId();

  let showForm = $state(false);
  let editingId = $state<string | undefined>(undefined);
  let type = $state<VitalType>('bp');
  let value = $state<number | ''>('');
  let value2 = $state<number | ''>('');
  let unit = $derived.by(() => {
    switch (type) {
      case 'bp': return 'mmHg';
      case 'glucose': return 'mg/dL';
      case 'weight': return 'kg';
      case 'spo2': return '%';
      case 'hr': return 'bpm';
      case 'temp': return '°C';
      case 'steps': return 'pasos';
      case 'sleep': return 'horas';
      default: return '';
    }
  });

  const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;

  let recentVitals = $derived.by(() => {
    const cutoff = Date.now() - THIRTY_DAYS_MS;
    return vitals
      .filter(v => v.at >= cutoff)
      .sort((a, b) => b.at - a.at);
  });

  let vitalsByType = $derived.by(() => {
    const grouped = new Map<VitalType, VitalReading[]>();
    for (const v of recentVitals) {
      if (!grouped.has(v.type)) grouped.set(v.type, []);
      grouped.get(v.type)!.push(v);
    }
    return grouped;
  });

  async function load() {
    if (owner) {
      vitals = await services.records.list('vital', owner);
    }
  }

  let unsub: () => void;
  onMount(() => {
    load();
    unsub = services.records.onChange(() => {
      load();
    });
  });
  onDestroy(() => {
    if (unsub) unsub();
  });

  function validateVital(t: VitalType, v1: number, v2?: number) {
    if (v1 <= 0) return false;
    switch(t) {
      case 'bp': return v1 < 300 && v2! > 0 && v2! < 200 && v1 > v2!; // systolic > diastolic
      case 'glucose': return v1 < 1000;
      case 'weight': return v1 < 500;
      case 'spo2': return v1 <= 100;
      case 'hr': return v1 < 300;
      case 'temp': return v1 > 20 && v1 < 45;
      default: return true;
    }
  }

  async function save(e: Event) {
    e.preventDefault();
    if (!owner || value === '') return;

    const v1 = Number(value);
    const v2 = type === 'bp' ? Number(value2) : undefined;

    if (isNaN(v1) || (type === 'bp' && isNaN(v2!))) {
        alert('Por favor ingrese valores numéricos válidos.');
        return;
    }

    if (!validateVital(type, v1, v2)) {
      alert('Valores fuera del rango fisiológico normal.');
      return;
    }

    try {
      const existing = vitals.find(v => v.recordId === editingId);
      await services.records.put({
        recordId: editingId || crypto.randomUUID(),
        owner,
        updatedAt: Date.now(),
        kind: 'vital',
        type,
        value: v1,
        value2: v2,
        unit,
        at: existing ? existing.at : Date.now()
      });

      showForm = false;
      editingId = undefined;
      value = '';
      value2 = '';
    } catch (err) {
      console.error(err);
    }
  }

  function editRecord(vt: VitalReading) {
    editingId = vt.recordId;
    type = vt.type;
    value = vt.value;
    value2 = vt.value2 ?? '';
    showForm = true;
  }

  async function deleteRecord(vt: VitalReading) {
    if (!owner) return;
    try {
      await services.records.remove('vital', vt.recordId);
    } catch (err) {
      console.error(err);
    }
  }

  function getSparklinePath(readings: VitalReading[], useValue2: boolean = false): string {
    if (readings.length < 2) return '';

    // Sort chronologically for sparkline
    const sorted = [...readings].sort((a, b) => a.at - b.at);

    const width = 100;
    const height = 30;
    const padding = 2;

    const minAt = sorted[0].at;
    const maxAt = sorted[sorted.length - 1].at;
    const rangeAt = maxAt - minAt || 1;

    const values = sorted.map(r => useValue2 && r.type === 'bp' ? (r.value2 ?? r.value) : r.value);
    const minVal = Math.min(...values);
    const maxVal = Math.max(...values);
    const rangeVal = maxVal - minVal || 1;

    const points = sorted.map((r, i) => {
      const val = useValue2 && r.type === 'bp' ? (r.value2 ?? r.value) : r.value;
      const x = padding + ((r.at - minAt) / rangeAt) * (width - 2 * padding);
      const y = height - padding - ((val - minVal) / rangeVal) * (height - 2 * padding);
      return `${x},${y}`;
    });

    return `M ${points.join(' L ')}`;
  }

  const typeLabels: Record<VitalType, string> = {
    bp: 'Presión arterial',
    glucose: 'Glucosa',
    weight: 'Peso',
    spo2: 'Saturación O2',
    hr: 'Frecuencia cardíaca',
    temp: 'Temperatura',
    steps: 'Pasos',
    sleep: 'Sueño'
  };
</script>

<div class="tab-pane">
  <div class="header">
    <h2>Signos vitales (últimos 30 días)</h2>
    <button class="btn-primary" onclick={() => (showForm = !showForm)}>
      {showForm ? 'Cancelar' : 'Añadir'}
    </button>
  </div>

  {#if showForm}
    <form class="add-form" onsubmit={save}>
      <div class="form-group">
        <label for="vital-type">Tipo</label>
        <select id="vital-type" bind:value={type}>
          {#each Object.entries(typeLabels) as [k, label]}
            <option value={k}>{label}</option>
          {/each}
        </select>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="vital-value">{type === 'bp' ? 'Sistólica' : 'Valor'} ({unit})</label>
          <input id="vital-value" type="number" step="any" bind:value={value} required />
        </div>
        {#if type === 'bp'}
          <div class="form-group">
            <label for="vital-value2">Diastólica ({unit})</label>
            <input id="vital-value2" type="number" step="any" bind:value={value2} required />
          </div>
        {/if}
      </div>

      <button type="submit" class="btn-submit">Guardar</button>
    </form>
  {/if}

  {#if vitalsByType.size === 0}
    <p class="empty">No hay registros recientes.</p>
  {:else}
    <div class="vitals-grid">
      {#each Array.from(vitalsByType.entries()) as [vt, readings]}
        <div class="vital-card">
          <div class="vital-card-header">
            <h3>{typeLabels[vt]}</h3>
            <span class="unit">{readings[0].unit}</span>
          </div>

          <div class="latest-reading">
            <span class="value">{readings[0].value}{vt === 'bp' && readings[0].value2 ? `/${readings[0].value2}` : ''}</span>
            <span class="date">{new Date(readings[0].at).toLocaleDateString()}</span>
          </div>
          <div class="record-actions">
            <button data-testid="edit-vital-{readings[0].recordId}" onclick={() => editRecord(readings[0])}>Editar</button>
            <button data-testid="delete-vital-{readings[0].recordId}" onclick={() => deleteRecord(readings[0])}>Eliminar</button>
          </div>

          {#if readings.length > 1}
            <div class="sparkline-container">
              <svg viewBox="0 0 100 30" class="sparkline" preserveAspectRatio="none">
                <path d={getSparklinePath(readings)} stroke="var(--oh-accent)" stroke-width="2" fill="none" />
                {#if vt === 'bp'}
                   <path d={getSparklinePath(readings, true)} stroke="var(--oh-secondary)" stroke-width="2" fill="none" opacity="0.6"/>
                {/if}
              </svg>
            </div>
          {/if}

          <div class="history-list">
            {#each readings.slice(1, 4) as r}
              <div class="history-item">
                <span class="hist-val">{r.value}{vt === 'bp' && r.value2 ? `/${r.value2}` : ''}</span>
                <span class="hist-date">{new Date(r.at).toLocaleDateString()}</span>
              </div>
            {/each}
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }

  h2 {
    font-size: 1.25rem;
    color: var(--oh-text);
  }

  .btn-primary, .btn-submit {
    background-color: var(--oh-accent);
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font-weight: 600;
  }

  .btn-primary:hover, .btn-submit:hover {
    background-color: var(--oh-accent-dark);
  }

  .add-form {
    background-color: var(--oh-bg);
    padding: 1rem;
    border-radius: var(--oh-radius);
    margin-bottom: 1.5rem;
  }

  .form-group {
    margin-bottom: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .form-row {
    display: flex;
    gap: 1rem;
  }

  .form-row .form-group {
    flex: 1;
  }

  label {
    font-size: 0.875rem;
    color: var(--oh-muted);
  }

  input, select {
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background-color: var(--oh-surface);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
  }

  .empty {
    color: var(--oh-muted);
    font-style: italic;
  }

  .vitals-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
  }

  .vital-card {
    background-color: var(--oh-bg);
    padding: 1rem;
    border-radius: var(--oh-radius);
    display: flex;
    flex-direction: column;
  }

  .vital-card-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    margin-bottom: 0.5rem;
  }

  .vital-card-header h3 {
    margin: 0;
    font-size: 1rem;
    color: var(--oh-text);
  }

  .unit {
    font-size: 0.75rem;
    color: var(--oh-muted);
  }

  .latest-reading {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    margin-bottom: 1rem;
  }

  .latest-reading .value {
    font-size: 1.5rem;
    font-weight: bold;
    color: var(--oh-text);
  }

  .latest-reading .date {
    font-size: 0.75rem;
    color: var(--oh-muted);
  }

  .sparkline-container {
    height: 30px;
    margin-bottom: 1rem;
    width: 100%;
  }

  .sparkline {
    width: 100%;
    height: 100%;
  }

  .history-list {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    border-top: 1px solid var(--oh-surface);
    padding-top: 0.5rem;
  }

  .history-item {
    display: flex;
    justify-content: space-between;
    font-size: 0.75rem;
    color: var(--oh-muted);
  }

  .record-actions {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .record-actions button {
    background: none;
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 0.25rem 0.5rem;
    cursor: pointer;
    font-size: 0.75rem;
    color: var(--oh-text);
  }
</style>
