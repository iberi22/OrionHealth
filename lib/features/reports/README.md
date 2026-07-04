# Reports Feature

## Propósito
Generación y visualización de reportes de salud del usuario: resúmenes médicos, estadísticas de actividad, evolución de métricas y exportación de datos.

## Capas
- **Domain**: Entidades de reportes, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado de generación y filtros.
- **Infrastructure**: Datasources de datos históricos, repositorio.
- **Presentation**: UI de reportes con gráficos y exportación.

## Estado
- **Tests**: 16 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
