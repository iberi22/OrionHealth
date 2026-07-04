import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart' as bloc_state;
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/receive_medical_data_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/share_medical_data_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/auth_methods_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import '../../../../core/golden_test_utils.dart';

class MockAuthCubit extends Mock implements AuthCubit {}
class MockSharingCubit extends Mock implements SharingCubit {}
class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockSharingCubit mockSharingCubit;

  setUpAll(() {
    registerFallbackValue(TransferMethod.ble);
    registerFallbackValue(FakeSharedHealthPackage());
  });

  setUp(() async {
    mockAuthCubit = MockAuthCubit();
    mockSharingCubit = MockSharingCubit();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<AuthCubit>(mockAuthCubit);
    GetIt.I.registerSingleton<SharingCubit>(mockSharingCubit);

    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.state).thenReturn(const bloc_state.AuthInitial());
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});

    when(() => mockSharingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSharingCubit.state).thenReturn(const SharingReady());
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {});
    when(() => mockSharingCubit.startListening(any())).thenAnswer((_) async {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Auth Pages Golden Tests', () {
    testWidgets('Setup PIN Page - Golden', (WidgetTester tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const SetupPinPage()));
      await tester.pump();

      await expectLater(
        find.byType(SetupPinPage),
        matchesGoldenFile("goldens/setup_pin_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Receive Medical Data Page - Golden', (WidgetTester tester) async {
      setupGoldenTest(tester);
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

      await tester.pumpWidget(wrapWithMaterial(
        const ReceiveMedicalDataPage(),
        sharingCubit: mockSharingCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(ReceiveMedicalDataPage),
        matchesGoldenFile("goldens/receive_medical_data_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Share Medical Data Page - Golden', (WidgetTester tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const ShareMedicalDataPage(),
        sharingCubit: mockSharingCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(ShareMedicalDataPage),
        matchesGoldenFile("goldens/share_medical_data_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Auth Methods Page - Golden', (WidgetTester tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const AuthMethodsPage(),
        sharingCubit: mockSharingCubit,
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(AuthMethodsPage),
        matchesGoldenFile("goldens/auth_methods_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
