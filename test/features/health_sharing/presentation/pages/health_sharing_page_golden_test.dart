import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/share_medical_data_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/receive_medical_data_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/auth_methods_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart' as auth_state;
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:flutter/services.dart';
import '../../../../core/golden_test_utils.dart';

class MockSharingCubit extends Mock implements SharingCubit {}
class MockAuthCubit extends Mock implements AuthCubit {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  late MockSharingCubit mockSharingCubit;
  late MockAuthCubit mockAuthCubit;
  late StreamController<SharingState> sharingStateController;
  late StreamController<auth_state.AuthState> authStateController;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });

    registerFallbackValue(TransferMethod.nfc);
    registerFallbackValue(FakeSharedHealthPackage());

    getIt.allowReassignment = true;
  });

  setUp(() async {
    mockSharingCubit = MockSharingCubit();
    mockAuthCubit = MockAuthCubit();
    sharingStateController = StreamController<SharingState>.broadcast();
    authStateController = StreamController<auth_state.AuthState>.broadcast();

    getIt.registerSingleton<SharingCubit>(mockSharingCubit);
    getIt.registerSingleton<AuthCubit>(mockAuthCubit);

    when(() => mockSharingCubit.initialize()).thenAnswer((_) async => {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async => {});
    when(() => mockSharingCubit.stream).thenAnswer((_) => sharingStateController.stream);
    when(() => mockSharingCubit.state).thenReturn(SharingReady());
    when(() => mockSharingCubit.startListening(any(), pin: any(named: 'pin'))).thenAnswer((_) async {});
    when(() => mockSharingCubit.cancelSharing()).thenAnswer((_) async {});

    when(() => mockAuthCubit.close()).thenAnswer((_) async => {});
    when(() => mockAuthCubit.stream).thenAnswer((_) => authStateController.stream);
    when(() => mockAuthCubit.state).thenReturn(const auth_state.AuthInitial());
    when(() => mockAuthCubit.checkStatus()).thenAnswer((_) async {});
  });

  tearDown(() {
    sharingStateController.close();
    authStateController.close();
  });

  final testPackage = SharedHealthPackage(
    id: 'test-id',
    senderNodeId: 'sender-001',
    recipientNodeId: 'recipient-002',
    createdAt: DateTime(2024, 1, 1),
    expiresAt: DateTime(2024, 1, 1).add(const Duration(minutes: 5)),
    payload: const EncryptedPayload(
      encryptedData: 'data',
      iv: 'iv',
      ephemeralPublicKey: 'key',
    ),
    metadata: const PackageMetadata(
      packageType: 'selective',
      consentVerified: true,
      includedCategories: {DataCategory.labResults, DataCategory.vitalSigns},
      appVersion: '1.0.0',
    ),
    signature: 'sig',
  );

  Widget createTestWidget(Widget child) {
    return wrapWithMaterial(
      child,
      sharingCubit: mockSharingCubit,
      authCubit: mockAuthCubit,
    );
  }

  group('Health Sharing Pages Golden Tests', () {
    testWidgets('ReceivePage - Setup State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(SharingReady());

      await tester.pumpWidget(createTestWidget(const ReceivePage()));
      await tester.pump();

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile("../../../../golden/reference/receive_page_setup.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReceivePage - Data Preview Dialog', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(SharingReady());
      await tester.pumpWidget(createTestWidget(const ReceivePage()));
      await tester.pump();

      final receivingState = SharingReceiving(
        package: testPackage,
        method: TransferMethod.wifi,
      );
      when(() => mockSharingCubit.state).thenReturn(receivingState);
      sharingStateController.add(receivingState);

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile("../../../../golden/reference/receive_page_preview.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SharePage - Initial State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(SharingReady());

      await tester.pumpWidget(createTestWidget(const SharePage()));
      await tester.pump();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("../../../../golden/reference/share_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SharePage - Active Transfer', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(const SharingTransferring(
        method: TransferMethod.wifi,
        progress: 0.6,
        message: 'Enviando registros médicos...',
      ));

      await tester.pumpWidget(createTestWidget(const SharePage()));
      await tester.pump();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("../../../../golden/reference/share_page_active.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReceiveMedicalDataPage', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

      await tester.pumpWidget(createTestWidget(const ReceiveMedicalDataPage()));
      await tester.pump();

      await expectLater(
        find.byType(ReceiveMedicalDataPage),
        matchesGoldenFile("../../../../golden/reference/receive_medical_data_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ShareMedicalDataPage', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(SharingReady());

      await tester.pumpWidget(createTestWidget(const ShareMedicalDataPage()));
      await tester.pump();

      await expectLater(
        find.byType(ShareMedicalDataPage),
        matchesGoldenFile("../../../../golden/reference/share_medical_data_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SetupPinPage', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(createTestWidget(const SetupPinPage()));
      await tester.pump();

      await expectLater(
        find.byType(SetupPinPage),
        matchesGoldenFile("../../../../golden/reference/setup_pin_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AuthMethodsPage', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(createTestWidget(const AuthMethodsPage()));
      await tester.pump();

      await expectLater(
        find.byType(AuthMethodsPage),
        matchesGoldenFile("../../../../golden/reference/auth_methods_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
