// Pattern for UI tests: mount a Svelte 5 component in jsdom over the demo services.
import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../lib/contracts/services';
import { createMockServices } from '../../lib/contracts/mock';
import { matchRoute, routes } from './routes';
import Home from './home/Home.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('app routes', () => {
  it('falls back to /app and strips trailing slashes', () => {
    expect(matchRoute('/app/family/').path).toBe('/app/family');
    expect(matchRoute('/app/nope').path).toBe('/app');
  });

  it('keeps onboarding, lock, recovery and join public, everything else gated', () => {
    expect(routes.filter((r) => r.public).map((r) => r.path).sort()).toEqual(['/app/join', '/app/lock', '/app/onboarding', '/app/recovery']);
  });

  it('mounts an area component in jsdom', () => {
    setServices(createMockServices(0));
    app = mount(Home, { target: document.body });
    flushSync();
    expect(document.querySelector('[data-testid="area-home"]')).not.toBeNull();
  });
});
