export interface OnboardingStep {
  id: string;
  title: string;
  body: string;
  actionHref?: string;
}

export const ONBOARDING_STEPS: OnboardingStep[] = [
  {
    id: 'no-account',
    title: 'Usa sin registro',
    body: 'Empieza a usar la app de inmediato, sin cuenta ni correo electrónico obligatorio.',
  },
  {
    id: 'on-device',
    title: 'Privacidad total en tu dispositivo',
    body: 'Tus datos de salud nunca salen de tu teléfono. Funcionamiento offline nativo PWA.',
  },
  {
    id: 'local-ai',
    title: 'Asistente Inteligente Local',
    body: 'IA integrada directamente en el navegador (cuando lo soporte), sin envíos a la nube ni límites diarios.',
  },
  {
    id: 'device-lock',
    title: 'Bloqueo Biométrico',
    body: 'Protege tu historial médico con el PIN o huella dactilar de tu dispositivo móvil.',
  },
  {
    id: 'own-your-data',
    title: 'Dueño de tus Datos',
    body: 'Exporta, importa y controla tus registros clínicos cuando quieras.',
  }
];

export function onboardingStepIds(): string[] {
  return ONBOARDING_STEPS.map(s => s.id);
}
