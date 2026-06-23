import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_cubit.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_state.dart';
import 'package:orionhealth_health/features/meditation/presentation/meditation_page.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockMeditationCubit extends Mock implements MeditationCubit {}

void main() {
  late MockMeditationCubit mockCubit;

  setUp(() {
    mockCubit = MockMeditationCubit();
    when(() => mockCubit.state).thenReturn(const MeditationState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.initialize()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Meditation screen golden test - Welcome View', (WidgetTester tester) async {
    const script = MeditationScript(
      id: 'test-01',
      title: 'Respiración Guiada',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: ['Inhala', 'Exhala'],
    );
    when(() => mockCubit.state).thenReturn(
      const MeditationState(status: MeditationStatus.idle, script: script),
    );

    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MeditationCubit>.value(value: mockCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MeditationView(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MeditationView),
      matchesGoldenFile('../../../golden/reference/meditation_welcome.png'),
    );
  });

  testWidgets('Meditation screen golden test - Active View', (WidgetTester tester) async {
    const script = MeditationScript(
      id: 'test-01',
      title: 'Respiración Guiada',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: ['Inhala profundamente', 'Exhala lentamente'],
    );
    when(() => mockCubit.state).thenReturn(
      const MeditationState(
        status: MeditationStatus.playing,
        script: script,
        steps: ['Inhala profundamente', 'Exhala lentamente'],
        currentStep: 0,
        elapsedSeconds: 42,
      ),
    );

    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MeditationCubit>.value(value: mockCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MeditationView(),
        ),
      ),
    );

    // We don't use pumpAndSettle because of the infinite animation
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(MeditationView),
      matchesGoldenFile('../../../golden/reference/meditation_active.png'),
    );
  });

  testWidgets('Meditation screen golden test - Completed View', (WidgetTester tester) async {
    const script = MeditationScript(
      id: 'test-01',
      title: 'Respiración Guiada',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: ['Inhala profundamente', 'Exhala lentamente'],
    );
    when(() => mockCubit.state).thenReturn(
      const MeditationState(
        status: MeditationStatus.completed,
        script: script,
        elapsedSeconds: 300,
      ),
    );

    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MeditationCubit>.value(value: mockCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MeditationView(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MeditationView),
      matchesGoldenFile('../../../golden/reference/meditation_completed.png'),
    );
  });
}
