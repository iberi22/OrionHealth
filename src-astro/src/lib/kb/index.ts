import MiniSearch from 'minisearch';
import type { KbEntry, KbHit, KbSystem } from '../contracts/types';
import type { KbService } from '../contracts/services';

const ALL_SYSTEMS: KbSystem[] = ['icd10', 'loinc', 'rxnorm', 'snomed', 'guideline', 'interaction', 'symptom'];

export interface Fetcher {
  (url: string): Promise<Response>;
}

export class KbServiceImpl implements KbService {
  private fetcher: Fetcher;
  private miniSearch: MiniSearch<KbEntry>;
  private store: Map<string, KbEntry>;
  private loadedSystems: Set<KbSystem>;

  constructor(fetcher: Fetcher = globalThis.fetch.bind(globalThis)) {
    this.fetcher = fetcher;
    this.store = new Map();
    this.loadedSystems = new Set();

    this.miniSearch = new MiniSearch({
      fields: ['code', 'title', 'body'],
      storeFields: ['id'],
      searchOptions: {
        prefix: true,
        fuzzy: 0.2,
        boost: {
          code: 3,
          title: 2
        }
      }
    });
  }

  async load(systems: KbSystem[] = ALL_SYSTEMS): Promise<void> {
    for (const system of systems) {
      if (this.loadedSystems.has(system)) continue;

      try {
        const res = await this.fetcher(`/kb/${system}.json`);
        if (!res.ok) {
          throw new Error(`Failed to fetch /kb/${system}.json: ${res.statusText}`);
        }

        const data: KbEntry[] = await res.json();

        for (const entry of data) {
          this.store.set(entry.id, entry);
        }

        this.miniSearch.addAll(data);
        this.loadedSystems.add(system);
      } catch (e) {
        console.warn(`Error loading KB system ${system}:`, e);
      }
    }
  }

  async search(query: string, opts?: { systems?: KbSystem[]; limit?: number }): Promise<KbHit[]> {
    if (this.loadedSystems.size === 0) {
      await this.load(); // Load all systems if none are loaded
    }

    const rawHits = this.miniSearch.search(query, {
      filter: (result) => {
        if (!opts?.systems) return true;
        const entry = this.store.get(result.id);
        return entry ? opts.systems.includes(entry.system) : false;
      }
    });

    const limit = opts?.limit ?? 10;

    // Sort and map
    const hits = rawHits.map(result => {
      const entry = this.store.get(result.id)!;
      // Exact code match boost
      const isExactCode = entry.code.toLowerCase() === query.toLowerCase();
      return {
        entry,
        score: isExactCode ? result.score + 100 : result.score
      };
    });

    hits.sort((a, b) => b.score - a.score);

    return hits.slice(0, limit);
  }

  async get(id: string): Promise<KbEntry | null> {
    const entry = this.store.get(id);
    if (entry) return entry;

    // Try to parse system from id
    const parts = id.split(':');
    if (parts.length >= 2) {
      const system = parts[0] as KbSystem;
      if (ALL_SYSTEMS.includes(system)) {
        await this.load([system]);
        return this.store.get(id) || null;
      }
    }

    return null;
  }
}

export function createKb(fetcher?: Fetcher): KbServiceImpl {
  return new KbServiceImpl(fetcher);
}
