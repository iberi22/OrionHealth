export type FundingClass = 'public' | 'industry' | 'mixed' | 'unknown' | (string & {});

export interface Card {
  id: string;
  title: string;
  doc_type: string;
  published: string | null;
  funding_class: FundingClass;
  retracted: boolean;
  /** Id of the entry this one supersedes (null when none). */
  supersedes: string | null;
  url?: string;
  source?: string;
  icd10?: string[];
  mesh?: string[];
  evidence_level?: { scale: string; level: number | null; grade: string | null } | null;
}

export interface SearchHit {
  entryId: string;
  score: number;
  card: Card;
  chunkIds: string[];
}

export interface ModelPart { url: string; sha256: string; bytes: number }

export interface ShardMeta {
  id: string;
  chapter: string;
  /** Total bytes of the four shard files (vec, bits, meta, lex). */
  bytes: number;
  /** sha256 of the concatenation vec+bits+meta.json.gz+lex.json.gz. */
  sha256: string;
  chunks: number;
  /** sha256 of the model file the shard was embedded with (refused when it differs). */
  model_sha256?: string;
}

export interface CorpusIndex {
  corpus_version: string;
  model: { id: string; revision: string; file_sha256: string; dtype: string; dim: number; parts: ModelPart[] };
  shards: ShardMeta[];
}

export interface InstallProgress { phase: 'model' | 'shards'; file: string; done: number; total: number }

export interface StatusInfo { installed: boolean; version: string | null; shards: string[] }

export type RpcRequest =
  | { id: number; type: 'install'; index: CorpusIndex; baseUrl: string; shardIds: string[] }
  | { id: number; type: 'status' }
  | { id: number; type: 'search'; query: string; k?: number }
  | { id: number; type: 'delete'; version?: string };

export type RpcResult = {
  install: StatusInfo;
  status: StatusInfo;
  search: SearchHit[];
  delete: StatusInfo;
};

export type RpcResponse =
  | { id: number; ok: true; type: keyof RpcResult; result: RpcResult[keyof RpcResult] }
  | { id: number; ok: false; error: string }
  | { id: number; progress: InstallProgress };
