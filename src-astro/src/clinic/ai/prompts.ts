import { INSUFFICIENT_EN, INSUFFICIENT_ES } from './grounding';
import type { Passage, UiLang } from './types';

export function systemPrompt(lang: UiLang): string {
  if (lang === 'es') {
    return (
      'Eres un asistente de evidencia clínica sin conexión. Responde solo con los pasajes numerados. ' +
      'Termina cada oración con una cita [n] válida. No añadas datos, cifras ni dosis que no aparezcan en el pasaje citado. ' +
      `Si los pasajes no responden la pregunta, responde exactamente: "${INSUFFICIENT_ES}".`
    );
  }
  return (
    'You are an offline clinical evidence assistant. Answer only from the numbered passages. ' +
    'End every sentence with a valid [n] citation. Do not add facts, numbers or doses absent from the cited passage. ' +
    `If the passages do not answer the question, reply exactly: "${INSUFFICIENT_EN}".`
  );
}

export function userPrompt(question: string, passages: Passage[]): string {
  return passages.map((p, i) => `[${i + 1}] ${p.text}`).join('\n') + `\n\n${question}`;
}
