export interface KillSwitchStorage {
  getItem(key: string): string | null;
  setItem(key: string, value: string): void;
}

export const AI_ENABLED_KEY = 'orion.ai.enabled';

function defaultStorage(): KillSwitchStorage | null {
  try {
    return (globalThis as { localStorage?: KillSwitchStorage }).localStorage ?? null;
  } catch {
    return null;
  }
}

/** Global AI kill switch. Default OFF: only an explicit '1' enables generative tiers. */
export function isAiEnabled(storage?: KillSwitchStorage | null): boolean {
  const s = storage === undefined ? defaultStorage() : storage;
  try {
    return s?.getItem(AI_ENABLED_KEY) === '1';
  } catch {
    return false;
  }
}

export function setAiEnabled(enabled: boolean, storage?: KillSwitchStorage | null): void {
  const s = storage === undefined ? defaultStorage() : storage;
  try {
    s?.setItem(AI_ENABLED_KEY, enabled ? '1' : '0');
  } catch {
    /* storage unavailable: stays off */
  }
}
