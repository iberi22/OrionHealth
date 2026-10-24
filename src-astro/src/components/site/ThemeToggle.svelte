<script lang="ts">
  let theme = $state<'light' | 'dark'>('light');
  let mounted = $state(false);

  $effect(() => {
    mounted = true;
    try {
      const stored = localStorage.getItem('oh-theme');
      if (stored === 'light' || stored === 'dark') {
        theme = stored;
      } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        theme = 'dark';
      }
    } catch {
      // Ignore if localStorage is unavailable
    }
  });

  $effect(() => {
    if (mounted) {
      if (theme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
      } else {
        document.documentElement.removeAttribute('data-theme');
      }
    }
  });

  function toggle() {
    theme = theme === 'light' ? 'dark' : 'light';
    try {
      localStorage.setItem('oh-theme', theme);
    } catch {
      // Ignore
    }
  }
</script>

<button class="theme-toggle" onclick={toggle} aria-label="Toggle theme" data-testid="theme-toggle">
  {#if theme === 'dark'}
    <svg class="icon" fill="currentColor" viewBox="0 0 20 20">
      <path d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" fill-rule="evenodd" clip-rule="evenodd"></path>
    </svg>
  {:else}
    <svg class="icon" fill="currentColor" viewBox="0 0 20 20">
      <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
    </svg>
  {/if}
</button>

<style>
  .theme-toggle {
    background: transparent;
    border: none;
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 9999px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--oh-nav-text);
    transition: background-color 0.3s ease, color 0.3s ease;
  }

  .theme-toggle:hover {
    background-color: rgba(16, 185, 129, 0.1);
  }

  .icon {
    width: 1.25rem;
    height: 1.25rem;
  }
</style>
