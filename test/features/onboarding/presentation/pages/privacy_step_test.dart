import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/privacy_step.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockCubit;

  setUp(() {
    mockCubit = MockOnboardingCubit();
    when(() => mockCubit.state).thenReturn(OnboardingInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.saveAndComplete()).thenAnswer((_) async {});
    when(() => mockCubit.previousStep()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OnboardingCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: PrivacyStep()),
      ),
    );
  }

  testWidgets('PrivacyStep displays correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Privacidad y Seguridad'), findsOneWidget);
    expect(find.text('Protección de acceso'), findsOneWidget);
    expect(find.text('Tus datos están protegidos'), findsOneWidget);
  });

  testWidgets('Completar button is disabled until checkboxes are checked', (tester) async {
    // Increase surface size for scrolling elements
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());

    final completeButtonFinder = find.widgetWithText(ElevatedButton, 'Completar');
    expect(tester.widget<ElevatedButton>(completeButtonFinder).onPressed, isNull);

    await tester.scrollUntilVisible(find.text('Acepto el procesamiento de mis datos'), 100);
    await tester.tap(find.text('Acepto el procesamiento de mis datos'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(completeButtonFinder).onPressed, isNull);

    await tester.scrollUntilVisible(find.text('Acepto la política de privacidad'), 100);
    await tester.tap(find.text('Acepto la política de privacidad'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(completeButtonFinder).onPressed, isNotNull);

    await tester.tap(completeButtonFinder);
    verify(() => mockCubit.saveAndComplete()).called(1);
  });

  testWidgets('Atrás button calls previousStep', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.scrollUntilVisible(find.text('Atrás'), 100);
    await tester.tap(find.text('Atrás'));
    verify(() => mockCubit.previousStep()).called(1);
  });
}
