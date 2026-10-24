import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/workouts/domain/entities/workout_session.dart';
import 'package:orionhealth_health/features/workouts/domain/repositories/workout_repository.dart';
import 'package:orionhealth_health/features/workouts/presentation/pages/workouts_page.dart';
import 'package:intl/intl.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
  });

  Widget createTestWidget() {
    return MaterialApp(home: WorkoutsPage(repository: mockRepository));
  }

  testWidgets('shows loading state initially', (WidgetTester tester) async {
    when(
      () => mockRepository.getAllSessions(),
    ).thenAnswer((_) async => <WorkoutSession>[]);

    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error state when load fails', (WidgetTester tester) async {
    when(
      () => mockRepository.getAllSessions(),
    ).thenAnswer((_) => Future.error(Exception('Failed to load')));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar. Reintentar'), findsOneWidget);
  });

  testWidgets('shows empty state when no sessions', (
    WidgetTester tester,
  ) async {
    when(
      () => mockRepository.getAllSessions(),
    ).thenAnswer((_) async => <WorkoutSession>[]);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Importa un archivo .swalhealth.json para ver tus entrenamientos.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows sessions list and navigates to detail', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final session = WorkoutSession()
      ..id = 1
      ..recordId = 'test-id'
      ..subject = 'test-subject'
      ..startedAt = now.subtract(const Duration(minutes: 30))
      ..endedAt = now
      ..energyKcal = 300
      ..energyMethod = 'test-method'
      ..perceivedEffort = 5
      ..routineId = 'test-routine'
      ..exercises = [
        WorkoutExercise()
          ..ref = 'wg:pushups'
          ..sets = [WorkoutSet()..reps = 10],
      ]
      ..envelopeJson = '{}';

    when(
      () => mockRepository.getAllSessions(),
    ).thenAnswer((_) async => [session]);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.textContaining('1 ejercicios'), findsOneWidget);
    expect(find.textContaining('300 kcal'), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutDetailPage), findsOneWidget);
    expect(find.text('Duración: 30.0 min'), findsOneWidget);
    expect(find.text('Energía: 300.0 kcal (test-method)'), findsOneWidget);
    expect(find.text('Esfuerzo: 5.0/10'), findsOneWidget);
    expect(find.text('Rutina: test-routine'), findsOneWidget);
    expect(find.text('pushups'), findsOneWidget);
    expect(find.text('Serie 1: 10 reps'), findsOneWidget);
  });
}
