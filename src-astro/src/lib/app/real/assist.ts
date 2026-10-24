import { createKb } from '../../kb/index';
import { createRag } from '../../rag/index';
import type { RecordsService, KbService, RagService } from '../../contracts/services';
import { RECORD_CATEGORY, type HealthRecord } from '../../contracts/types';

export function createAssist(
  records: RecordsService,
  fetcher?: (url: string) => Promise<Response>
): { kb: KbService; rag: RagService } {
  const kb = createKb(fetcher);

  const personalSource = async (): Promise<HealthRecord[]> => {
    const kinds = Object.keys(RECORD_CATEGORY) as HealthRecord['kind'][];
    const allRecords: HealthRecord[] = [];
    for (const kind of kinds) {
      const categoryRecords = await records.list(kind);
      allRecords.push(...categoryRecords);
    }
    return allRecords;
  };

  const rag = createRag({ kb, personalSource });

  return { kb, rag };
}
