import { test } from '@e2e-dev/web';
import { expect } from 'e2e';

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

test('PWA manifest and service worker are served as real assets', async ({ app }) => {
  const manifestResponse = await fetch(new URL('/manifest.json', app.baseUrl));
  expect(manifestResponse.status).toBe(200);
  expect(manifestResponse.headers.get('content-type')).toContain('application/json');

  const manifest = (await manifestResponse.json()) as {
    name: string;
    short_name: string;
    start_url: string;
    display: string;
    icons: Array<{ src: string; sizes: string; type: string }>;
  };
  expect(manifest.name).toBe('OrionHealth');
  expect(manifest.short_name).toBe('OrionHealth');
  expect(manifest.start_url).toBe('/');
  expect(manifest.display).toBe('standalone');
  expect(manifest.icons.length).toBeGreaterThanOrEqual(2);
  for (const icon of manifest.icons) {
    expect(icon.src).toMatch(/^\/icon-\d+\.png$/);
    expect(icon.sizes).toMatch(/^\d+x\d+$/);
    expect(icon.type).toBe('image/png');
  }

  // A 200 alone can be a fallback HTML page: assert the body really is the
  // generated Workbox service worker before trusting the response.
  const swResponse = await fetch(new URL('/sw.js', app.baseUrl));
  expect(swResponse.status).toBe(200);
  expect(swResponse.headers.get('content-type')).toContain('javascript');
  const serviceWorker = await swResponse.text();
  expect(serviceWorker.trimStart().startsWith('<')).toBe(false);
  expect(serviceWorker).toContain('self.addEventListener');
  expect(serviceWorker).toContain('precacheAndRoute');
});

test('the document declares its locale, theme color and manifest', { requires: ['browser'] }, async ({ app, browser }) => {
  await app.open('/');
  const declared = await browser.evaluate(() => ({
    lang: document.documentElement.lang,
    themeColor: document.querySelector('meta[name="theme-color"]')?.getAttribute('content') ?? null,
    manifestHref: document.querySelector('link[rel="manifest"]')?.getAttribute('href') ?? null,
  }));
  expect(declared.lang).toBe('es');
  expect(declared.themeColor).toBe('#10B981');
  expect(declared.manifestHref).toBe('/manifest.json');
});

test('unknown route shows a not-found page or redirects home', async ({ app, screen }) => {
  await app.open('/unknown-route-12345');
  // the page might just show text "Not Found" if it is the cloudflare default
  // or it might fallback to standard UI if SPA
  const fallbackText = await screen.getByRole('heading', { name: /404/i });
  await expect(fallbackText).toBeVisible();
});
