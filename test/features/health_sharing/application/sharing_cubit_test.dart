import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/start_sharing_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/start_listening_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/cancel_sharing_usecase.dart';
import 'package:health_wallet/health_wallet.dart' as wallet;

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}
class MockStartSharingUseCase extends Mock implements StartSharingUseCase {}
class MockStartListeningUseCase extends Mock implements StartListeningUseCase {}
class MockCancelSharingUseCase extends Mock implements CancelSharingUseCase {}
class MockWalletService extends Mock implements wallet.WalletService {}
class MockWalletEncryption extends Mock implements wallet.EncryptionService {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}
class FakeLabResult extends Fake implements wallet.LabResult {}

void main() {
  setUpAll(() {
    registerFallbackValue(TransferMethod.ble);
    registerFallbackValue(FakeSharedHealthPackage());
    registerFallbackValue(FakeLabResult());
  });

  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;
  late MockStartSharingUseCase mockStartSharingUseCase;
  late MockStartListeningUseCase mockStartListeningUseCase;
  late MockCancelSharingUseCase mockCancelSharingUseCase;
  late MockWalletService mockWalletService;
  late MockWalletEncryption mockWalletEncryption;
  late SharingCubit cubit;

  final testPackage = SharedHealthPackage(
    id: 'test-id',
    senderNodeId: 'sender-1',
    recipientNodeId: 'recipient-1',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    payload: const EncryptedPayload(
      encryptedData: '{"labs": []}',
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
    mockStartSharingUseCase = MockStartSharingUseCase();
    mockStartListeningUseCase = MockStartListeningUseCase();
    mockCancelSharingUseCase = MockCancelSharingUseCase();
    mockWalletService = MockWalletService();
    mockWalletEncryption = MockWalletEncryption();

    when(() => mockBleService.stateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockNfcService.stateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockWifiService.stateStream)
        .thenAnswer((_) => const Stream.empty());

    when(() => mockBleService.initialize()).thenAnswer((_) async {});
    when(() => mockNfcService.initialize()).thenAnswer((_) async {});
    when(() => mockWifiService.initialize()).thenAnswer((_) async {});

    when(() => mockBleService.dispose()).thenAnswer((_) => {});
    when(() => mockNfcService.dispose()).thenAnswer((_) => {});
    when(() => mockWifiService.dispose()).thenAnswer((_) => {});

    when(() => mockStartSharingUseCase(
      method: any(named: 'method'),
      package: any(named: 'package'),
      pin: any(named: 'pin'),
    )).thenAnswer((_) async {});
    when(() => mockStartListeningUseCase(any(), pin: any(named: 'pin')))
        .thenAnswer((_) async {});
    when(() => mockCancelSharingUseCase()).thenAnswer((_) async {});

    cubit = SharingCubit(
      bleService: mockBleService,
      nfcService: mockNfcService,
      wifiService: mockWifiService,
      startSharingUseCase: mockStartSharingUseCase,
      startListeningUseCase: mockStartListeningUseCase,
      cancelSharingUseCase: mockCancelSharingUseCase,
      walletService: mockWalletService,
      walletEncryption: mockWalletEncryption,
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
      verify(() => mockBleService.initialize()).called(1);
      verify(() => mockNfcService.initialize()).called(1);
      verify(() => mockWifiService.initialize()).called(1);
    });

    test('startSharing with NFC calls startSharingUseCase', () async {
      await cubit.startSharing(
        method: TransferMethod.nfc,
        package: testPackage,
      );

      verify(() => mockStartSharingUseCase(
            method: TransferMethod.nfc,
            package: testPackage,
          )).called(1);
    });

    test('startSharing with BLE calls startSharingUseCase', () async {
      await cubit.startSharing(
        method: TransferMethod.ble,
        package: testPackage,
      );

      verify(() => mockStartSharingUseCase(
            method: TransferMethod.ble,
            package: testPackage,
          )).called(1);
    });

    test('cancelSharing calls cancelSharingUseCase and emits SharingReady',
        () async {
      await cubit.cancelSharing();

      expect(cubit.state, const SharingReady());
      verify(() => mockCancelSharingUseCase()).called(1);
    });

    test('acceptIncomingPackage decrypts and imports data', () async {
      final decryptedData = {
        'labs': [
          {
            'remoteId': 'lab-1',
            'loincCode': '123-4',
            'testName': 'Glucose',
            'resultValue': '100',
            'unit': 'mg/dL',
            'referenceRangeLow': 70.0,
            'referenceRangeHigh': 110.0,
            'collectedAt': DateTime.now().toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          }
        ]
      };

      when(() => mockWalletEncryption.decryptPayload(any(), any()))
          .thenAnswer((_) async => decryptedData);
      when(() => mockWalletService.addLabResult(any())).thenAnswer((_) async {});

      await cubit.startListening(TransferMethod.ble);
      cubit.handleIncomingPackage(testPackage);
      await cubit.acceptIncomingPackage();

      expect(cubit.state, isA<SharingComplete>());
      verify(() => mockWalletEncryption.decryptPayload(any(), any())).called(1);
      verify(() => mockWalletService.addLabResult(any())).called(1);
    });
  });
}
