<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { RecoveryProgress } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';

  const services = getServices();

  let method = $state<'none' | 'family' | 'code'>('none');
  let inviteLink = $state('');
  let recoveryCode = $state('');

  let progress = $state<RecoveryProgress>({ step: 'idle', approvals: 0, threshold: 0 });
  let sas = $state<string | null>(null);
  let codeError = $state<string | null>(null);

  $effect(() => {
    const unsub = services.recovery.onProgress((p) => {
      progress = p;
    });
    return unsub;
  });

  onMount(() => {
    progress = services.recovery.progress();
  });

  async function startWithFamily() {
    try {
      const res = await services.recovery.startRecovery(inviteLink);
      sas = res.sas;
    } catch (e: any) {
      console.error(e);
    }
  }

  async function startWithCode() {
    codeError = null;
    try {
      // Normalize code: remove spaces and dashes
      const normalized = recoveryCode.replace(/[\s-]/g, '');
      await services.recovery.recoverWithCode(normalized);
    } catch (e: any) {
      if (e.message && e.message.includes('checksum')) {
        codeError = 'El código es incorrecto. Por favor, revisa que esté bien escrito.';
      } else {
        codeError = 'Hubo un error al recuperar la cuenta con el código.';
      }
    }
  }
</script>

<div class="restore-wizard">
  {#if progress.step === 'idle' || progress.step === 'failed'}
    <h2>Recuperar acceso</h2>
    <p>Elige un método para recuperar tu cuenta en este dispositivo.</p>

    <div class="methods">
      <button class:active={method === 'family'} onclick={() => method = 'family'}>
        Recuperar con mi familia
      </button>
      <button class:active={method === 'code'} onclick={() => method = 'code'}>
        Usar código de recuperación
      </button>
    </div>

    {#if method === 'family'}
      <div class="method-content">
        <p>Pide a un administrador de tu círculo que te invite. Pega el enlace de invitación aquí:</p>
        <input type="text" bind:value={inviteLink} placeholder="https://orionhealth.swal.network/app/join#..." />
        <button disabled={!inviteLink} onclick={startWithFamily} class="primary">Continuar</button>
      </div>
    {:else if method === 'code'}
      <div class="method-content">
        <p>Ingresa tu código de recuperación de 24 palabras o los caracteres alfanuméricos:</p>
        <textarea bind:value={recoveryCode} placeholder="Escribe tu código aquí..." rows="3"></textarea>
        {#if codeError}
          <div class="error">{codeError}</div>
        {/if}
        <button disabled={!recoveryCode} onclick={startWithCode} class="primary">Recuperar</button>
      </div>
    {/if}
  {:else if progress.step === 'awaiting-invite'}
    <div class="progress-view">
      <h3>Conectando con tu familia...</h3>
      <p>Espera mientras se establece la conexión.</p>
    </div>
  {:else if progress.step === 'awaiting-approvals'}
    <div class="progress-view">
      <h3>Esperando aprobaciones</h3>
      {#if sas}
        <p>Para mayor seguridad, verifica que este número coincida con la pantalla de quien te invitó:</p>
        <div class="sas">{sas}</div>
      {/if}
      <p>Tus custodios deben aprobar tu solicitud en sus dispositivos.</p>
      <div class="approvals">
        Aprobaciones recibidas: <strong>{progress.approvals}</strong> de <strong>{progress.threshold}</strong>
      </div>
    </div>
  {:else if progress.step === 'combining'}
    <div class="progress-view">
      <h3>Combinando las partes...</h3>
      <p>Se han recibido suficientes aprobaciones.</p>
    </div>
  {:else if progress.step === 'register-passkey'}
    <div class="progress-view">
      <h3>Registrando nueva passkey</h3>
      <p>Se te pedirá que crees una nueva passkey para este dispositivo.</p>
    </div>
  {:else if progress.step === 'done'}
    <div class="progress-view success">
      <h3>¡Recuperación completada!</h3>
      <p>Has recuperado el acceso a tu cuenta exitosamente.</p>
      <button class="primary" onclick={() => window.location.reload()}>Ir al inicio</button>
    </div>
  {/if}
</div>

<style>
  .restore-wizard {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    max-width: 500px;
  }
  .methods {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
  }
  .methods button {
    flex: 1;
    padding: 1rem;
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    background: transparent;
    color: var(--oh-text);
    cursor: pointer;
    font: inherit;
  }
  .methods button.active {
    border-color: var(--oh-accent);
    background: rgba(16, 185, 129, 0.1);
    font-weight: bold;
  }
  .method-content {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  input, textarea {
    padding: 0.75rem;
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    background: var(--oh-bg);
    color: var(--oh-text);
    font: inherit;
    width: 100%;
    box-sizing: border-box;
  }
  button.primary {
    background: var(--oh-accent);
    color: #fff;
    border: none;
    padding: 0.75rem;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font: inherit;
    font-weight: bold;
  }
  button.primary:disabled {
    background: var(--oh-muted);
    cursor: not-allowed;
  }
  .error {
    color: var(--oh-danger);
    font-size: 0.9em;
  }
  .progress-view {
    text-align: center;
    padding: 2rem;
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
  }
  .sas {
    font-size: 2.5rem;
    font-family: var(--oh-font-mono);
    letter-spacing: 0.2em;
    margin: 1.5rem 0;
    font-weight: bold;
    color: var(--oh-accent);
  }
  .approvals {
    margin-top: 1rem;
    padding: 1rem;
    background: var(--oh-bg);
    border-radius: var(--oh-radius);
    font-size: 1.1em;
  }
  .success {
    border: 2px solid var(--oh-accent);
  }
</style>
