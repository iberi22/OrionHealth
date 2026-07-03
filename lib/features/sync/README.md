# Sync Feature

## Propósito
Gestiona la sincronización de datos de salud con nodos externos, cumpliendo con el estándar FHIR (Fast Healthcare Interoperability Resources). Permite que la información local se mantenga actualizada con los sistemas de salud conectados.

## Capas

### Domain
- `SyncNode`: Entidad que representa un nodo de sincronización (servidor FHIR, otro dispositivo, etc.).
- `SyncRepository`: Interfaz para la gestión de nodos y estados de sincronización.
- `SyncService`: Interfaz para las operaciones de intercambio de datos FHIR.

### Application
- `FhirSyncCubit`: Gestiona el proceso de sincronización, reportando el progreso y manejando errores de red.

### Infrastructure
- `SyncRepositoryImpl`: Almacenamiento local de la configuración de los nodos de sincronización.
- `FhirSyncService`: Implementación de la lógica de negocio para la serialización y envío de recursos FHIR.
- `NodeDiscoveryService`: Servicio para encontrar automáticamente nodos compatibles en la red.

### Presentation
- `SyncPage`: Interfaz para visualizar el estado de la sincronización y disparar el proceso manualmente.

## Dependencias con otras features
- `health_record`: Es la fuente/destino principal de los datos sincronizados.
- `network`: Utiliza la infraestructura de red para descubrir y conectar con otros nodos.

## Estado de completitud
- **Tests**: Unit tests para `FhirSyncCubit` y `SyncState`. Golden tests para `SyncPage`.
- **Protocolo**: Soporte base para recursos FHIR implementado.
- **Data Layer**: Migrado a la capa de infraestructura.

## Ejemplos de uso

### Disparar sincronización manual
```dart
context.read<FhirSyncCubit>().performSync();
```

### Consultar estado de sincronización
```dart
BlocBuilder<FhirSyncCubit, SyncState>(
  builder: (context, state) {
    if (state.isSyncing) return ProgressIndicator();
    return Text("Última sincronización: ${state.lastSync}");
  },
)
```
