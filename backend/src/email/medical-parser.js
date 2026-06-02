/**
 * Extracts medical appointment information from email text using regex.
 */
function parseMedicalEmail(text) {
  const result = {
    dateTime: null,
    specialty: null,
    doctorName: null,
    location: null,
    insurer: null,
  };

  // Regex for Date and Time (Basic example)
  const dateRegex = /(\d{1,2})[\/\-s](ene|feb|mar|abr|may|jun|jul|ago|sep|oct|nov|dic|\d{1,2})[\/\-s](\d{2,4})/i;
  const timeRegex = /(\d{1,2}):(\d{2})\s*(am|pm)/i;

  const dateMatch = text.match(dateRegex);
  const timeMatch = text.match(timeRegex);

  if (dateMatch) {
    // Simple normalization logic would go here
    result.dateStr = dateMatch[0];
  }
  if (timeMatch) {
    result.timeStr = timeMatch[0];
  }

  // Keywords for specialty
  const specialties = ['Odontología', 'Medicina General', 'Pediatría', 'Cardiología', 'Dermatología', 'Oftalmología'];
  for (const spec of specialties) {
    if (text.toLowerCase().includes(spec.toLowerCase())) {
      result.specialty = spec;
      break;
    }
  }

  // Doctor extraction (e.g., "Dr. Juan Perez")
  const doctorMatch = text.match(/Dr\.\s+([A-Za-zÀ-ÿ\s]+)/i);
  if (doctorMatch) {
    result.doctorName = doctorMatch[1].trim();
  }

  // Location / Clinic
  const locationMatch = text.match(/(Clínica|Centro Médico|Hospital)\s+([A-Za-zÀ-ÿ\s]+)/i);
  if (locationMatch) {
    result.location = locationMatch[0].trim();
  }

  // Insurer (EPS)
  const epsKeywords = ['Sura', 'Sanitas', 'Compensar', 'Salud Total', 'Coomeva'];
  for (const eps of epsKeywords) {
    if (text.toLowerCase().includes(eps.toLowerCase())) {
      result.insurer = eps;
      break;
    }
  }

  return result;
}

module.exports = { parseMedicalEmail };
