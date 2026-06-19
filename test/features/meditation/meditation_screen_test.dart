import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_cubit.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_state.dart';
import 'package:orionhealth_health/features/meditation/presentation/meditation_page.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockMeditationCubit extends Mock implements MeditationCubit {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockMeditationCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockCubit = MockMeditationCubit();
    when(() => mockCubit.state).thenReturn(const MeditationState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.initialize()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest({List<NavigatorObserver>? observers}) {
    return MaterialApp(
      home: BlocProvider<MeditationCubit>.value(
        value: mockCubit,
        child: const MeditationView(),
      ),
      navigatorObservers: observers ?? [],
    );
  }

  testWidgets('MeditationView basic rendering and states', (tester) async {
    // Loading
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.loading));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Idle
    const script = MeditationScript(id: '1', title: 'Test', category: MeditationCategory.calm, durationMinutes: 5, steps: ['Step 1']);
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.idle, script: script));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Test'), findsOneWidget);

    when(() => mockCubit.startMeditation()).thenAnswer((_) async {});
    await tester.tap(find.text('Comenzar'));
    await tester.pump();
    verify(() => mockCubit.startMeditation()).called(1);

    // Error
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.error, error: 'Error!'));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Error!'), findsOneWidget);

    // Completed
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.completed, elapsedSeconds: 60));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Sesión Completada'), findsOneWidget);
  });

  testWidgets('MeditationView active states and controls', (tester) async {
    // Playing
    when(() => mockCubit.state).thenReturn(const MeditationState(
      status: MeditationStatus.playing,
      steps: ['Step 1'],
      currentStep: 0,
    ));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Inhala / Exhala'), findsOneWidget);

    when(() => mockCubit.nextStep()).thenAnswer((_) async {});
    when(() => mockCubit.previousStep()).thenAnswer((_) async {});
    when(() => mockCubit.togglePause()).thenAnswer((_) async {});

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    verify(() => mockCubit.nextStep()).called(1);
    verify(() => mockCubit.previousStep()).called(1);
    verify(() => mockCubit.togglePause()).called(1);

    // Paused
    when(() => mockCubit.state).thenReturn(const MeditationState(
      status: MeditationStatus.paused,
      steps: ['Step 1'],
      currentStep: 0,
    ));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Pausado'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('MeditationView navigation pops', (tester) async {
    final observer = MockNavigatorObserver();

    // Close button
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.idle));
    await tester.pumpWidget(createWidgetUnderTest(observers: [observer]));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    verify(() => observer.didPop(any(), any())).called(1);

    // Back to start button
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.completed));
    await tester.pumpWidget(createWidgetUnderTest(observers: [observer]));
    await tester.tap(find.text('Volver al inicio'));
    await tester.pump();
    verify(() => observer.didPop(any(), any())).called(2);
  });

  testWidgets('MeditationPage coverage', (tester) async {
    getIt.allowReassignment = true;
    getIt.registerFactory<MeditationCubit>(() => mockCubit);
    final page = MeditationPage(key: UniqueKey());
    await tester.pumpWidget(MaterialApp(home: page));
    expect(find.byType(MeditationView), findsOneWidget);
    getIt.unregister<MeditationCubit>();
  });

  testWidgets('MeditationView listener coverage', (tester) async {
    final controller = StreamController<MeditationState>();
    when(() => mockCubit.stream).thenAnswer((_) => controller.stream);
    when(() => mockCubit.state).thenReturn(const MeditationState(status: MeditationStatus.idle));

    await tester.pumpWidget(createWidgetUnderTest());

    controller.add(const MeditationState(status: MeditationStatus.playing));
    await tester.pump();

    controller.add(const MeditationState(status: MeditationStatus.paused));
    await tester.pump();

    await controller.close();
    await tester.pumpWidget(Container());
  });
}
