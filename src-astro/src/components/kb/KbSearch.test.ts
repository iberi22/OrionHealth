import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../lib/contracts/services';
import { createMockServices } from '../../lib/contracts/mock';
import KbSearch from './KbSearch.svelte';
import KbEntryView from './KbEntryView.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
  window.location.hash = ''; // reset hash
});

describe('KbSearch', () => {
  it('mounts the search component when there is no hash', async () => {
    setServices(createMockServices(0));
    app = mount(KbSearch, { target: document.body });
    flushSync();

    // Wait for services initialization tick
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(document.querySelector('[data-testid="kb-search"]')).not.toBeNull();
    const input = document.querySelector('.search-input');
    expect(input).not.toBeNull();
  });

  it('renders search results when query matches', async () => {
    setServices(createMockServices(0));
    app = mount(KbSearch, { target: document.body });
    flushSync();

    // Wait for services initialization tick
    await new Promise((resolve) => setTimeout(resolve, 0));

    const input = document.querySelector('.search-input') as HTMLInputElement;
    input.value = 'hipertensión';
    input.dispatchEvent(new window.Event('input', { bubbles: true }));

    // Wait for debounce and search
    await new Promise((resolve) => setTimeout(resolve, 200));
    flushSync();

    const results = document.querySelectorAll('.result-item');
    expect(results.length).toBeGreaterThan(0);
    expect(document.body.textContent).toContain('Hipertensión esencial');
  });
});

describe('KbEntryView', () => {
  it('mounts and loads entry data correctly', async () => {
    setServices(createMockServices(0));
    app = mount(KbEntryView, { target: document.body, props: { id: 'icd10:I10' } });
    flushSync();

    // Wait for fetch
    await new Promise((resolve) => setTimeout(resolve, 0));
    flushSync();

    expect(document.querySelector('[data-testid="kb-entry-view"]')).not.toBeNull();
    expect(document.body.textContent).toContain('Hipertensión esencial');
    expect(document.body.textContent).toContain('I10');
  });
});
