const test = require('node:test');
const assert = require('node:assert');
const { RdaParser } = require('../src/fhir/rda-parser');

test('RdaParser Tests', async (t) => {
  const patientFixture = require('./fixtures/patient.json');
  const bundleFixture = require('./fixtures/bundle.json');
  const compositionFixture = require('./fixtures/composition.json');

  await t.test('Parse single Composition', () => {
    const summary = RdaParser.parse(compositionFixture);
    assert.ok(summary);
    assert.strictEqual(summary.id, 'c123');
    assert.strictEqual(summary.date, '2023-01-01');
    assert.strictEqual(summary.title, 'RDA Summary');
    // Patient reference without bundle should remain as reference object
    assert.strictEqual(summary.patient.reference, 'Patient/p123');
  });

  await t.test('Parse Bundle resolves patient reference', () => {
    const summary = RdaParser.parse(bundleFixture);
    assert.ok(summary);
    assert.strictEqual(summary.id, 'c123');
    // Patient reference should be resolved to the Patient resource in the bundle
    assert.strictEqual(summary.patient.resourceType, 'Patient');
    assert.strictEqual(summary.patient.id, 'p123');
    assert.strictEqual(summary.patient.name[0].family, 'Doe');
  });

  await t.test('Parse malformed or empty data returns null', () => {
    assert.strictEqual(RdaParser.parse(null), null);
    assert.strictEqual(RdaParser.parse({}), null);
    assert.strictEqual(RdaParser.parse({ resourceType: 'Bundle' }), null);
    assert.strictEqual(RdaParser.parse({ resourceType: 'Patient' }), null);
  });
});
