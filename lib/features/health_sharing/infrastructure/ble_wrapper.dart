import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BleWrapper {
  Future<bool> get isSupported => FlutterBluePlus.isSupported;

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
}
