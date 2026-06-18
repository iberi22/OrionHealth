import 'package:injectable/injectable.dart';
import '../../infrastructure/ble_sharing_service.dart';
import '../../infrastructure/nfc_sharing_service.dart';
import '../../infrastructure/wifi_direct_service.dart';

@lazySingleton
class CancelSharingUseCase {
  final BleSharingService _bleService;
  final NfcSharingService _nfcService;
  final WifiDirectService _wifiService;

  CancelSharingUseCase(
    this._bleService,
    this._nfcService,
    this._wifiService,
  );

  Future<void> call() async {
    await _bleService.disconnect();
    await _bleService.stopAdvertising();
    await _nfcService.stopListening();
    await _wifiService.stop();
  }
}
