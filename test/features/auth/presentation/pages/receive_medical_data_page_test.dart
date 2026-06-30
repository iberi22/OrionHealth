import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/receive_medical_data_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

void main() {
  late MockSharingCubit mockSharingCubit;
  late StreamController<SharingState> stateController;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(TransferMethod.nfc);
  });

  setUp(() {
    mockSharingCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();

    if (getIt.isRegistered<SharingCubit>()) {
      getIt.unregister<SharingCubit>();
    }
    getIt.registerSingleton<SharingCubit>(mockSharingCubit);

    when(() => mockSharingCubit.state).thenReturn(const SharingInitial());
    when(() => mockSharingCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {});
    when(() => mockSharingCubit.startListening(any())).thenAnswer((_) async {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async {
      await stateController.close();
    });
  });

  tearDown(() async {
    await stateController.close();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: ReceiveMedicalDataPage(),
      ),
    );
  }

  group('ReceiveMedicalDataPage', () {
    testWidgets('initialization calls initialize and startListening with NFC', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      verify(() => mockSharingCubit.initialize()).called(1);
      verify(() => mockSharingCubit.startListening(TransferMethod.nfc)).called(1);
    });

    testWidgets('displays correct message when state is SharingScanning with NFC', (tester) async {
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Tap devices to receive...'), findsOneWidget);
      expect(find.byIcon(Icons.nfc), findsOneWidget);
    });

    testWidgets('displays "Connection established" when state is SharingConnected', (tester) async {
      when(() => mockSharingCubit.state).thenReturn(const SharingConnected(TransferMethod.nfc, 'device-123'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Connection established'), findsOneWidget);
    });

    testWidgets('shows preview dialog with "Data Received" when state is SharingReceiving', (tester) async {
      final package = SharedHealthPackage(
        id: '1',
        senderNodeId: 'sender-1',
        recipientNodeId: 'recipient-1',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
        metadata: const PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {DataCategory.vitalSigns},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      stateController.add(SharingReceiving(package: package, method: TransferMethod.nfc));
      await tester.pump();
      await tester.pump();

      expect(find.text('Data Received'), findsOneWidget);
      expect(find.text('From: sender-1'), findsOneWidget);
      expect(find.text('• Signos Vitales'), findsOneWidget);
    });

    testWidgets('shows success dialog with "Import Complete!" when state is SharingComplete', (tester) async {
      final result = SharingResult(
        success: true,
        bytesTransferred: 1024,
        transferTime: const Duration(seconds: 5),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      stateController.add(SharingComplete(result, TransferMethod.nfc));
      await tester.pump();
      await tester.pump();

      expect(find.text('Import Complete!'), findsOneWidget);
      expect(find.text('1024 bytes imported'), findsOneWidget);
    });

    testWidgets('shows SnackBar on SharingError', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      stateController.add(const SharingError('Transfer failed'));
      await tester.pump();

      expect(find.text('Transfer failed'), findsOneWidget);
    });
  });
}
