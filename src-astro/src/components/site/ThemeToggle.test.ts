import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import ThemeToggle from './ThemeToggle.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
  document.documentElement.removeAttribute('data-theme');
  localStorage.clear();
});

describe('ThemeToggle', () => {
  it('mounts and toggles theme', () => {
    app = mount(ThemeToggle, { target: document.body });
    flushSync();

    const button = document.querySelector('[data-testid="theme-toggle"]') as HTMLButtonElement;
    expect(button).not.toBeNull();

    // Initial state (defaults to light, so theme is light)
    expect(document.documentElement.getAttribute('data-theme')).toBeNull();

    // Toggle
    button.click();
    flushSync();

    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
    expect(localStorage.getItem('oh-theme')).toBe('dark');

    // Toggle back
    button.click();
    flushSync();

    expect(document.documentElement.getAttribute('data-theme')).toBeNull();
    expect(localStorage.getItem('oh-theme')).toBe('light');
  });

  it('respects stored theme', () => {
    localStorage.setItem('oh-theme', 'dark');
    app = mount(ThemeToggle, { target: document.body });
    flushSync();

    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
  });
});
