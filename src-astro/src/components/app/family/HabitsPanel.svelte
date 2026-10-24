<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { Habit } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';

  let habits = $state<Habit[]>([]);
  let isUpdating = $state<Record<string, boolean>>({});

  async function loadHabits() {
    const me = getServices().vault.memberId();
    if (!me) return;
    habits = await getServices().records.list('habit', me);
  }

  async function toggleShare(habit: Habit) {
    if (isUpdating[habit.recordId]) return;
    try {
      isUpdating[habit.recordId] = true;
      const updated = { ...habit, shareSummaryWithCircle: !habit.shareSummaryWithCircle, updatedAt: Date.now() };
      await getServices().records.put(updated);
      await loadHabits();
    } catch (err) {
      console.error(err);
    } finally {
      isUpdating[habit.recordId] = false;
    }
  }

  onMount(() => {
    loadHabits();
    const unsub = getServices().records.onChange(loadHabits);
    return unsub;
  });

  // Derived aggregated summary
  let summary = $derived.by(() => {
    const activeHabits = habits.filter(h => h.shareSummaryWithCircle);
    if (activeHabits.length === 0) return 'No hay hábitos compartidos.';
    const msgs = activeHabits.map(h => {
      const todayTotal = h.checkins.filter(c => new Date(c.at).toDateString() === new Date().toDateString()).reduce((sum, c) => sum + c.value, 0);
      return `${h.name}: ${todayTotal}/${h.target} ${h.unit}`;
    });
    return 'Hoy: ' + msgs.join(', ');
  });
</script>

<div class="habits-panel">
  <h3>Mis Hábitos</h3>

  {#if habits.length === 0}
    <p class="empty">No tienes hábitos registrados. Añádelos en la sección de Historial.</p>
  {/if}

  <ul class="habit-list">
    {#each habits as h}
      <li class="habit-item">
        <div class="habit-info">
          <strong>{h.name}</strong>
          <span class="meta">Meta: {h.target} {h.unit}</span>
        </div>
        <label class="toggle-label">
          <input type="checkbox" checked={h.shareSummaryWithCircle} onchange={() => toggleShare(h)} disabled={isUpdating[h.recordId]} />
          Compartir
        </label>
      </li>
    {/each}
  </ul>

  <div class="summary-box">
    <h5>Resumen compartido con el círculo</h5>
    <p>{summary}</p>
  </div>
</div>

<style>
  .habits-panel {
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
  .empty {
    font-size: 0.9rem;
    color: var(--oh-muted);
  }
  .habit-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }
  .habit-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: var(--oh-bg);
    padding: 0.75rem;
    border-radius: 6px;
  }
  .habit-info {
    display: flex;
    flex-direction: column;
  }
  .habit-info strong {
    font-size: 0.95rem;
  }
  .habit-info .meta {
    font-size: 0.8rem;
    color: var(--oh-muted);
  }
  .toggle-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.85rem;
    cursor: pointer;
  }
  .summary-box {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--oh-bg);
  }
  .summary-box h5 {
    margin: 0 0 0.5rem;
    font-size: 0.9rem;
  }
  .summary-box p {
    margin: 0;
    font-size: 0.85rem;
    color: var(--oh-text);
  }
</style>
