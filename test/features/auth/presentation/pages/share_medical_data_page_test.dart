import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/share_medical_data_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

void main() {
  late MockSharingCubit mockSharingCubit;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(TransferMethod.ble);
    registerFallbackValue(SharedHealthPackage(
      id: '',
      senderNodeId: '',
      recipientNodeId: '',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now(),
      payload: const EncryptedPayload(encryptedData: '', iv: '', ephemeralPublicKey: '', authTag: ''),
      metadata: const PackageMetadata(packageType: '', consentVerified: true, includedCategories: {}, appVersion: '1.0.0'),
      signature: '',
    ));
  });

  setUp(() {
    mockSharingCubit = MockSharingCubit();
    getIt.registerSingleton<SharingCubit>(mockSharingCubit);

    when(() => mockSharingCubit.state).thenReturn(SharingInitial());
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {});
    when(() => mockSharingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSharingCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await getIt.unregister<SharingCubit>();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ShareMedicalDataPage(),
    );
  }

  testWidgets('renders ShareMedicalDataPage with initial state', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Share Medical Data'), findsOneWidget);
    expect(find.text('Select data to share'), findsOneWidget);
    expect(find.text('Transfer method'), findsOneWidget);
    expect(find.text('Select at least one category'), findsOneWidget);
  });

  testWidgets('can select categories and method', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockSharingCubit.state).thenReturn(const SharingReady());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Select a category
    await tester.tap(find.text(DataCategory.vitalSigns.displayName));
    await tester.pump();

    expect(find.text('1 categories selected'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    // Change transfer method
    await tester.tap(find.text(TransferMethod.ble.displayName));
    await tester.pump();

    final radio = tester.widget<RadioListTile<TransferMethod>>(
      find.widgetWithText(RadioListTile<TransferMethod>, TransferMethod.ble.displayName),
    );
    expect(radio.value, TransferMethod.ble);
  });

  testWidgets('calls startSharing when Share button is pressed', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockSharingCubit.state).thenReturn(const SharingReady());
    when(() => mockSharingCubit.startSharing(
          method: any(named: 'method'),
          package: any(named: 'package'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Select category to enable button
    await tester.tap(find.text(DataCategory.vitalSigns.displayName));
    await tester.pump();

    await tester.ensureVisible(find.text('Share'));
    await tester.tap(find.text('Share'));
    await tester.pump();

    verify(() => mockSharingCubit.startSharing(
          method: any(named: 'method'),
          package: any(named: 'package'),
        )).called(1);
  });

  testWidgets('shows transferring UI when in scanning state', (tester) async {
    when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Searching for devices...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows success dialog on SharingComplete', (tester) async {
    final controller = StreamController<SharingState>.broadcast();
    when(() => mockSharingCubit.stream).thenAnswer((_) => controller.stream);
    when(() => mockSharingCubit.state).thenReturn(const SharingReady());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    const result = SharingResult(success: true, bytesTransferred: 1024, transferTime: Duration(seconds: 5));
    const completeState = SharingComplete(result, TransferMethod.nfc);

    when(() => mockSharingCubit.state).thenReturn(completeState);
    controller.add(completeState);

    await tester.pump();
    await tester.pump(); // Second pump for dialog animation

    expect(find.text('Shared successfully!'), findsOneWidget);
    expect(find.text('1024 bytes transferred'), findsOneWidget);

    await controller.close();
  });

  testWidgets('shows snackbar on SharingError', (tester) async {
    final controller = StreamController<SharingState>.broadcast();
    when(() => mockSharingCubit.stream).thenAnswer((_) => controller.stream);
    when(() => mockSharingCubit.state).thenReturn(const SharingReady());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    controller.add(const SharingError('Error message'));
    await tester.pump(); // Trigger listener
    await tester.pump(); // Trigger snackbar animation

    expect(find.text('Error message'), findsOneWidget);

    await controller.close();
  });
}
