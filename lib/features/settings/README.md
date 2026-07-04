# Settings Feature

## Propósito
Pantalla de configuración de la aplicación. Permite al usuario ajustar preferencias de privacidad, notificaciones, tema, idioma y gestión de datos.

## Capas
- **Domain**: Entidades de configuración, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado de las preferencias.
- **Infrastructure**: Datasources de preferencias persistentes.
- **Presentation**: UI de configuración con secciones organizadas.

## Estado
- **Tests**: 23 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
