import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/start_sharing_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}
class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSharedHealthPackage());
  });

  late StartSharingUseCase useCase;
  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;

  setUp(() {
    mockBleService = MockBleSharingService();
    mockNfcService = MockNfcSharingService();
    mockWifiService = MockWifiDirectService();
    useCase = StartSharingUseCase(mockBleService, mockNfcService, mockWifiService);
  });

  final package = SharedHealthPackage(
    id: '1',
    senderNodeId: 'sender',
    recipientNodeId: 'recipient',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    payload: const EncryptedPayload(encryptedData: '', iv: '', ephemeralPublicKey: ''),
    metadata: const PackageMetadata(
      packageType: 'selective',
      consentVerified: true,
      includedCategories: {},
      appVersion: '1.0.0',
    ),
    signature: '',
  );

  test('calls bleService.startAdvertising when method is BLE', () async {
    when(() => mockBleService.startAdvertising(any())).thenAnswer((_) async => {});

    await useCase(method: TransferMethod.ble, package: package);

    verify(() => mockBleService.startAdvertising('recipient')).called(1);
  });

  test('calls nfcService.shareData when method is NFC', () async {
    when(() => mockNfcService.shareData(any())).thenAnswer((_) async => const SharingResult(
          success: true,
          bytesTransferred: 100,
          transferTime: Duration(seconds: 1),
        ));

    await useCase(method: TransferMethod.nfc, package: package);

    verify(() => mockNfcService.shareData(package)).called(1);
  });

  test('calls wifiService.discoverDevices when method is WiFi', () async {
    when(() => mockWifiService.discoverDevices()).thenAnswer((_) async => []);

    await useCase(method: TransferMethod.wifi, package: package);

    verify(() => mockWifiService.discoverDevices()).called(1);
  });
}
