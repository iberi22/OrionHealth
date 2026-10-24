<script lang="ts">
  import type { AccessPreset, PersonalCategory, Access } from '../../../lib/contracts/types';
  import { PERSONAL_CATEGORIES } from '../../../lib/contracts/types';
  import { CATEGORY_LABELS } from './categoryLabels';

  let {
    preset = $bindable('caregiver'),
    customCategories = $bindable([]),
    customAccess = $bindable('read'),
  }: {
    preset: AccessPreset;
    customCategories: PersonalCategory[];
    customAccess: Access;
  } = $props();

  function toggleCategory(category: PersonalCategory) {
    if (customCategories.includes(category)) {
      customCategories = customCategories.filter((c) => c !== category);
    } else {
      customCategories = [...customCategories, category];
    }
  }
</script>

<div class="preset-picker">
  <label for="preset-select">Nivel de acceso</label>
  <select id="preset-select" bind:value={preset} class="input">
    <option value="guardian">Acudiente de primer nivel</option>
    <option value="caregiver">Cuidador</option>
    <option value="emergency-only">Solo emergencia</option>
    <option value="custom">Personalizado</option>
  </select>

  {#if preset === 'guardian'}
    <p class="summary warning">
      Incluye todas las categorías con permiso de escritura. Recibirá alertas y será apoderado de recuperación.
    </p>
  {/if}

  {#if preset === 'custom'}
    <div class="custom-section">
      <div class="access-mode">
        <label>
          <input type="radio" bind:group={customAccess} value="read" />
          Solo lectura
        </label>
        <label>
          <input type="radio" bind:group={customAccess} value="write" />
          Lectura y escritura
        </label>
      </div>

      <fieldset>
        <legend>Categorías permitidas</legend>
        <div class="categories-grid">
          {#each PERSONAL_CATEGORIES as category (category)}
            <label class="category-checkbox">
              <input
                type="checkbox"
                checked={customCategories.includes(category)}
                onchange={() => toggleCategory(category)}
              />
              <span class="label-text">{CATEGORY_LABELS[category].label}</span>
            </label>
          {/each}
        </div>
      </fieldset>
    </div>
  {/if}
</div>

<style>
  .preset-picker {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 1.5rem;
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
  .summary {
    font-size: 0.9rem;
    color: var(--oh-muted);
  }
  .warning {
    color: var(--oh-danger);
    font-weight: 500;
  }
  .custom-section {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
  }
  .access-mode {
    display: flex;
    gap: 1.5rem;
  }
  fieldset {
    border: none;
    padding: 0;
    margin: 0;
  }
  legend {
    font-weight: 600;
    margin-bottom: 0.5rem;
  }
  .categories-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 0.5rem;
  }
  .category-checkbox {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
  }
</style>
