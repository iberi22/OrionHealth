import { test, expect } from 'e2e';

test('mutating journey', async ({ app }) => {
  await app.open('/');
});
