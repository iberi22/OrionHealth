<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import { navigate } from '../routes';
  import { EXPLANATION_SCREENS } from './steps';
  import Illustrations from './Illustrations.svelte';
  import RecoveryCodeStep from './RecoveryCodeStep.svelte';
  import type { MedicalId } from '../../../lib/contracts/types';

  const services = getServices();

  type Step =
    | 'explanation'
    | 'capability-check'
    | 'create-vault'
    | 'recovery'
    | 'basic-profile'
    | 'family'
    | 'tour';

  let currentStep = $state<Step>('explanation');
  let explanationIndex = $state(0);

  let prfSupported = $state<boolean>(true);
  let readOnly = $state<boolean>(false);
  let recoveryCode = $state<string>('');
  let createError = $state<string | null>(null);

  let name = $state('');

  // Basic profile
  let fullName = $state('');
  let birthDate = $state('');

  async function checkCapabilities() {
    currentStep = 'capability-check';
    const caps = await services.vault.capabilities();
    if (!caps.webauthn || caps.prf === false) {
      readOnly = true;
    } else {
      readOnly = false;
      currentStep = 'create-vault';
    }
  }

  function nextExplanation() {
    if (explanationIndex < EXPLANATION_SCREENS.length - 1) {
      explanationIndex++;
    } else {
      checkCapabilities();
    }
  }

  async function createVault() {
    if (!name.trim()) return;
    createError = null;
    try {
      const res = await services.vault.create(name);
      recoveryCode = res.recoveryCode;
      currentStep = 'recovery';
    } catch (e) {
      if (e && typeof e === 'object' && 'code' in e && e.code === 'NO_PASSKEY') {
        createError = 'Creación cancelada. Inténtalo de nuevo.';
      } else {
        readOnly = true;
        currentStep = 'capability-check';
      }
    }
  }

  function onRecoveryConfirmed() {
    recoveryCode = ''; // Clear it from memory
    currentStep = 'basic-profile';
  }

  async function saveProfile() {
    if (!fullName.trim()) return;
    try {
      const id = Date.now().toString(); // Basic unique id for demo
      const record: MedicalId = {
        kind: 'medical-id',
        recordId: id,
        owner: services.vault.memberId()!,
        updatedAt: Date.now(),
        fullName,
        birthDate: birthDate || undefined,
        allergies: [],
        conditions: [],
        medications: [],
        emergencyContacts: []
      };
      await services.records.put(record);
      currentStep = 'family';
    } catch (e) {
      console.error(e);
    }
  }

  function finish() {
    navigate('/app');
  }
</script>

<section data-testid="area-onboarding" class="onboarding-area">
  {#if currentStep === 'explanation'}
    <div class="step">
      <Illustrations id={EXPLANATION_SCREENS[explanationIndex]!.id} />
      <h2>{EXPLANATION_SCREENS[explanationIndex]!.title}</h2>
      <p>{EXPLANATION_SCREENS[explanationIndex]!.body}</p>

      <div class="actions">
        <button onclick={nextExplanation}>
          {explanationIndex === EXPLANATION_SCREENS.length - 1 ? 'Empezar' : 'Siguiente'}
        </button>
      </div>
    </div>

  {:else if currentStep === 'capability-check'}
    <div class="step">
      {#if readOnly}
        <h2>Modo de solo lectura</h2>
        <p>Tu dispositivo no soporta las características de seguridad necesarias para guardar datos (WebAuthn PRF).</p>
        <p>Aún puedes usar la aplicación para:</p>
        <div class="actions-col">
          <button onclick={() => navigate('/app/assistant')}>Explorar la base médica</button>
          <button onclick={() => navigate('/app/settings')}>Ver documentación</button>
        </div>
      {:else}
        <h2>Comprobando compatibilidad...</h2>
      {/if}
    </div>

  {:else if currentStep === 'create-vault'}
    <div class="step">
      <h2>Crear tu bóveda segura</h2>
      <p>Configura tu acceso seguro. Utilizaremos el bloqueo de tu dispositivo (huella, rostro o patrón).</p>

      <div class="input-group">
        <label for="vault-name">¿Cómo te llamas?</label>
        <input id="vault-name" type="text" bind:value={name} placeholder="Tu nombre" />
      </div>

      {#if createError}
        <p class="error">{createError}</p>
      {/if}

      <button onclick={createVault} disabled={!name.trim()}>
        Crear passkey
      </button>
    </div>

  {:else if currentStep === 'recovery'}
    <div class="step">
      <RecoveryCodeStep code={recoveryCode} onconfirm={onRecoveryConfirmed} />
    </div>

  {:else if currentStep === 'basic-profile'}
    <div class="step">
      <h2>Perfil básico</h2>
      <p>Cuéntanos un poco más sobre ti para tu ID Médico.</p>

      <div class="input-group">
        <label for="full-name">Nombre completo</label>
        <input id="full-name" type="text" bind:value={fullName} />
      </div>

      <div class="input-group">
        <label for="birth-date">Fecha de nacimiento (opcional)</label>
        <input id="birth-date" type="date" bind:value={birthDate} />
      </div>

      <button onclick={saveProfile} disabled={!fullName.trim()}>
        Guardar perfil
      </button>
    </div>

  {:else if currentStep === 'family'}
    <div class="step">
      <h2>Familia</h2>
      <p>Puedes crear un círculo familiar para compartir tu información, o unirte a uno existente con una invitación.</p>

      <div class="actions-col">
        <button onclick={() => navigate('/app/family')}>Crear círculo</button>
        <button onclick={() => navigate('/app/join')}>Unirse con invitación</button>
        <button class="secondary" onclick={() => { currentStep = 'tour'; }}>Omitir por ahora</button>
      </div>
    </div>

  {:else if currentStep === 'tour'}
    <div class="step">
      <h2>¡Todo listo!</h2>
      <p>Aquí tienes un pequeño recorrido:</p>
      <ul class="tour-list">
        <li><strong>Inicio:</strong> Un resumen de tu salud.</li>
        <li><strong>Historial:</strong> Todos tus registros médicos.</li>
        <li><strong>Familia:</strong> Comparte y cuida a los tuyos.</li>
        <li><strong>Ajustes:</strong> Puedes volver a ver este recorrido desde "Cómo funciona".</li>
      </ul>
      <button onclick={finish}>Entrar a la app</button>
    </div>
  {/if}
</section>

<style>
  .onboarding-area {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    padding: var(--oh-spacing-4, 1rem);
    text-align: center;
  }

  .step {
    max-width: 400px;
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: var(--oh-spacing-4, 1rem);
    align-items: center;
  }

  h2 {
    margin: 0;
    font-size: 1.5rem;
    color: var(--oh-color-text, #333);
  }

  p {
    margin: 0;
    color: var(--oh-color-text-muted, #666);
    line-height: 1.5;
  }

  .actions {
    margin-top: var(--oh-spacing-4, 1rem);
  }

  .actions-col {
    display: flex;
    flex-direction: column;
    gap: var(--oh-spacing-3, 0.75rem);
    width: 100%;
    margin-top: var(--oh-spacing-4, 1rem);
  }

  .input-group {
    display: flex;
    flex-direction: column;
    gap: var(--oh-spacing-1, 0.25rem);
    width: 100%;
    text-align: left;
  }

  input {
    padding: var(--oh-spacing-3, 0.75rem);
    border: 1px solid var(--oh-border, #ccc);
    border-radius: var(--oh-radius, 8px);
    font-family: inherit;
    width: 100%;
    box-sizing: border-box;
  }

  .error {
    color: var(--oh-color-danger, #d32f2f);
    font-size: 0.875rem;
    margin: 0;
  }

  button {
    padding: var(--oh-spacing-3, 0.75rem) var(--oh-spacing-4, 1rem);
    background: var(--oh-color-primary, #1976d2);
    color: white;
    border: none;
    border-radius: var(--oh-radius, 8px);
    cursor: pointer;
    font-weight: 500;
    width: 100%;
  }

  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  button.secondary {
    background: transparent;
    color: var(--oh-color-primary, #1976d2);
    border: 1px solid var(--oh-color-primary, #1976d2);
  }

  .tour-list {
    text-align: left;
    margin: 0;
    padding-left: var(--oh-spacing-4, 1rem);
    color: var(--oh-color-text-muted, #666);
    line-height: 1.6;
  }
</style>
