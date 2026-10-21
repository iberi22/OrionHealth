import { sha256Hex } from './hash';

/** Minimal flat file API (paths like `v1/a.bin`). */
export interface FileStore {
  write(path: string, data: Uint8Array): Promise<void>;
  read(path: string): Promise<Uint8Array | null>;
  /** Remove every file whose path starts with `prefix`. */
  removePrefix(prefix: string): Promise<void>;
  list(prefix: string): Promise<string[]>;
}

export class MemoryFileStore implements FileStore {
  private files = new Map<string, Uint8Array>();
  async write(path: string, data: Uint8Array) { this.files.set(path, data.slice()); }
  async read(path: string) { return this.files.get(path)?.slice() ?? null; }
  async removePrefix(prefix: string) {
    for (const k of [...this.files.keys()]) if (k.startsWith(prefix)) this.files.delete(k);
  }
  async list(prefix: string) { return [...this.files.keys()].filter((k) => k.startsWith(prefix)); }
}

interface SyncHandle {
  write(b: Uint8Array, o?: { at: number }): number;
  read(b: Uint8Array, o?: { at: number }): number;
  truncate(n: number): void;
  getSize(): number;
  flush(): void;
  close(): void;
}
interface FileHandleLike {
  createSyncAccessHandle?: () => Promise<SyncHandle>;
  createWritable?: () => Promise<{ write(d: Uint8Array): Promise<void>; close(): Promise<void> }>;
  getFile(): Promise<{ arrayBuffer(): Promise<ArrayBuffer> }>;
}
interface DirHandleLike {
  getDirectoryHandle(n: string, o?: { create?: boolean }): Promise<DirHandleLike>;
  getFileHandle(n: string, o?: { create?: boolean }): Promise<FileHandleLike>;
  removeEntry(n: string, o?: { recursive?: boolean }): Promise<void>;
  keys(): AsyncIterable<string>;
}

/** OPFS-backed store. Uses createSyncAccessHandle (worker) with a createWritable fallback. */
export class OpfsFileStore implements FileStore {
  constructor(private rootPromise: Promise<unknown> = (navigator as unknown as { storage: { getDirectory(): Promise<unknown> } }).storage.getDirectory()) {}

  private async dir(parts: string[], create: boolean): Promise<DirHandleLike | null> {
    let d = (await this.rootPromise) as DirHandleLike;
    for (const p of parts) {
      try { d = await d.getDirectoryHandle(p, { create }); } catch { return null; }
    }
    return d;
  }

  async write(path: string, data: Uint8Array) {
    const parts = path.split('/');
    const name = parts.pop()!;
    const d = (await this.dir(parts, true))!;
    const fh = await d.getFileHandle(name, { create: true });
    if (fh.createSyncAccessHandle) {
      const h = await fh.createSyncAccessHandle();
      try { h.truncate(0); h.write(data, { at: 0 }); h.flush(); } finally { h.close(); }
    } else {
      const w = await fh.createWritable!();
      await w.write(data);
      await w.close();
    }
  }

  async read(path: string) {
    const parts = path.split('/');
    const name = parts.pop()!;
    const d = await this.dir(parts, false);
    if (!d) return null;
    try {
      const fh = await d.getFileHandle(name);
      return new Uint8Array(await (await fh.getFile()).arrayBuffer());
    } catch { return null; }
  }

  async removePrefix(prefix: string) {
    const parts = prefix.split('/').filter(Boolean);
    if (prefix.endsWith('/')) {
      const parent = await this.dir(parts.slice(0, -1), false);
      try { await parent?.removeEntry(parts[parts.length - 1], { recursive: true }); } catch { /* absent */ }
      return;
    }
    for (const f of await this.list(prefix)) {
      const p = f.split('/');
      const d = await this.dir(p.slice(0, -1), false);
      try { await d?.removeEntry(p[p.length - 1]); } catch { /* absent */ }
    }
  }

  async list(prefix: string) {
    const parts = prefix.split('/');
    const tail = parts.pop()!;
    const d = await this.dir(parts, false);
    if (!d) return [];
    const out: string[] = [];
    for await (const k of d.keys()) if (k.startsWith(tail)) out.push([...parts, k].join('/'));
    return out;
  }
}

const ACTIVE = 'active.json';

/** Versioned layout `<corpus_version>/<file>` plus an `active.json` pointer. */
export class CorpusStore {
  constructor(private fs: FileStore) {}

  writeFile(version: string, name: string, data: Uint8Array) { return this.fs.write(`${version}/${name}`, data); }
  readFile(version: string, name: string) { return this.fs.read(`${version}/${name}`); }
  removeVersion(version: string) { return this.fs.removePrefix(`${version}/`); }

  async activeVersion(): Promise<string | null> {
    const raw = await this.fs.read(ACTIVE);
    if (!raw) return null;
    try { return (JSON.parse(new TextDecoder().decode(raw)) as { version?: string }).version ?? null; } catch { return null; }
  }

  /** Verifies every file's sha256 against `expected` (name -> hex), then switches active.json. */
  async activate(version: string, expected: Record<string, string>): Promise<void> {
    for (const [name, sha] of Object.entries(expected)) {
      const data = await this.readFile(version, name);
      if (!data) throw new Error(`missing file ${version}/${name}`);
      if ((await sha256Hex(data)) !== sha) throw new Error(`sha256 mismatch for ${version}/${name}`);
    }
    await this.fs.write(ACTIVE, new TextEncoder().encode(JSON.stringify({ version })));
  }
}
