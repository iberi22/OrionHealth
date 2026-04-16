import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BleSharingService {
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  /// Scan for nearby devices
  Stream<List<ScanResult>> scanForDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    return FlutterBluePlus.scanResults;
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Connect to a device and send data
  Future<void> sendData(BluetoothDevice device, String encryptedData) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();

      BluetoothService? targetService;
      for (var service in services) {
        if (service.uuid.toString() == serviceUuid) {
          targetService = service;
          break;
        }
      }

      if (targetService != null) {
        for (var char in targetService.characteristics) {
          if (char.uuid.toString() == characteristicUuid) {
            final bytes = utf8.encode(encryptedData);
            const int chunkSize = 512;
            for (var i = 0; i < bytes.length; i += chunkSize) {
              final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
              await char.write(bytes.sublist(i, end), withoutResponse: false);
            }
            break;
          }
        }
      }
    } finally {
      await device.disconnect();
    }
  }

  /// Start advertising and listen for incoming data (Simulated for this implementation)
  Stream<String> receiveData() async* {
    // In a real implementation, we would use a BLE Peripheral plugin
    // flutter_blue_plus is primarily for Central role.
    // For this feat, we will simulate the reception mechanism.
    yield* const Stream.empty();
  }
}
