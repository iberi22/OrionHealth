# Health Data Import Feature

## Propósito
Importación de datos de salud desde fuentes externas: dispositivos wearable, archivos CSV/JSON, otras apps de salud y historiales médicos digitales.

## Capas
- **Domain**: Entidades de datos de salud importados, repositorio, casos de uso.
- **Application**: Cubit para estado y progreso de importación.
- **Infrastructure**: Parsers de archivos, datasources, repositorio.
- **Presentation**: UI de importación con selector de archivos y vista previa.

## Estado
- **Tests**: 21 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
