# Appointments Feature

## Propósito
Gestiona el ciclo de vida de las citas médicas del usuario, permitiendo la programación, visualización y gestión de encuentros con profesionales de la salud.

## Capas

### Domain
- `Appointment`: Entidad que representa una cita médica (fecha, médico, especialidad, etc.).
- `AppointmentRepository`: Interfaz para el acceso a datos de citas.
- `GetAppointments`, `SaveAppointment`: Casos de uso para operaciones específicas.

### Application
- `AppointmentsCubit`: Orquestador del estado de la lista de citas y operaciones de filtrado o actualización.

### Infrastructure
- `IsarAppointmentRepository`: Implementación de persistencia local utilizando la base de datos Isar.
- `AppointmentDto`: Objeto de transferencia de datos para el mapeo entre la base de datos y la entidad de dominio.

### Presentation
- `AppointmentsPage`: Pantalla principal con el listado de citas.
- `AppointmentCard`: Componente visual para mostrar detalles de una cita individual.

## Dependencias con otras features
- `user_profile`: Utilizado para asociar citas al perfil del usuario actual.
- `calendar_import`: (Potencial) Sincronización de citas con calendarios externos.

## Estado de completitud
- **Tests**: Unit tests para `AppointmentsCubit` y `AppointmentsState`.
- **Data Layer**: Repositorio basado en Isar completamente funcional.
- **UI**: Diseños terminados con soporte para temas.

## Ejemplos de uso

### Obtener todas las citas
```dart
final appointments = await getIt<AppointmentRepository>().getAllAppointments();
```

### Suscribirse al estado de citas
```dart
BlocBuilder<AppointmentsCubit, AppointmentsState>(
  builder: (context, state) {
    if (state is AppointmentsLoaded) {
      return ListView(children: state.appointments.map((a) => AppointmentCard(a)).toList());
    }
    return CircularProgressIndicator();
  },
)
```
