<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import { randomBytes, b64u } from '../../../lib/crypto/index';
  import type { CircleState } from '../../../lib/contracts/types';

  let { circle, onCreated }: { circle: CircleState; onCreated: () => void } = $props();

  const TEMPLATES = [
    { title: 'Menos azúcar 30 días', description: 'Cambiamos bebidas azucaradas por agua.', metric: 'días', target: 30 },
    { title: 'Caminar 8.000 pasos', description: 'Objetivo diario de pasos.', metric: 'días logrados', target: 30 },
    { title: 'Dormir 7 horas', description: 'Descanso mínimo.', metric: 'noches', target: 30 },
    { title: '5 porciones de frutas y verduras', description: 'Mejorar alimentación.', metric: 'días', target: 30 },
  ];

  let isCreating = $state(false);
  let title = $state('');
  let description = $state('');
  let metric = $state('');
  let target = $state(30);
  let startsAtStr = $state(new Date().toISOString().split('T')[0]);
  let endsAtStr = $state(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]);
  let participants = $state<Record<string, boolean>>({});

  $effect(() => {
    if (Object.keys(participants).length === 0 && circle) {
      for (const mId of Object.keys(circle.members)) {
        participants[mId] = true;
      }
    }
  });

  function applyTemplate(t: typeof TEMPLATES[0]) {
    title = t.title;
    description = t.description;
    metric = t.metric;
    target = t.target;
  }

  async function submit(e: Event) {
    e.preventDefault();
    if (isCreating) return;
    try {
      isCreating = true;
      const me = getServices().vault.memberId();
      if (!me) return;
      const recordId = 'ini-' + b64u(randomBytes(12));
      const startsAt = new Date(startsAtStr!).getTime();
      const endsAt = new Date(endsAtStr!).getTime();
      const pList = Object.entries(participants).filter(([_, v]) => v).map(([k]) => k);

      await getServices().health.put({
        kind: 'initiative',
        recordId,
        owner: me,
        updatedAt: Date.now(),
        title,
        description,
        metric,
        target,
        startsAt,
        endsAt,
        participants: pList,
        createdBy: me,
      });

      title = ''; description = ''; metric = ''; target = 30;
      onCreated();
    } catch (err) {
      console.error(err);
    } finally {
      isCreating = false;
    }
  }
</script>

<div class="initiative-form">
  <h3>Nueva Iniciativa</h3>
  <div class="templates">
    {#each TEMPLATES as t}
      <button type="button" class="tmpl-btn" onclick={() => applyTemplate(t)}>
        {t.title}
      </button>
    {/each}
  </div>

  <form onsubmit={submit}>
    <label>
      Título
      <input type="text" bind:value={title} required />
    </label>
    <label>
      Descripción
      <textarea bind:value={description} required></textarea>
    </label>
    <div class="row">
      <label>
        Métrica
        <input type="text" bind:value={metric} required />
      </label>
      <label>
        Objetivo
        <input type="number" bind:value={target} min="1" required />
      </label>
    </div>
    <div class="row">
      <label>
        Inicio
        <input type="date" bind:value={startsAtStr} required />
      </label>
      <label>
        Fin
        <input type="date" bind:value={endsAtStr} required />
      </label>
    </div>
    <fieldset>
      <legend>Participantes</legend>
      {#each Object.values(circle.members) as m}
        {#if !m.removed}
          <label class="check-label">
            <input type="checkbox" bind:checked={participants[m.memberId]} />
            {m.displayName}
          </label>
        {/if}
      {/each}
    </fieldset>
    <button type="submit" class="submit-btn" disabled={isCreating || !title}>Crear Iniciativa</button>
  </form>
</div>

<style>
  .initiative-form {
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 1rem;
    margin-bottom: 1.5rem;
  }
  h3 {
    margin-top: 0;
    margin-bottom: 1rem;
    font-size: 1.1rem;
  }
  .templates {
    display: flex;
    gap: 0.5rem;
    overflow-x: auto;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
  }
  .tmpl-btn {
    background: var(--oh-bg);
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 0.5rem;
    font-size: 0.85rem;
    cursor: pointer;
    white-space: nowrap;
    color: var(--oh-text);
  }
  .tmpl-btn:hover {
    border-color: var(--oh-accent);
  }
  form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  label {
    display: flex;
    flex-direction: column;
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--oh-text);
  }
  input, textarea {
    margin-top: 0.25rem;
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 6px;
    background: var(--oh-bg);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
  }
  textarea {
    resize: vertical;
    min-height: 60px;
  }
  .row {
    display: flex;
    gap: 1rem;
  }
  .row > label {
    flex: 1;
  }
  fieldset {
    border: 1px solid var(--oh-muted);
    border-radius: 6px;
    padding: 0.5rem;
    margin: 0;
  }
  legend {
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--oh-text);
    padding: 0 0.5rem;
  }
  .check-label {
    flex-direction: row;
    align-items: center;
    gap: 0.5rem;
    font-weight: normal;
    margin-bottom: 0.25rem;
    cursor: pointer;
  }
  .submit-btn {
    background: var(--oh-accent);
    color: white;
    border: none;
    padding: 0.75rem;
    border-radius: var(--oh-radius);
    font-weight: bold;
    cursor: pointer;
    margin-top: 0.5rem;
  }
  .submit-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
</style>
