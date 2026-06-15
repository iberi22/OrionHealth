import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/shared_health_package.dart';
import 'ble_wrapper.dart';

/// BLE Service UUID for OrionHealth sharing
const String kOrionHealthServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
const String kOrionHealthTxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
const String kOrionHealthRxCharacteristic = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

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

  static const Duration connectionTimeout = Duration(seconds: 35);
  static const Duration transferTimeout = Duration(minutes: 3);

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
  Completer<SharedHealthPackage?>? _receiveCompleter;
  final List<int> _receiveBuffer = [];

  final _stateController = StreamController<BleSharingState>.broadcast();
  Stream<BleSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<SharedHealthPackage>.broadcast();
  Stream<SharedHealthPackage> get incomingData => _dataController.stream;

  /// Initialize BLE adapter
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (await _bleWrapper.isSupported == false) {
      throw Exception('Bluetooth not supported on this device');
    }
    _isInitialized = true;
    _stateController.add(BleSharingState.ready());
  }

  /// Start advertising as an OrionHealth node.
  ///
  /// Uses the platform-specific GATT server (Android/iOS/macOS) via
  /// [BleWrapper.startAdvertise] to broadcast the OrionHealth service
  /// UUID so that other devices can discover, connect, and receive
  /// health data from this node.
  Future<void> startAdvertising(String nodeId) async {
    if (!_isInitialized) await initialize();
    _stateController.add(BleSharingState.advertising(nodeId));

    await _bleWrapper.startAdvertise(
      serviceUuid: kOrionHealthServiceUuid,
      localName: nodeId,
      includePowerLevel: true,
    );
  }

  /// Stop advertising.
  Future<void> stopAdvertising() async {
    await _bleWrapper.stopAdvertise();
    _stateController.add(BleSharingState.ready());
  }

  /// Scan for nearby OrionHealth devices (to receive data)
  Future<List<BleDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!_isInitialized) await initialize();

    final results = <BleDevice>[];
    _scannedDevices.clear();
    _stateController.add(BleSharingState.scanning());

    await _bleWrapper.startScan(
      timeout: timeout,
      withServices: [
        Guid(heartRateServiceUuid),
        Guid(glucoseServiceUuid),
        Guid(thermometerServiceUuid),
        Guid(kOrionHealthServiceUuid),
      ],
    );

    final completer = Completer<void>();
    final scanSubscription = _bleWrapper.scanResults.listen((scanResults) {
      for (final r in scanResults) {
        final deviceId = r.device.remoteId.str;
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

    _stateController.add(BleSharingState.ready());
    return results.toSet().toList();
  }

  String _detectDeviceType(List<Guid> uuids) {
    final strUuids = uuids.map((u) => u.str.toLowerCase()).toList();
    if (strUuids.contains(heartRateServiceUuid)) return 'Heart Rate Monitor';
    if (strUuids.contains(glucoseServiceUuid)) return 'Glucose Meter';
    if (strUuids.contains(thermometerServiceUuid)) return 'Health Thermometer';
    if (strUuids.contains(kOrionHealthServiceUuid)) return 'OrionHealth Node';
    return 'Medical Device';
  }

  /// Connect to a BLE device
  Future<bool> connect(String deviceId) async {
    if (!_isInitialized) await initialize();

    BluetoothDevice device;
    if (_scannedDevices.containsKey(deviceId)) {
      device = _scannedDevices[deviceId]!;
    } else {
      device = _bleWrapper.deviceFromId(deviceId);
    }

    _stateController.add(BleSharingState.connecting(deviceId));

    try {
      await device.connect(
        license: License.nonprofit,
        timeout: connectionTimeout,
        mtu: 512,
        autoConnect: false,
      );

      final services = await device.discoverServices(
        subscribeToServicesChanged: true,
        timeout: 15,
      );

      BluetoothService? orionService;
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == kOrionHealthServiceUuid.toLowerCase()) {
          orionService = service;
          break;
        }
      }

      if (orionService == null) {
        await device.disconnect();
        _stateController.add(
          BleSharingState.error('OrionHealth service not found on device'),
        );
        return false;
      }

      for (final characteristic in orionService.characteristics) {
        final uuid = characteristic.uuid.str.toLowerCase();
        if (uuid == kOrionHealthTxCharacteristic.toLowerCase()) {
          _txCharacteristic = characteristic;
        } else if (uuid == kOrionHealthRxCharacteristic.toLowerCase()) {
          _rxCharacteristic = characteristic;
        }
      }

      if (_txCharacteristic == null) {
        await device.disconnect();
        _stateController.add(
          BleSharingState.error('TX characteristic not found'),
        );
        return false;
      }

      if (_rxCharacteristic != null) {
        await _rxCharacteristic!.setNotifyValue(true, timeout: 15);
        _rxSubscription = _rxCharacteristic!.lastValueStream.listen(
          _onRxDataReceived,
        );
      }

      _connectedDevice = device;
      _connectedDeviceId = deviceId;
      _sessionKey = _generateSessionKey();

      _stateController.add(BleSharingState.connected(deviceId));
      return true;
    } catch (e) {
      _stateController.add(BleSharingState.error('Failed to connect: $e'));
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    if (_connectedDevice == null) return;

    _rxSubscription?.cancel();
    _rxSubscription = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;

    if (_receiveCompleter != null && !_receiveCompleter!.isCompleted) {
      _receiveCompleter!.complete(null);
    }
    _receiveCompleter = null;
    _receiveBuffer.clear();

    await _connectedDevice!.disconnect();
    _connectedDevice = null;
    _connectedDeviceId = null;
    _sessionKey = null;

    _stateController.add(BleSharingState.ready());
  }

  /// Send data package to connected device
  Future<SharingResult> sendData(SharedHealthPackage package) async {
    if (_txCharacteristic == null || _connectedDeviceId == null) {
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
      final encryptedBytes = await _encryptPackage(package);

      final lengthBytes = Uint8List(4);
      final byteData = ByteData.sublistView(lengthBytes);
      byteData.setUint32(0, encryptedBytes.length, Endian.big);
      await _txCharacteristic!.write(lengthBytes.toList(),
          withoutResponse: false, timeout: 15);

      const chunkSize = 512;
      for (int i = 0; i < encryptedBytes.length; i += chunkSize) {
        final end = i + chunkSize > encryptedBytes.length ? encryptedBytes.length : i + chunkSize;
        final chunk = encryptedBytes.sublist(i, end);

        await _txCharacteristic!.write(chunk.toList(),
            withoutResponse: true, timeout: 15);
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final transferTime = DateTime.now().difference(startTime);
      _stateController.add(BleSharingState.completed(
        encryptedBytes.length,
        transferTime,
      ));

      return SharingResult(
        success: true,
        bytesTransferred: encryptedBytes.length,
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

  void _onRxDataReceived(List<int> data) {
    _receiveBuffer.addAll(data);

    if (_receiveBuffer.length < 4) return;

    final expectedLength =
        ByteData.sublistView(Uint8List.fromList(_receiveBuffer.sublist(0, 4)))
            .getUint32(0, Endian.big);

    final totalExpected = 4 + expectedLength;

    if (_receiveBuffer.length >= totalExpected) {
      final payload = _receiveBuffer.sublist(4, totalExpected);
      _receiveBuffer.removeRange(0, totalExpected);
      _decryptAndParsePackage(payload);
    }
  }

  Future<void> _decryptAndParsePackage(List<int> encryptedData) async {
    try {
      final nonce = encryptedData.sublist(0, 12);
      final mac = encryptedData.sublist(encryptedData.length - 16);
      final ciphertext = encryptedData.sublist(12, encryptedData.length - 16);

      final secretBox = SecretBox(
        ciphertext,
        nonce: nonce,
        mac: Mac(mac),
      );

      final decrypted = await _aesGcm.decrypt(secretBox, secretKey: _sessionKey!);
      final jsonStr = utf8.decode(decrypted);
      final package = SharedHealthPackage.fromJson(jsonDecode(jsonStr));

      _stateController.add(BleSharingState.ready());
      _dataController.add(package);

      if (_receiveCompleter != null && !_receiveCompleter!.isCompleted) {
        _receiveCompleter!.complete(package);
      }
    } catch (e) {
      _stateController.add(BleSharingState.error('Decrypt failed: $e'));
    }
  }

  /// Receive data from connected device
  Future<SharedHealthPackage?> receiveData({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_connectedDeviceId == null) return null;

    _stateController.add(BleSharingState.transferring('Receiving...'));
    _receiveCompleter = Completer<SharedHealthPackage?>();

    try {
      final result = await _receiveCompleter!.future.timeout(
        timeout,
        onTimeout: () => null,
      );
      _receiveCompleter = null;
      return result;
    } catch (e) {
      _stateController.add(BleSharingState.error('Receive failed: $e'));
      _receiveCompleter = null;
      return null;
    }
  }

  Future<void> startMedicalDataStream(String deviceId) async {
    if (!_isInitialized) await initialize();
    await scanForDevices(timeout: const Duration(seconds: 10));

    if (_scannedDevices.containsKey(deviceId)) {
      final connected = await connect(deviceId);
      if (!connected) {
        throw Exception('Failed to connect to medical device: $deviceId');
      }
    }
  }

  SecretKey _generateSessionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return SecretKey(bytes);
  }

  Future<Uint8List> _encryptPackage(SharedHealthPackage package) async {
    final payload = package.toJson();
    final jsonStr = jsonEncode(payload);
    final plainBytes = utf8.encode(jsonStr);

    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      plainBytes,
      secretKey: _sessionKey!,
      nonce: nonce,
    );

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

    return combined;
  }

  /// Clean up resources
  void dispose() {
    stopAdvertising();
    disconnect();
    _rxSubscription?.cancel();
    _stateController.close();
    _dataController.close();
  }
}

/// BLE device discovered during scan
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
