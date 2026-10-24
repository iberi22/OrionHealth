import type { Page } from '@playwright/test';

/**
 * Dumps all IndexedDB databases, object stores, and records on the current page into a JSON string.
 */
export async function dumpIndexedDb(page: Page): Promise<string> {
  return await page.evaluate(async () => {
    // Check if the browser supports indexedDB.databases()
    if (!indexedDB.databases) {
      return JSON.stringify({ error: 'indexedDB.databases() is not supported in this browser environment.' });
    }

    const dbs = await indexedDB.databases();
    const result: Record<string, Record<string, any[]>> = {};

    for (const dbInfo of dbs) {
      if (!dbInfo.name) continue;

      const dbName = dbInfo.name;
      result[dbName] = {};

      const db = await new Promise<IDBDatabase>((resolve, reject) => {
        const req = indexedDB.open(dbName);
        req.onsuccess = () => resolve(req.result);
        req.onerror = () => reject(req.error);
      });

      const storeNames = Array.from(db.objectStoreNames);
      if (storeNames.length > 0) {
        const tx = db.transaction(storeNames, 'readonly');

        for (const storeName of storeNames) {
          const store = tx.objectStore(storeName);
          const records = await new Promise<any[]>((resolve, reject) => {
            const req = store.getAll();
            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
          });
          const keys = await new Promise<any[]>((resolve, reject) => {
            const req = store.getAllKeys();
            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
          });
          result[dbName][storeName] = [{ __keys: keys }, ...records];
        }

        await new Promise<void>((resolve, reject) => {
          tx.oncomplete = () => resolve();
          tx.onerror = () => reject(tx.error);
        });
      }

      db.close();
    }

    return JSON.stringify(result, null, 2);
  });
}
