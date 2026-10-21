import type { Caps } from './detect';

const MB = 1024 ** 2;
const GB = 1024 ** 3;

export type BudgetProfile = 'low' | 'standard' | 'large';

export interface Budget {
  profile: BudgetProfile;
  maxPackBytes: number;
  /** lexical parts kept in RAM (LRU); Infinity = all loaded */
  lexicalPartsInRam: number;
  semanticVisible: boolean;
  generativeVisible: boolean;
}

const PROFILES: Record<BudgetProfile, Budget> = {
  low: { profile: 'low', maxPackBytes: 80 * MB, lexicalPartsInRam: 1, semanticVisible: false, generativeVisible: false },
  standard: { profile: 'standard', maxPackBytes: 400 * MB, lexicalPartsInRam: 4, semanticVisible: true, generativeVisible: true },
  large: { profile: 'large', maxPackBytes: 2 * GB, lexicalPartsInRam: Infinity, semanticVisible: true, generativeVisible: true },
};

export function resolveBudget(caps: Pick<Caps, 'deviceMemory' | 'saveData' | 'quotaBytes'>): Budget {
  const { deviceMemory: mem, saveData, quotaBytes: quota } = caps;
  if ((mem !== null && mem <= 2) || saveData || (quota !== null && quota < GB)) {
    return { ...PROFILES.low };
  }
  if (mem !== null && mem >= 8 && quota !== null && quota >= 4 * GB) {
    return { ...PROFILES.large };
  }
  return { ...PROFILES.standard };
}
