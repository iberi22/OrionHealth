// ignore_for_file: unused_field
import 'dart:async';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'encryption_service.dart';

/// BLE Medical Sharing Service for peer-to-peer health data transfer.
///
/// ⚠️ STUB — flutter_blue_plus API has changed significantly in v1.x.
/// To implement:
/// 1. Run: `flutter pub add flutter_blue_plus`
/// 2. Check FlutterBluePlus.adapterState for availability
/// 3. Use FlutterBluePlus.turnOn() if adapter is off
/// 4. Implement GATT server using BluetoothServer.create()
/// 5. Data characteristic with encryption via [EncryptionService]
///
/// See: https://pub.dev/packages/flutter_blue_plus
/// See: https://github.com/boskokg/flutter_blue_plus
@lazySingleton
class BleMedicalSharingService {
  final EncryptionService _encryptionService;

  bool _isAdvertising = false;
  bool _isInitialized = false;

  BleMedicalSharingService(this._encryptionService);

  /// Initialize BLE stack. Check permissions first.
  ///
  /// Android: BLUETOOTH_SCAN, BLUETOOTH_ADVERTISE, BLUETOOTH_CONNECT + location
  /// iOS: Declare NSBluetoothAlwaysUsageDescription in Info.plist
  Future<void> initialize() async {
    _isInitialized = true;
  }

  /// Start advertising this device as available for health data sharing.
  Future<bool> startAdvertising() async {
    _isAdvertising = true;
    return true;
  }

  /// Stop advertising.
  Future<void> stopAdvertising() async {
    _isAdvertising = false;
  }

  /// Scan for nearby OrionHealth devices.
  Stream<Map<String, dynamic>> scanForDevices() async* {
    // Stub: return empty stream
    yield* const Stream.empty();
  }

  /// Send encrypted health data to a peer.
  Future<void> sendData(Uint8List data, String remoteId) async {
    // Stub: no-op until flutter_blue_plus re-integration
  }

  /// Clean up.
  void dispose() {
    _isInitialized = false;
    _isAdvertising = false;
  }
}
