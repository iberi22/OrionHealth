$prompt = @'
Tienes 30 minutos para COMPLETAR y VERIFICAR todo.

Lee TASK_LANDING.md para contexto completo.

TAREAS PRIORIZADAS (en este orden):

1. **FIX ASTRO CONFIG** - Cambiar applyBaseStyles a true en astro.config.mjs

2. **CREAR DATA DIRECTORY** - docs/src/data/ con:
   - project-stats.json (test counts, feat status, github stats)
   - medical-standards.json (ICD-10 278, LOINC 145, RxNorm 118, SNOMED CT 87)
   - features-map.json (25 features con layer y status)
   - timeline.json (hitos de desarrollo)

3. **CREAR 7 COMPONENTES** en docs/src/components/:
   - ArchitectureFlow.astro (diagrama SVG Clean Architecture 4 capas)
   - FeatureGrid.astro (25 features en grid con status dots)
   - MedicalStandardsViz.astro (4 standards con cards interactivas)
   - DataPrivacyFlow.astro (diagrama flujo local-only SVG)
   - TestCoverageDashboard.astro (donut/bar charts custom SVG)
   - GitHubLiveStatus.astro (dashboard stats)
   - TimelineViz.astro (linea de tiempo SVG)

4. **MODIFICAR index.astro** - Agregar seccion ProjectDashboard

5. **CREAR dashboard.astro** - Pagina dedicada

6. **BUILD** - npm run build, arreglar errores

REGLAS ESTRICTAS:
- Solo SVG inline para graficos (NO chart.js, NO recharts, NO D3)
- Cyber-minimalist: #0a0a0a bg, #10B981 accent, Fira Code
- Todos los componentes en src/components/
- build debe pasar sin errores

IMPORTANTE: No preguntes nada, solo ejecuta. Si ves errores, corrigelos inmediatamente.
'@

$prompt | claude -p "$prompt" --permission-mode bypassPermissions --print
