<script lang="ts">
  // SPA root: picks the route, enforces the lock gate, renders the area inside the shell.
  import { onMount } from 'svelte';
  import type { Component } from 'svelte';
  import { getServices, setServices } from '../../lib/contracts/services';
  import { loadServices } from '../../lib/app/services';
  import Shell from './Shell.svelte';
  import { matchRoute, navigate } from './routes';

  let path = $state('/app');
  let View = $state<Component<any> | null>(null);
  let ready = $state(false);

  async function render() {
    path = location.pathname;
    const route = matchRoute(path);
    const vault = getServices().vault;
    if (!route.public && vault.state() !== 'unlocked') {
      navigate(vault.state() === 'empty' || vault.state() === 'unsupported' ? '/app/onboarding' : '/app/lock');
      return;
    }
    View = (await route.load()).default;
  }

  onMount(() => {
    let off = () => {};
    loadServices().then((s) => {
      setServices(s);
      ready = true;
      off = s.vault.onState(() => render());
      render();
    });
    addEventListener('popstate', render);
    return () => {
      removeEventListener('popstate', render);
      off();
    };
  });
</script>

{#if ready && View}
  <Shell {path}>
    <View />
  </Shell>
{/if}
