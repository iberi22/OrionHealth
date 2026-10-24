import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { dumpIndexedDb } from './helpers/idb';
import { startSignaling } from './helpers/signaling';
import type { ChildProcess } from 'node:child_process';

let signalingServer: ChildProcess;

test.beforeAll(async () => {
  signalingServer = await startSignaling();
});

test.afterAll(() => {
  if (signalingServer) {
    signalingServer.kill();
  }
});

test('site navigation and offline capabilities', async ({ page }) => {
  // We mock webauthn first so when we visit /app it has virtual passkey if needed
  await addVirtualPasskey(page);

  // 1. Visit root (landing page)
  let res = await page.goto('/');
  expect(res?.status()).toBe(200);

  // 2. Visit docs index
  res = await page.goto('/docs/');
  expect(res?.status()).toBe(200);
  await expect(page.locator('h1').first()).toBeVisible();

  // 3. Visit a specific docs page
  res = await page.goto('/docs/architecture/');
  expect(res?.status()).toBe(200);
  await expect(page.locator('h1').first()).toBeVisible();

  // 4. Visit a blog entry
  res = await page.goto('/blog/privacy-in-the-age-of-ai/');
  expect(res?.status()).toBe(200);
  await expect(page.locator('h1').first()).toBeVisible();

  // 5. Visit knowledge base search
  res = await page.goto('/kb/');
  expect(res?.status()).toBe(200);
  await expect(page.locator('h1').first()).toBeVisible();

  // 6. Visit /app, it should redirect to onboarding or lock
  await page.goto('/app');
  await expect(page).toHaveURL(/\/app\/(onboarding|lock)/);

  // Dump IndexedDB for sanity check (no strict assertions here as requested for just navigation)
  const idbDump = await dumpIndexedDb(page);
  expect(typeof idbDump).toBe('string');

  // 7. Visit /offline (PWA offline fallback page)
  res = await page.goto('/offline');
  expect(res?.status()).toBe(200);
  await expect(page.locator('h1').first()).toBeVisible();
});
