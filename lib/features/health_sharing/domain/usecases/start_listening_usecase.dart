import 'package:injectable/injectable.dart';
import '../entities/shared_health_package.dart';
import '../../infrastructure/ble_sharing_service.dart';
import '../../infrastructure/nfc_sharing_service.dart';
import '../../infrastructure/wifi_direct_service.dart';

@lazySingleton
class StartListeningUseCase {
  final BleSharingService _bleService;
  final NfcSharingService _nfcService;
  final WifiDirectService _wifiService;

  StartListeningUseCase(
    this._bleService,
    this._nfcService,
    this._wifiService,
  );

  Future<void> call(TransferMethod method, {String? pin}) async {
    switch (method) {
      case TransferMethod.ble:
        await _bleService.scanForDevices();
        break;
      case TransferMethod.nfc:
        await _nfcService.startListening();
        break;
      case TransferMethod.wifi:
        await _wifiService.startServer();
        break;
    }
  }
}
