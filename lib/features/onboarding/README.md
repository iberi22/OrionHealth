# Onboarding Feature

## Propósito
Flujo de incorporación para nuevos usuarios. Guía al usuario a través de la configuración inicial: permisos, perfil, preferencias y visión general de la app.

## Capas
- **Domain**: Entidades de onboarding, repositorio abstracto, casos de uso.
- **Application**: Cubit para estado del flujo de onboarding.
- **Infrastructure**: Datasource de persistencia de progreso.
- **Presentation**: Pantallas paso a paso del onboarding.

## Estado
- **Tests**: 25 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
