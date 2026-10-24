<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import type { RagAnswer } from '../../../lib/contracts/types';
  import AnswerCard from './AnswerCard.svelte';

  const services = getServices();

  let question = $state('');
  let usePersonalData = $state(false);
  let answers = $state<RagAnswer[]>([]);
  let isLoading = $state(false);

  let isUnlocked = $state(services.vault.state() === 'unlocked');

  $effect(() => {
    const unsub = services.vault.onState((s) => {
      isUnlocked = s === 'unlocked';
      if (!isUnlocked) {
        usePersonalData = false;
      }
    });

    return unsub;
  });

  async function askQuestion(e: Event) {
    e.preventDefault();
    if (!question.trim()) return;

    isLoading = true;
    try {
      const q = question;
      question = ''; // clear input
      const res = await services.rag.ask(q, { includePersonal: usePersonalData });
      answers = [res, ...answers]; // prepend
    } catch (err) {
      console.error(err);
      // In a real app we'd show an error toast
    } finally {
      isLoading = false;
    }
  }
</script>

<section data-testid="area-assistant" class="assistant-area">
  <header>
    <h1>Asistente</h1>
    <p class="subtitle">Consulta la base de conocimientos {isUnlocked ? 'y tus registros' : ''}.</p>
  </header>

  <form class="ask-form" onsubmit={askQuestion}>
    <label for="question-input">Pregunta</label>
    <div class="input-row">
      <input
        id="question-input"
        type="text"
        bind:value={question}
        placeholder="¿Qué quieres saber?"
        disabled={isLoading}
      />
      <button type="submit" disabled={isLoading || !question.trim()}>Preguntar</button>
    </div>

    <div class="options">
      <label class="toggle-label">
        <input
          type="checkbox"
          bind:checked={usePersonalData}
          disabled={!isUnlocked || isLoading}
        />
        <span>Usar mis datos</span>
      </label>
      <small class="explanation">
        La pregunta y tus datos nunca salen de este dispositivo.
        {#if !isUnlocked}
          <br/><span class="locked-warning">(Desbloquea para usar tus datos)</span>
        {/if}
      </small>
    </div>
  </form>

  <div class="answers-list">
    {#if isLoading}
      <div class="loading">Pensando...</div>
    {/if}

    {#each answers as answer, index (answer.question + answer.mode + index)}
      <AnswerCard {answer} />
    {/each}
  </div>
</section>

<style>
  .assistant-area {
    padding: 16px;
    max-width: 600px;
    margin: 0 auto;
    color: var(--oh-text);
  }
  header {
    margin-bottom: 24px;
  }
  h1 {
    margin: 0 0 8px 0;
  }
  .subtitle {
    margin: 0;
    color: var(--oh-muted);
  }
  .ask-form {
    background-color: var(--oh-surface);
    padding: 16px;
    border-radius: var(--oh-radius);
    margin-bottom: 24px;
  }
  label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
  }
  .input-row {
    display: flex;
    gap: 8px;
    margin-bottom: 16px;
  }
  input[type="text"] {
    flex: 1;
    padding: 8px 12px;
    border: 1px solid var(--oh-muted);
    border-radius: var(--oh-radius);
    background-color: var(--oh-bg);
    color: var(--oh-text);
  }
  button {
    padding: 8px 16px;
    background-color: var(--oh-accent);
    color: #fff;
    border: none;
    border-radius: var(--oh-radius);
    cursor: pointer;
    font-weight: 500;
  }
  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .options {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .toggle-label {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 0;
    cursor: pointer;
  }
  .toggle-label input:disabled + span {
    color: var(--oh-muted);
  }
  .explanation {
    color: var(--oh-muted);
    font-size: 0.85em;
    margin-left: 24px; /* match checkbox width approx */
  }
  .locked-warning {
    color: var(--oh-danger);
  }
  .answers-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }
  .loading {
    text-align: center;
    color: var(--oh-muted);
    font-style: italic;
    padding: 16px;
  }
</style>
