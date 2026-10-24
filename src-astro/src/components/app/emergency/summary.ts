import type { MedicalId } from '../../../lib/contracts/types';

export function emergencySummary(m: MedicalId): string {
  const parts: string[] = [];

  parts.push(`Nombre: ${m.fullName}`);
  if (m.birthDate) parts.push(`Nacimiento: ${m.birthDate}`);
  if (m.bloodType) parts.push(`Sangre: ${m.bloodType}`);
  if (m.organDonor !== undefined) {
    parts.push(`Donante de órganos: ${m.organDonor ? 'Sí' : 'No'}`);
  }

  if (m.allergies && m.allergies.length > 0) {
    parts.push(`Alergias: ${m.allergies.join(', ')}`);
  }
  if (m.conditions && m.conditions.length > 0) {
    parts.push(`Condiciones: ${m.conditions.join(', ')}`);
  }
  if (m.medications && m.medications.length > 0) {
    parts.push(`Medicamentos: ${m.medications.join(', ')}`);
  }

  if (m.emergencyContacts && m.emergencyContacts.length > 0) {
    const contacts = m.emergencyContacts
      .map(c => `${c.name} (${c.phone})${c.relation ? ` - ${c.relation}` : ''}`)
      .join('; ');
    parts.push(`Contactos ICE: ${contacts}`);
  }

  if (m.notes) {
    parts.push(`Notas: ${m.notes}`);
  }

  const text = parts.join('\n');
  return text.length > 600 ? text.slice(0, 597) + '...' : text;
}
