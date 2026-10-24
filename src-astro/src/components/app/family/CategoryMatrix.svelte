<script lang="ts">
  import type { Member, Grant, PersonalCategory } from '../../../lib/contracts/types';
  import { CATEGORY_LABELS } from './categoryLabels';

  let {
    members = [],
    grantsGiven = [],
    categories = [],
  }: {
    members: Member[];
    grantsGiven: Grant[];
    categories: PersonalCategory[];
  } = $props();

  function getAccessLevel(memberId: string, category: PersonalCategory): 'write' | 'read' | 'none' {
    const grants = grantsGiven.filter((g) => g.to === memberId && g.category === category);
    if (grants.some((g) => g.access === 'write')) return 'write';
    if (grants.some((g) => g.access === 'read')) return 'read';
    return 'none';
  }
</script>

<div class="matrix-container">
  <table>
    <thead>
      <tr>
        <th>Categoría</th>
        {#each members as member (member.memberId)}
          <th>{member.displayName}</th>
        {/each}
      </tr>
    </thead>
    <tbody>
      {#each categories as category (category)}
        <tr>
          <td>
            <span class="category-label" title={CATEGORY_LABELS[category].description}>
              {CATEGORY_LABELS[category].label}
            </span>
          </td>
          {#each members as member (member.memberId)}
            {@const access = getAccessLevel(member.memberId, category)}
            <td class="access-cell">
              {#if access === 'write'}
                <svg
                  aria-label="Lectura y escritura"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="var(--oh-accent)"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M12 20h9"></path>
                  <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
                </svg>
              {:else if access === 'read'}
                <svg
                  aria-label="Solo lectura"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="var(--oh-secondary)"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
                  <circle cx="12" cy="12" r="3"></circle>
                </svg>
              {:else}
                <svg
                  aria-label="Sin acceso"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="var(--oh-muted)"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
              {/if}
            </td>
          {/each}
        </tr>
      {/each}
    </tbody>
  </table>
</div>

<style>
  .matrix-container {
    overflow-x: auto;
    margin-bottom: 2rem;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
    min-width: 360px;
  }
  th, td {
    padding: 0.75rem;
    border-bottom: 1px solid var(--oh-surface);
  }
  th {
    font-weight: 600;
    color: var(--oh-text);
  }
  .category-label {
    cursor: help;
  }
  .access-cell {
    text-align: center;
  }
</style>
