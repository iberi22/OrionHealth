import { createEngine } from './engine';
import { installCorpus } from './installer';
import { CorpusStore, OpfsFileStore } from './opfs-store';
import type { RpcRequest, RpcResponse } from './types';

const store = new CorpusStore(new OpfsFileStore());
const engine = createEngine(store);

type WorkerScope = { postMessage(m: RpcResponse): void; onmessage: ((e: MessageEvent<RpcRequest>) => void) | null };
const ctx = self as unknown as WorkerScope;

ctx.onmessage = async (e) => {
  const req = e.data;
  try {
    switch (req.type) {
      case 'install':
        await installCorpus({
          index: req.index, baseUrl: req.baseUrl, shardIds: req.shardIds, installModel: req.installModel ?? false, store,
          onProgress: (progress) => ctx.postMessage({ id: req.id, progress }),
        });
        engine.invalidate();
        ctx.postMessage({ id: req.id, ok: true, type: 'install', result: await engine.status() });
        break;
      case 'status':
        ctx.postMessage({ id: req.id, ok: true, type: 'status', result: await engine.status() });
        break;
      case 'search':
        ctx.postMessage({ id: req.id, ok: true, type: 'search', result: await engine.search(req.query, req.k) });
        break;
      case 'delete': {
        const v = req.version ?? (await store.activeVersion());
        if (v) await store.removeVersion(v);
        engine.invalidate();
        ctx.postMessage({ id: req.id, ok: true, type: 'delete', result: { installed: false, version: null, shards: [] } });
        break;
      }
    }
  } catch (err) {
    ctx.postMessage({ id: req.id, ok: false, error: err instanceof Error ? err.message : String(err) });
  }
};
