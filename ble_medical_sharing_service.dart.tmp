import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';

import 'encryption_service.dart';

/// Estado de la conexión Bluetooth
enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  transferring,
  error,
}

/// Tipo de rol en la transferencia
enum BleRole {
  sender, // Paciente enviando datos al médico
  receiver, // Médico recibiendo datos del paciente
}

/// Resultado de la transferencia
class BleTransferResult {
  final bool success;
  final String? data;
  final String? errorMessage;
  final int bytesTransferred;

  BleTransferResult({
    required this.success,
    this.data,
    this.errorMessage,
    this.bytesTransferred = 0,
  });
}

/// Información de un dispositivo descubierto
class DiscoveredDevice {
  final String id;
  final String name;
  final int rssi;
  final BluetoothDevice device;

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.device,
  });
}

/// Paquete de datos médicos para compartir
class MedicalDataPackage {
  final String patientId;
  final String patientName;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  MedicalDataPackage({
    required this.patientId,
    required this.patientName,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'patientName': patientName,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };

  factory MedicalDataPackage.fromJson(Map<String, dynamic> json) {
    return MedicalDataPackage(
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

/// Servicio para compartir datos médicos via Bluetooth Low Energy
@lazySingleton
class BleMedicalSharingService {
  // UUIDs personalizados para el servicio de OrionHealth
  static const _serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
  static const _sessionKeyCharUuid = '12345678-1234-5678-1234-56789abcdef1';
  static const _dataCharUuid = '12345678-1234-5678-1234-56789abcdef2';
  static const _statusCharUuid = '12345678-1234-5678-1234-56789abcdef3';

  final EncryptionService _encryptionService;

  // Estado interno
  BleConnectionState _state = BleConnectionState.disconnected;
  BluetoothDevice? _connectedDevice;
  String? _sessionKey;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // Controladores de stream para eventos
  final _stateController = StreamController<BleConnectionState>.broadcast();
  final _deviceController =
      StreamController<List<DiscoveredDevice>>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  BleMedicalSharingService(this._encryptionService);

  // Streams públicos
  Stream<BleConnectionState> get stateStream => _stateController.stream;
  Stream<List<DiscoveredDevice>> get devicesStream => _deviceController.stream;
  Stream<double> get progressStream => _progressController.stream;
  BleConnectionState get currentState => _state;

  /// Verifica si Bluetooth está disponible y encendido
  Future<bool> isBluetoothAvailable() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) return false;

      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }

  /// Solicita encender Bluetooth si está apagado
  Future<bool> requestEnableBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Inicia escaneo de dispositivos cercanos
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (_state == BleConnectionState.scanning) return;

    _updateState(BleConnectionState.scanning);
    final devices = <String, DiscoveredDevice>{};

    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: [
        Guid(_serviceUuid),
      ], // Solo dispositivos con nuestro servicio
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final device = DiscoveredDevice(
          id: result.device.remoteId.str,
          name: result.device.platformName.isNotEmpty
              ? result.device.platformName
              : 'OrionHealth Device',
          rssi: result.rssi,
          device: result.device,
        );
        devices[device.id] = device;
      }
      _deviceController.add(devices.values.toList());
    });

    // Auto-stop después del timeout
    Future.delayed(timeout, () {
      if (_state == BleConnectionState.scanning) {
        stopScan();
      }
    });
  }

  /// Detiene el escaneo
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    if (_state == BleConnectionState.scanning) {
      _updateState(BleConnectionState.disconnected);
    }
  }

  /// Conecta a un dispositivo descubierto
  Future<bool> connectToDevice(DiscoveredDevice device) async {
    try {
      _updateState(BleConnectionState.connecting);
      await stopScan();

      await device.device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      _connectedDevice = device.device;

      // Escuchar desconexiones
      _connectionSubscription = device.device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      _updateState(BleConnectionState.connected);
      return true;
    } catch (e) {
      _updateState(BleConnectionState.error);
      return false;
    }
  }

  /// Desconecta del dispositivo actual
  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } finally {
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _connectedDevice = null;
    _sessionKey = null;
    _updateState(BleConnectionState.disconnected);
  }

  /// Envía datos médicos encriptados al dispositivo conectado
  Future<BleTransferResult> sendMedicalData(MedicalDataPackage package) async {
    if (_connectedDevice == null) {
      return BleTransferResult(
        success: false,
        errorMessage: 'No hay dispositivo conectado',
      );
    }

    try {
      _updateState(BleConnectionState.transferring);
      _progressController.add(0.0);

      // 1. Descubrir servicios
      final services = await _connectedDevice!.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid == Guid(_serviceUuid),
        orElse: () => throw Exception('Servicio no encontrado'),
      );

      // 2. Generar clave de sesión y enviarla
      _sessionKey = await _encryptionService.generateShareSessionKey();
      final sessionKeyChar = service.characteristics.firstWhere(
        (c) => c.uuid == Guid(_sessionKeyCharUuid),
      );
      await sessionKeyChar.write(utf8.encode(_sessionKey!));
      _progressController.add(0.2);

      // 3. Encriptar datos médicos
      final jsonData = jsonEncode(package.toJson());
      final encryptedData = await _encryptionService.encryptForSharing(
        jsonData,
        _sessionKey!,
      );
      _progressController.add(0.4);

      // 4. Enviar datos en chunks (BLE tiene límite de MTU)
      final dataChar = service.characteristics.firstWhere(
        (c) => c.uuid == Guid(_dataCharUuid),
      );

      final dataBytes = utf8.encode(encryptedData);
      const chunkSize = 512; // Tamaño seguro para BLE
      final totalChunks = (dataBytes.length / chunkSize).ceil();

      for (var i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize).clamp(0, dataBytes.length);
        final chunk = dataBytes.sublist(start, end);

        await dataChar.write(chunk, withoutResponse: false);

        final progress = 0.4 + (0.5 * (i + 1) / totalChunks);
        _progressController.add(progress);
      }

      // 5. Enviar señal de fin
      final statusChar = service.characteristics.firstWhere(
        (c) => c.uuid == Guid(_statusCharUuid),
      );
      await statusChar.write(utf8.encode('COMPLETE'));
      _progressController.add(1.0);

      _updateState(BleConnectionState.connected);
      return BleTransferResult(
        success: true,
        bytesTransferred: dataBytes.length,
      );
    } catch (e) {
      _updateState(BleConnectionState.error);
      return BleTransferResult(
        success: false,
        errorMessage: 'Error enviando datos: $e',
      );
    }
  }

  /// Recibe datos médicos encriptados (modo receptor/médico)
  Future<BleTransferResult> receiveMedicalData() async {
    if (_connectedDevice == null) {
      return BleTransferResult(
        success: false,
        errorMessage: 'No hay dispositivo conectado',
      );
    }

    try {
      _updateState(BleConnectionState.transferring);
      _progressController.add(0.0);

      // 1. Descubrir servicios
      final services = await _connectedDevice!.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid == Guid(_serviceUuid),
        orElse: () => throw Exception('Servicio no encontrado'),
      );

      // 2. Recibir clave de sesión
      final sessionKeyChar = service.characteristics.firstWhere(
        (c) => c.uuid == Guid(_sessionKeyCharUuid),
      );
      await sessionKeyChar.setNotifyValue(true);

      final sessionKeyCompleter = Completer<String>();
      final sessionKeySub = sessionKeyChar.onValueReceived.listen((value) {
        if (value.isNotEmpty && !sessionKeyCompleter.isCompleted) {
          sessionKeyCompleter.complete(utf8.decode(value));
        }
      });

      _sessionKey = await sessionKeyCompleter.future.timeout(
        const Duration(seconds: 30),
      );
      await sessionKeySub.cancel();
      _progressController.add(0.2);

      // 3. Recibir datos encriptados
      final dataChar = service.characteristics.firstWhere(
        (c) => c.uuid == Guid(_dataCharUuid),
      );
      await dataChar.setNotifyValue(true);

      final receivedData = <int>[];
      final dataCompleter = Completer<void>();

      final dataSub = dataChar.onValueReceived.listen((value) {
        receivedData.addAll(value);
        // Actualizar progreso aproximado
        _progressController.add(
          0.2 + (0.6 * (receivedData.length / 10000).clamp(0, 1)),
        );
      });

      // 4. Esperar señal de completado
      final statusChar = service.characteristics.firstWhere(
        (c) => c.uuid == Guid(_statusCharUuid),
      );
      await statusChar.setNotifyValue(true);

      final statusSub = statusChar.onValueReceived.listen((value) {
        final status = utf8.decode(value);
        if (status == 'COMPLETE' && !dataCompleter.isCompleted) {
          dataCompleter.complete();
        }
      });

      await dataCompleter.future.timeout(const Duration(minutes: 2));
      await dataSub.cancel();
      await statusSub.cancel();
      _progressController.add(0.9);

      // 5. Desencriptar datos
      final encryptedData = utf8.decode(receivedData);
      final decryptedJson = await _encryptionService.decryptSharedData(
        encryptedData,
        _sessionKey!,
      );
      _progressController.add(1.0);

      _updateState(BleConnectionState.connected);
      return BleTransferResult(
        success: true,
        data: decryptedJson,
        bytesTransferred: receivedData.length,
      );
    } catch (e) {
      _updateState(BleConnectionState.error);
      return BleTransferResult(
        success: false,
        errorMessage: 'Error recibiendo datos: $e',
      );
    }
  }

  void _updateState(BleConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Limpia recursos
  Future<void> dispose() async {
    await stopScan();
    await disconnect();
    await _stateController.close();
    await _deviceController.close();
    await _progressController.close();
  }
}
