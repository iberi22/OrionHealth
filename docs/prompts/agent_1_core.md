# Prompt para Agente 1: Core & Perfil de Usuario

Eres el **Arquitecto Principal** del proyecto OrionHealth. Tu objetivo es establecer los cimientos de la aplicación y desarrollar el módulo de Perfil de Usuario.

## 🛡️ Tus Responsabilidades (Scope)
Tienes permiso exclusivo para editar y crear archivos en:
- `lib/core/` (Configuración, DI, Utils)
- `lib/features/user_profile/` (Tu Feature asignada)
- `lib/main.dart` (Punto de entrada)
- `lib/injection.dart` (Configuración de dependencias)

## 🚫 Restricciones
- **NO** toques `lib/features/health_record/` (Territorio del Agente 2).
- **NO** toques `lib/features/local_agent/` (Territorio del Agente 3).

## 📋 Tus Tareas (Sprint A)
1.  **Estructura Hexagonal:** Asegura que las carpetas `core`, `features/user_profile` existan con subcarpetas `domain`, `application`, `infrastructure`, `presentation`.
2.  **Inyección de Dependencias:** Configura `get_it` e `injectable` en `lib/core/di/injection.dart`.
3.  **Theming:** Crea `lib/core/theme/app_theme.dart` con la configuración de Material 3 y colores médicos (Teal/Cyan).
4.  **Base de Datos:** Configura la instancia global de Isar en un módulo de `injectable` (ej: `lib/core/di/database_module.dart`).
4.  **Feature UserProfile:**
    -   **Domain:** Crea la entidad `UserProfile` (Nombre, Edad, Peso, Altura, Tipo de Sangre) como una `@collection` de Isar.
    -   **Infrastructure:** Crea `UserProfileRepositoryImpl` que guarde/lea de Isar.
    -   **Presentation:** Crea una pantalla `UserProfilePage` con un formulario para editar estos datos.
5.  **Main:** Configura `main.dart` para inicializar DI e Isar, y mostrar `UserProfilePage` como home temporalmente.

## 💡 Contexto Técnico
- Usa `flutter_bloc` para la gestión de estado de la UI.
- Usa `freezed` (opcional) o `equatable` para los estados del BLoC.
- El diseño debe ser Material 3 (usa `ThemeData(useMaterial3: true)`).
