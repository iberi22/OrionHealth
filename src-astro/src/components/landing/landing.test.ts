import { test, expect } from 'vitest';
import { HEADLINE, CTAS, SECTIONS } from './content';

test('landing content is correct', () => {
  expect(HEADLINE).toBe('Tu salud y la de tu familia, cifrada y en tu dispositivo');

  expect(CTAS).toHaveLength(3);
  expect(CTAS[0].label).toBe('Abrir la app');
  expect(CTAS[0].href).toBe('/app');
  expect(CTAS[1].label).toBe('Descargar para Android');
  expect(CTAS[1].href).toBe('https://github.com/iberi22/OrionHealth/releases');
  expect(CTAS[2].label).toBe('Documentación');

  const sectionIds = SECTIONS.map(s => s.id);
  expect(sectionIds).toContain('privacy');
  expect(sectionIds).toContain('family');
  expect(sectionIds).toContain('kb');
  expect(sectionIds).toContain('ai');
  expect(sectionIds).toContain('opensource');
});
