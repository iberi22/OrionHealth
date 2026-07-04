# Dashboard Feature

## Propósito
Pantalla principal de la aplicación que muestra un resumen de la información más relevante del usuario: citas próximas, últimas lecturas de salud, recordatorios y acceso rápido a todas las funcionalidades.

## Capas

### Domain
- Entidades del dashboard, repositorio abstracto, casos de uso agregadores.

### Application
- Cubit para manejo del estado agregado del dashboard.

### Infrastructure
- Datasources y repositorio que combinan datos de múltiples features.

### Presentation
- Pantalla principal con widgets de resumen, gráficos y acceso rápido.

## Estado
- **Tests**: 12 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
