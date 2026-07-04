# EPS Connection Feature

## Propósito
Conexión con Entidades Prestadoras de Salud (EPS) colombianas. Permite vincular la cuenta de la EPS del usuario para consultar autorizaciones, historial y más.

## Capas
- **Domain**: Entidades EPS, repositorio abstracto, casos de uso.
- **Application**: Cubit para flujo de conexión y estado.
- **Infrastructure**: Datasources de API EPS, repositorio de implementación.
- **Presentation**: UI de conexión y gestión de EPS.

## Estado
- **Tests**: 19 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
