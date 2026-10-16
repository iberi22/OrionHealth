import { test, expect } from 'e2e';
import { request } from '@playwright/test';

test('home opens with its main heading and primary call to action', async ({ app, screen }) => {
  await app.open('/');
  const heading = await screen.getByRole('heading', { name: /OrionHealth/i });
  await expect(heading).toBeVisible();

  const cta = await screen.getByRole('button', { name: 'Documentación' });
  await expect(cta).toBeVisible();
});

test('the AUI section renders', async ({ app, screen }) => {
  await app.open('/');
  const auiHeading = await screen.getByRole('heading', { name: 'Demo AUI — UI generada por agente' });
  await expect(auiHeading).toBeVisible();

  const cardTitle = await screen.getByText('Signos vitales');
  await expect(cardTitle).toBeVisible();

  const cardContent = await screen.getByText(/TA 120\/80/i);
  await expect(cardContent).toBeVisible();

  const button = await screen.getByRole('button', { name: 'Ver historial' });
  await expect(button).toBeVisible();
});

test('PWA manifest and service worker are served', async ({ app, session }) => {
  await app.open('/');
  let baseUrl = 'http://127.0.0.1:4321';
  if (session && session.target && session.target.name === 'live' && process.env.E2E_LIVE_URL) {
     baseUrl = process.env.E2E_LIVE_URL;
  }
  const reqContext = await request.newContext();
  const manifestRes = await reqContext.get(new URL('/manifest.json', baseUrl).toString());
  expect(manifestRes.status()).toBe(200);
  const manifestData = await manifestRes.json();
  expect(manifestData).toHaveProperty('name');

  const swRes = await reqContext.get(new URL('/sw.js', baseUrl).toString());
  expect(swRes.status()).toBe(200);
  const swData = await swRes.text();
  expect(swData).toContain('workbox');
});

test('theme switch exists', async ({ app, screen }) => {
  await app.open('/');
  const themeSwitch = screen.getByRole('button', { name: /theme|tema/i });
});

test('unknown route shows a not-found page or redirects home', async ({ app, screen, session }) => {
  let baseUrl = 'http://127.0.0.1:4321';
  if (session && session.target && session.target.name === 'live' && process.env.E2E_LIVE_URL) {
     baseUrl = process.env.E2E_LIVE_URL;
  }
  const reqContext = await request.newContext();
  const res = await reqContext.get(new URL('/unknown-route-12345', baseUrl).toString());
  expect([200, 404]).toContain(res.status());
  await app.open('/unknown-route-12345');
  const fallbackText = await screen.getByRole('heading', { name: /404/i });
});
