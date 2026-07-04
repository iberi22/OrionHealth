# Vitals Feature

## Propósito
Registro y seguimiento de signos vitales del usuario: frecuencia cardíaca, presión arterial, temperatura, peso, glucosa, y otros biomarcadores. Incluye visualización de tendencias y alertas.

## Capas
- **Domain**: Entidades de signos vitales, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado de las lecturas y filtros.
- **Infrastructure**: Datasources de almacenamiento local, repositorio.
- **Presentation**: UI de registro, histórico y gráficos de tendencias.

## Estado
- **Tests**: 16 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
