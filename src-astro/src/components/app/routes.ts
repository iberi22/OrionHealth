// Fixed route registry of the /app SPA. Areas own their component file, not this table.
import type { Component } from 'svelte';

export interface AppRoute {
  path: string;
  label: string;
  /** Rendered without the vault being unlocked. */
  public?: boolean;
  /** Shown in the main navigation. */
  nav?: boolean;
  load: () => Promise<{ default: Component<any> }>;
}

export const routes: AppRoute[] = [
  { path: '/app', label: 'Inicio', nav: true, load: () => import('./home/Home.svelte') },
  { path: '/app/onboarding', label: 'Bienvenida', public: true, load: () => import('./onboarding/Onboarding.svelte') },
  { path: '/app/lock', label: 'Desbloquear', public: true, load: () => import('./lock/LockScreen.svelte') },
  { path: '/app/emergency', label: 'Emergencia', nav: true, load: () => import('./emergency/Emergency.svelte') },
  { path: '/app/records', label: 'Historial', nav: true, load: () => import('./records/Records.svelte') },
  { path: '/app/family', label: 'Familia', nav: true, load: () => import('./family/Circle.svelte') },
  { path: '/app/family/permissions', label: 'Permisos', load: () => import('./family/Permissions.svelte') },
  { path: '/app/family/health', label: 'Salud familiar', nav: true, load: () => import('./family/HealthCircle.svelte') },
  { path: '/app/family/guardian', label: 'Acudiente', load: () => import('./family/Guardian.svelte') },
  { path: '/app/recovery', label: 'Recuperación', public: true, load: () => import('./recovery/Recovery.svelte') },
  { path: '/app/join', label: 'Unirse', public: true, load: () => import('./join/Join.svelte') },
  { path: '/app/assistant', label: 'Asistente', nav: true, load: () => import('./assistant/Assistant.svelte') },
  { path: '/app/settings', label: 'Ajustes', nav: true, load: () => import('./settings/Settings.svelte') },
];

export function matchRoute(pathname: string): AppRoute {
  const clean = pathname.replace(/\/+$/, '') || '/app';
  return routes.find((r) => r.path === clean) ?? routes[0]!;
}

/** Client-side navigation used by every area: navigate('/app/family'). */
export function navigate(path: string): void {
  history.pushState({}, '', path);
  dispatchEvent(new PopStateEvent('popstate'));
}
