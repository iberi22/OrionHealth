<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';

  const { code, onconfirm } = $props<{ code: string; onconfirm: () => void }>();

  // Spec §9.1 (D4): the code opens orion-recovery.json; on a brand-new device the code needs that file
  // (or the family circle). The file is ciphertext: without the code it reveals nothing.
  let fileError = $state(false);
  async function downloadFile() {
    fileError = false;
    try {
      const { filename, content } = await getServices().recovery.recoveryFile();
      const url = URL.createObjectURL(new Blob([content], { type: 'application/json' }));
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      a.click();
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch (e) {
      console.error(e);
      fileError = true;
    }
  }

  // Use a predictable pseudo-random selection so it doesn't flicker, based on code length or just Math.random initialized once
  const parts = $derived(code.includes('-') ? code.split('-') : code.split(' '));
  const numParts = $derived(parts.length);

  // Pick 3 distinct random positions (1-indexed for the user)
  const indices = $state<number[]>([]);

  $effect(() => {
    if (indices.length === 0 && numParts >= 3) {
      const selected = new Set<number>();
      while (selected.size < 3) {
        selected.add(Math.floor(Math.random() * numParts));
      }
      indices.push(...Array.from(selected).sort((a, b) => a - b));
    }
  });

  const inputs = $state<string[]>(['', '', '']);
  let error = $state(false);

  function verify() {
    error = false;
    for (let i = 0; i < 3; i++) {
      if (inputs[i]?.trim() !== parts[indices[i]]) {
        error = true;
        return;
      }
    }
    onconfirm();
  }
</script>

<div class="recovery-step">
  <h2>Tu código de recuperación</h2>
  <p>Guarda este código en un lugar seguro. Es la única forma de recuperar tus datos si pierdes el acceso.</p>

  <div class="code-display">
    {code}
  </div>

  <p>Descarga también el archivo de recuperación cifrado. En un dispositivo nuevo necesitarás el código y este archivo (o a tu familia).</p>
  <button type="button" class="secondary" onclick={downloadFile}>Descargar archivo de recuperación</button>
  {#if fileError}
    <p class="error">No se pudo generar el archivo. Inténtalo de nuevo.</p>
  {/if}

  {#if indices.length === 3}
    <div class="verification">
      <p>Para confirmar, ingresa las partes indicadas:</p>

      <div class="inputs">
        {#each indices as idx, i}
          <div class="input-group">
            <label for="part-{i}">Parte {idx + 1}</label>
            <input
              id="part-{i}"
              type="text"
              bind:value={inputs[i]}
              autocomplete="off"
              autocapitalize="off"
            />
          </div>
        {/each}
      </div>

      {#if error}
        <p class="error">Las palabras no coinciden. Inténtalo de nuevo.</p>
      {/if}

      <button type="button" onclick={verify}>Confirmar</button>
    </div>
  {/if}
</div>

<style>
  .recovery-step {
    display: flex;
    flex-direction: column;
    gap: var(--oh-spacing-4, 1rem);
  }

  .code-display {
    background: var(--oh-bg-subtle, #f5f5f5);
    padding: var(--oh-spacing-4, 1rem);
    border-radius: var(--oh-radius, 8px);
    font-family: monospace;
    word-break: break-all;
    font-size: 1.1rem;
    line-height: 1.5;
    text-align: center;
    user-select: all;
  }

  .verification {
    display: flex;
    flex-direction: column;
    gap: var(--oh-spacing-3, 0.75rem);
    margin-top: var(--oh-spacing-4, 1rem);
  }

  .inputs {
    display: flex;
    gap: var(--oh-spacing-3, 0.75rem);
    flex-wrap: wrap;
  }

  .input-group {
    display: flex;
    flex-direction: column;
    gap: var(--oh-spacing-1, 0.25rem);
    flex: 1;
    min-width: 80px;
  }

  input {
    padding: var(--oh-spacing-2, 0.5rem);
    border: 1px solid var(--oh-border, #ccc);
    border-radius: var(--oh-radius, 8px);
    font-family: inherit;
  }

  .error {
    color: var(--oh-color-danger, #d32f2f);
    font-size: 0.875rem;
  }

  button {
    padding: var(--oh-spacing-2, 0.5rem) var(--oh-spacing-4, 1rem);
    background: var(--oh-color-primary, #1976d2);
    color: white;
    border: none;
    border-radius: var(--oh-radius, 8px);
    cursor: pointer;
    font-weight: 500;
  }

  button.secondary {
    background: transparent;
    color: var(--oh-color-primary, #1976d2);
    border: 1px solid currentColor;
    align-self: flex-start;
  }
</style>
