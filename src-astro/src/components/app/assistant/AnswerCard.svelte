<script lang="ts">
  import type { RagAnswer, Citation } from '../../../lib/contracts/types';

  interface Props {
    answer: RagAnswer;
  }

  const { answer }: Props = $props();
</script>

<div class="answer-card">
  <div class="header">
    <div class="question">{answer.question}</div>
    <span class="badge {answer.mode}">{answer.mode === 'extractive' ? 'Extractivo' : 'Local LLM'}</span>
  </div>

  <div class="body">
    <p>{answer.answer}</p>
  </div>

  {#if answer.citations.length > 0}
    <div class="citations">
      <strong>Fuentes:</strong>
      <ul>
        {#each answer.citations as citation}
          <li>
            <a href={citation.source === 'kb' ? `/kb#${citation.id}` : `/app/records#${citation.id}`}>
              {citation.title}
            </a>
            <span class="snippet">- {citation.snippet}</span>
          </li>
        {/each}
      </ul>
    </div>
  {/if}

  {#if answer.usedPersonalData}
    <div class="footer-note">
      <small>Se utilizaron tus datos personales para esta respuesta.</small>
    </div>
  {/if}
</div>

<style>
  .answer-card {
    background-color: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 16px;
    margin-bottom: 16px;
    color: var(--oh-text);
  }
  .header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
  }
  .question {
    font-weight: bold;
    font-size: 1.1em;
  }
  .badge {
    font-size: 0.75rem;
    padding: 2px 6px;
    border-radius: 8px;
    background-color: var(--oh-accent);
    color: #fff;
    white-space: nowrap;
    margin-left: 8px;
  }
  .badge.local-llm {
    background-color: var(--oh-secondary);
  }
  .body p {
    margin: 0 0 12px 0;
    line-height: 1.4;
  }
  .citations {
    font-size: 0.9em;
    border-top: 1px solid var(--oh-muted);
    padding-top: 8px;
  }
  .citations ul {
    list-style: none;
    padding: 0;
    margin: 8px 0 0 0;
  }
  .citations li {
    margin-bottom: 4px;
  }
  .citations a {
    color: var(--oh-accent);
    text-decoration: none;
  }
  .citations a:hover {
    text-decoration: underline;
  }
  .snippet {
    color: var(--oh-muted);
  }
  .footer-note {
    margin-top: 12px;
    color: var(--oh-muted);
    font-style: italic;
  }
</style>
