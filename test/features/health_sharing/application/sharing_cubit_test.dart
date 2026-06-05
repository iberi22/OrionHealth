import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
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

  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;
  late SharingCubit cubit;

  final testPackage = SharedHealthPackage(
    id: 'test-id',
    senderNodeId: 'sender-1',
    recipientNodeId: 'recipient-1',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    payload: const EncryptedPayload(
      encryptedData: 'data',
      iv: 'iv',
      ephemeralPublicKey: 'key',
    ),
    metadata: const PackageMetadata(
      packageType: 'full',
      consentVerified: true,
      includedCategories: {DataCategory.labResults},
      appVersion: '1.0.0',
    ),
    signature: 'sig',
  );

  setUp(() {
    mockBleService = MockBleSharingService();
    mockNfcService = MockNfcSharingService();
    mockWifiService = MockWifiDirectService();

    when(() => mockBleService.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockNfcService.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockWifiService.stateStream).thenAnswer((_) => const Stream.empty());

    when(() => mockBleService.initialize()).thenAnswer((_) async {});
    when(() => mockNfcService.initialize()).thenAnswer((_) async {});
    when(() => mockWifiService.initialize()).thenAnswer((_) async {});

    when(() => mockBleService.dispose()).thenAnswer((_) => {});
    when(() => mockNfcService.dispose()).thenAnswer((_) => {});
    when(() => mockWifiService.dispose()).thenAnswer((_) => {});

    cubit = SharingCubit(
      bleService: mockBleService,
      nfcService: mockNfcService,
      wifiService: mockWifiService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SharingCubit', () {
    test('initial state is SharingInitial', () {
      expect(cubit.state, SharingInitial());
    });

    test('initialize initializes services and emits SharingReady', () async {
      await cubit.initialize();

      expect(cubit.state, SharingReady());
      // verify calls
      verify(() => mockBleService.initialize()).called(1);
      verify(() => mockNfcService.initialize()).called(1);
      verify(() => mockWifiService.initialize()).called(1);
    });

    test('startSharing with NFC calls nfcService.shareData', () async {
      when(() => mockNfcService.shareData(any())).thenAnswer((_) async => const SharingResult(
        success: true,
        bytesTransferred: 100,
        transferTime: Duration(seconds: 1),
      ));

      await cubit.startSharing(
        method: TransferMethod.nfc,
        package: testPackage,
      );

      verify(() => mockNfcService.shareData(testPackage)).called(1);
    });

    test('startSharing with BLE calls bleService.startAdvertising', () async {
      when(() => mockBleService.startAdvertising(any())).thenAnswer((_) async {});

      await cubit.startSharing(
        method: TransferMethod.ble,
        package: testPackage,
      );

      verify(() => mockBleService.startAdvertising(testPackage.recipientNodeId)).called(1);
    });

    test('cancelSharing stops all services and emits SharingReady', () async {
      when(() => mockBleService.disconnect()).thenAnswer((_) async {});
      when(() => mockBleService.stopAdvertising()).thenAnswer((_) async {});
      when(() => mockNfcService.stopListening()).thenAnswer((_) async {});
      when(() => mockWifiService.stop()).thenAnswer((_) async {});

      await cubit.cancelSharing();

      expect(cubit.state, SharingReady());
      verify(() => mockBleService.disconnect()).called(1);
      verify(() => mockBleService.stopAdvertising()).called(1);
      verify(() => mockNfcService.stopListening()).called(1);
      verify(() => mockWifiService.stop()).called(1);
    });
  });
}
