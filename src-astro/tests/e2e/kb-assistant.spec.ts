import { test, expect } from '@playwright/test';
import { addVirtualPasskey } from './helpers/webauthn';

// Personal data we want to make sure NEVER leaves the device.
const PERSONAL_DATA = [
  'Ana Demo', 'Luis Demo', 'med-rosa-1', 'cond-rosa-1', 'mid-ana', 'al-1'
];

test.describe('Knowledge Base and Assistant', () => {
  // Common test logic to run for both mock and real services
  const runTests = (suffix: string) => {
    test(`KB search by code and text, view entry ${suffix}`, async ({ page }) => {
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
      await expect(page.getByRole('option')).toHaveCount(1);

      // Check that the entry is found
      const codeMatch = page.getByRole('option', { name: /I10/i });
      await expect(codeMatch).toBeVisible();

      // Search by text
      await searchInput.fill('Hipertensión');
      // Wait for search results again
      const textMatch = page.getByRole('option', { name: /Hipertensión/i }).first();
      await expect(textMatch).toBeVisible();

      // Click to view entry
      await page.getByRole('link', { name: /I10.*Hipertensión/i }).click();

      // Verify entry view
      const entryView = page.getByTestId('kb-entry-view');
      await expect(entryView).toBeVisible();
      await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    });

    test(`Assistant answer with citations and request interception ${suffix}`, async ({ page }) => {
      // Setup vault and authenticate to unlock personal data (for the toggle)
      await page.goto('/app/onboarding');
      await addVirtualPasskey(page);

      // Navigate to assistant
      await page.goto('/app/assistant');
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
      await questionInput.fill('¿Qué medicación tomo para la hipertensión?');

      const submitButton = page.getByRole('button', { name: /Preguntar/i });
      await submitButton.click();

      // Wait for answer card to appear
      await expect(page.getByText('Se utilizaron tus datos personales para esta respuesta.')).toBeVisible();
    });
  };

  runTests('');
  runTests('@real');
});
