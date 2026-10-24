<script lang="ts">
  import { onMount } from 'svelte';
  import { getServices } from '../../../lib/contracts/services';

  const services = getServices();

  let displayName = $state('');
  let sas = $state<string | null>(null);
  let loading = $state(false);
  let error = $state<string | null>(null);

  async function joinCircle() {
    if (!displayName) return;
    loading = true;
    error = null;
    try {
      const result = await services.family.join(location.href, displayName);
      sas = result.sas;
    } catch (err) {
      error = err instanceof Error ? err.message : 'Error al unirse al círculo';
    } finally {
      loading = false;
    }
  }
</script>

<section data-testid="area-join">
  <div class="container">
    <h1>Unirse a una familia</h1>

    {#if sas}
      <div class="success-state">
        <h2>Esperando aprobación</h2>
        <p>Compara este código con el administrador de la familia:</p>
        <div class="sas-code">{sas}</div>
        <p>Si los números coinciden, pídeles que aprueben tu solicitud en su pantalla.</p>
      </div>
    {:else}
      <p>Ingresa tu nombre para unirte a este círculo familiar.</p>

      <div class="form">
        <label for="displayName">Tu nombre</label>
        <input
          id="displayName"
          type="text"
          bind:value={displayName}
          placeholder="Ej. Juan"
          disabled={loading}
        />

        {#if error}
          <div class="error">{error}</div>
        {/if}

        <button onclick={joinCircle} disabled={loading || !displayName}>
          {loading ? 'Conectando...' : 'Unirse'}
        </button>
      </div>
    {/if}
  </div>
</section>

<style>
  section {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 50vh;
    padding: 1rem;
  }
  .container {
    background: var(--oh-surface);
    padding: 2rem;
    border-radius: var(--oh-radius);
    max-width: 400px;
    width: 100%;
    text-align: center;
  }
  .form {
    margin-top: 1.5rem;
    text-align: left;
  }
  input {
    width: 100%;
    padding: 0.5rem;
    margin-top: 0.5rem;
    margin-bottom: 1rem;
    border: 1px solid var(--oh-muted);
    border-radius: 4px;
    background: var(--oh-bg);
    color: var(--oh-text);
  }
  button {
    width: 100%;
    padding: 0.75rem;
    border: none;
    border-radius: 4px;
    background: var(--oh-accent);
    color: white;
    cursor: pointer;
    font-weight: bold;
  }
  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .sas-code {
    font-size: 2.5rem;
    font-weight: bold;
    letter-spacing: 0.2rem;
    margin: 1.5rem 0;
    color: var(--oh-accent-dark);
  }
  .error {
    color: var(--oh-danger);
    margin-bottom: 1rem;
    font-size: 0.9rem;
  }
</style>
