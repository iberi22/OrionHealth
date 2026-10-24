import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit } from './helpers/vault';

test.describe('@real Guardian Alerts', () => {
  test('systolic 170 written by the elder -> alert visible to the guardian', async ({ browser, baseURL }) => {
    await startSignaling();

    const elder = await newMember(browser, baseURL, 'Elder');
    const guardian = await newMember(browser, baseURL, 'Guardian');

    // Elder creates the circle and the guardian joins it
    await createCircle(elder.page, 'Family Health');
    await inviteAndJoin(elder.page, guardian.page, 'Guardian');

    // Elder names the guardian (grants guardian access, with the risk confirmation)
    await visit(elder.page, '/app/family/permissions');
    await elder.page.getByLabel('Miembro familiar').selectOption({ label: 'Guardian' });
    await elder.page.getByLabel('Nivel de acceso').selectOption('guardian');
    elder.page.once('dialog', (dialog) => void dialog.accept());
    await elder.page.getByRole('button', { name: 'Otorgar acceso' }).click();
    await expect(elder.page.locator('.grant-list .grant-item').getByText('Guardian').first()).toBeVisible();

    // Guardian sees the elder's panel and sets the default alert rules (bp > 160)
    await visit(guardian.page, '/app/family/guardian');
    await expect(guardian.page.getByRole('heading', { name: 'Elder', exact: true })).toBeVisible({ timeout: 20_000 });
    await guardian.page.getByRole('button', { name: 'Añadir reglas por defecto' }).click();
    await expect(guardian.page.getByText('bp >')).toBeVisible();

    // Elder logs systolic 170 / diastolic 90
    await visit(elder.page, '/app/records');
    await elder.page.locator('button.tab-btn', { hasText: 'Signos vitales' }).click();
    await elder.page.locator('button', { hasText: 'Añadir' }).first().click();
    await elder.page.locator('input#vital-value').fill('170');
    await elder.page.locator('input#vital-value2').fill('90');
    await elder.page.locator('button[type="submit"]', { hasText: 'Guardar' }).click();
    await expect(elder.page.locator('.latest-reading .value')).toContainText('170/90');

    // The vital replicates to the guardian, whose rules raise the alert
    const alerts = guardian.page.locator('.alerts .alert-item');
    await expect(alerts).toHaveCount(1, { timeout: 20_000 });
    await expect(alerts).toContainText('170');

    await elder.context.close();
    await guardian.context.close();
  });
});
