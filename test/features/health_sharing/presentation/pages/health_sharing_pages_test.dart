import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:flutter/services.dart';
import '../../../../core/golden_test_utils.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  late MockSharingCubit mockCubit;
  late StreamController<SharingState> stateController;

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
  });

  setUp(() async {
    GetIt.instance.reset();
    mockCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();

    GetIt.I.registerSingleton<SharingCubit>(mockCubit);

    when(() => mockCubit.initialize()).thenAnswer((_) async => {});
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.state).thenReturn(SharingReady());
  });

  tearDown(() {
    stateController.close();
  });

  group('SharePage Interaction Tests', () {
    testWidgets('should allow selecting data categories', (tester) async {
      when(() => mockCubit.state).thenReturn(SharingReady());

      await tester.pumpWidget(wrapWithMaterial(const SharePage()));
      await tester.pump();

      final chip = find.text('Laboratorios');
      expect(chip, findsOneWidget);

      await tester.tap(chip);
      await tester.pump();

      expect(find.text('1 categorías seleccionadas'), findsOneWidget);
    });

    testWidgets('should call startSharing when Share button is pressed', (tester) async {
      when(() => mockCubit.state).thenReturn(SharingReady());
      when(() => mockCubit.startSharing(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(wrapWithMaterial(const SharePage()));
      await tester.pump();

      await tester.tap(find.text('Laboratorios'));
      await tester.pump();

      final shareButton = find.text('Compartir');
      await tester.tap(shareButton);
      await tester.pump();

      verify(() => mockCubit.startSharing(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).called(1);
    });
  });

  group('ReceivePage Interaction Tests', () {
    testWidgets('should call startListening when a method is selected', (tester) async {
      when(() => mockCubit.state).thenReturn(SharingReady());
      when(() => mockCubit.startListening(any(), pin: any(named: 'pin')))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(wrapWithMaterial(const ReceivePage()));
      await tester.pump();

      expect(find.text('NFC'), findsOneWidget);
      await tester.tap(find.text('NFC'));
      await tester.pump();

      verify(() => mockCubit.startListening(TransferMethod.nfc, pin: any(named: 'pin'))).called(1);
    });
  });
}
