import 'package:injectable/injectable.dart';
import '../entities/shared_health_package.dart';
import '../../infrastructure/ble_sharing_service.dart';
import '../../infrastructure/nfc_sharing_service.dart';
import '../../infrastructure/wifi_direct_service.dart';

@lazySingleton
class StartSharingUseCase {
  final BleSharingService _bleService;
  final NfcSharingService _nfcService;
  final WifiDirectService _wifiService;

  StartSharingUseCase(
    this._bleService,
    this._nfcService,
    this._wifiService,
  );

  Future<void> call({
    required TransferMethod method,
    required SharedHealthPackage package,
    String? pin,
  }) async {
    switch (method) {
      case TransferMethod.ble:
        await _bleService.startAdvertising(package.recipientNodeId);
        break;
      case TransferMethod.nfc:
        await _nfcService.shareData(package);
        break;
      case TransferMethod.wifi:
        await _wifiService.discoverDevices();
        break;
    }
  }
}
