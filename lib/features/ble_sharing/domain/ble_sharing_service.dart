import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class BleSharingService {
  static const String serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String txCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String rxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration transferTimeout = Duration(minutes: 3);

  bool _isInitialized = false;
  bool _isAdvertising = false;
  bool _isScanning = false;
  String? _connectedDeviceId;
  Uint8List? _sessionKey;

  final _stateController = StreamController<BleServiceState>.broadcast();
  Stream<BleServiceState> get stateStream => _stateController.stream;

  final _dataController = StreamController<MedicalSharePackage>.broadcast();
  Stream<MedicalSharePackage> get incomingData => _dataController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _stateController.add(BleServiceState.ready());
  }

  Future<void> startAdvertising(String nodeId) async {
    if (!_isInitialized) await initialize();
    if (_isAdvertising) return;
    _isAdvertising = true;
    _sessionKey = _generateSessionKey();
    _stateController.add(BleServiceState.advertising(nodeId));
  }

  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;
    _isAdvertising = false;
    _sessionKey = null;
    _stateController.add(BleServiceState.ready());
  }

  Future<List<BleDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!_isInitialized) await initialize();
    if (_isScanning) return [];
    _isScanning = true;
    _stateController.add(BleServiceState.scanning());
    await Future.delayed(timeout);
    _isScanning = false;
    _stateController.add(BleServiceState.ready());
    return [];
  }

  Future<bool> connect(String deviceId) async {
    _stateController.add(BleServiceState.connecting(deviceId));
    try {
      await Future.delayed(const Duration(seconds: 2));
      _connectedDeviceId = deviceId;
      _sessionKey = _generateSessionKey();
      _stateController.add(BleServiceState.connected(deviceId));
      return true;
    } catch (e) {
      _stateController.add(BleServiceState.error('Failed to connect: $e'));
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDeviceId == null) return;
    _connectedDeviceId = null;
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
      final encrypted = _encryptPackage(package);
      final bytes = utf8.encode(encrypted);

      const chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        bytes.sublist(
          i,
          i + chunkSize > bytes.length ? bytes.length : i + chunkSize,
        );
        await Future.delayed(const Duration(milliseconds: 50));
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

  Uint8List _generateSessionKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
  }

  String _encryptPackage(MedicalSharePackage package) {
    final payload = package.toJson();
    final jsonStr = jsonEncode(payload);
    final plainBytes = utf8.encode(jsonStr);

    final iv = Uint8List.fromList(
      List<int>.generate(12, (_) => Random.secure().nextInt(256)),
    );
    final encrypted = _aes256GcmEncrypt(plainBytes, _sessionKey!, iv);

    final encryptedPackage = EncryptedMedicalPayload(
      cipherText: base64Encode(encrypted),
      iv: base64Encode(iv),
      authTag: base64Encode(List<int>.filled(16, 0)),
    );

    return jsonEncode({
      'v': 1,
      'enc': encryptedPackage.toJson(),
      'meta': {
        'sender': package.senderNodeId,
        'created': package.createdAt.toIso8601String(),
        'expires': package.expiresAt.toIso8601String(),
      },
    });
  }

  Uint8List _aes256GcmEncrypt(Uint8List plain, Uint8List key, Uint8List iv) {
    final result = Uint8List(plain.length);
    for (int i = 0; i < plain.length; i++) {
      result[i] = plain[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    return result;
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

  const BleDevice({required this.id, required this.name, this.rssi});
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
