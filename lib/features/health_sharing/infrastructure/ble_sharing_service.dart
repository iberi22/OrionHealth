import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../auth/infrastructure/services/encryption_service.dart';
import '../domain/entities/shared_health_package.dart';

/// BLE Service UUID for OrionHealth sharing
const String kOrionHealthServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
const String kOrionHealthTxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
const String kOrionHealthRxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

/// BLE sharing service for P2P health data transfer
class BleSharingService {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration transferTimeout = Duration(minutes: 3);

  final EncryptionService _encryptionService;
  bool _isInitialized = false;
  bool _isAdvertising = false;
  bool _isScanning = false;
  String? _connectedDeviceId;

  final _stateController = StreamController<BleSharingState>.broadcast();
  Stream<BleSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<SharedHealthPackage>.broadcast();
  Stream<SharedHealthPackage> get incomingData => _dataController.stream;

  BleSharingService(this._encryptionService);

  /// Initialize BLE adapter
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _stateController.add(BleSharingState.ready());
  }

  /// Start advertising as a BLE server (to send data)
  Future<void> startAdvertising(String nodeId) async {
    if (!_isInitialized) await initialize();
    if (_isAdvertising) return;

    _isAdvertising = true;
    _stateController.add(BleSharingState.advertising(nodeId));
  }

  /// Stop advertising
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;
    _isAdvertising = false;
    _stateController.add(BleSharingState.ready());
  }

  /// Scan for nearby OrionHealth devices (to receive data)
  Future<List<BleDevice>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) async {
    if (!_isInitialized) await initialize();
    if (_isScanning) return [];

    _isScanning = true;
    _stateController.add(BleSharingState.scanning());

    await Future.delayed(timeout);

    _isScanning = false;
    _stateController.add(BleSharingState.ready());

    return [];
  }

  /// Connect to a BLE device
  Future<bool> connect(String deviceId) async {
    _stateController.add(BleSharingState.connecting(deviceId));
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate connection
      _connectedDeviceId = deviceId;
      _stateController.add(BleSharingState.connected(deviceId));
      return true;
    } catch (e) {
      _stateController.add(BleSharingState.error('Failed to connect: $e'));
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    if (_connectedDeviceId == null) return;
    _connectedDeviceId = null;
    _stateController.add(BleSharingState.ready());
  }

  /// Send data package to connected device
  Future<SharingResult> sendData(SharedHealthPackage package, {String? sessionKey}) async {
    if (_connectedDeviceId == null) {
      return SharingResult(
        success: false,
        error: 'Not connected to any device',
        bytesTransferred: 0,
        transferTime: Duration.zero,
      );
    }

    _stateController.add(BleSharingState.transferring('Encrypting and sending...'));
    final startTime = DateTime.now();

    try {
      // 1. Prepare payload - in a real scenario we'd encrypt with sessionKey or recipient public key
      // For this overhaul, we ensure use of AES-256-GCM via encryptionService

      String jsonToEncrypt = jsonEncode(package.toJson());
      final encryptedBytes = await _encryptionService.encrypt(jsonToEncrypt);

      // In production, we'd send these bytes over BLE characteristics
      final bytes = encryptedBytes;

      // Simulate chunked transfer
      const chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final transferTime = DateTime.now().difference(startTime);
      _stateController.add(BleSharingState.completed(
        bytes.length,
        transferTime,
      ));

      return SharingResult(
        success: true,
        bytesTransferred: bytes.length,
        transferTime: transferTime,
      );
    } catch (e) {
      _stateController.add(BleSharingState.error('Transfer failed: $e'));
      return SharingResult(
        success: false,
        error: e.toString(),
        bytesTransferred: 0,
        transferTime: DateTime.now().difference(startTime),
      );
    }
  }

  /// Receive data from connected device
  Future<SharedHealthPackage?> receiveData({String? sessionKey}) async {
    if (_connectedDeviceId == null) return null;

    _stateController.add(BleSharingState.transferring('Receiving and decrypting...'));

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate receive

      // In a real scenario, we'd get bytes from characteristic and decrypt them
      // final decryptedJson = await _encryptionService.decrypt(receivedBytes);
      // return SharedHealthPackage.fromJson(jsonDecode(decryptedJson));

      _stateController.add(BleSharingState.ready());
      return null;
    } catch (e) {
      _stateController.add(BleSharingState.error('Receive failed: $e'));
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    stopAdvertising();
    disconnect();
    _stateController.close();
    _dataController.close();
  }
}

/// BLE device discovered during scan
class BleDevice {
  final String id;
  final String name;
  final int? rssi;

  const BleDevice({
    required this.id,
    required this.name,
    this.rssi,
  });
}

/// State of BLE sharing service
class BleSharingState {
  final String status;
  final String? deviceId;
  final String? message;
  final bool isError;
  final int? bytesTransferred;
  final Duration? transferTime;

  const BleSharingState._({
    required this.status,
    this.deviceId,
    this.message,
    this.isError = false,
    this.bytesTransferred,
    this.transferTime,
  });

  factory BleSharingState.ready() => const BleSharingState._(status: 'ready');

  factory BleSharingState.scanning() => const BleSharingState._(
        status: 'scanning',
        message: 'Searching for nearby devices...',
      );

  factory BleSharingState.advertising(String nodeId) => BleSharingState._(
        status: 'advertising',
        deviceId: nodeId,
        message: 'Waiting for receiver...',
      );

  factory BleSharingState.connecting(String deviceId) => BleSharingState._(
        status: 'connecting',
        deviceId: deviceId,
        message: 'Connecting...',
      );

  factory BleSharingState.connected(String deviceId) => BleSharingState._(
        status: 'connected',
        deviceId: deviceId,
        message: 'Connected',
      );

  factory BleSharingState.transferring(String message) => BleSharingState._(
        status: 'transferring',
        message: message,
      );

  factory BleSharingState.completed(int bytes, Duration time) => BleSharingState._(
        status: 'completed',
        message: 'Transfer complete',
        bytesTransferred: bytes,
        transferTime: time,
      );

  factory BleSharingState.error(String message) => BleSharingState._(
        status: 'error',
        message: message,
        isError: true,
      );
}
