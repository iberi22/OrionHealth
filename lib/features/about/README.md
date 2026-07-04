# About Feature

## Propósito
Proporciona información sobre la aplicación OrionHealth: misión, valores, blog posts y actividades. Es la página "Acerca de" de la app.

## Capas

### Domain
- `AboutInfo`: Entidad que contiene la declaración de misión, valores, actividades y blog posts.
- `BlogPost`: Entidad que representa una entrada de blog (título, contenido, fecha, categoría).
- `IAboutRepository`: Interfaz para el repositorio de datos de About.

### Application
- `AboutCubit`: Orquestador del estado de la pantalla About, maneja loading/loaded/error.

### Infrastructure
- `AboutLocalDatasource`: Fuente de datos local (caché/in-memory).
- `AboutRemoteDatasource`: Fuente de datos remota (API).
- `AboutRepositoryImpl`: Implementación del repositorio combinando datasources.

### Presentation
- `AboutPage`: Pantalla principal con la información de la app.
- `MissionSection`: Widget que muestra la misión y valores.

## Dependencias con otras features
- Ninguna. Es una feature independiente.

## Estado de completitud
- **Tests**: 12 unit tests.
- **Arquitectura**: Clean architecture completa (4 capas).
- **UI**: Diseño terminado con misión, valores y blog.

## Archivos clave
- `domain/entities/about_info.dart` — Entidades del dominio
- `domain/repositories/i_about_repository.dart` — Interfaz del repositorio
- `infrastructure/datasources/*` — Datasources local y remoto
- `infrastructure/repositories/about_repository_impl.dart` — Implementación
- `application/about_cubit.dart` — Estado y lógica de negocio
- `presentation/pages/about_page.dart` — UI principal
