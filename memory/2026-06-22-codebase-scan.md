# OrionHealth Codebase Scan + Jules Issues (2026-06-22)

## PRs Mergeados (5)
- #815 FHIRMapper stubs - MERGED
- #816 OAuthRepository completion - MERGED
- #817 RdaParser - MERGED
- #818 Dependency injection fix - MERGED
- #819 AboutRemoteDataSource HTTP - MERGED

## Ramas eliminadas
- ~20 ramas remote no-main eliminadas
- Solo main queda en remote

## Issues creados para Jules (10) - ALL IN PLANNING
| # | Title | Type | Status |
|---|-------|------|--------|
| 820 | Core services tests (ASR/TTS/Audio) | test | Planning |
| 821 | Application layers allergies/appointments/medications/vitals | impl | Planning |
| 822 | Core utilities tests | test | Planning |
| 823 | Complete dashboard feature (D+I+A) | impl | Planning |
| 824 | Infra layers home/onboarding/calendar_import | impl | Planning |
| 825 | Clean Architecture sync feature | impl | Planning |
| 826 | Application layers eps_connection/health_data_import/email-citas | impl | Planning |
| 827 | WiFi Direct protocol mismatch BUG | fix | Planning |
| 828 | Integration tests | test | Planning |
| 829 | Core widgets tests | test | Planning |

## Áreas sin test: 52 archivos en core/
### Servicios (ASR - 8, TTS - 8, Audio - 2, AI - 1): 19 files
### Utilidades: 9 files (cache, error_handler, isolate_manager, etc.)
### Widgets: 7 files
### Theme: 3 files
### Responsive: 2 files
### DI modules: 5 files

## Bugs identificados
### WiFi Direct: Socket.connect vs HttpServer mismatch (HIGH)
