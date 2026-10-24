import { afterEach, describe, expect, it, vi } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../lib/contracts/services';
import { createMockServices } from '../../lib/contracts/mock';


let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

// Using a mock text element is not straightforward to pass as snippet in Svelte 5 from JS mount.
// A simpler check is that the slot renders.
// We will test slot behavior using another Svelte component as wrapper if needed,
// but since Shell just wraps, we will skip dummy children and focus on what's testable via props.
import DummyWrapper from './__tests__/DummyWrapper.svelte';

describe('Shell', () => {
  it('renders children and navigation for private routes', () => {
    setServices(createMockServices(0));

    app = mount(DummyWrapper, {
      target: document.body,
      props: {
        path: '/app/family'
      }
    });
    flushSync();

    const shellArea = document.querySelector('[data-testid="area-shell"]');
    expect(shellArea).not.toBeNull();
    expect(document.querySelector('[data-testid="child-content"]')).not.toBeNull();

    // Nav should exist
    const nav = document.querySelector('.shell-nav');
    expect(nav).not.toBeNull();

    // Check lock button
    const lockBtn = document.querySelector('.lock-button');
    expect(lockBtn).not.toBeNull();
  });

  it('hides navigation for public routes', () => {
    setServices(createMockServices(0));

    app = mount(DummyWrapper, {
      target: document.body,
      props: {
        path: '/app/lock'
      }
    });
    flushSync();

    // Nav should NOT exist on /app/lock
    const nav = document.querySelector('.shell-nav');
    expect(nav).toBeNull();
  });

  it('calls vault.lock() on lock button click', () => {
    const services = createMockServices(0);
    const lockSpy = vi.spyOn(services.vault, 'lock');
    setServices(services);

    app = mount(DummyWrapper, {
      target: document.body,
      props: {
        path: '/app/family'
      }
    });
    flushSync();

    const lockBtn = document.querySelector('.lock-button') as HTMLButtonElement;
    lockBtn.click();

    expect(lockSpy).toHaveBeenCalled();
  });
});
