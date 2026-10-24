<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { RecoveryProgress } from '../../../lib/contracts/types';
  import { onMount } from 'svelte';
  import { navigate } from '../routes';

  const services = getServices();

  let method = $state<'none' | 'family' | 'code'>('none');
  let inviteLink = $state('');
  let recoveryCode = $state('');

  let progress = $state<RecoveryProgress>({ step: 'idle', approvals: 0, threshold: 0 });
  let sas = $state<string | null>(null);
  let codeError = $state<string | null>(null);
  let recoveryFileText = $state<string | undefined>(undefined);
  let familyError = $state<string | null>(null);

  $effect(() => {
    const unsub = services.recovery.onProgress((p) => {
      progress = p;
    });
    return unsub;
  });

  onMount(() => {
    progress = services.recovery.progress();
    // Opened from a recovery invitation link (/app/recovery#…): the fragment is the invitation.
    if (location.pathname.startsWith('/app/recovery') && location.hash.length > 1) {
      inviteLink = location.href;
      method = 'family';
    }
  });

  async function startWithFamily() {
    familyError = null;
    try {
      const res = await services.recovery.startRecovery(inviteLink);
      sas = res.sas;
    } catch (e: any) {
      console.error(e);
      familyError = 'El enlace no es una invitación de recuperación válida o ha caducado.';
    }
  }

  async function onFile(ev: Event) {
    const file = (ev.currentTarget as HTMLInputElement).files?.[0];
    recoveryFileText = file ? await file.text() : undefined;
  }

  async function startWithCode() {
    codeError = null;
    try {
      // Normalize code: remove spaces and dashes
      const normalized = recoveryCode.replace(/[\s-]/g, '');
      await services.recovery.recoverWithCode(normalized, recoveryFileText);
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
    {#if progress.step === 'failed' && progress.error}
      <div class="error" style="margin-bottom: 1rem;">
        {#if progress.error.includes('CANCELLED')}
          Operación cancelada por el usuario.
        {:else if progress.error.includes('NO_UV')}
          No se pudo verificar la identidad del usuario (passkey).
        {:else}
          {progress.error}
        {/if}
      </div>
    {/if}
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
        <p>Pide a un administrador de tu círculo una invitación de recuperación. Pega el enlace aquí:</p>
        <input type="text" bind:value={inviteLink} placeholder="https://orionhealth.swal.network/app/recovery#..." />
        {#if familyError}
          <div class="error">{familyError}</div>
        {/if}
        <button disabled={!inviteLink} onclick={startWithFamily} class="primary">Continuar</button>
      </div>
    {:else if method === 'code'}
      <div class="method-content">
        <p>Ingresa tu código de recuperación de 54 caracteres o los caracteres alfanuméricos:</p>
        <textarea bind:value={recoveryCode} placeholder="Escribe tu código aquí..." rows="3"></textarea>
        <label class="file">
          Archivo de recuperación (orion-recovery.json), necesario en un dispositivo nuevo:
          <input type="file" accept=".json,application/json" onchange={onFile} />
        </label>
        {#if codeError}
          <div class="error">{codeError}</div>
        {/if}
        <button disabled={!recoveryCode} onclick={startWithCode} class="primary">Recuperar</button>
      </div>
    {/if}
  {:else if progress.step === 'awaiting-invite'}
    <div class="progress-view">
      <h3>Conectando con tu familia...</h3>
      {#if sas}
        <p>Muestra este número al administrador que te invitó. Debe coincidir con su pantalla:</p>
        <div class="sas">{sas}</div>
      {:else}
        <p>Espera mientras se establece la conexión.</p>
      {/if}
    </div>
  {:else if progress.step === 'awaiting-approvals'}
    <div class="progress-view">
      <h3>Esperando aprobaciones</h3>
      {#if sas}
        <p>Tus custodios te llamarán y te pedirán este número antes de aprobar:</p>
        <div class="sas">{sas}</div>
      {/if}
      <p>Tus custodios deben aprobar tu solicitud en sus dispositivos.</p>
      <div class="approvals">
        Aprobaciones recibidas: <strong>{progress.approvals}</strong> de <strong>{progress.threshold}</strong>
      </div>
      <div class="code-fallback">
        <h4>¿Ya tienes tu código?</h4>
        <div class="method-content code-fallback-content">
          <textarea bind:value={recoveryCode} placeholder="Escribe tu código aquí..." rows="2"></textarea>
          {#if codeError}
            <div class="error">{codeError}</div>
          {/if}
          <button disabled={!recoveryCode} onclick={startWithCode} class="primary">Tengo mi código</button>
        </div>
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
      <button class="primary" onclick={() => navigate('/app')}>Ir al inicio</button>
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
  .file {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    font-size: 0.9em;
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
  .code-fallback {
    margin-top: 2rem;
  }
  .code-fallback-content {
    text-align: left;
  }
</style>
