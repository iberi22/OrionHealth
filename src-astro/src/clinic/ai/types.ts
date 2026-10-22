export type AnswerFlag = 'mixed-only' | 'numeric-unverified';

export type Answer =
  | {
      kind: 'generated';
      tier: 'prompt-api' | 'webllm';
      sentences: { text: string; cites: number[]; flags: AnswerFlag[] }[];
    }
  | { kind: 'retrieval-only'; reason: 'no-model' | 'user-off' | 'model-error' | 'ungrounded' | 'timeout' };

export type UiLang = 'es' | 'en';

/** A numbered passage given to the model; its citation number is index + 1. */
export interface Passage {
  text: string;
  funding_class: string;
}
