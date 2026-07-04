# Medications Feature

## Propósito
Gestión de medicamentos del usuario: registro de medicación actual, historial, dosis, recordatorios y verificación de interacciones farmacológicas.

## Capas
- **Domain**: Entidades de medicamentos, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado de la lista de medicamentos.
- **Infrastructure**: Datasources con base de datos local, repositorio.
- **Presentation**: UI de lista, detalle y recordatorios de medicamentos.

## Estado
- **Tests**: 12 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
