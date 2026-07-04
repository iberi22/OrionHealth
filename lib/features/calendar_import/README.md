# Calendar Import Feature

## Propósito
Permite importar eventos de calendarios externos (Google Calendar, Outlook, etc.) y sincronizarlos con las citas médicas de OrionHealth.

## Capas

### Domain
- Entidades de evento de calendario, repositorio abstracto, casos de uso.

### Application
- Cubit para manejo del estado de importación.

### Infrastructure
- Datasources y repositorio para integración con APIs de calendario.

### Presentation
- Pantallas y widgets para configurar y ejecutar importaciones.

## Estado
- **Tests**: 15 unit tests, 4 golden tests.
- **Arquitectura**: Clean architecture completa (4 capas).
