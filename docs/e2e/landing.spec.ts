import { test, expect } from '@playwright/test';

const BASE = '/OrionHealth';

test.describe('OrionHealth Landing Page', () => {
  test('should load hero section with title', async ({ page }) => {
    await page.goto(BASE + '/');
    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('h1')).toContainText('OrionHealth');
  });

  test('should have working navigation', async ({ page }) => {
    await page.goto(BASE + '/');
    await expect(page.locator('header')).toBeVisible();
  });

  test('should render project dashboard section', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.waitForSelector('#dashboard', { timeout: 10000 });
    await expect(page.locator('#dashboard')).toBeVisible();
    await expect(page.locator('#dashboard')).toContainText('BUILD');
  });

  test('should render medical standards section', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.waitForSelector('#standards', { timeout: 10000 });
    await expect(page.locator('#standards')).toBeVisible();
    await expect(page.locator('#standards')).toContainText('628');
  });
});

test.describe('OrionHealth Dashboard Page', () => {
  test('should load dashboard page with title', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('h1')).toContainText('Dashboard');
  });

  test('should show test coverage widget', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.tcd-section')).toBeVisible();
  });

  test('should show GitHub status widget', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.ghs-section')).toBeVisible();
  });

  test('should show architecture diagram', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.arch-flow')).toBeVisible();
  });

  test('should show data privacy flow', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.dpf-section')).toBeVisible();
  });

  test('should show feature grid', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    const features = page.locator('.feature-grid-section');
    await expect(features).toBeVisible();
  });

  test('should show timeline', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.tl-section')).toBeVisible();
  });

  test('should show dashboard stats', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    // Look for stats numbers in the dashboard content
    await expect(page.locator('.ghs-section')).toBeVisible();
    await expect(page.locator('.tcd-section')).toBeVisible();
  });

  test('should show architecture layers in sidebar', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.arch-layer.domain-layer')).toBeVisible();
    await expect(page.locator('.arch-layer.application-layer')).toBeVisible();
    await expect(page.locator('.arch-layer.infrastructure-layer')).toBeVisible();
    await expect(page.locator('.arch-layer.presentation-layer')).toBeVisible();
  });
});

test.describe('Medical Standards Search', () => {
  test('should load medical standards page', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    await expect(page.locator('h1')).toContainText('Medical');
  });

  test('should have search input visible', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const searchInput = page.locator('.med-search-input');
    await expect(searchInput).toBeVisible();
    await expect(searchInput).toHaveAttribute('type', 'search');
  });

  test('should search by code (I10) and show Essential hypertension', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const searchInput = page.locator('.med-search-input');
    await searchInput.fill('I10');
    const results = page.locator('#search-results');
    await expect(results).toBeVisible({ timeout: 5000 });
    await expect(results).toContainText('Essential hypertension');
  });

  test('should search by name (diabetes) and find results', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const searchInput = page.locator('.med-search-input');
    await searchInput.fill('diabetes');
    const results = page.locator('#search-results');
    await expect(results).toBeVisible({ timeout: 5000 });
    await expect(results).toContainText('diabetes');
  });

  test('should show empty state for no results', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const searchInput = page.locator('.med-search-input');
    await searchInput.fill('zzzzzzz');
    const empty = page.locator('#search-empty');
    await expect(empty).toBeVisible({ timeout: 5000 });
    await expect(empty).toContainText('No codes found');
  });

  test('should navigate to code detail on result click', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const searchInput = page.locator('.med-search-input');
    await searchInput.fill('I10');
    const resultItem = page.locator('.med-search-item').first();
    await expect(resultItem).toBeVisible({ timeout: 5000 });
    await resultItem.click();
    await expect(page).toHaveURL(/\/medical-standards\/icd-10\/I10/);
  });

  test('should show keyboard shortcut hint', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const hint = page.locator('.med-search-hint');
    await expect(hint).toBeVisible();
    await expect(hint).toContainText('Ctrl+K');
  });

  test('should highlight matched text in search results', async ({ page }) => {
    await page.goto(BASE + '/medical-standards');
    const searchInput = page.locator('.med-search-input');
    await searchInput.fill('hyper');
    const results = page.locator('#search-results');
    await expect(results).toBeVisible({ timeout: 5000 });
    const strong = results.locator('strong');
    await expect(strong.first()).toBeVisible();
  });
});

test.describe('Medical Standards Detail Pages', () => {
  test('should load ICD-10 page', async ({ page }) => {
    await page.goto(BASE + '/medical-standards/icd-10');
    await expect(page.locator('body')).toBeVisible();
  });

  test('should load LOINC page', async ({ page }) => {
    await page.goto(BASE + '/medical-standards/loinc');
    await expect(page.locator('body')).toBeVisible();
  });

  test('should load RxNorm page', async ({ page }) => {
    await page.goto(BASE + '/medical-standards/rxnorm');
    await expect(page.locator('body')).toBeVisible();
  });

  test('should load SNOMED CT page', async ({ page }) => {
    await page.goto(BASE + '/medical-standards/snomed');
    await expect(page.locator('body')).toBeVisible();
  });

  test('should load I10 detail page', async ({ page }) => {
    await page.goto(BASE + '/medical-standards/icd-10/I10');
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('PWA Support', () => {
  test('should have manifest link in page head', async ({ page }) => {
    await page.goto(BASE + '/');
    // Wait for full page load, including <link> elements
    await page.waitForLoadState('networkidle');
    const manifestHref = await page.evaluate(() => {
      const link = document.querySelector('link[rel="manifest"]');
      return link ? link.getAttribute('href') : null;
    });
    expect(manifestHref).toBe('/OrionHealth/manifest.json');
  });
});

test.describe('Dashboard Architecture Components', () => {
  test('should have Architecture Flow component', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.arch-flow')).toBeVisible();
  });

  test('should have Feature Grid component', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.feature-grid-section')).toBeVisible();
  });

  test('should have Test Coverage Dashboard component', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.tcd-section')).toBeVisible();
  });

  test('should have GitHub Live Status component', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.ghs-section')).toBeVisible();
  });

  test('should have Timeline component', async ({ page }) => {
    await page.goto(BASE + '/dashboard');
    await expect(page.locator('.tl-section')).toBeVisible();
  });
});
