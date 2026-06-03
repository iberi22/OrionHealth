import 'dart:async';
import '../domain/entities/shared_health_package.dart';

/// BLE Service UUID for OrionHealth sharing
const String kOrionHealthServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
const String kOrionHealthTxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
const String kOrionHealthRxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

/// BLE sharing service for P2P health data transfer
class BleSharingService {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration transferTimeout = Duration(minutes: 3);

  final _stateController = StreamController<BleSharingState>.broadcast();
  Stream<BleSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<SharedHealthPackage>.broadcast();
  Stream<SharedHealthPackage> get incomingData => _dataController.stream;

  /// Initialize BLE adapter
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<void> initialize() async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Start advertising as a BLE server (to send data)
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<void> startAdvertising(String nodeId) async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Stop advertising
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<void> stopAdvertising() async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Scan for nearby OrionHealth devices (to receive data)
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<List<BleDevice>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Connect to a BLE device
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<bool> connect(String deviceId) async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Disconnect from current device
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<void> disconnect() async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Send data package to connected device
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<SharingResult> sendData(SharedHealthPackage package) async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Receive data from connected device
  // TODO: Implement BLE sharing (ref: CODE_REVIEW_ANOMALIES.md)
  Future<SharedHealthPackage?> receiveData() async {
    throw UnimplementedError('BLE sharing — implement when NFC/BLE infra ready');
  }

  /// Clean up resources
  void dispose() {
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
