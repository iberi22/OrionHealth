import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/receive_medical_data_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/share_medical_data_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import '../../../../core/golden_test_utils.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  late MockSharingCubit mockSharingCubit;
  late StreamController<SharingState> stateController;

  setUpAll(() {
    registerFallbackValue(TransferMethod.nfc);
    registerFallbackValue(FakeSharedHealthPackage());
  });

  setUp(() async {
    mockSharingCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();
    final getIt = GetIt.I;
    if (getIt.isRegistered<SharingCubit>()) {
      await getIt.unregister<SharingCubit>();
    }
    getIt.registerSingleton<SharingCubit>(mockSharingCubit);

    when(() => mockSharingCubit.state).thenReturn(const SharingReady());
    when(() => mockSharingCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {});
    when(() => mockSharingCubit.startListening(any())).thenAnswer((_) async {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await stateController.close();
    await GetIt.I.reset();
  });

  group('Auth Pages Golden Tests', () {
    testWidgets('ReceiveMedicalDataPage - Scanning NFC', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

      await tester.pumpWidget(wrapWithMaterial(const ReceiveMedicalDataPage()));
      await tester.pump();

      await expectLater(
        find.byType(ReceiveMedicalDataPage),
        matchesGoldenFile("../../../../../golden/reference/receive_medical_data_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ShareMedicalDataPage - Initial State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());

      await tester.pumpWidget(wrapWithMaterial(const ShareMedicalDataPage()));
      await tester.pump();

      await expectLater(
        find.byType(ShareMedicalDataPage),
        matchesGoldenFile("../../../../../golden/reference/share_medical_data_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
