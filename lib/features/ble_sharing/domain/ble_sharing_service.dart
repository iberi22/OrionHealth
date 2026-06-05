import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:cryptography/cryptography.dart';
import 'ble_wrapper.dart';

@lazySingleton
class BleSharingService {
  final BleWrapper _bleWrapper;

  BleSharingService({BleWrapper? bleWrapper})
      : _bleWrapper = bleWrapper ?? BleWrapper();

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
  SecretKey? _sessionKey;
  final AesGcm _aesGcm = AesGcm.with256bits();

  // BLE device references from the last scan
  final Map<String, BluetoothDevice> _scannedDevices = {};

  // Active BLE connection state
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;
  StreamSubscription? _rxSubscription;

  // Completer for receiving data (signals when a full package is received)
  Completer<MedicalSharePackage?>? _receiveCompleter;
  final List<int> _receiveBuffer = [];

  final _stateController = StreamController<BleServiceState>.broadcast();
  Stream<BleServiceState> get stateStream => _stateController.stream;

  final _dataController = StreamController<MedicalSharePackage>.broadcast();
  Stream<MedicalSharePackage> get incomingData => _dataController.stream;

  // ─── Lifecycle ──────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (await _bleWrapper.isSupported == false) {
      throw Exception('Bluetooth not supported on this device');
    }
    _isInitialized = true;
  }

  void dispose() {
    stopAdvertising();
    disconnect();
    _rxSubscription?.cancel();
    _stateController.close();
    _dataController.close();
  }

  // ─── Scanning ───────────────────────────────────────────────────

  Future<List<BleDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!_isInitialized) await initialize();

    final results = <BleDevice>[];
    _scannedDevices.clear();
    _stateController.add(BleServiceState.scanning());

    await _bleWrapper.startScan(
      timeout: timeout,
      withServices: [
        Guid(heartRateServiceUuid),
        Guid(glucoseServiceUuid),
        Guid(thermometerServiceUuid),
        Guid(serviceUuid), // OrionHealth P2P
      ],
    );

    final completer = Completer<void>();
    final scanSubscription = _bleWrapper.scanResults.listen((scanResults) {
      for (final r in scanResults) {
        final deviceId = r.device.remoteId.str;
        // Cache the BluetoothDevice reference for later connect()
        _scannedDevices[deviceId] = r.device;

        final deviceType = _detectDeviceType(r.advertisementData.serviceUuids);
        results.add(BleDevice(
          id: deviceId,
          name: r.device.platformName.isNotEmpty
              ? r.device.platformName
              : 'Unknown Device',
          rssi: r.rssi,
          type: deviceType,
        ));
      }
      if (results.length > 20) completer.complete();
    }, onDone: () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future.timeout(timeout, onTimeout: () {});
    await scanSubscription.cancel();
    await _bleWrapper.stopScan();

    _stateController.add(BleServiceState.ready());
    return results.toSet().toList();
  }

  String _detectDeviceType(List<Guid> uuids) {
    final strUuids = uuids.map((u) => u.str.toLowerCase()).toList();
    if (strUuids.contains(heartRateServiceUuid)) return 'Heart Rate Monitor';
    if (strUuids.contains(glucoseServiceUuid)) return 'Glucose Meter';
    if (strUuids.contains(thermometerServiceUuid)) return 'Health Thermometer';
    if (strUuids.contains(serviceUuid)) return 'OrionHealth Node';
    return 'Medical Device';
  }

  // ─── Connection ─────────────────────────────────────────────────

  /// Connect to a previously scanned device.
  ///
  /// Performs: connect → discoverServices → find OrionHealth GATT service
  /// → store TX (write) and RX (notify) characteristics.
  Future<bool> connect(String deviceId) async {
    // Look up the BluetoothDevice from our scan cache
    BluetoothDevice device;
    if (_scannedDevices.containsKey(deviceId)) {
      device = _scannedDevices[deviceId]!;
    } else {
      // Fallback: create from ID (only works on Android with cached devices)
      device = _bleWrapper.deviceFromId(deviceId);
    }

    _stateController.add(BleServiceState.connecting(deviceId));

    try {
      // Real BLE connection
      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 35),
        mtu: 512,
        autoConnect: false,
      );

      // Discover GATT services
      final services = await device.discoverServices(
        subscribeToServicesChanged: true,
        timeout: 15,
      );

      // Find our custom OrionHealth service
      BluetoothService? orionService;
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == serviceUuid.toLowerCase()) {
          orionService = service;
          break;
        }
      }

      if (orionService == null) {
        await device.disconnect();
        _stateController.add(
          BleServiceState.error('OrionHealth service not found on device'),
        );
        return false;
      }

      // Find TX (write) and RX (notify) characteristics
      for (final characteristic in orionService.characteristics) {
        final uuid = characteristic.uuid.str.toLowerCase();
        if (uuid == txCharacteristic.toLowerCase()) {
          _txCharacteristic = characteristic;
        } else if (uuid == rxCharacteristic.toLowerCase()) {
          _rxCharacteristic = characteristic;
        }
      }

      if (_txCharacteristic == null) {
        await device.disconnect();
        _stateController.add(
          BleServiceState.error('TX characteristic not found'),
        );
        return false;
      }

      // Subscribe to RX characteristic for incoming data
      if (_rxCharacteristic != null) {
        await _rxCharacteristic!.setNotifyValue(true, timeout: 15);
        _rxSubscription = _rxCharacteristic!.lastValueStream.listen(
          _onRxDataReceived,
        );
      }

      _connectedDevice = device;
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
    if (_connectedDevice == null) return;

    // Unsubscribe from RX notifications
    _rxSubscription?.cancel();
    _rxSubscription = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;

    // Cancel pending receive
    if (_receiveCompleter != null && !_receiveCompleter!.isCompleted) {
      _receiveCompleter!.complete(null);
    }
    _receiveCompleter = null;
    _receiveBuffer.clear();

    await _connectedDevice!.disconnect();
    _connectedDevice = null;
    _connectedDeviceId = null;
    _sessionKey = null;

    _stateController.add(BleServiceState.ready());
  }

  // ─── Sending ────────────────────────────────────────────────────

  Future<SharingResult> sendData(MedicalSharePackage package) async {
    if (_txCharacteristic == null || _connectedDeviceId == null) {
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

      // Send length prefix first (4 bytes, big-endian)
      final lengthBytes = Uint8List(4);
      final byteData = ByteData.sublistView(lengthBytes);
      byteData.setUint32(0, bytes.length, Endian.big);
      await _txCharacteristic!.write(lengthBytes.toList(),
          withoutResponse: false, timeout: 15);

      // Chunked write: 512 bytes per packet (MTU default)
      const chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end =
            i + chunkSize > bytes.length ? bytes.length : i + chunkSize;
        final chunk = bytes.sublist(i, end);

        await _txCharacteristic!.write(chunk.toList(),
            withoutResponse: true, timeout: 15);

        // Small delay between chunks to avoid overwhelming the BLE stack
        await Future.delayed(const Duration(milliseconds: 20));
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

  // ─── Receiving ──────────────────────────────────────────────────

  /// Called when data arrives on the RX characteristic.
  void _onRxDataReceived(List<int> data) {
    _receiveBuffer.addAll(data);

    // First 4 bytes = length prefix
    if (_receiveBuffer.length < 4) return;

    final expectedLength =
        ByteData.sublistView(Uint8List.fromList(_receiveBuffer.sublist(0, 4)))
            .getUint32(0, Endian.big);

    // Buffer now contains: 4-byte length + data
    final totalExpected = 4 + expectedLength;

    if (_receiveBuffer.length >= totalExpected) {
      // Extract the payload (skip 4-byte length prefix)
      final payload = _receiveBuffer.sublist(4, totalExpected);
      _receiveBuffer.removeRange(0, totalExpected);

      // Decrypt and parse
      _decryptAndParsePackage(payload);
    }
  }

  Future<void> _decryptAndParsePackage(List<int> encryptedData) async {
    try {
      // Decrypt with session key
      final nonce = encryptedData.sublist(0, 12);
      final mac = encryptedData.sublist(encryptedData.length - 16);
      final ciphertext =
          encryptedData.sublist(12, encryptedData.length - 16);

      final secretBox = SecretBox(
        ciphertext,
        nonce: nonce,
        mac: Mac(mac),
      );

      final decrypted = await _aesGcm.decrypt(secretBox, secretKey: _sessionKey!);
      final jsonStr = utf8.decode(decrypted);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final encPayload = EncryptedMedicalPayload.fromJson(json['enc']);
      final package = MedicalSharePackage(
        id: json['meta']['sender'] ?? 'unknown',
        senderNodeId: json['meta']['sender'] ?? 'unknown',
        recipientNodeId: _connectedDeviceId ?? 'self',
        createdAt: DateTime.parse(json['meta']['created']),
        expiresAt: DateTime.parse(json['meta']['expires']),
        payload: encPayload,
        metadata: const MedicalShareMetadata(
          packageType: 'MedicalData',
          consentVerified: false,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: '',
      );

      _stateController.add(BleServiceState.ready());
      _dataController.add(package);

      if (_receiveCompleter != null && !_receiveCompleter!.isCompleted) {
        _receiveCompleter!.complete(package);
      }
    } catch (e) {
      _stateController.add(
        BleServiceState.error('Decrypt failed: $e'),
      );
    }
  }

  /// Wait for incoming data. Returns null on timeout.
  Future<MedicalSharePackage?> receiveData({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_connectedDeviceId == null) return null;

    _stateController.add(BleServiceState.transferring('Receiving...'));
    _receiveCompleter = Completer<MedicalSharePackage?>();

    try {
      final result = await _receiveCompleter!.future.timeout(
        timeout,
        onTimeout: () => null,
      );
      _receiveCompleter = null;
      return result;
    } catch (e) {
      _stateController.add(BleServiceState.error('Receive failed: $e'));
      _receiveCompleter = null;
      return null;
    }
  }

  Future<void> startMedicalDataStream(String deviceId) async {
    if (!_isInitialized) await initialize();

    // Scan for the specific device
    await scanForDevices(timeout: const Duration(seconds: 10));

    if (_scannedDevices.containsKey(deviceId)) {
      final connected = await connect(deviceId);
      if (!connected) {
        throw Exception('Failed to connect to medical device: $deviceId');
      }
    }
  }

  // ─── Encryption ─────────────────────────────────────────────────

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

  // ─── Advertising (BLE Peripheral) ───────────────────────────────

  /// Start advertising as an OrionHealth node.
  ///
  /// TODO: BLE peripheral mode requires platform-specific GATT server.
  /// flutter_blue_plus 2.3.2 does not expose startAdvertising in the
  /// public API. Advertising requires Android GATT server / iOS CBPeripheralManager.
  /// For now, use the scan+connect pairing flow.
  Future<void> startAdvertising(String nodeId) async {
    _stateController.add(BleServiceState.advertising(nodeId));
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> stopAdvertising() async {
    _stateController.add(BleServiceState.ready());
  }
}

// ─── Data Models ──────────────────────────────────────────────────

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
