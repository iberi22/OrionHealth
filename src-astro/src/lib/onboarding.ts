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
    title: 'Datos en tu dispositivo',
    body: 'Tus datos de salud se guardan en tu dispositivo. Funcionamiento offline nativo PWA.',
  },
  {
    id: 'local-ai',
    title: 'Asistente inteligente local',
    body: 'IA integrada directamente en el navegador (cuando lo soporte), sin límites diarios.',
  },
  {
    id: 'device-lock',
    title: 'Bloqueo biométrico opcional',
    body: 'Protege el acceso a la app con el PIN o huella dactilar (opcional, cuando tu navegador lo soporte).',
  },
  {
    id: 'own-your-data',
    title: 'Dueño de tus datos',
    body: 'Usa la app completa para gestionar tus registros clínicos cuando quieras.',
  }
];

export function onboardingStepIds(): string[] {
  return ONBOARDING_STEPS.map(s => s.id);
}
