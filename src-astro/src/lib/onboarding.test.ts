import { describe, it, expect } from 'vitest';
import { ONBOARDING_STEPS, onboardingStepIds } from './onboarding';
import * as fs from 'node:fs';
import * as path from 'node:path';

describe('Onboarding Module', () => {
  it('should have correct step ids in order', () => {
    const expectedIds = ['no-account', 'on-device', 'local-ai', 'device-lock', 'own-your-data'];
    expect(onboardingStepIds()).toEqual(expectedIds);
    expect(ONBOARDING_STEPS.map(s => s.id)).toEqual(expectedIds);
  });

  it('should have non-empty title and body for each step', () => {
    for (const step of ONBOARDING_STEPS) {
      expect(step.title.trim().length).toBeGreaterThan(0);
      expect(step.body.trim().length).toBeGreaterThan(0);
    }
  });

  it('should contain required phrases in joined copy', () => {
    const fullText = ONBOARDING_STEPS.map(s => `${s.title} ${s.body}`).join(' ').toLowerCase();

    // Check for "sin registro" OR "sin cuenta"
    const hasNoAccount = fullText.includes('sin registro') || fullText.includes('sin cuenta');
    expect(hasNoAccount).toBe(true);

    // Check for "en tu dispositivo"
    expect(fullText).toContain('en tu dispositivo');
  });

  it('should not contain forbidden phrases like cuota, suscripcion obligatoria, etc', () => {
    const fullText = ONBOARDING_STEPS.map(s => `${s.title} ${s.body}`).join(' ').toLowerCase();

    const forbiddenRegex = /cuota|cupo diario|suscripción obligatoria|registro obligatorio/i;
    expect(fullText).not.toMatch(forbiddenRegex);
  });

  it('should integrate with index.astro to render steps', () => {
    let indexSource = '';
    try {
      indexSource = fs.readFileSync(path.resolve(process.cwd(), 'src-astro/src/pages/index.astro'), 'utf-8');
    } catch (err) {
      try {
        indexSource = fs.readFileSync(path.resolve(process.cwd(), 'src/pages/index.astro'), 'utf-8');
      } catch (err2) {
        throw new Error('Could not find index.astro file');
      }
    }

    expect(indexSource).toContain('id="onboarding"');
    expect(indexSource).toContain('ONBOARDING_STEPS.map(');
  });
});
