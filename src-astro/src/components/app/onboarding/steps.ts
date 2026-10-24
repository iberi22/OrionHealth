export interface ExplanationScreen {
  id: string;
  title: string;
  body: string;
}

export const EXPLANATION_SCREENS: ExplanationScreen[] = [
  {
    id: 'on-device',
    title: 'Tus datos en tu dispositivo',
    body: 'Toda tu información médica de OrionHealth vive y se procesa directamente en tu teléfono, cifrada de extremo a extremo.',
  },
  {
    id: 'encrypted',
    title: 'Solo tú tienes la llave',
    body: 'Tus datos se abren únicamente con la huella, rostro o patrón de tu dispositivo. OrionHealth no tiene contraseñas.',
  },
  {
    id: 'access-control',
    title: 'Tú decides quién ve qué',
    body: 'Al formar un círculo familiar, la familia solo ve la información que tú permitas. Si pierdes el teléfono, ellos o tu código de recuperación podrán restaurar tus datos.',
  },
];
