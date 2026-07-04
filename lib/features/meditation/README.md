# Meditation Feature

## Propósito
Guías y sesiones de meditación integradas en la app de salud. Incluye ejercicios de respiración, meditaciones guiadas y seguimiento de bienestar mental.

## Capas
- **Domain**: Entidades de meditación/sesión, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado del reproductor de meditación.
- **Infrastructure**: Repositorio de sesiones, integración con ASR/TTS.
- **Presentation**: UI del reproductor, lista de sesiones y estadísticas.

## Estado
- **Tests**: 20 unit tests, 2 golden tests.
- **Arquitectura**: Clean architecture completa (4 capas).
