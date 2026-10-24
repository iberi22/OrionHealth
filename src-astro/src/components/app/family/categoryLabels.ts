import type { PersonalCategory } from '../../../lib/contracts/types';

export const CATEGORY_LABELS: Record<PersonalCategory, { label: string; description: string }> = {
  emergency: { label: 'Emergencia', description: 'Información médica esencial y contactos en caso de emergencia.' },
  conditions: { label: 'Condiciones', description: 'Enfermedades y condiciones médicas crónicas o actuales.' },
  medications: { label: 'Medicamentos', description: 'Medicinas actuales, dosis e historial de consumo.' },
  allergies: { label: 'Alergias', description: 'Alergias conocidas a sustancias, medicamentos y reacciones.' },
  vitals: { label: 'Signos vitales', description: 'Mediciones de presión, glucosa, peso, oxigenación y más.' },
  documents: { label: 'Documentos', description: 'Resultados de laboratorio y otros documentos médicos.' },
  habits: { label: 'Hábitos', description: 'Seguimiento de agua, sueño y actividad física.' },
  nutrition: { label: 'Nutrición', description: 'Registro de comidas, ingestas y etiquetas alimenticias.' },
  mental: { label: 'Salud mental', description: 'Registro del estado de ánimo y notas personales.' },
  appointments: { label: 'Citas', description: 'Próximas citas médicas, lugares y notas de consulta.' },
};
