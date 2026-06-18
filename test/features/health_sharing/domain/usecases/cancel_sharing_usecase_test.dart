import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/cancel_sharing_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}

void main() {
  late CancelSharingUseCase useCase;
  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;

  setUp(() {
    mockBleService = MockBleSharingService();
    mockNfcService = MockNfcSharingService();
    mockWifiService = MockWifiDirectService();
    useCase = CancelSharingUseCase(mockBleService, mockNfcService, mockWifiService);
  });

  test('calls disconnect and stop on all services', () async {
    when(() => mockBleService.disconnect()).thenAnswer((_) async => {});
    when(() => mockBleService.stopAdvertising()).thenAnswer((_) async => {});
    when(() => mockNfcService.stopListening()).thenAnswer((_) async => {});
    when(() => mockWifiService.stop()).thenAnswer((_) async => {});

    await useCase();

    verify(() => mockBleService.disconnect()).called(1);
    verify(() => mockBleService.stopAdvertising()).called(1);
    verify(() => mockNfcService.stopListening()).called(1);
    verify(() => mockWifiService.stop()).called(1);
  });
}
