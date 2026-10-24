<script lang="ts">
  import { getServices } from '../../../lib/contracts/services';
  import { randomBytes, b64u } from '../../../lib/crypto/index';
  import type { CircleState, Initiative, CheckIn, CircleNote } from '../../../lib/contracts/types';

  let { initiative, circle, allCheckIns, allNotes }: { initiative: Initiative; circle: CircleState; allCheckIns: CheckIn[]; allNotes: CircleNote[] } = $props();

  let checkIns = $derived(allCheckIns.filter(c => c.initiativeId === initiative.recordId));
  let notes = $derived(allNotes.filter(n => n.initiativeId === initiative.recordId).sort((a, b) => a.at - b.at));

  // Progress per participant (value / target, max 1.0)
  let progressMap = $derived.by(() => {
    const map: Record<string, number> = {};
    for (const p of initiative.participants) {
      const pCheckIns = checkIns.filter(c => c.member === p);
      const total = pCheckIns.reduce((sum, c) => sum + c.value, 0);
      map[p] = Math.min(total / (initiative.target || 1), 1.0);
    }
    return map;
  });

  let myId = $derived(getServices().vault.memberId());

  let checkInValue = $state(1);
  let checkInMsg = $state('');
  let isCheckingIn = $state(false);

  let newNote = $state('');
  let isPostingNote = $state(false);

  async function addCheckIn(e: Event) {
    e.preventDefault();
    if (!myId || isCheckingIn) return;
    try {
      isCheckingIn = true;
      const recordId = 'ci-' + b64u(randomBytes(12));
      await getServices().health.put({
        kind: 'checkin',
        recordId,
        owner: myId,
        updatedAt: Date.now(),
        initiativeId: initiative.recordId,
        member: myId,
        at: Date.now(),
        value: checkInValue,
        message: checkInMsg || undefined,
      });
      checkInValue = 1;
      checkInMsg = '';
    } catch (err) {
      console.error(err);
    } finally {
      isCheckingIn = false;
    }
  }

  async function addNote(e: Event) {
    e.preventDefault();
    if (!myId || isPostingNote || !newNote.trim()) return;
    try {
      isPostingNote = true;
      const recordId = 'n-' + b64u(randomBytes(12));
      await getServices().health.put({
        kind: 'note',
        recordId,
        owner: myId,
        updatedAt: Date.now(),
        member: myId,
        at: Date.now(),
        text: newNote.trim(),
        initiativeId: initiative.recordId,
      });
      newNote = '';
    } catch (err) {
      console.error(err);
    } finally {
      isPostingNote = false;
    }
  }

  function getMemberName(mId: string) {
    return circle?.members[mId]?.displayName || mId;
  }
</script>

<div class="initiative-card">
  <h4>{initiative.title}</h4>
  <p class="desc">{initiative.description}</p>
  <div class="meta">
    <span>Meta: {initiative.target} {initiative.metric}</span>
    <span>
      {new Date(initiative.startsAt).toLocaleDateString()} - {new Date(initiative.endsAt).toLocaleDateString()}
    </span>
  </div>

  <div class="progress-section">
    <h5>Progreso</h5>
    {#each initiative.participants as p}
      <div class="participant-progress">
        <span class="p-name">{getMemberName(p)}</span>
        <div class="bar-bg" aria-label={`Progreso de ${getMemberName(p)}: ${Math.round((progressMap[p] || 0) * 100)}%`}>
          <div class="bar-fill" style={`width: ${(progressMap[p] || 0) * 100}%`}></div>
        </div>
      </div>
    {/each}
  </div>

  {#if initiative.participants.includes(myId || '')}
    <form class="checkin-form" onsubmit={addCheckIn}>
      <input type="number" bind:value={checkInValue} min="1" required aria-label="Valor de progreso" />
      <input type="text" bind:value={checkInMsg} placeholder="Mensaje (opcional)" />
      <button type="submit" disabled={isCheckingIn}>Avanzar</button>
    </form>
  {/if}

  <div class="notes-feed">
    <h5>Mensajes</h5>
    {#if notes.length === 0}
      <p class="empty">No hay mensajes aún.</p>
    {/if}
    {#each notes as n}
      <div class="note">
        <strong>{getMemberName(n.member)}:</strong> {n.text}
      </div>
    {/each}
    <form class="note-form" onsubmit={addNote}>
      <input type="text" bind:value={newNote} placeholder="Escribe un mensaje de apoyo..." required />
      <button type="submit" disabled={isPostingNote || !newNote.trim()}>Enviar</button>
    </form>
  </div>
</div>

<style>
  .initiative-card {
    background: var(--oh-surface);
    border-radius: var(--oh-radius);
    padding: 1rem;
    margin-bottom: 1rem;
  }
  h4 {
    margin: 0 0 0.5rem;
  }
  .desc {
    margin: 0 0 0.5rem;
    font-size: 0.9rem;
    color: var(--oh-muted);
  }
  .meta {
    display: flex;
    justify-content: space-between;
    font-size: 0.85rem;
    font-weight: 500;
    margin-bottom: 1rem;
    color: var(--oh-text);
  }
  h5 {
    margin: 1rem 0 0.5rem;
    font-size: 0.95rem;
  }
  .participant-progress {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
  }
  .p-name {
    width: 80px;
    font-size: 0.85rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .bar-bg {
    flex: 1;
    background: var(--oh-bg);
    height: 12px;
    border-radius: 6px;
    overflow: hidden;
  }
  .bar-fill {
    background: var(--oh-accent);
    height: 100%;
    transition: width 0.3s;
  }
  .checkin-form {
    display: flex;
    gap: 0.5rem;
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--oh-bg);
  }
  .checkin-form input[type="number"] {
    width: 60px;
  }
  .checkin-form input {
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 6px;
    background: var(--oh-bg);
    color: var(--oh-text);
  }
  .checkin-form input[type="text"] {
    flex: 1;
  }
  button {
    background: var(--oh-accent);
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 500;
  }
  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .notes-feed {
    margin-top: 1rem;
    background: var(--oh-bg);
    padding: 0.75rem;
    border-radius: var(--oh-radius);
  }
  .note {
    font-size: 0.85rem;
    margin-bottom: 0.5rem;
  }
  .empty {
    font-size: 0.85rem;
    color: var(--oh-muted);
  }
  .note-form {
    display: flex;
    gap: 0.5rem;
    margin-top: 0.5rem;
  }
  .note-form input {
    flex: 1;
    padding: 0.5rem;
    border: 1px solid var(--oh-muted);
    border-radius: 6px;
    background: var(--oh-surface);
    color: var(--oh-text);
  }
</style>
