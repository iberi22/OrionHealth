import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { createRag } from './index';
import type { KbService } from '../contracts/services';
import type { HealthRecord } from '../contracts/types';

describe('RagService', () => {
  let mockKb: KbService;
  let mockPersonalSource: () => Promise<HealthRecord[]>;

  beforeEach(() => {
    mockKb = {
      search: vi.fn().mockResolvedValue([
        {
          entry: {
            id: 'kb-1',
            system: 'icd10',
            code: 'I10',
            title: 'Hipertensión',
            body: 'La hipertensión es una presión arterial alta.'
          },
          score: 0.9
        }
      ]),
      get: vi.fn().mockResolvedValue(null)
    };

    mockPersonalSource = vi.fn().mockResolvedValue([
      {
        kind: 'medication',
        recordId: 'med-1',
        owner: 'me',
        updatedAt: Date.now(),
        name: 'Losartán',
        dose: '50 mg',
        schedule: 'Diario',
        active: true
      } as HealthRecord
    ]);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('Test 1: Ask relying only on KB returns extractive answer with KB citations', async () => {
    const rag = createRag({ kb: mockKb, personalSource: mockPersonalSource });
    const answer = await rag.ask('¿Qué es la hipertensión?');

    expect(answer.mode).toBe('extractive');
    expect(answer.usedPersonalData).toBe(false);
    expect(answer.citations.length).toBe(1);
    expect(answer.citations[0].source).toBe('kb');
    expect(answer.answer).toContain('hipertensión');
    expect(answer.answer).toContain('Esto no reemplaza el consejo de un profesional de salud.');

    expect(mockKb.search).toHaveBeenCalledWith('¿Qué es la hipertensión?', { limit: 5 });
    expect(mockPersonalSource).not.toHaveBeenCalled();
  });

  it('Test 2: Ask relying on personal data without includePersonal doesn\'t call personalSource', async () => {
    const rag = createRag({ kb: mockKb, personalSource: mockPersonalSource });
    const answer = await rag.ask('¿Qué medicamento tomo?', { includePersonal: false });

    expect(answer.usedPersonalData).toBe(false);
    expect(mockPersonalSource).not.toHaveBeenCalled();
    // It should still fallback to KB citations if available
    expect(answer.citations.length).toBe(1);
    expect(answer.citations[0].source).toBe('kb');
  });

  it('Test 3: Ask with includePersonal retrieves from both KB and vault, usedPersonalData: true', async () => {
    const rag = createRag({ kb: mockKb, personalSource: mockPersonalSource });
    const answer = await rag.ask('Losartán y presión alta', { includePersonal: true });

    expect(answer.usedPersonalData).toBe(true);
    expect(mockPersonalSource).toHaveBeenCalled();
    expect(answer.citations.length).toBeGreaterThan(0);
    const hasVault = answer.citations.some(c => c.source === 'vault');
    const hasKb = answer.citations.some(c => c.source === 'kb');
    expect(hasVault).toBe(true);
    expect(hasKb).toBe(true);
    expect(answer.answer).toContain('Losartán');
    expect(answer.answer).toContain('Esto no reemplaza el consejo de un profesional de salud.');
  });

  it('Test 4: When nothing relevant is found, returns fallback message with no citations', async () => {
    mockKb.search = vi.fn().mockResolvedValue([]);
    const rag = createRag({ kb: mockKb });

    const answer = await rag.ask('xyz');

    expect(answer.answer).toBe('No encontré información suficiente. Esto no reemplaza el consejo de un profesional de salud.');
    expect(answer.citations.length).toBe(0);
  });

  it('Test 5: Verify that the network is never called', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch');
    const rag = createRag({ kb: mockKb, personalSource: mockPersonalSource });
    await rag.ask('¿Qué es la hipertensión?', { includePersonal: true });

    expect(fetchSpy).not.toHaveBeenCalled();
    fetchSpy.mockRestore();
  });
});
