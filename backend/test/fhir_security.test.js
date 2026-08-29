const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const express = require('express');
const session = require('express-session');
const { authMiddleware, verifyPatientOwnership } = require('../src/middleware/auth');
const { asyncHandler, errorHandler } = require('../src/utils/errorHandler');

function createTestApp() {
  const app = express();
  app.use(express.json());
  app.use(session({
    secret: 'test-secret',
    resave: false,
    saveUninitialized: false
  }));

  // Helper route to set session tokenData
  app.post('/test/session', (req, res) => {
    req.session.tokenData = req.body.tokenData;
    res.json({ status: 'ok' });
  });

  const fhirRouter = express.Router();

  fhirRouter.get('/patient/:id', authMiddleware, verifyPatientOwnership, asyncHandler(async (req, res) => {
    if (req.params.id === 'error-trigger') {
      throw new Error('Database connection failed with sensitive path /var/secret');
    }
    res.json({ resourceType: 'Patient', id: req.params.id });
  }));

  fhirRouter.get('/rda', authMiddleware, asyncHandler(async (req, res) => {
    res.json({ resourceType: 'Bundle', type: 'document' });
  }));

  app.use('/api/fhir', fhirRouter);
  app.use(errorHandler);

  return app;
}

async function makeRequest(server, path, method = 'GET', headers = {}, body = null) {
  const address = server.address();
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port: address.port,
      path,
      method,
      headers
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ statusCode: res.statusCode, headers: res.headers, body: parsed });
        } catch {
          resolve({ statusCode: res.statusCode, headers: res.headers, body: data });
        }
      });
    });

    req.on('error', reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

test('IDOR and Error Leakage Security Audit Tests', async (t) => {
  const app = createTestApp();
  const server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, resolve));

  t.after(() => {
    server.close();
  });

  await t.test('Unauthenticated request to /api/fhir/patient/p123 returns 401', async () => {
    const res = await makeRequest(server, '/api/fhir/patient/p123');
    assert.strictEqual(res.statusCode, 401);
    assert.strictEqual(res.body.error, 'unauthorized');
  });

  await t.test('IDOR attempt to access another patient data returns 403', async () => {
    // 1. Authenticate as patient p123
    const sessRes = await makeRequest(server, '/test/session', 'POST', { 'Content-Type': 'application/json' }, {
      tokenData: { patient: 'p123' }
    });
    const cookie = sessRes.headers['set-cookie']?.[0]?.split(';')[0];
    assert.ok(cookie, 'Cookie should be returned');

    // 2. Attempt IDOR access to p999
    const idorRes = await makeRequest(server, '/api/fhir/patient/p999', 'GET', { Cookie: cookie });
    assert.strictEqual(idorRes.statusCode, 403);
    assert.strictEqual(idorRes.body.error, 'forbidden');
  });

  await t.test('Authorized patient accessing their own patient data succeeds (200)', async () => {
    const sessRes = await makeRequest(server, '/test/session', 'POST', { 'Content-Type': 'application/json' }, {
      tokenData: { patient: 'p123' }
    });
    const cookie = sessRes.headers['set-cookie']?.[0]?.split(';')[0];

    const ownRes = await makeRequest(server, '/api/fhir/patient/p123', 'GET', { Cookie: cookie });
    assert.strictEqual(ownRes.statusCode, 200);
    assert.strictEqual(ownRes.body.id, 'p123');
  });

  await t.test('Internal server errors in production do not leak stack traces or error details', async () => {
    const origEnv = process.env.NODE_ENV;
    process.env.NODE_ENV = 'production';

    try {
      const sessRes = await makeRequest(server, '/test/session', 'POST', { 'Content-Type': 'application/json' }, {
        tokenData: { patient: 'error-trigger' }
      });
      const cookie = sessRes.headers['set-cookie']?.[0]?.split(';')[0];

      const errRes = await makeRequest(server, '/api/fhir/patient/error-trigger', 'GET', { Cookie: cookie });
      assert.strictEqual(errRes.statusCode, 500);
      assert.strictEqual(errRes.body.error, 'internal_error');
      assert.strictEqual(errRes.body.stack, undefined);
    } finally {
      process.env.NODE_ENV = origEnv;
    }
  });
});
