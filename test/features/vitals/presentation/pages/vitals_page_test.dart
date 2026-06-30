import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  late MockVitalSignRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeVitalSign());
  });

  setUp(() {
    mockRepository = MockVitalSignRepository();
    getIt.allowReassignment = true;
    getIt.registerSingleton<VitalSignRepository>(mockRepository);
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: VitalsPage(),
    );
  }

  group('VitalsPage', () {
    testWidgets('shows loading then displays vitals', (tester) async {
      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {});
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Signos Vitales'), findsOneWidget);
    });

    testWidgets('displays latest vitals in cards', (tester) async {
      final now = DateTime.now();
      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
        VitalSignType.heartRate: VitalSign(type: VitalSignType.heartRate, value: 72, dateTime: now),
        VitalSignType.temperature: VitalSign(type: VitalSignType.temperature, value: 36.6, dateTime: now),
      });
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('72.0'), findsOneWidget);
      expect(find.text('36.6'), findsOneWidget);
    });

    testWidgets('opens add vital bottom sheet and saves', (tester) async {
      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {});
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => []);
      when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Agregar Signo Vital'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '80');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveVitalSign(any())).called(1);
    });
  });
}
