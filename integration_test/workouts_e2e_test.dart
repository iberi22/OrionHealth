import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/workouts/presentation/pages/workouts_page.dart';
import 'package:orionhealth_health/features/workouts/domain/repositories/workout_repository.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
  });

  testWidgets('Workouts E2E: start, track and save a workout session', (
    WidgetTester tester,
  ) async {
    // Mount the WorkoutsPage directly wrapped in MaterialApp to test the
    // workouts flow with real Isar DI. app.main() is not started: it opens a
    // second DI/Workmanager stack and never settles, which hung the job.
    final repo = di.getIt<WorkoutRepository>();

    await tester.pumpWidget(MaterialApp(home: WorkoutsPage(repository: repo)));
    await tester.pumpAndSettle();

    // 2. Start a workout session.
    final startButton = find.byType(FloatingActionButton);
    expect(startButton, findsOneWidget);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    // Verify we are in the tracking page
    expect(find.text('En progreso'), findsOneWidget);

    // 3. Track (add an exercise).
    final addExerciseButton = find.text('Añadir Ejercicio');
    expect(addExerciseButton, findsOneWidget);
    await tester.tap(addExerciseButton);
    await tester.pumpAndSettle();

    // Check that exercise was added to the list
    expect(find.text('wg:custom-exercise'), findsOneWidget);

    // 4. Save the session.
    final saveButton = find.text('Terminar y Guardar');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // We should be back on the WorkoutsPage
    expect(find.text('Entrenamientos'), findsOneWidget);

    // Verify the saved session is now in the list
    expect(
      find.text('wg:custom-exercise'),
      findsNothing,
    ); // It's in the detail page, list shows count
    expect(find.textContaining('1 ejercicios'), findsOneWidget);

    // Tap to view detail
    await tester.tap(find.byType(ListTile).last);
    await tester.pumpAndSettle();

    // Verify detail page
    expect(find.text('Entrenamiento'), findsOneWidget);
    expect(find.text('custom exercise'), findsOneWidget);
    expect(find.text('Serie 1: 10 reps · 20.0 kg'), findsOneWidget);
  });
}
