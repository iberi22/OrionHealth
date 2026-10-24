const { describe, it } = require('node:test');
const assert = require('node:assert');
const { fetchGmailAppointments } = require('../src/email/gmail-reader');
const { fetchOutlookAppointments } = require('../src/email/outlook-reader');

describe('Email Readers', () => {
  describe('Gmail Reader', () => {
    it('should fetch appointments using the injected client', async () => {
      const mockClient = {
        users: {
          messages: {
            list: async () => ({
              data: {
                messages: [{ id: 'msg1' }, { id: 'msg2' }],
              },
            }),
            get: async ({ id }) => {
              if (id === 'msg1') {
                return {
                  data: {
                    snippet: 'Cita con Dr. Juan Perez en Odontología',
                  },
                };
              }
              if (id === 'msg2') {
                return {
                  data: {
                    snippet: 'Not a medical appointment',
                  },
                };
              }
            },
          },
        },
      };

      const result = await fetchGmailAppointments('dummy-auth', mockClient);

      assert.strictEqual(result.length, 1);
      assert.strictEqual(result[0].doctorName, 'Juan Perez');
      assert.strictEqual(result[0].specialty, 'Odontología');
      assert.strictEqual(result[0].source, 'Gmail');
      assert.strictEqual(result[0].emailId, 'msg1');
    });

    it('should handle errors gracefully when API fails', async () => {
      const mockClient = {
        users: {
          messages: {
            list: async () => { throw new Error('API Error'); },
          },
        },
      };

      const originalConsoleError = console.error;
      let consoleErrorCalled = false;
      console.error = () => { consoleErrorCalled = true; };

      const result = await fetchGmailAppointments('dummy-auth', mockClient);

      console.error = originalConsoleError;

      assert.strictEqual(result.length, 0);
      assert.strictEqual(consoleErrorCalled, true);
    });
  });

  describe('Outlook Reader', () => {
    it('should fetch appointments using the injected client', async () => {
      const mockClient = {
        api: (path) => ({
          filter: () => ({
            select: () => ({
              get: async () => ({
                value: [
                  { id: 'msg1', bodyPreview: 'Confirmación de cita en Cardiología con Dr. Maria Gomez.' },
                  { id: 'msg2', bodyPreview: 'Reunión de equipo a las 10am' },
                ],
              }),
            }),
          }),
        }),
      };

      const result = await fetchOutlookAppointments('dummy-token', mockClient);

      assert.strictEqual(result.length, 1);
      assert.strictEqual(result[0].doctorName, 'Maria Gomez');
      assert.strictEqual(result[0].specialty, 'Cardiología');
      assert.strictEqual(result[0].source, 'Outlook');
      assert.strictEqual(result[0].emailId, 'msg1');
    });

    it('should handle errors gracefully when API fails', async () => {
       const mockClient = {
        api: (path) => ({
          filter: () => ({
            select: () => ({
              get: async () => { throw new Error('Graph API Error'); },
            }),
          }),
        }),
      };

      const originalConsoleError = console.error;
      let consoleErrorCalled = false;
      console.error = () => { consoleErrorCalled = true; };

      const result = await fetchOutlookAppointments('dummy-token', mockClient);

      console.error = originalConsoleError;

      assert.strictEqual(result.length, 0);
      assert.strictEqual(consoleErrorCalled, true);
    });
  });
});
