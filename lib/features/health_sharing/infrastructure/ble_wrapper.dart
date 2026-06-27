import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';

/// Channel for platform-specific BLE peripheral (advertiser) operations.
const MethodChannel _bleAdvertiseChannel =
    MethodChannel('orionhealth/ble_peripheral');

@lazySingleton
class BleWrapper {
  bool _isAdvertising = false;
  StreamSubscription? _advertisementStateSub;

  final _advertisementStateController =
      StreamController<bool>.broadcast();

  /// Stream that emits true when advertising starts, false when it stops.
  Stream<bool> get advertisementState =>
      _advertisementStateController.stream;

  /// Whether this device is currently advertising BLE services.
  bool get isAdvertising => _isAdvertising;

  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  /// Start BLE scanning for nearby peripherals.
  Future<void> startScan({
    List<Guid> withServices = const [],
    Duration? timeout,
    bool androidUsesFineLocation = false,
  }) {
    return FlutterBluePlus.startScan(
      withServices: withServices,
      timeout: timeout,
      androidUsesFineLocation: androidUsesFineLocation,
    );
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  BluetoothDevice deviceFromId(String remoteId) =>
      BluetoothDevice.fromId(remoteId);

  /// Start BLE advertising as a peripheral / GATT server.
  ///
  /// Uses the platform channel 'orionhealth/ble_peripheral' to invoke
  /// native BLE advertising (advertise the OrionHealth service UUID
  /// so that other devices can discover and connect to this node).
  ///
  /// Peripheral mode (advertising) is not currently implemented in the
  /// native layer. This method throws an [UnsupportedError] to notify
  /// the caller that BLE advertising is not available.
  Future<void> startAdvertise({
    required String serviceUuid,
    required String localName,
    bool includePowerLevel = true,
  }) async {
    throw UnsupportedError(
      'BLE Peripheral mode (advertising) is not supported on this platform yet. '
      'Use WiFi or NFC sharing instead.',
    );
  }

  /// Stop BLE advertising.
  Future<void> stopAdvertise() async {
    if (!_isAdvertising) return;
    _isAdvertising = false;
    _advertisementStateController.add(false);

    try {
      await _bleAdvertiseChannel.invokeMethod('stopAdvertising');
    } on MissingPluginException {
      // Ignore — nothing to stop on platforms without native handler.
    } catch (_) {
      // Best-effort stop.
    }
  }

  /// Clean up.
  void dispose() {
    _advertisementStateController.close();
    _advertisementStateSub?.cancel();
  }
}
