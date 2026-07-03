# Auth Feature

## Propósito
Esta feature es el núcleo de seguridad de la aplicación. Gestiona la autenticación del usuario mediante PIN y biometría, protegiendo el acceso a los datos sensibles de salud.

## Capas

### Domain
- `AuthService`: Interfaz que define las operaciones de autenticación (setPin, verifyPin, verifyBiometric, etc.).
- `AuthRepository`: Interfaz para la persistencia de datos relacionados con la sesión (opcional, dependiendo de la implementación).
- `AuthMethod`: Enum que define los métodos disponibles (pin, biometric, none).

### Application
- `AuthCubit`: Gestiona el estado global de autenticación de la aplicación (Authenticated, Unauthenticated, Locked, NotSetup).
- `AuthState`: Representa los diferentes estados de seguridad del usuario.

### Infrastructure
- `AuthServiceImpl`: Implementación de `AuthService` que utiliza servicios de cifrado.
- `EncryptionService`: Servicio para el hashing de PIN y generación de salt.
- `BiometricAuthService`: Wrapper sobre `local_auth` para validación biométrica.
- `SecureStorageService`: Almacenamiento seguro de credenciales.

### Presentation
- `AuthGate`: Widget principal que decide qué pantalla mostrar según el estado de autenticación y el perfil del usuario.
- `LoginPage`: Interfaz para ingresar el PIN o usar biometría.
- `SetupPinPage`: Flujo para la creación inicial del PIN.

## Dependencias con otras features
- `user_profile`: `AuthGate` consulta el repositorio de perfiles para determinar si debe redirigir a onboarding.
- `onboarding`: Flujo destino si no existe un perfil de usuario.
- `home`: Flujo destino tras una autenticación exitosa.

## Estado de completitud
- **Tests**: Cubierto con unit tests para `AuthCubit` y `AuthService`, y golden tests para `LoginPage`.
- **Data Layer**: Implementado usando almacenamiento seguro y servicios de cifrado.
- **Biometría**: Integrado con `local_auth`.

## Ejemplos de uso

### Proteger el acceso a la App
```dart
void main() {
  runApp(
    MaterialApp(
      home: AuthGate(),
    ),
  );
}
```

### Verificar PIN manualmente
```dart
final authService = getIt<AuthService>();
final result = await authService.verifyPin('1234');
if (result.success) {
  // Acceso concedido
}
```
