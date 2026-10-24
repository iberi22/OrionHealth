<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import { navigate } from '../routes';

  let error = $state<string | null>(null);
  let isUnlocking = $state(false);

  async function handleUnlock() {
    error = null;
    isUnlocking = true;
    try {
      const vault = getServices().vault;
      await vault.unlock();
      navigate('/app');
    } catch (e) {
      error = "No se pudo verificar tu identidad. Intenta de nuevo.";
    } finally {
      isUnlocking = false;
    }
  }
</script>

<section data-testid="area-lock" class="lock-screen">
  <div class="lock-container">
    <div class="icon">
      <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
      </svg>
    </div>

    <h1 class="title">Bóveda de salud</h1>
    <p class="subtitle">Desbloquea para acceder a tus datos privados</p>

    {#if error}
      <div class="error-message" role="alert">{error}</div>
    {/if}

    <button
      class="unlock-button"
      onclick={handleUnlock}
      disabled={isUnlocking}
    >
      {isUnlocking ? 'Verificando...' : 'Desbloquear'}
    </button>
  </div>
</section>

<style>
  .lock-screen {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100%;
    height: 100vh;
    background-color: var(--oh-bg);
    color: var(--oh-text);
    padding: 1rem;
    box-sizing: border-box;
  }

  .lock-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    max-width: 400px;
    width: 100%;
    padding: 2rem;
    background-color: var(--oh-surface);
    border-radius: var(--oh-radius);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  }

  .icon {
    color: var(--oh-accent);
    margin-bottom: 1.5rem;
  }

  .title {
    font-size: 1.5rem;
    font-weight: bold;
    margin: 0 0 0.5rem 0;
  }

  .subtitle {
    font-size: 1rem;
    color: var(--oh-muted);
    margin: 0 0 2rem 0;
  }

  .error-message {
    color: var(--oh-danger);
    background-color: rgba(248, 113, 113, 0.1);
    padding: 0.75rem;
    border-radius: var(--oh-radius);
    margin-bottom: 1.5rem;
    font-size: 0.875rem;
    width: 100%;
    box-sizing: border-box;
  }

  .unlock-button {
    background-color: var(--oh-accent);
    color: #ffffff;
    border: none;
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    font-weight: bold;
    border-radius: var(--oh-radius);
    cursor: pointer;
    width: 100%;
    transition: background-color 0.2s;
  }

  .unlock-button:hover:not(:disabled) {
    background-color: var(--oh-accent-dark);
  }

  .unlock-button:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
</style>
