import { test, expect } from '@playwright/test';

test.describe('Content Security Policy', () => {
  const routes = ['/', '/app', '/kb'];

  for (const route of routes) {
    test(`has no CSP violations on ${route}`, async ({ page }) => {
      const violations: any[] = [];

      await page.addInitScript(() => {
        document.addEventListener('securitypolicyviolation', (e) => {
          (window as any).__cspViolations = (window as any).__cspViolations || [];
          (window as any).__cspViolations.push({
            violatedDirective: e.violatedDirective,
            originalPolicy: e.originalPolicy,
            blockedURI: e.blockedURI,
            sourceFile: e.sourceFile,
            lineNumber: e.lineNumber,
            columnNumber: e.columnNumber,
          });
        });
      });

      await page.goto(route, { waitUntil: 'networkidle' });

      // Wait a little extra time for any lazy-loaded content or external requests
      await page.waitForTimeout(500);

      const pageViolations = await page.evaluate(() => {
        return (window as any).__cspViolations || [];
      });

      expect(pageViolations, `Expected no CSP violations on ${route}, found: ${JSON.stringify(pageViolations)}`).toHaveLength(0);
    });
  }
});
