const express = require('express');
const session = require('express-session');
const FileStore = require('session-file-store')(session);
const { createClient } = require('redis');
const RedisStore = require('connect-redis').default;
const dotenv = require('dotenv');
const { IhceOAuth } = require('./auth/ihce-oauth');
const { FhirClient } = require('./fhir/fhir-client');
const { RdaParser } = require('./fhir/rda-parser');
const { v4: uuidv4 } = require('uuid');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Session storage configuration
let sessionStore;
if (process.env.REDIS_URL) {
  const redisClient = createClient({ url: process.env.REDIS_URL });
  redisClient.connect().catch(console.error);
  sessionStore = new RedisStore({
    client: redisClient,
    prefix: 'ihce:',
  });
} else {
  sessionStore = new FileStore({ path: './sessions' });
}

// Session middleware for multi-user support and token caching
app.use(session({
  store: sessionStore,
  secret: process.env.SESSION_SECRET || 'ihce-gateway-secret',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

const ihceOAuth = new IhceOAuth();
const fhirClient = new FhirClient();

// Auth Endpoints
app.post('/api/auth/ihce/login', (req, res) => {
  const state = uuidv4();
  req.session.oauthState = state;
  const authUrl = ihceOAuth.getAuthUrl(state);
  res.json({ url: authUrl });
});

// GET fallback for browser testing if needed, but requirements asked for POST
app.get('/api/auth/ihce/login', (req, res) => {
  const state = uuidv4();
  req.session.oauthState = state;
  const authUrl = ihceOAuth.getAuthUrl(state);
  res.redirect(authUrl);
});

app.get('/api/auth/ihce/callback', async (req, res) => {
  const { code, state } = req.query;

  if (!code) {
    return res.status(400).json({ error: 'Authorization code is missing' });
  }

  if (state !== req.session.oauthState) {
    return res.status(400).json({ error: 'Invalid state' });
  }

  try {
    const tokenData = await ihceOAuth.getTokenFromCode(code);

    // Store token data in user's session
    req.session.tokenData = tokenData;
    req.session.save();

    res.json({
      message: 'Authentication successful',
      patientId: tokenData.patient
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// FHIR Endpoints
app.get('/api/fhir/patient/:id', async (req, res) => {
  const { id } = req.params;
  const tokenData = req.session.tokenData;

  if (!tokenData) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const patient = await fhirClient.getPatient(id, tokenData.accessToken);
    res.json(patient);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/fhir/rda', async (req, res) => {
  const tokenData = req.session.tokenData;

  if (!tokenData || !tokenData.patient) {
    return res.status(401).json({ error: 'Unauthorized or Patient ID not found' });
  }

  try {
    const rdaBundle = await fhirClient.getRDA(tokenData.patient, tokenData.accessToken);
    const parsedRda = RdaParser.parse(rdaBundle);
    res.json(parsedRda || rdaBundle);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`IHCE Gateway Backend listening at http://localhost:${port}`);
});
