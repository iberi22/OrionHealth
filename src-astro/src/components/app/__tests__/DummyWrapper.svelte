<script lang="ts">
  import Shell from '../Shell.svelte';
  let { path }: { path: string } = $props();
</script>

<Shell {path}>
  <div data-testid="child-content">Child Content</div>
</Shell>
