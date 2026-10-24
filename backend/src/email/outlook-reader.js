const { Client } = require('@microsoft/microsoft-graph-client');
try { require('isomorphic-fetch'); } catch (e) {}
const { parseMedicalEmail } = require('./medical-parser');

async function fetchOutlookAppointments(accessToken, graphClient = null) {
  const client = graphClient || Client.init({
    authProvider: (done) => {
      done(null, accessToken);
    },
  });

  const appointments = [];

  try {
    const res = await client.api('/me/messages')
      .filter("contains(subject, 'cita') or contains(body/content, 'cita')")
      .select('id,bodyPreview,subject')
      .get();

    const messages = res.value || [];
    for (const msg of messages) {
      const parsed = parseMedicalEmail(msg.bodyPreview);

      if (parsed.specialty || parsed.doctorName) {
        appointments.push({
          ...parsed,
          source: 'Outlook',
          emailId: msg.id,
        });
      }
    }
  } catch (error) {
    console.error('The Microsoft Graph API returned an error: ' + error);
  }

  return appointments;
}

module.exports = { fetchOutlookAppointments };
