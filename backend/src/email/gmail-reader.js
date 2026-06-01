const { google } = require('googleapis');
const { parseMedicalEmail } = require('./medical-parser');

async function fetchGmailAppointments(auth) {
  const gmail = google.gmail({ version: 'v1', auth });
  const appointments = [];

  try {
    const res = await gmail.users.messages.list({
      userId: 'me',
      q: 'cita médica OR odontología OR control médico',
    });

    const messages = res.data.messages || [];
    for (const msg of messages) {
      const message = await gmail.users.messages.get({
        userId: 'me',
        id: msg.id,
      });

      const body = message.data.snippet; // Simplified for this example
      const parsed = parseMedicalEmail(body);

      if (parsed.specialty || parsed.doctorName) {
        appointments.push({
          ...parsed,
          source: 'Gmail',
          emailId: msg.id,
        });
      }
    }
  } catch (error) {
    console.error('The API returned an error: ' + error);
  }

  return appointments;
}

module.exports = { fetchGmailAppointments };
