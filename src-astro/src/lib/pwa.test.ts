import { describe, it, expect } from 'vitest';
import fs from 'node:fs';
import path from 'node:path';

describe('PWA Manifest', () => {
  it('should have the correct fields', () => {
    const manifestPath = path.resolve(__dirname, '../../public/manifest.json');
    const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));
    expect(manifest.name).toBe('OrionHealth');
    expect(manifest.short_name).toBe('OrionHealth');
    expect(manifest.start_url).toBe('/app');
    expect(manifest.display).toBe('standalone');
    expect(manifest.theme_color).toBe('#10B981');
    expect(manifest.shortcuts).toHaveLength(3);
    expect(manifest.shortcuts[0].name).toBe('Emergencia');
    expect(manifest.shortcuts[0].url).toBe('/app/emergency');
    expect(manifest.shortcuts[1].name).toBe('Familia');
    expect(manifest.shortcuts[1].url).toBe('/app/family');
    expect(manifest.shortcuts[2].name).toBe('Asistente');
    expect(manifest.shortcuts[2].url).toBe('/app/assistant');
  });
});
