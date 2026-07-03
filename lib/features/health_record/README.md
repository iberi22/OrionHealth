# Health Record Feature

## Propósito
Centraliza y visualiza la historia clínica del usuario. Proporciona una línea de tiempo unificada de eventos médicos, documentos y registros de salud.

## Capas

### Domain
- `MedicalRecord`: Entidad base para cualquier registro de salud.
- `TimelineEntry`: Representación de un evento en la cronología del usuario.
- `HealthRecordRepository`: Interfaz para acceder a la historia clínica consolidada.

### Application
- `HealthRecordCubit`: Gestiona la carga y el filtrado de la línea de tiempo clínica.

### Infrastructure
- `HealthRecordRepositoryImpl`: Implementación que consolida datos de diversas fuentes locales.
- `HealthRecordService`: Servicio para procesar y categorizar registros médicos.

### Presentation
- `TimelinePage`: Vista cronológica de la historia clínica.
- `MedicalRecordDetailPage`: Visualización detallada de un registro específico.

## Dependencias con otras features
- `dashboard`: Proporciona datos para los widgets de resumen en la pantalla de inicio.
- `vitals`: Integra mediciones biométricas en la línea de tiempo.
- `medications`: Incluye el historial de prescripciones.
- `health_data_import`: Fuente de datos externos que alimentan el registro.

## Estado de completitud
- **Tests**: Unit tests para `HealthRecordCubit`.
- **Data Layer**: Integración con repositorio local.
- **UI**: Visualización en formato Timeline implementada.

## Ejemplos de uso

### Acceder a la línea de tiempo
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const TimelinePage()),
);
```

### Consultar registros recientes
```dart
final records = await getIt<HealthRecordRepository>().getRecentRecords(limit: 5);
```
