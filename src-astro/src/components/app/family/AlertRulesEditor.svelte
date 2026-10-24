<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { AlertRule } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';

  let { subject, memberId }: { subject: string; memberId: string } = $props();

  let rules = $state<AlertRule[]>([]);

  const services = getServices();

  function loadRules() {
    services.health.alertRules(subject).then((res) => {
      rules = res;
    });
  }

  onMount(() => {
    loadRules();
    return services.health.onChange(loadRules);
  });

  async function toggleRule(rule: AlertRule) {
    await services.health.putAlertRule({ ...rule, enabled: !rule.enabled });
  }

  async function updateThreshold(rule: AlertRule, newThreshold: number) {
    if (!isNaN(newThreshold)) {
      await services.health.putAlertRule({ ...rule, threshold: newThreshold });
    }
  }

  async function addDefaultRules() {
    const defaults: Partial<AlertRule>[] = [
      { vital: 'bp', comparator: '>', threshold: 160 },
      { vital: 'glucose', comparator: '<', threshold: 70 },
      { vital: 'spo2', comparator: '<', threshold: 92 },
      { comparator: 'missed-for-hours', threshold: 24 }
    ];

    for (const d of defaults) {
      // Create an ID following the mock structure
      const recordId = `rule-${Math.random().toString(36).substring(2, 9)}`;
      await services.health.putAlertRule({
        kind: 'alert-rule',
        recordId,
        owner: memberId,
        updatedAt: Date.now(),
        subject,
        vital: d.vital,
        comparator: d.comparator!,
        threshold: d.threshold!,
        notify: [memberId],
        enabled: true,
      });
    }
  }
</script>

<div class="rules-editor">
  <h3>Reglas de alerta</h3>

  {#if rules.length === 0}
    <p>No hay reglas configuradas.</p>
    <button onclick={addDefaultRules}>Añadir reglas por defecto</button>
  {:else}
    <ul>
      {#each rules as rule (rule.recordId)}
        <li>
          <div class="rule-row">
            <label class="toggle-label">
              <input type="checkbox" checked={rule.enabled} onchange={() => toggleRule(rule)} />
              {#if rule.vital}
                <span>{rule.vital} {rule.comparator}</span>
              {:else if rule.comparator === 'missed-for-hours'}
                <span>Medicamento omitido por (horas):</span>
              {/if}
            </label>
            <input
              type="number"
              class="threshold-input"
              value={rule.threshold}
              onchange={(e) => updateThreshold(rule, parseInt(e.currentTarget.value, 10))}
              min="0"
              aria-label={`Umbral para ${rule.vital || 'medicamento omitido'}`}
            />
          </div>
        </li>
      {/each}
    </ul>
  {/if}
</div>

<style>
  .rules-editor {
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    padding: 1rem;
    margin-top: 1rem;
    background-color: var(--oh-surface);
  }

  h3 {
    margin-top: 0;
    color: var(--oh-text);
  }

  ul {
    list-style: none;
    padding: 0;
  }

  li {
    margin-bottom: 0.75rem;
  }

  .rule-row {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .toggle-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--oh-text);
    flex-grow: 1;
  }

  .threshold-input {
    width: 60px;
    padding: 0.25rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    text-align: right;
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
