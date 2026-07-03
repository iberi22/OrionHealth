# Health Sharing Feature

## Propósito
Permite el intercambio seguro de datos de salud entre dispositivos sin necesidad de servidores intermedios. Facilita la transferencia de perfiles médicos y registros clínicos mediante tecnologías de proximidad.

## Capas

### Domain
- `SharedHealthPackage`: Entidad que empaqueta los datos a compartir (datos de salud, firma digital, etc.).
- `SharingRepository`: Interfaz para la gestión de las sesiones de intercambio.

### Application
- `SharingCubit`: Controla el estado del proceso de envío y recepción (inicializando, buscando, conectando, transfiriendo, completado).

### Infrastructure
- `BleSharingService`: Implementación de intercambio vía Bluetooth Low Energy.
- `NfcSharingService`: Implementación para transferencia por contacto mediante NFC.
- `WifiDirectService`: Implementación para transferencias de alta velocidad en red local.
- `HealthSharingRepositoryImpl`: Gestión de la persistencia de los registros compartidos/recibidos.

### Presentation
- `SharePage`: Interfaz para seleccionar datos y método de envío.
- `ReceivePage`: Interfaz para poner el dispositivo en modo escucha y aceptar transferencias.

## Dependencias con otras features
- `auth`: Los flujos de `receive_medical_data_page` y `share_medical_data_page` utilizan `SharingCubit` para la transferencia inicial de perfiles.
- `health_record`: Proporciona los datos que serán empaquetados para compartir.
- `user_profile`: Permite compartir la identidad médica del usuario.

## Estado de completitud
- **Tests**: Cubierto con unit tests para servicios BLE, NFC y WiFi Direct.
- **Hardware**: Integración con plugins nativos para Bluetooth y NFC.
- **Protocolo**: Implementación de handshake y transferencia de paquetes cifrados.

## Ejemplos de uso

### Iniciar escucha por NFC
```dart
context.read<SharingCubit>().startListening(TransferMethod.nfc);
```

### Enviar datos vía WiFi
```dart
context.read<SharingCubit>().sendViaWifi(targetAddress, myHealthPackage);
```
