<script lang="ts">
  import type { Snippet } from 'svelte';
  import { matchRoute, routes, navigate } from './routes';
  import { getServices } from '../../lib/contracts/services';

  let { path, children }: { path: string; children: Snippet } = $props();

  let isPublic = $derived(matchRoute(path).public === true);
  let navRoutes = routes.filter((r) => r.nav);

  const services = getServices();
  const isDemo = 'demo' in services && (services as any).demo === true;

  function lockVault() {
    getServices().vault.lock();
    navigate('/app/lock');
  }

  function handleNav(e: MouseEvent, targetPath: string) {
    e.preventDefault();
    navigate(targetPath);
  }
</script>

<div class="shell-container" data-testid="area-shell" data-path={path}>
  {#if isDemo}
    <div class="demo-banner">Modo demo: no se guarda ningún dato</div>
  {/if}

  {#if !isPublic}
    <nav class="shell-nav" aria-label="Navegación principal">
      <ul class="nav-list">
        {#each navRoutes as route}
          <li>
            <a
              href={route.path}
              class="nav-link"
              class:active={path === route.path || (route.path !== '/app' && path.startsWith(route.path))}
              onclick={(e) => handleNav(e, route.path)}
            >
              {route.label}
            </a>
          </li>
        {/each}
        <li class="nav-lock">
          <button class="lock-button" onclick={lockVault} aria-label="Bloquear bóveda">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
              <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
            </svg>
            <span class="lock-label">Bloquear</span>
          </button>
        </li>
      </ul>
    </nav>
  {/if}

  <main class="shell-content" class:public-layout={isPublic}>
    {@render children()}
  </main>
</div>

<style>
  .shell-container {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background-color: var(--oh-bg);
    color: var(--oh-text);
    font-family: var(--oh-font-sans);
  }

  .demo-banner {
    background-color: var(--oh-warning, #f57c00);
    color: white;
    text-align: center;
    padding: 0.5rem;
    font-weight: bold;
    font-size: 0.875rem;
  }

  .shell-content {
    flex: 1;
    padding: 1rem;
    padding-bottom: calc(1rem + 60px); /* Space for bottom nav on mobile */
    overflow-y: auto;
  }

  .shell-content.public-layout {
    padding-bottom: 1rem; /* No bottom nav */
  }

  .shell-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background-color: var(--oh-surface);
    border-top: 1px solid var(--oh-muted);
    z-index: 100;
  }

  .nav-list {
    display: flex;
    margin: 0;
    padding: 0;
    list-style: none;
    overflow-x: auto;
    /* Hide scrollbar for nav */
    scrollbar-width: none;
    -ms-overflow-style: none;
  }

  .nav-list::-webkit-scrollbar {
    display: none;
  }

  .nav-link, .lock-button {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 0.5rem 1rem;
    color: var(--oh-text);
    text-decoration: none;
    font-size: 0.875rem;
    min-width: 72px;
    background: none;
    border: none;
    cursor: pointer;
  }

  .nav-link.active {
    color: var(--oh-accent);
    font-weight: bold;
  }

  .nav-link:focus-visible, .lock-button:focus-visible {
    outline: 2px solid var(--oh-accent);
    border-radius: var(--oh-radius);
  }

  .lock-button {
    color: var(--oh-danger);
  }

  .lock-label {
    margin-top: 0.25rem;
    font-size: 0.75rem;
  }

  /* Desktop layout (side rail) */
  @media (min-width: 768px) {
    .shell-container {
      flex-direction: row;
    }

    .shell-content {
      padding-bottom: 1rem; /* No bottom nav space needed */
    }

    .shell-nav {
      position: static;
      width: 200px;
      border-top: none;
      border-right: 1px solid var(--oh-muted);
    }

    .nav-list {
      flex-direction: column;
      height: 100%;
      overflow-x: visible;
    }

    .nav-link, .lock-button {
      flex-direction: row;
      justify-content: flex-start;
      padding: 1rem;
      font-size: 1rem;
    }

    .lock-label {
      margin-top: 0;
      margin-left: 0.5rem;
      font-size: 1rem;
    }

    .nav-lock {
      margin-top: auto;
    }
  }
</style>
