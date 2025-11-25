# Protocolo de Trabajo Paralelo (Multi-Agente)

Para garantizar que 3 agentes (o desarrolladores) puedan trabajar simultáneamente sin romper el código del otro, se deben seguir estas reglas estrictas.

## 1. Límites de Propiedad (Boundaries)
Cada agente tiene un "Territorio" asignado en `TASK.md`.
- **Agente A (Core):** `lib/core`, `lib/features/user_profile`, `lib/main.dart`.
- **Agente B (Ingesta):** `lib/features/health_record`.
- **Agente C (IA):** `lib/features/local_agent`.

**Regla de Oro:** Si necesitas usar código de otro territorio que AÚN NO EXISTE, crea una **Interfaz (Abstract Class)** en tu propio dominio y úsala. No esperes ni invadas el código del otro.

## 2. Archivos Generados (`.g.dart`, `.config.dart`)
El uso de `build_runner` es frecuente.
- **Conflicto:** Si Agente A y Agente B generan código al mismo tiempo y hacen push, habrá conflictos en `injection.config.dart`.
- **Solución:**
    - Cada agente debe correr `flutter pub run build_runner build --delete-conflicting-outputs` localmente para probar.
    - Al hacer commit, **NO** incluyas `lib/injection.config.dart` si no eres el Agente A.
    - Los archivos `.g.dart` dentro de tu propia feature (ej: `user_profile.g.dart`) SÍ se pueden commitear.

## 3. Testing Aislado (`main_preview.dart`)
Los Agentes B y C **NO** pueden modificar `lib/main.dart` para probar sus pantallas.
- Deben crear un archivo `main_preview.dart` dentro de su carpeta de feature (ej: `lib/features/health_record/main_preview.dart`).
- Este archivo debe contener un `main()` que inicialice lo mínimo necesario (Theme, Mocks de dependencias) y lance su Widget principal.
- Este archivo **NO** se debe importar en la app real, es solo para desarrollo.

## 4. Inyección de Dependencias
- Usa `@injectable` en tus clases.
- Si eres Agente B o C, no te preocupes si `get_it` no tiene registrado el repositorio del otro. Usa Mocks en tu `main_preview.dart`.
