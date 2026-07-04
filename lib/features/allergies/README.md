# Allergies Feature

## Propósito
Gestiona el registro de alergias del usuario, permitiendo añadir, editar y consultar alergias a medicamentos, alimentos y otros alérgenos.

## Capas

### Domain
- Entidades de alergias, repositorio abstracto, casos de uso.

### Application
- Cubit para manejo del estado de la lista de alergias.

### Infrastructure
- Datasources y repositorio con persistencia Isar.

### Presentation
- Pantallas y widgets para visualizar y gestionar alergias.

## Estado
- **Tests**: 16 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
