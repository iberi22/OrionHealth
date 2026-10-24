const { describe, it } = require('node:test');
const assert = require('node:assert');
const { parseMedicalEmail } = require('../src/email/medical-parser');

describe('Medical Email Parser', () => {
  it('should parse an email containing doctor, specialty, date, time, location and insurer', () => {
    const emailBody = `
      Estimado paciente,
      Le confirmamos su cita de Odontología con el Dr. Carlos Ruiz.
      Fecha: 15/mar/2024 a las 10:30 am.
      Lugar: Clínica Las Condes.
      Aseguradora: Sanitas EPS.
      Recuerde llegar 15 minutos antes.
    `;

    const result = parseMedicalEmail(emailBody);

    assert.strictEqual(result.specialty, 'Odontología');
    assert.strictEqual(result.doctorName, 'Carlos Ruiz');
    assert.strictEqual(result.dateStr, '15/mar/2024');
    assert.strictEqual(result.timeStr, '10:30 am');
    assert.strictEqual(result.location, 'Clínica Las Condes');
    assert.strictEqual(result.insurer, 'Sanitas');
  });

  it('should parse an email with different formats and missing fields', () => {
    const emailBody = `
      Su cita de Medicina General está confirmada.
      Día 05-oct-2023, Hora: 3:00 pm.
      Sura le recuerda asistir con tapabocas.
      Centro Médico Especializado.
    `;

    const result = parseMedicalEmail(emailBody);

    assert.strictEqual(result.specialty, 'Medicina General');
    assert.strictEqual(result.doctorName, null);
    assert.strictEqual(result.dateStr, '05-oct-2023');
    assert.strictEqual(result.timeStr, '3:00 pm');
    assert.strictEqual(result.location, 'Centro Médico Especializado');
    assert.strictEqual(result.insurer, 'Sura');
  });

  it('should parse an email with another doctor format', () => {
    const emailBody = `
      Cita con Dr. Ana Maria Fernandez en Oftalmología
      Hospital Regional, Coomeva.
    `;

    const result = parseMedicalEmail(emailBody);

    assert.strictEqual(result.specialty, 'Oftalmología');
    assert.strictEqual(result.doctorName, 'Ana Maria Fernandez');
    assert.strictEqual(result.location, 'Hospital Regional');
    assert.strictEqual(result.insurer, 'Coomeva');
    assert.strictEqual(result.dateStr, null);
    assert.strictEqual(result.timeStr, null);
  });

  it('should return nulls for an unrelated email', () => {
    const emailBody = `
      Hola Juan,
      ¿Nos vemos para el partido mañana a las 5:00 pm?
      Saludos,
      Pedro
    `;

    const result = parseMedicalEmail(emailBody);

    assert.strictEqual(result.specialty, null);
    assert.strictEqual(result.doctorName, null);
    assert.strictEqual(result.location, null);
    assert.strictEqual(result.insurer, null);
    // Notice time can still match
    assert.strictEqual(result.timeStr, '5:00 pm');
    assert.strictEqual(result.dateStr, null);
  });
});
