import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';
import { createVault } from './helpers/vault';
import { seedPersonalData } from './helpers/seed';

// Personal data we want to make sure NEVER leaves the device.
const PERSONAL_DATA = [
  'Ana Demo', 'Luis Demo', 'med-rosa-1', 'cond-rosa-1', 'mid-ana', 'al-1', 'ZZ-PHI-1', 'ZZ-PHI-2'
];

test.describe('Knowledge Base and Assistant', () => {
  test(`KB search by code and text, view entry @real`, async ({ page }) => {
      // Intercept all network requests to ensure no personal data is sent
      await page.route('**/*', (route) => {
        const request = route.request();
        const url = request.url();
        const body = request.postData() || '';

        if (!url.startsWith('data:')) {
          for (const sensitive of PERSONAL_DATA) {
            expect(url.toLowerCase()).not.toContain(sensitive.toLowerCase());
            expect(body.toLowerCase()).not.toContain(sensitive.toLowerCase());
          }
        }
        return route.continue();
      });

      // Navigate to KB
      await page.goto('/kb');
      const searchContainer = page.getByTestId('kb-search');
      await expect(searchContainer).toBeVisible();

      // Search by code
      const searchInput = page.getByRole('searchbox', { name: /buscar/i });
      await searchInput.fill('I10');

      // Wait for search results
      // The KB also returns prefix/fuzzy matches (E10, F10...), so the exact code must rank first.
      await expect(page.getByRole('option').first()).toBeVisible();

      // Check that the entry is found: the first option is the ICD-10 I10 entry
      const codeMatch = page.getByRole('option').first();
      await expect(codeMatch).toContainText('ICD10');
      await expect(codeMatch).toContainText('I10');
      await expect(codeMatch).toContainText('Essential (primary) hypertension');

      // Search by text
      // The KB corpus is in English
      await searchInput.fill('Essential hypertension');
      // Wait for search results again
      const textMatch = page.getByRole('option', { name: /Essential hypertension|Essential \(primary\) hypertension/i }).first();
      await expect(textMatch).toBeVisible();

      // Click to view entry
      await page.getByRole('link', { name: /I10.*Essential \(primary\) hypertension/i }).first().click();

      // Verify entry view
      const entryView = page.getByTestId('kb-entry-view');
      await expect(entryView).toBeVisible();
      await expect(entryView.getByRole('heading', { level: 2, name: 'Essential (primary) hypertension' })).toBeVisible();
    });

    test(`Assistant answer with citations and request interception @real`, async ({ page }) => {
      // Setup vault and authenticate to unlock personal data (for the toggle)
      await addVirtualPasskey(page);
      await createVault(page, 'Ana');

      // Seed personal data
      await seedPersonalData(page);

      // Client-side navigation: a full reload would start a new (locked) session
      await page.getByRole('navigation', { name: 'Navegación principal' }).getByRole('link', { name: 'Asistente' }).click();
      const assistantArea = page.getByTestId('area-assistant');
      await expect(assistantArea).toBeVisible();

      // Intercept network requests while interacting with the assistant
      await page.route('**/*', (route) => {
        const request = route.request();
        const url = request.url();
        const body = request.postData() || '';

        if (!url.startsWith('data:')) {
          for (const sensitive of PERSONAL_DATA) {
            expect(url.toLowerCase(), `URL leak: ${url}`).not.toContain(sensitive.toLowerCase());
            expect(body.toLowerCase(), `Body leak: ${body}`).not.toContain(sensitive.toLowerCase());
          }
        }
        return route.continue();
      });

      // Enable "Use personal data"
      const toggle = page.getByRole('checkbox', { name: /Usar mis datos/i });
      await expect(toggle).not.toBeDisabled();
      await toggle.check();

      // Ask a question
      const questionInput = page.getByRole('textbox', { name: /Pregunta/i });
      await questionInput.fill('¿Qué medicación tomo?');

      const submitButton = page.getByRole('button', { name: /Preguntar/i });
      await submitButton.click();

      // Wait for answer card to appear
      await expect(page.getByText('Se utilizaron tus datos personales para esta respuesta.')).toBeVisible();

      // Verify citation
      await expect(page.getByText('Fuentes:')).toBeVisible();
    });
});
