<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { getServices } from '../../../lib/contracts/services';
  import type { Alert, Medication, CheckIn, CircleState } from '../../../lib/contracts/types';
  import { navigate } from '../routes';

  let alerts = $state<Alert[]>([]);
  let medications = $state<Medication[]>([]);
  let checkins = $state<CheckIn[]>([]);
  let circle = $state<CircleState | null>(null);
  let loading = $state(true);

  async function loadData() {
    try {
      const services = getServices();
      const [fetchedAlerts, fetchedMeds, fetchedCheckins, fetchedCircle] = await Promise.all([
        services.health.alerts(),
        services.records.list('medication'),
        services.health.list('checkin'),
        services.family.circle(),
      ]);

      alerts = fetchedAlerts.filter(a => !a.acknowledgedBy);
      medications = fetchedMeds.filter(m => m.active);
      checkins = fetchedCheckins;
      circle = fetchedCircle;
    } catch (error) {
      console.error('Failed to load home data:', error);
    } finally {
      loading = false;
    }
  }

  let cleanupRecords: () => void;
  let cleanupHealth: () => void;
  let cleanupFamily: () => void;

  onMount(() => {
    loadData();
    const services = getServices();
    cleanupRecords = services.records.onChange(loadData);
    cleanupHealth = services.health.onChange(loadData);
    cleanupFamily = services.family.onChange(loadData);
  });

  onDestroy(() => {
    cleanupRecords?.();
    cleanupHealth?.();
    cleanupFamily?.();
  });

  async function handleAcknowledge(alertId: string) {
    try {
      await getServices().health.acknowledge(alertId);
      // Reload is handled by onChange event, but let's eagerly remove it for snappy UI
      alerts = alerts.filter(a => a.alertId !== alertId);
    } catch (e) {
      console.error('Failed to acknowledge alert', e);
    }
  }

</script>

<section data-testid="area-home" class="home-dashboard">
  <header class="home-header">
    <h1>Inicio</h1>
    {#if circle}
      <p class="subtitle">Círculo: {circle.name}</p>
    {:else if !loading}
      <p class="subtitle">Sin círculo familiar</p>
    {/if}
  </header>

  {#if loading}
    <div class="loading">Cargando tu información...</div>
  {:else}
    <div class="dashboard-grid">

      <!-- Alerts Section -->
      <article class="card alerts-card">
        <div class="card-header">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon-danger">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
          </svg>
          <h2>Alertas ({alerts.length})</h2>
        </div>
        {#if alerts.length === 0}
          <p class="empty-state">No hay alertas pendientes.</p>
        {:else}
          <ul class="item-list">
            {#each alerts as alert}
              <li class="alert-item" class:critical={alert.severity === 'critical'} class:warning={alert.severity === 'warning'}>
                <div class="alert-content">
                  <span class="alert-msg">{alert.message}</span>
                </div>
                <button class="btn-small" onclick={() => handleAcknowledge(alert.alertId)}>Entendido</button>
              </li>
            {/each}
          </ul>
        {/if}
      </article>

      <!-- Medications Section -->
      <article class="card">
        <div class="card-header">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon-accent">
            <path d="M10.5 20.5l-6-6a4.5 4.5 0 0 1 6.5-6.5l6 6a4.5 4.5 0 0 1-6.5 6.5z"></path>
            <line x1="8.5" y1="8.5" x2="15.5" y2="15.5"></line>
          </svg>
          <h2>Medicamentos Activos</h2>
        </div>
        {#if medications.length === 0}
          <p class="empty-state">No hay medicamentos registrados.</p>
        {:else}
          <ul class="item-list">
            {#each medications as med}
              <li class="list-item">
                <span class="item-title">{med.name}</span>
                <span class="item-detail">{med.dose} - {med.schedule}</span>
              </li>
            {/each}
          </ul>
        {/if}
      </article>

      <!-- Family Activity Section -->
      <article class="card">
        <div class="card-header">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon-secondary">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
            <circle cx="9" cy="7" r="4"></circle>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
          </svg>
          <h2>Actividad Familiar</h2>
        </div>
        {#if checkins.length === 0}
          <p class="empty-state">No hay registros recientes.</p>
        {:else}
          <ul class="item-list">
            {#each checkins.slice(0, 5) as checkin}
              <li class="list-item">
                <span class="item-title">Check-in: {checkin.value}</span>
                {#if checkin.message}
                  <span class="item-detail">"{checkin.message}"</span>
                {/if}
              </li>
            {/each}
          </ul>
        {/if}
      </article>

      <!-- Quick Actions Section -->
      <article class="card actions-card">
        <h2>Acciones Rápidas</h2>
        <div class="actions-grid">
          <button class="action-btn" onclick={() => navigate('/app/emergency')}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
            </svg>
            <span>Emergencia</span>
          </button>
          <button class="action-btn" onclick={() => navigate('/app/records')}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
              <polyline points="14 2 14 8 20 8"></polyline>
              <line x1="16" y1="13" x2="8" y2="13"></line>
              <line x1="16" y1="17" x2="8" y2="17"></line>
              <polyline points="10 9 9 9 8 9"></polyline>
            </svg>
            <span>Historial</span>
          </button>
          <button class="action-btn" onclick={() => navigate('/app/assistant')}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
            </svg>
            <span>Asistente</span>
          </button>
        </div>
      </article>

    </div>
  {/if}
</section>

<style>
  .home-dashboard {
    padding: 1rem;
    max-width: 1200px;
    margin: 0 auto;
  }

  .home-header {
    margin-bottom: 2rem;
  }

  h1 {
    font-size: 1.75rem;
    font-weight: bold;
    margin: 0 0 0.25rem 0;
    color: var(--oh-text);
  }

  .subtitle {
    color: var(--oh-muted);
    margin: 0;
    font-size: 1rem;
  }

  .loading {
    color: var(--oh-muted);
    font-style: italic;
    padding: 2rem 0;
  }

  .dashboard-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  @media (min-width: 768px) {
    .dashboard-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  .card {
    background-color: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  }

  .card-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .card h2 {
    font-size: 1.25rem;
    margin: 0;
  }

  .icon-danger { color: var(--oh-danger); }
  .icon-accent { color: var(--oh-accent); }
  .icon-secondary { color: var(--oh-secondary); }

  .empty-state {
    color: var(--oh-muted);
    font-size: 0.875rem;
    margin: 0;
  }

  .item-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .list-item {
    display: flex;
    flex-direction: column;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid var(--oh-muted);
  }

  .list-item:last-child {
    border-bottom: none;
    padding-bottom: 0;
  }

  .item-title {
    font-weight: 500;
  }

  .item-detail {
    font-size: 0.875rem;
    color: var(--oh-muted);
  }

  .alert-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem;
    border-radius: var(--oh-radius);
    background-color: var(--oh-bg);
    border-left: 4px solid var(--oh-accent);
  }

  .alert-item.warning {
    border-left-color: #f59e0b;
  }

  .alert-item.critical {
    border-left-color: var(--oh-danger);
    background-color: rgba(248, 113, 113, 0.1);
  }

  .alert-msg {
    font-size: 0.875rem;
    font-weight: 500;
  }

  .btn-small {
    background-color: transparent;
    border: 1px solid var(--oh-muted);
    color: var(--oh-text);
    border-radius: var(--oh-radius);
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
    cursor: pointer;
  }

  .btn-small:hover {
    background-color: var(--oh-bg);
  }

  .actions-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    margin-top: 1rem;
  }

  .action-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    background-color: var(--oh-bg);
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 1rem 0.5rem;
    color: var(--oh-text);
    cursor: pointer;
    transition: transform 0.1s, background-color 0.2s;
  }

  .action-btn:hover {
    background-color: var(--oh-accent);
    color: white;
    border-color: var(--oh-accent);
  }

  .action-btn:active {
    transform: scale(0.95);
  }

  .action-btn span {
    font-size: 0.875rem;
    font-weight: 500;
  }
</style>
