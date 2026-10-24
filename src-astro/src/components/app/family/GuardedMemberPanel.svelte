<script lang="ts">
  import type { GuardedSummary, Alert } from '../../../lib/contracts/types';
  import { getServices } from '../../../lib/contracts/services';
  import AlertRulesEditor from './AlertRulesEditor.svelte';

  let { summary }: { summary: GuardedSummary } = $props();

  const services = getServices();

  async function acknowledge(alert: Alert) {
    await services.health.acknowledge(alert.alertId);
  }

  let openAlerts = $derived(summary.openAlerts.filter(a => !a.acknowledgedBy));

  let adherence = $derived(summary.adherence7d !== undefined ? Math.round(summary.adherence7d * 100) : null);
</script>

<article class="member-panel">
  <h2>{summary.member.displayName}</h2>

  <div class="vitals">
    <h3>Últimos signos vitales</h3>
    {#if summary.latestVitals.length > 0}
      <ul>
        {#each summary.latestVitals as vital}
          <li>
            <strong>{vital.type}:</strong> {vital.value} {vital.unit}
            {#if vital.value2 !== undefined}
              / {vital.value2}
            {/if}
          </li>
        {/each}
      </ul>
    {:else}
      <p>Sin datos.</p>
    {/if}
  </div>

  <div class="adherence">
    <h3>Adherencia (7 días)</h3>
    {#if adherence !== null}
      <p>{adherence}%</p>
    {:else}
      <p>Sin datos.</p>
    {/if}
  </div>

  <div class="alerts">
    <h3>Alertas</h3>
    {#if openAlerts.length > 0}
      <ul>
        {#each openAlerts as alert}
          <li class="alert-item" class:critical={alert.severity === 'critical'}>
            <div class="alert-content">
              {#if alert.severity === 'critical'}
                <span class="critical-icon" aria-hidden="true">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                  </svg>
                </span>
                <strong class="sr-only">Crítica:</strong>
                <span aria-hidden="true">Crítica: </span>
              {/if}
              <span>{alert.message}</span>
            </div>
            <button onclick={() => acknowledge(alert)}>Confirmar</button>
          </li>
        {/each}
      </ul>
    {:else}
      <p>No hay alertas activas.</p>
    {/if}
  </div>

  <div class="categories">
    <h3>Categorías permitidas</h3>
    {#if summary.grantedCategories.length > 0}
      <p>{summary.grantedCategories.join(', ')}</p>
    {:else}
      <p>Ninguna.</p>
    {/if}
  </div>

  {#if services.vault.memberId()}
    <AlertRulesEditor subject={summary.member.memberId} memberId={services.vault.memberId()!} />
  {/if}

</article>

<style>
  .member-panel {
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
    background-color: var(--oh-bg);
  }

  h2 {
    margin-top: 0;
    color: var(--oh-accent-dark);
  }

  h3 {
    margin-bottom: 0.5rem;
    color: var(--oh-text);
  }

  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  li {
    margin-bottom: 0.5rem;
  }

  .alert-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: var(--oh-surface);
    padding: 0.75rem;
    border-radius: var(--oh-radius);
    margin-bottom: 0.5rem;
  }

  .alert-item.critical {
    border-left: 4px solid var(--oh-danger);
    background-color: color-mix(in srgb, var(--oh-danger) 15%, var(--oh-surface));
  }

  .alert-content {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .critical-icon {
    color: var(--oh-danger);
    display: flex;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border-width: 0;
  }

  button {
    background-color: var(--oh-accent);
    color: #fff;
    border: none;
    border-radius: var(--oh-radius);
    padding: 0.5rem 1rem;
    cursor: pointer;
  }
</style>
