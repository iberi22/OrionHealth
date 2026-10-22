import { describe, expect, it } from 'vitest';
import { applyGrounding, withTimeout, INSUFFICIENT_ES } from './grounding';
import { checkPromptApi } from './prompt-api';
import { checkWebLlm, WEBLLM_MODEL_ID } from './webllm';
import { answerQuestion } from './tiers';
import { isAiEnabled, setAiEnabled } from './kill-switch';
import { systemPrompt } from './prompts';

const passages = [
  { text: 'Metformin 500 mg twice daily is first line.', funding_class: 'public' },
  { text: 'Industry-linked trial reported 12% reduction.', funding_class: 'mixed' },
];

describe('grounding', () => {
  it('drops uncited sentences and keeps cited ones', () => {
    const a = applyGrounding('Metformin is first line [1]. Random claim. It helps [1].', passages);
    expect(a.kind).toBe('generated');
    if (a.kind === 'generated') expect(a.sentences.map((s) => s.cites)).toEqual([[1], [1]]);
  });
  it('ungrounded when fewer than 60% survive', () => {
    const a = applyGrounding('No cite. Another none. Cited [1].', passages);
    expect(a).toEqual({ kind: 'retrieval-only', reason: 'ungrounded' });
  });
  it('invalid citation index is dropped', () => {
    expect(applyGrounding('Claim [9].', passages)).toEqual({ kind: 'retrieval-only', reason: 'ungrounded' });
  });
  it('flags numbers not verbatim in cited passage', () => {
    const a = applyGrounding('Dose is 500 mg [1]. Dose is 850 mg [1].', passages);
    if (a.kind !== 'generated') throw new Error('x');
    expect(a.sentences[0].flags).toEqual([]);
    expect(a.sentences[1].flags).toContain('numeric-unverified');
  });
  it('numbers are whole tokens with units', () => {
    const flag = (claim: string, passage: string) => {
      const a = applyGrounding(`${claim} [1].`, [{ text: passage, funding_class: 'public' }]);
      if (a.kind !== 'generated') throw new Error('x');
      return a.sentences[0].flags.includes('numeric-unverified');
    };
    expect(flag('Dose is 5 mg', 'Give 50 mg daily')).toBe(true);
    expect(flag('Dose is 50 mg', 'Give 50 mg daily')).toBe(false);
    expect(flag('Dose is 5', 'Give 2.5 daily')).toBe(true);
    expect(flag('Dose is 5 mg', 'Give 5 g daily')).toBe(true);
    expect(flag('Dose is 5,5 mg', 'Give 5.5 mg daily')).toBe(false);
  });
  it('flags mixed-only', () => {
    const a = applyGrounding('Reduction seen with 12% [2].', passages);
    if (a.kind !== 'generated') throw new Error('x');
    expect(a.sentences[0].flags).toEqual(['mixed-only']);
  });
  it('honours insufficient evidence reply', () => {
    expect(applyGrounding(INSUFFICIENT_ES, passages)).toEqual({ kind: 'retrieval-only', reason: 'ungrounded' });
    expect(applyGrounding('Insufficient evidence in the offline library', passages).kind).toBe('retrieval-only');
  });
  it('times out after the limit', async () => {
    await expect(withTimeout(new Promise(() => {}), 10)).rejects.toThrow('timeout');
  });
});

describe('prompt api', () => {
  it('maps availability and passes expected langs', async () => {
    let seen: any;
    const lm = { availability: async (o: any) => ((seen = o), 'downloadable') };
    expect(await checkPromptApi('es', lm)).toBe('downloadable');
    expect(seen.expectedOutputs[0].languages).toEqual(['es']);
    expect(seen.expectedInputs[0].languages).toEqual(['en', 'es']);
    expect(await checkPromptApi('es', undefined)).toBe('unavailable');
  });
});

describe('webllm gate', () => {
  const ok = { gpu: true, deviceMemory: 8, maxBufferSize: 2 ** 31 };
  it('requires gpu, memory and buffer', () => {
    expect(checkWebLlm(ok)).toBe(true);
    expect(checkWebLlm({ ...ok, gpu: false })).toBe(false);
    expect(checkWebLlm({ ...ok, deviceMemory: 2 })).toBe(false);
    expect(checkWebLlm({ ...ok, maxBufferSize: 2 ** 20 })).toBe(false);
    expect(WEBLLM_MODEL_ID).toBe('Qwen2.5-1.5B-Instruct-q4f16_1-MLC');
  });
});

describe('tiers', () => {
  const mem = () => {
    const m = new Map<string, string>();
    return { getItem: (k: string) => m.get(k) ?? null, setItem: (k: string, v: string) => void m.set(k, v) };
  };
  const on = mem();
  setAiEnabled(true, on);
  const base = { question: 'q', passages, uiLang: 'en' as const, aiOptIn: true, killSwitchStorage: on };
  it('prefers prompt api', async () => {
    const a = await answerQuestion({
      ...base,
      promptApi: { availability: async () => 'available', generate: async () => 'Metformin is first line [1].' },
    });
    expect(a.kind === 'generated' && a.tier).toBe('prompt-api');
  });
  it('falls to webllm only when opted in', async () => {
    const webllm = { capable: true, generate: async () => 'Metformin is first line [1].' };
    expect((await answerQuestion({ ...base, webllm, webllmOptIn: false })).kind).toBe('retrieval-only');
    const a = await answerQuestion({ ...base, webllm, webllmOptIn: true });
    expect(a.kind === 'generated' && a.tier).toBe('webllm');
  });
  it('available prompt api without opt-in is retrieval-only/user-off', async () => {
    let called = false;
    const promptApi = {
      availability: async () => 'available',
      generate: async () => ((called = true), 'Metformin is first line [1].'),
    };
    expect(await answerQuestion({ ...base, aiOptIn: undefined, promptApi })).toEqual({ kind: 'retrieval-only', reason: 'user-off' });
    expect(called).toBe(false);
  });
  it('kill switch off (default) calls nothing', async () => {
    let calls = 0;
    const promptApi = { availability: async () => (calls++, 'available'), generate: async () => (calls++, 'x [1].') };
    const webllm = { get capable() { calls++; return true; }, generate: async () => (calls++, 'x [1].') };
    const off = mem();
    const r = { ...base, killSwitchStorage: off, promptApi, webllm, webllmOptIn: true };
    expect(isAiEnabled(off)).toBe(false);
    expect(await answerQuestion(r)).toEqual({ kind: 'retrieval-only', reason: 'user-off' });
    setAiEnabled(true, off);
    setAiEnabled(false, off);
    expect(await answerQuestion(r)).toEqual({ kind: 'retrieval-only', reason: 'user-off' });
    expect(calls).toBe(0);
  });
  it('reasons: no-model, user-off, model-error, timeout', async () => {
    expect(await answerQuestion(base)).toEqual({ kind: 'retrieval-only', reason: 'no-model' });
    expect(await answerQuestion({ ...base, webllm: { capable: true, generate: async () => '' } })).toEqual({
      kind: 'retrieval-only',
      reason: 'user-off',
    });
    const bad = { availability: async () => 'available', generate: async () => { throw new Error('boom'); } };
    expect(await answerQuestion({ ...base, promptApi: bad })).toEqual({ kind: 'retrieval-only', reason: 'model-error' });
    const slow = { availability: async () => 'available', generate: () => new Promise<string>(() => {}) };
    expect(await answerQuestion({ ...base, promptApi: slow, timeoutMs: 10 })).toEqual({
      kind: 'retrieval-only',
      reason: 'timeout',
    });
  });
});

describe('prompts', () => {
  it('has es and en', () => {
    expect(systemPrompt('es')).toContain(INSUFFICIENT_ES);
    expect(systemPrompt('en')).toContain('Insufficient evidence in the offline library');
  });
});

describe('no placeholder answers', () => {
  it('non-test sources avoid forbidden words', () => {
    const files = import.meta.glob('./*.ts', { query: '?raw', import: 'default', eager: true }) as Record<string, string>;
    const names = Object.keys(files).filter((f) => !f.endsWith('.test.ts'));
    expect(names.length).toBeGreaterThan(0);
    for (const f of names) expect(files[f], f).not.toMatch(/stub|mock|placeholder/i);
  });
});
