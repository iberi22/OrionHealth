Archivos:
- lib/features/auth/presentation/providers/auth_provider.dart
- lib/features/auth/domain/usecases/check_session_timeout.dart

Implementar session timeout de 15 minutos:
- Detectar inactividad del usuario (touches, scrolls, input)
- Despues de 15 min sin actividad, cerrar sesion
- Mostrar pantalla de "sesion expirada" con boton para login
- Usar Timer en el provider y resetearlo en cada interaccion
