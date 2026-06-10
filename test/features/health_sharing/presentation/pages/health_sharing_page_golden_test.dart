import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

void main() {
  late MockSharingCubit mockCubit;

  setUpAll(() {
    final getIt = GetIt.instance;
    mockCubit = MockSharingCubit();
    getIt.registerLazySingleton<SharingCubit>(() => mockCubit);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Health Sharing Golden Tests', () {
    testWidgets('SharePage - Initial/Consent', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockCubit.state).thenReturn(SharingReady());
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile('goldens/share_page_initial.png'),
      );
    });

    testWidgets('SharePage - Active Session (Transferring)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

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
        matchesGoldenFile('goldens/share_page_active.png'),
      );
    });

    testWidgets('ReceivePage - Setup UI', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockCubit.state).thenReturn(SharingReady());
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile('goldens/receive_page_setup.png'),
      );
    });

    testWidgets('ReceivePage - Received Data Preview', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      final package = SharedHealthPackage(
        id: 'pkg-123',
        senderNodeId: 'Node-A',
        recipientNodeId: 'Node-B',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: '...', iv: '', ephemeralPublicKey: ''),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {DataCategory.vitalSigns, DataCategory.medications},
          appVersion: '1.0.0',
        ),
        signature: '',
      );

      when(() => mockCubit.state).thenReturn(SharingReceiving(
        package: package,
        method: TransferMethod.wifi,
      ));
      when(() => mockCubit.initialize()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile('goldens/receive_page_preview.png'),
      );
    });
  });
}
