const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { fetchGmailAppointments } = require('./email/gmail-reader');
const { fetchOutlookAppointments } = require('./email/outlook-reader');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// Endpoint to fetch appointments from Gmail
app.post('/api/gmail/appointments', async (req, res) => {
  const { code } = req.body;
  if (!code) return res.status(400).send('OAuth code is required');

  try {
    // In a real app, exchange code for tokens here
    // For now, passing a mock auth object to gmail-reader
    const appointments = await fetchGmailAppointments({ access_token: 'mock_token' });
    res.json(appointments);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

// Endpoint to fetch appointments from Outlook
app.post('/api/outlook/appointments', async (req, res) => {
  const { code } = req.body;
  if (!code) return res.status(400).send('OAuth code is required');

  try {
    const appointments = await fetchOutlookAppointments('mock_token');
    res.json(appointments);
  } catch (error) {
    res.status(500).send(error.toString());
  }
});

app.listen(port, () => {
  console.log(`Backend server listening at http://localhost:${port}`);
});
