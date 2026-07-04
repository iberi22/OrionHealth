# PWA Docs — OrionHealth Medical Knowledge Base

## Visión

Convertir el site docs (Astro 6 + GitHub Pages) en una **PWA completa** instalable que sea el banco de conocimiento médico offline y el panel de documentación de la app.

## Stack Actual

| Componente | Estatus |
|---|---|
| Astro 6.4.6 + Tailwind | ✅ En producción |
| GitHub Pages (`docs/` → `https://iberi22.github.io/OrionHealth/`) | ✅ Build automático |
| Manifest.json (standalone mode) | ✅ Implementado |
| Service Worker (sw.js) | ✅ Cache-first + network-first |
| PWA meta tags (apple-mobile-web-app, theme-color) | ✅ En `BaseLayout.astro` |
| Iconos SVG + PNG 192/512 | ✅ En `public/` |
| Service Worker registration | ✅ En `BaseLayout.astro` |

## Lo que Falta para PWA 10/10

### Alto Impacto
- [ ] **Offline search** de estándares médicos (ICD-10, LOINC, SNOMED, RxNorm) usando IndexedDB + SW cache
- [ ] **Splash screen** configurada en manifest.json (splash_pages)
- [ ] **Push notifications** para actualizaciones de documentación
- [ ] **Lighthouse PWA audit** — target > 90

### Medio Impacto
- [ ] **Iconos en todos los tamaños** (apple-touch-icon 180x180, favicon multi-size)
- [ ] **Dark mode nativo** (ya casi listo con theme-color #121212)
- [ ] **Offline fallback page** personalizada (no solo el homepage)
- [ ] **Cache de datos JSON** (clinical_guidelines.json, icd10.json, etc.)

### Bajo Impacto
- [ ] **Share target API** para compartir desde otras apps
- [ ] **Badge API** para contar features documentados
- [ ] **Periodic background sync** para refrescar estándares médicos

## Arquitectura Planeada

```
Site Docs (Astro)
├── / (Landing page)
├── /es/ (Español)
├── /dashboard (Estado del proyecto)
├── /features/ (Documentación de features)
├── /medical-standards/ (Banco médico offline)
│   ├── /icd10 (Búsqueda + detalle offline)
│   ├── /loinc
│   ├── /snomed
│   └── /rxnorm
├── /docs/ (Documentación técnica)
├── /blog/ (Artículos)
└── PWA Service Worker (sw.js)
    ├── Cache-first: medical data JSONs
    ├── Network-first: HTML pages
    ├── IndexedDB: offline search
    └── Push notifications
```

## Cómo Probar

```bash
cd docs/
npm run dev          # Desarrollo local
npm run build        # Build para producción
npm run preview      # Preview del build
```

### Auditoría PWA (Lighthouse)
1. Build: `npm run build`
2. Servir: `npx serve docs/dist`
3. Abrir Chrome DevTools → Lighthouse → PWA

### Service Worker Debug
- Chrome DevTools → Application → Service Workers
- Verificar: `orionhealth-v1` cache
- Forzar offline y navegar

## Integración con Harness

El cron job `orionhealth-harness-scan` corre cada 4h y reporta el estado. La PWA docs debe mostrar:
- Dashboard de features coverage
- % de implementación en vivo
- Qué gaps quedan (READMEs, goldens, E2E)
- Features pendientes de review humano

## Referencias
- Issue: [#1017](https://github.com/iberi22/OrionHealth/issues/1017)
- Harness: `.gitcore/orionhealth-harness.ps1`
- Cron: `orionhealth-harness-scan` (cada 4h)
