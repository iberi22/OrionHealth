import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/start_listening_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}

void main() {
  setUpAll(() {
    registerFallbackValue(TransferMethod.ble);
  });

  late StartListeningUseCase useCase;
  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;

  setUp(() {
    mockBleService = MockBleSharingService();
    mockNfcService = MockNfcSharingService();
    mockWifiService = MockWifiDirectService();
    useCase = StartListeningUseCase(mockBleService, mockNfcService, mockWifiService);
  });

  test('calls bleService.scanForDevices when method is BLE', () async {
    when(() => mockBleService.scanForDevices()).thenAnswer((_) async => []);

    await useCase(TransferMethod.ble);

    verify(() => mockBleService.scanForDevices()).called(1);
  });

  test('calls nfcService.startListening when method is NFC', () async {
    when(() => mockNfcService.startListening()).thenAnswer((_) async => {});

    await useCase(TransferMethod.nfc);

    verify(() => mockNfcService.startListening()).called(1);
  });

  test('calls wifiService.startServer when method is WiFi', () async {
    when(() => mockWifiService.startServer()).thenAnswer((_) async => {});

    await useCase(TransferMethod.wifi);

    verify(() => mockWifiService.startServer()).called(1);
  });
}
