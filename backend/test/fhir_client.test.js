const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const { FhirClient } = require('../src/fhir/fhir-client');
const { encrypt } = require('../src/auth/ihce-oauth');

// Set a dummy encryption key for tests
process.env.ENCRYPTION_KEY = '12345678901234567890123456789012';

test('FhirClient Tests', { timeout: 10000 }, async (t) => {
  // Read fixtures
  const patientFixture = require('./fixtures/patient.json');
  const bundleFixture = require('./fixtures/bundle.json');

  // Set up fake HTTP server
  const server = http.createServer((req, res) => {
    // Check Authorization header for the mock token
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer mock-token')) {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      return res.end(JSON.stringify({ error: 'Unauthorized' }));
    }

    if (req.url === '/Patient/p123' && req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/fhir+json' });
      return res.end(JSON.stringify(patientFixture));
    }

    if (req.url.startsWith('/Composition') && req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/fhir+json' });
      return res.end(JSON.stringify(bundleFixture));
    }

    if (req.url.startsWith('/Patient') && req.method === 'GET') {
      // Simulate pagination handling
      if (req.url.includes('_getpages=123')) {
        res.writeHead(200, { 'Content-Type': 'application/fhir+json' });
        return res.end(JSON.stringify({
          resourceType: 'Bundle',
          type: 'searchset',
          entry: [{ resource: patientFixture }]
        }));
      }

      res.writeHead(200, { 'Content-Type': 'application/fhir+json' });
      return res.end(JSON.stringify({
        resourceType: 'Bundle',
        type: 'searchset',
        link: [{ relation: 'next', url: 'http://localhost/Patient?_getpages=123' }],
        entry: []
      }));
    }

    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not Found' }));
  });

  await new Promise((resolve) => server.listen(0, resolve));
  const address = server.address();
  const baseUrl = `http://127.0.0.1:${address.port}`;

  const client = new FhirClient(baseUrl);
  const mockToken = encrypt('mock-token');

  t.after(async () => {
    server.closeAllConnections();
    await new Promise((resolve) => server.close(resolve));
  });

  await t.test('getPatient successful fetch', async () => {
    const patient = await client.getPatient('p123', mockToken);
    assert.strictEqual(patient.resourceType, 'Patient');
    assert.strictEqual(patient.id, 'p123');
  });

  await t.test('getPatient auth error (401)', async () => {
    const badToken = encrypt('bad-token');
    await assert.rejects(
      async () => {
        await client.getPatient('p123', badToken);
      },
      (err) => {
        assert.strictEqual(err.response.status, 401);
        return true;
      }
    );
  });

  await t.test('getRDA successful fetch', async () => {
    const rda = await client.getRDA('p123', mockToken);
    assert.strictEqual(rda.resourceType, 'Bundle');
    assert.strictEqual(rda.entry.length, 2);
  });

  await t.test('searchPatient simulates pagination support', async () => {
    // Initial search request
    const firstPage = await client.searchPatient({ name: 'John' }, mockToken);
    assert.strictEqual(firstPage.resourceType, 'Bundle');
    assert.strictEqual(firstPage.link[0].relation, 'next');

    // Simulate requesting the next page (e.g., following the next link)
    const nextPageUrl = new URL(firstPage.link[0].url);
    const nextPageParams = Object.fromEntries(nextPageUrl.searchParams.entries());

    // Explicitly pass only the next page parameter
    const nextPage = await client.searchPatient(nextPageParams, mockToken);

    assert.strictEqual(nextPage.resourceType, 'Bundle');
    assert.strictEqual(nextPage.entry[0].resource.id, 'p123');
  });
});
