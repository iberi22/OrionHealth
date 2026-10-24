import { test, expect } from '@playwright/test';
import { startSignaling } from './helpers/signaling';
import { newMember, createCircle, inviteAndJoin } from './helpers/circle';
import { visit, reloadAndUnlock } from './helpers/vault';

test.describe('Member Removal', () => {
  test('a removed member reads nothing new @real', async ({ browser, baseURL }) => {
    await startSignaling();

    // Contexts: admin A, member B, member C
    const adminA = await newMember(browser, baseURL, 'Admin A');
    const memberB = await newMember(browser, baseURL, 'Member B');
    const memberC = await newMember(browser, baseURL, 'Member C');

    // Admin A creates a circle
    await createCircle(adminA.page, 'Family Circle');

    // Admin A invites B
    await inviteAndJoin(adminA.page, memberB.page, 'Member B');
    // Admin A invites C
    await inviteAndJoin(adminA.page, memberC.page, 'Member C');

    // Admin A grants Guardian access to B and C
    await visit(adminA.page, '/app/family/permissions');

    // From here on (the SAS dialogs of the joins are handled by inviteAndJoin), every confirmation
    // (guardian preset, removal) is accepted by one handler.
    adminA.page.on('dialog', (dialog) => dialog.accept());

    // Grant B
    await adminA.page.getByLabel('Miembro familiar').selectOption({ label: 'Member B' });
    await adminA.page.getByLabel('Nivel de acceso').selectOption('guardian');
    await adminA.page.getByRole('button', { name: 'Otorgar acceso' }).click();
    // one granted-permission row per category; the select also shows the name
    await expect(adminA.page.getByRole('listitem').filter({ hasText: 'Member B' }).first()).toBeVisible();

    // Grant C
    await adminA.page.getByLabel('Miembro familiar').selectOption({ label: 'Member C' });
    await adminA.page.getByLabel('Nivel de acceso').selectOption('guardian');
    await adminA.page.getByRole('button', { name: 'Otorgar acceso' }).click();
    // one granted-permission row per category; the select also shows the name
    await expect(adminA.page.getByRole('listitem').filter({ hasText: 'Member C' }).first()).toBeVisible();

    // Write a vital record before removal to verify they could read it
    await visit(adminA.page, '/app/records');
    await adminA.page.getByRole('tab', { name: 'Signos vitales' }).click();
    await adminA.page.getByRole('button', { name: 'Añadir' }).click();
    await adminA.page.getByLabel('Tipo').selectOption('bp'); // Presión arterial
    await adminA.page.getByLabel('Sistólica (mmHg)').fill('120');
    await adminA.page.getByLabel('Diastólica (mmHg)').fill('80');
    await adminA.page.getByRole('button', { name: 'Guardar' }).click();
    await expect(adminA.page.getByText('120/80')).toBeVisible();

    // Both B and C can see the first record
    await reloadAndUnlock(memberB.page, '/app/family/guardian');
    await expect(memberB.page.getByRole('heading', { name: 'Admin A', exact: true })).toBeVisible();
    await expect(memberB.page.getByText(/120 mmHg \/ 80/)).toBeVisible();

    await reloadAndUnlock(memberC.page, '/app/family/guardian');
    await expect(memberC.page.getByRole('heading', { name: 'Admin A', exact: true })).toBeVisible();
    await expect(memberC.page.getByText(/120 mmHg \/ 80/)).toBeVisible();

    // A removes B
    await visit(adminA.page, '/app/family');

    // Find member B in the list and click its remove button
    // (Ensure we use semantic queries)
    const memberBCard = adminA.page.getByRole('heading', { name: 'Member B' }).locator('..').locator('..');
    await memberBCard.getByRole('button', { name: 'Eliminar' }).click();

    // B should not be in the list anymore
    await expect(adminA.page.getByRole('heading', { name: 'Member B' })).not.toBeVisible();

    // A writes a new vital
    await visit(adminA.page, '/app/records');
    await adminA.page.getByRole('tab', { name: 'Signos vitales' }).click();
    await adminA.page.getByRole('button', { name: 'Añadir' }).click();
    await adminA.page.getByLabel('Tipo').selectOption('bp'); // Presión arterial
    await adminA.page.getByLabel('Sistólica (mmHg)').fill('130');
    await adminA.page.getByLabel('Diastólica (mmHg)').fill('85');
    await adminA.page.getByRole('button', { name: 'Guardar' }).click();
    await expect(adminA.page.getByText('130/85')).toBeVisible();

    // A writes a new circle note
    await visit(adminA.page, '/app/family/health');
    // We need to create an initiative first to be able to post a note
    await adminA.page.getByRole('button', { name: '+ Nueva Iniciativa' }).click();
    await adminA.page.getByLabel('Título').fill('Test Initiative');
    await adminA.page.getByLabel('Descripción').fill('Test description');

    // Using semantic queries
    await adminA.page.getByLabel('Métrica').fill('días');
    await adminA.page.getByLabel('Objetivo').fill('30');
    await adminA.page.getByRole('button', { name: 'Crear Iniciativa' }).click();
    await expect(adminA.page.getByText('Test Initiative')).toBeVisible();

    await adminA.page.getByPlaceholder('Escribe un mensaje de apoyo...').first().fill('Secret note');
    await adminA.page.getByRole('button', { name: 'Enviar' }).first().click();
    await expect(adminA.page.getByText('Admin A: Secret note')).toBeVisible();

    // Member C can see both new items
    await reloadAndUnlock(memberC.page, '/app/family/guardian');
    await expect(memberC.page.getByRole('heading', { name: 'Admin A', exact: true })).toBeVisible();
    await expect(memberC.page.getByText(/130 mmHg \/ 85/)).toBeVisible();

    await visit(memberC.page, '/app/family/health');
    await expect(memberC.page.getByText('Admin A: Secret note')).toBeVisible();

    // Member B reads neither
    // After revocation the joiner no longer reads any of the admin's data: the guardian view is empty
    await reloadAndUnlock(memberB.page, '/app/family/guardian');
    await expect(memberB.page.getByText('Actualmente no eres acudiente')).toBeVisible();
    await expect(memberB.page.getByText(/120 mmHg \/ 80/)).not.toBeVisible();
    await expect(memberB.page.getByText(/130 mmHg \/ 85/)).not.toBeVisible();

    await visit(memberB.page, '/app/family/health');
    await expect(memberB.page.getByText('Admin A: Secret note')).not.toBeVisible();

    // B is out of the circle: its family screen says so and offers no circle actions
    await visit(memberB.page, '/app/family');
    await expect(memberB.page.getByTestId('circle-removed')).toBeVisible();
    await expect(memberB.page.getByRole('button', { name: 'Invitar' })).toHaveCount(0);

    await adminA.context.close();
    await memberB.context.close();
    await memberC.context.close();
  });
});
