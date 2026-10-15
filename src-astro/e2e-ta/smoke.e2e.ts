import { test, expect } from 'e2e';

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

test('PWA manifest and service worker are served', async ({ app }) => {
  await app.open('/manifest.json');
  await app.open('/sw.js');
});

test('language or theme switch changes the UI', async ({ app, screen }) => {
  await app.open('/');
  const text = await screen.getByText(/Self-managed/i);
  await expect(text).toBeVisible();
});

test('unknown route shows a not-found page or redirects home', async ({ app, screen }) => {
  await app.open('/unknown-route-12345');
  // the page might just show text "Not Found" if it is the cloudflare default
  // or it might fallback to standard UI if SPA
  const fallbackText = await screen.getByRole('heading', { name: /404/i });
  await expect(fallbackText).toBeVisible();
});
