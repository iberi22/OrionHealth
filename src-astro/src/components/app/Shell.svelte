<script lang="ts">
  // Placeholder of the "shell" area (navigation, header, lock button). Replace entirely; keep the props.
  import type { Snippet } from 'svelte';
  let { path, children }: { path: string; children: Snippet } = $props();
</script>

<div data-testid="area-shell" data-path={path}>
  {@render children()}
</div>
