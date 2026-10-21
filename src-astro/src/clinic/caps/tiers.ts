import type { Caps } from './detect';
import type { Budget } from './budgets';

const MB = 1024 ** 2;
const GB = 1024 ** 3;

export type Tier = 'U' | 'L0' | 'L1' | 'L2';

export interface OptIn {
  /** user opted in to semantic search (L1); off by default */
  semantic: boolean;
  /** explicit per-device opt-in to generative summaries (L2); off by default */
  generative: boolean;
}

export interface TierResult {
  tier: Tier;
  l1Eligible: boolean;
  l2Eligible: boolean;
}

export const NO_OPT_IN: OptIn = { semantic: false, generative: false };

export function resolveTier(caps: Caps, budget: Budget, optIn: OptIn = NO_OPT_IN): TierResult {
  if (!caps.supported) return { tier: 'U', l1Eligible: false, l2Eligible: false };

  const l1Eligible =
    caps.simd && budget.profile !== 'low' && caps.freeBytes !== null && caps.freeBytes >= 400 * MB;

  const gpuPath =
    caps.gpu.available &&
    caps.deviceMemory !== null &&
    caps.deviceMemory >= 4 &&
    caps.gpu.maxBufferSize >= GB;
  const l2Eligible = budget.profile !== 'low' && (caps.promptApi === 'available' || gpuPath);

  let tier: Tier = 'L0';
  if (l2Eligible && optIn.generative) tier = 'L2';
  else if (l1Eligible && optIn.semantic) tier = 'L1';
  return { tier, l1Eligible, l2Eligible };
}
