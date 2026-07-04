# Voice Chat Feature

## Propósito
Asistente de voz integrado en OrionHealth. Permite interacción por voz con la IA local usando ASR (reconocimiento de voz) y TTS (texto a voz) para consultas médicas hands-free.

## Capas
- **Domain**: Entidades de chat de voz, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado del asistente de voz.
- **Infrastructure**: Integraciones ASR/TTS, repositorio.
- **Presentation**: UI de chat de voz con micrófono y visualización.

## Estado
- **Tests**: 15 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
