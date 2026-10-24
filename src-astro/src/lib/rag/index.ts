import MiniSearch from 'minisearch';
import type { HealthRecord, RagAnswer, Citation } from '../contracts/types';
import type { RagService, KbService } from '../contracts/services';

export interface LlmProvider {
  available(): Promise<boolean>;
  generate(prompt: string): Promise<string>;
}

export function chunkRecords(records: HealthRecord[]): { id: string, title: string, text: string, recordId: string }[] {
  const chunks: { id: string, title: string, text: string, recordId: string }[] = [];

  for (const r of records) {
    if (r.deleted) continue;

    let title = '';
    let text = '';

    switch (r.kind) {
      case 'medical-id':
        title = 'Perfil Médico';
        text = `Nombre: ${r.fullName}. Condiciones: ${r.conditions.join(', ')}. Alergias: ${r.allergies.join(', ')}. Medicamentos: ${r.medications.join(', ')}. Notas: ${r.notes || ''}`;
        break;
      case 'condition':
        title = `Condición: ${r.name}`;
        text = `Condición: ${r.name}. CIE-10: ${r.icd10 || ''}. Desde: ${r.since || ''}. Notas: ${r.notes || ''}`;
        break;
      case 'medication':
        title = `Medicamento: ${r.name}`;
        text = `Medicamento: ${r.name}. Dosis: ${r.dose}. Horario: ${r.schedule}. Activo: ${r.active ? 'Sí' : 'No'}.`;
        break;
      case 'allergy':
        title = `Alergia: ${r.substance}`;
        text = `Alergia a: ${r.substance}. Severidad: ${r.severity}. Reacción: ${r.reaction || ''}`;
        break;
      case 'vital':
        title = `Signo vital: ${r.type}`;
        text = `Tipo: ${r.type}. Valor: ${r.value} ${r.value2 ? '/ ' + r.value2 : ''} ${r.unit}.`;
        break;
      case 'document':
        title = `Documento: ${r.title}`;
        text = `Documento: ${r.title}`;
        break;
      case 'appointment':
        title = `Cita: ${r.title}`;
        text = `Cita: ${r.title}. Lugar: ${r.place || ''}. Notas: ${r.notes || ''}`;
        break;
      case 'habit':
        title = `Hábito: ${r.name}`;
        text = `Hábito: ${r.name}. Meta: ${r.target} ${r.unit}.`;
        break;
      case 'meal':
        title = 'Comida';
        text = `Comida: ${r.description}. Etiquetas: ${r.tags.join(', ')}`;
        break;
      case 'mood':
        title = 'Estado de ánimo';
        text = `Ánimo (1-5): ${r.score}. Notas: ${r.note || ''}`;
        break;
    }

    chunks.push({
      id: r.recordId,
      title,
      text,
      recordId: r.recordId
    });
  }

  return chunks;
}

export function extractiveAnswer(
  question: string,
  passages: { id: string, title: string, snippet: string, source: 'kb' | 'vault' }[]
): { answer: string, citations: Citation[] } {
  const queryTerms = question.toLowerCase().replace(/[^\w\s\u00C0-\u017F]/g, '').split(/\s+/).filter(t => t.length > 2);

  let answerText = '';
  const citations: Citation[] = [];

  const disclaimer = ' Esto no reemplaza el consejo de un profesional de salud.';

  if (passages.length === 0) {
    return {
      answer: 'No encontré información suficiente.' + disclaimer,
      citations: []
    };
  }

  for (const passage of passages.slice(0, 3)) {
    const sentences = passage.snippet.split(/(?<=[.!?])\s+/);

    let matchedSentences = sentences;
    if (queryTerms.length > 0) {
       matchedSentences = sentences.filter(s => {
         const lower = s.toLowerCase();
         return queryTerms.some(term => lower.includes(term));
       });
       if (matchedSentences.length === 0) matchedSentences = sentences.slice(0, 1);
    }

    const textToAdd = matchedSentences.join(' ');

    if (textToAdd) {
      if (answerText.length > 0) answerText += ' ';

      const newLen = answerText.length + textToAdd.length + disclaimer.length;
      if (newLen > 600) {
        const remaining = 600 - disclaimer.length - answerText.length - 4; // 4 for " ..."
        if (remaining > 10) {
           answerText += textToAdd.substring(0, remaining) + '...';
           citations.push({
             source: passage.source,
             id: passage.id,
             title: passage.title,
             snippet: textToAdd
           });
        }
        break;
      } else {
        answerText += textToAdd;
        citations.push({
          source: passage.source,
          id: passage.id,
          title: passage.title,
          snippet: textToAdd
        });
      }
    }
  }

  if (answerText.length === 0) {
    return {
      answer: 'No encontré información suficiente.' + disclaimer,
      citations: []
    };
  }

  return {
    answer: answerText + disclaimer,
    citations
  };
}

export function createRag(opts: {
  kb: KbService;
  personalSource?: () => Promise<HealthRecord[]>;
  llm?: LlmProvider;
}): RagService {
  return {
    async ask(question: string, askOpts?: { includePersonal?: boolean }): Promise<RagAnswer> {
      let usedPersonalData = false;

      const kbHits = await opts.kb.search(question, { limit: 5 });
      const passages: { id: string, title: string, snippet: string, source: 'kb' | 'vault', score: number }[] = kbHits.map(hit => ({
        id: hit.entry.id,
        title: hit.entry.title,
        snippet: hit.entry.body,
        source: 'kb' as const,
        score: hit.score
      }));

      if (askOpts?.includePersonal && opts.personalSource) {
        const records = await opts.personalSource();
        usedPersonalData = true;

        const chunks = chunkRecords(records);

        if (chunks.length > 0) {
          const miniSearch = new MiniSearch({
            fields: ['title', 'text'],
            storeFields: ['title', 'text', 'recordId']
          });
          miniSearch.addAll(chunks);

          const searchResults = miniSearch.search(question, { prefix: true, fuzzy: 0.2 });

          for (const res of searchResults) {
            passages.push({
              id: res.recordId,
              title: res.title,
              snippet: res.text,
              source: 'vault' as const,
              score: res.score
            });
          }
        }
      }

      passages.sort((a, b) => b.score - a.score);

      const topPassages = passages.map(p => ({
        id: p.id,
        title: p.title,
        snippet: p.snippet,
        source: p.source
      }));

      const isLlmAvailable = opts.llm ? await opts.llm.available() : false;

      if (!isLlmAvailable) {
        const { answer, citations } = extractiveAnswer(question, topPassages);
        return {
          question,
          answer,
          mode: 'extractive',
          citations,
          usedPersonalData
        };
      }

      // Local LLM branch
      const contextText = topPassages.slice(0, 5).map((p, i) => `[${i+1}] ${p.title}: ${p.snippet}`).join('\n');
      const prompt = `Usa esta información para responder brevemente:\n\n${contextText}\n\nPregunta: ${question}`;

      let llmAnswer = await opts.llm!.generate(prompt);
      const disclaimer = ' Esto no reemplaza el consejo de un profesional de salud.';
      if (!llmAnswer.endsWith(disclaimer)) {
        llmAnswer += disclaimer;
      }

      return {
        question,
        answer: llmAnswer,
        mode: 'local-llm',
        citations: topPassages.slice(0, 3).map(p => ({
          source: p.source,
          id: p.id,
          title: p.title,
          snippet: p.snippet
        })),
        usedPersonalData
      };
    },

    async localLlmAvailable(): Promise<boolean> {
      if (!opts.llm) return false;
      return await opts.llm.available();
    }
  };
}
