import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

void main() {
  late MockSharingCubit mockCubit;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
<<<<<<< HEAD
    mockCubit = MockSharingCubit();

    await GetIt.I.reset();
    await configureDependencies();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<SharingCubit>()) {
      getIt.unregister<SharingCubit>();
    }
    getIt.registerLazySingleton<SharingCubit>(() => mockCubit);
=======
>>>>>>> origin/main
  });

  setUp(() async {
    // Reset GetIt completely before each test to avoid "already registered" errors
    GetIt.instance.reset();
    await configureDependencies();
    mockCubit = MockSharingCubit();
    GetIt.I.registerFactory<SharingCubit>(() => mockCubit);
  });

  group('Health Sharing Golden Tests', () {
    testWidgets('SharePage - Initial/Consent', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockCubit.state).thenReturn(SharingReady());
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("../../../../golden/reference/share_page_initial.png"),
      );
    });

    testWidgets('SharePage - Active Session (Transferring)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockCubit.state).thenReturn(const SharingTransferring(
        method: TransferMethod.wifi,
        progress: 0.45,
        message: 'Enviando registros médicos...',
      ));
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("../../../../golden/reference/share_page_active.png"),
      );
    });

    testWidgets('ReceivePage - Setup UI', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockCubit.state).thenReturn(SharingReady());
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile("../../../../golden/reference/receive_page_setup.png"),
      );
    });

    testWidgets('ReceivePage - Received Data Preview', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockPackage = SharedHealthPackage(
        senderId: 'doctor001',
        senderName: 'Dr. García',
        records: [
          HealthRecord(
            type: HealthRecordType.labResult,
            title: 'Hemograma',
            description: 'Resultados de análisis de sangre',
            data: '',
          ),
        ],
        timestamp: DateTime(2026, 6, 17),
        inboxUrl: 'https://inbox.example.com/receive',
      );

      when(() => mockCubit.state).thenReturn(SharingReceived(
        package: mockPackage,
        source: 'wifi',
      ));
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile("../../../../golden/reference/receive_page_data.png"),
      );
    });
  });
}
