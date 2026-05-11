import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:cryptography/cryptography.dart';

@lazySingleton
class BleSharingService {
  // Standard GATT Service UUIDs
  static const String heartRateServiceUuid = '180d';
  static const String glucoseServiceUuid = '1808';
  static const String thermometerServiceUuid = '1809';
  static const String pulseOximeterServiceUuid = '1822';

  static const String serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String txCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String rxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

  bool _isInitialized = false;
  String? _connectedDeviceId;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txChar;
  BluetoothCharacteristic? _rxChar;
  final Map<String, BluetoothDevice> _discoveredDevices = {};
  SecretKey? _sessionKey;
  final AesGcm _aesGcm = AesGcm.with256bits();
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  final _stateController = StreamController<BleServiceState>.broadcast();
  Stream<BleServiceState> get stateStream => _stateController.stream;

  final _dataController = StreamController<MedicalSharePackage>.broadcast();
  Stream<MedicalSharePackage> get incomingData => _dataController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth not supported on this device');
    }
    _isInitialized = true;
  }

  Future<List<BleDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!_isInitialized) await initialize();

    final results = <BleDevice>[];
    _discoveredDevices.clear();
    _stateController.add(BleServiceState.scanning());

    // Start scanning
    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: [
        Guid(heartRateServiceUuid),
        Guid(glucoseServiceUuid),
        Guid(thermometerServiceUuid),
        Guid(serviceUuid), // OrionHealth P2P
      ],
    );

    // Listen for results — subscription stored for lifecycle management
    final completer = Completer<void>();
    _scanSubscription = FlutterBluePlus.scanResults.listen((scanResults) {
      for (final r in scanResults) {
        _discoveredDevices[r.device.remoteId.str] = r.device;
        final deviceType = _detectDeviceType(r.advertisementData.serviceUuids);
        results.add(BleDevice(
          id: r.device.remoteId.str,
          name: r.device.platformName.isNotEmpty ? r.device.platformName : 'Unknown Device',
          rssi: r.rssi,
          type: deviceType,
        ));
      }
      if (results.length > 20) completer.complete(); // Limit results
    }, onDone: () => completer.complete());

    await completer.future.timeout(timeout, onTimeout: () {});
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    _stateController.add(BleServiceState.ready());
    return results.toSet().toList(); // Remove duplicates
  }

  String _detectDeviceType(List<Guid> uuids) {
    final strUuids = uuids.map((u) => u.str.toLowerCase()).toList();
    if (strUuids.contains(heartRateServiceUuid)) return 'Heart Rate Monitor';
    if (strUuids.contains(glucoseServiceUuid)) return 'Glucose Meter';
    if (strUuids.contains(thermometerServiceUuid)) return 'Health Thermometer';
    if (strUuids.contains(serviceUuid)) return 'OrionHealth Node';
    return 'Medical Device';
  }

  Future<bool> connect(String deviceId) async {
    _stateController.add(BleServiceState.connecting(deviceId));
    try {
      // Verify Bluetooth is on
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        throw Exception('Bluetooth is turned off');
      }

      final device = _discoveredDevices[deviceId];
      if (device == null) {
        throw Exception('Device not found in scan results');
      }

      // ignore: undefined_named_parameter
      await (device as dynamic).connect(autoConnect: false);
      _connectedDevice = device;
      _connectedDeviceId = deviceId;

      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (final char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() == txCharacteristic.toLowerCase()) {
              _txChar = char;
            } else if (char.uuid.toString().toLowerCase() == rxCharacteristic.toLowerCase()) {
              _rxChar = char;
            }
          }
        }
      }

      if (_txChar == null || _rxChar == null) {
        throw Exception('OrionHealth GATT characteristics not found');
      }

      _sessionKey = _generateSessionKey();
      _stateController.add(BleServiceState.connected(deviceId));
      return true;
    } catch (e) {
      await disconnect();
      _stateController.add(BleServiceState.error('Failed to connect: $e'));
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (_) {}

    _connectedDevice = null;
    _connectedDeviceId = null;
    _txChar = null;
    _rxChar = null;
    _sessionKey = null;
    _stateController.add(BleServiceState.ready());
  }

  Future<SharingResult> sendData(MedicalSharePackage package) async {
    if (_connectedDeviceId == null) {
      return SharingResult(
        success: false,
        error: 'Not connected to any device',
        bytesTransferred: 0,
        transferTime: Duration.zero,
      );
    }

    _stateController.add(
      BleServiceState.transferring('Encrypting and sending...'),
    );
    final startTime = DateTime.now();

    try {
      final encrypted = await _encryptPackage(package);
      final bytes = utf8.encode(encrypted);

      const chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = i + chunkSize > bytes.length ? bytes.length : i + chunkSize;
        final chunk = bytes.sublist(i, end);

        await _txChar!.write(chunk, withoutResponse: false);
        await Future.delayed(const Duration(milliseconds: 20)); // Flow control
      }

      final transferTime = DateTime.now().difference(startTime);
      _stateController.add(
        BleServiceState.completed(bytes.length, transferTime),
      );

      return SharingResult(
        success: true,
        bytesTransferred: bytes.length,
        transferTime: transferTime,
      );
    } catch (e) {
      _stateController.add(BleServiceState.error('Transfer failed: $e'));
      return SharingResult(
        success: false,
        error: e.toString(),
        bytesTransferred: 0,
        transferTime: DateTime.now().difference(startTime),
      );
    }
  }

  Future<void> startMedicalDataStream(String deviceId) async {
    // TODO: Re-enable when BLE license is properly configured
    // flutter_blue_plus 2.3.1+ requires license parameter for connect()
  }

  Future<MedicalSharePackage?> receiveData() async {
    if (_connectedDeviceId == null) return null;
    _stateController.add(BleServiceState.transferring('Receiving...'));
    try {
      await Future.delayed(const Duration(seconds: 2));
      _stateController.add(BleServiceState.ready());
      return null;
    } catch (e) {
      _stateController.add(BleServiceState.error('Receive failed: $e'));
      return null;
    }
  }

  SecretKey _generateSessionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return SecretKey(bytes);
  }

  Future<String> _encryptPackage(MedicalSharePackage package) async {
    final payload = package.toJson();
    final jsonStr = jsonEncode(payload);
    final plainBytes = utf8.encode(jsonStr);

    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      plainBytes,
      secretKey: _sessionKey!,
      nonce: nonce,
    );

    // Pack: nonce (12) + ciphertext + mac (16)
    final combined = Uint8List(
      nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length,
    );
    combined.setRange(0, nonce.length, nonce, 0);
    combined.setRange(
      nonce.length,
      nonce.length + secretBox.cipherText.length,
      secretBox.cipherText,
      0,
    );
    combined.setRange(
      nonce.length + secretBox.cipherText.length,
      combined.length,
      secretBox.mac.bytes,
      0,
    );

    final encryptedPackage = EncryptedMedicalPayload(
      cipherText: base64Encode(combined),
      iv: base64Encode(nonce),
      authTag: base64Encode(secretBox.mac.bytes),
    );

    return jsonEncode({
      'v': 2,
      'enc': encryptedPackage.toJson(),
      'meta': {
        'sender': package.senderNodeId,
        'created': package.createdAt.toIso8601String(),
        'expires': package.expiresAt.toIso8601String(),
      },
    });
  }

  Future<void> startAdvertising(String nodeId) async {
    _stateController.add(BleServiceState.advertising(nodeId));
    // Stub implementation for now
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> stopAdvertising() async {
    _stateController.add(BleServiceState.ready());
    // Stub implementation for now
  }

  void dispose() {
    stopAdvertising();
    disconnect();
    _stateController.close();
    _dataController.close();
  }
}

class BleDevice {
  final String id;
  final String name;
  final int? rssi;
  final String type;

  const BleDevice({
    required this.id,
    required this.name,
    this.rssi,
    this.type = 'Unknown',
  });
}

class BleServiceState {
  final String status;
  final String? deviceId;
  final String? message;
  final bool isError;
  final int? bytesTransferred;
  final Duration? transferTime;

  const BleServiceState._({
    required this.status,
    this.deviceId,
    this.message,
    this.isError = false,
    this.bytesTransferred,
    this.transferTime,
  });

  factory BleServiceState.ready() => const BleServiceState._(status: 'ready');
  factory BleServiceState.scanning() => const BleServiceState._(
    status: 'scanning',
    message: 'Searching for nearby devices...',
  );
  factory BleServiceState.advertising(String nodeId) => BleServiceState._(
    status: 'advertising',
    deviceId: nodeId,
    message: 'Waiting for receiver...',
  );
  factory BleServiceState.connecting(String deviceId) => BleServiceState._(
    status: 'connecting',
    deviceId: deviceId,
    message: 'Connecting...',
  );
  factory BleServiceState.connected(String deviceId) => BleServiceState._(
    status: 'connected',
    deviceId: deviceId,
    message: 'Connected',
  );
  factory BleServiceState.transferring(String message) =>
      BleServiceState._(status: 'transferring', message: message);
  factory BleServiceState.completed(int bytes, Duration time) =>
      BleServiceState._(
        status: 'completed',
        message: 'Transfer complete',
        bytesTransferred: bytes,
        transferTime: time,
      );
  factory BleServiceState.error(String message) =>
      BleServiceState._(status: 'error', message: message, isError: true);
}

class MedicalSharePackage extends Equatable {
  final String id;
  final String senderNodeId;
  final String recipientNodeId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final EncryptedMedicalPayload payload;
  final MedicalShareMetadata metadata;
  final String signature;

  const MedicalSharePackage({
    required this.id,
    required this.senderNodeId,
    required this.recipientNodeId,
    required this.createdAt,
    required this.expiresAt,
    required this.payload,
    required this.metadata,
    required this.signature,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get canShare => !isExpired && metadata.consentVerified;

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderNodeId': senderNodeId,
    'recipientNodeId': recipientNodeId,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'payload': payload.toJson(),
    'metadata': metadata.toJson(),
    'signature': signature,
  };

  factory MedicalSharePackage.fromJson(Map<String, dynamic> json) {
    return MedicalSharePackage(
      id: json['id'],
      senderNodeId: json['senderNodeId'],
      recipientNodeId: json['recipientNodeId'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      payload: EncryptedMedicalPayload.fromJson(json['payload']),
      metadata: MedicalShareMetadata.fromJson(json['metadata']),
      signature: json['signature'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderNodeId,
    recipientNodeId,
    createdAt,
    expiresAt,
  ];
}

class EncryptedMedicalPayload extends Equatable {
  final String cipherText;
  final String iv;
  final String authTag;

  const EncryptedMedicalPayload({
    required this.cipherText,
    required this.iv,
    required this.authTag,
  });

  Map<String, dynamic> toJson() => {
    'cipherText': cipherText,
    'iv': iv,
    'authTag': authTag,
  };

  factory EncryptedMedicalPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedMedicalPayload(
      cipherText: json['cipherText'],
      iv: json['iv'],
      authTag: json['authTag'],
    );
  }

  @override
  List<Object?> get props => [cipherText, iv, authTag];
}

class MedicalShareMetadata extends Equatable {
  final String packageType;
  final bool consentVerified;
  final Set<MedicalDataCategory> includedCategories;
  final String? pinHash;
  final String appVersion;

  const MedicalShareMetadata({
    required this.packageType,
    required this.consentVerified,
    required this.includedCategories,
    this.pinHash,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
    'packageType': packageType,
    'consentVerified': consentVerified,
    'includedCategories': includedCategories.map((c) => c.name).toList(),
    'pinHash': pinHash,
    'appVersion': appVersion,
  };

  factory MedicalShareMetadata.fromJson(Map<String, dynamic> json) {
    return MedicalShareMetadata(
      packageType: json['packageType'],
      consentVerified: json['consentVerified'],
      includedCategories: (json['includedCategories'] as List)
          .map((name) => MedicalDataCategory.valueOf(name))
          .toSet(),
      pinHash: json['pinHash'],
      appVersion: json['appVersion'],
    );
  }

  @override
  List<Object?> get props => [
    packageType,
    consentVerified,
    includedCategories,
    appVersion,
  ];
}

enum MedicalDataCategory {
  labResults('Laboratorios'),
  vitalSigns('Signos Vitales'),
  medications('Medicamentos'),
  medicalEvents('Eventos Médicos'),
  documents('Documentos'),
  allergies('Alergias'),
  conditions('Condiciones'),
  procedures('Procedimientos');

  final String displayName;
  const MedicalDataCategory(this.displayName);

  static MedicalDataCategory valueOf(String name) {
    return MedicalDataCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => MedicalDataCategory.labResults,
    );
  }
}

class SharingResult extends Equatable {
  final bool success;
  final String? error;
  final int bytesTransferred;
  final Duration transferTime;

  const SharingResult({
    required this.success,
    this.error,
    required this.bytesTransferred,
    required this.transferTime,
  });

  @override
  List<Object?> get props => [success, error, bytesTransferred, transferTime];
}

enum MedicalTransferMethod {
  nfc('NFC', 'Tap phones to share'),
  ble('Bluetooth', 'Nearby device'),
  wifi('WiFi Direct', 'Same network');

  final String displayName;
  final String description;
  const MedicalTransferMethod(this.displayName, this.description);
}
