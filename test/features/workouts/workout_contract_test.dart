import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/workouts/application/workout_fhir_export_service.dart';
import 'package:orionhealth_health/features/workouts/domain/entities/workout_session.dart';
import 'package:orionhealth_health/features/workouts/domain/repositories/workout_repository.dart';
import 'package:orionhealth_health/features/workouts/domain/services/workout_fhir_mapper.dart';
import 'package:orionhealth_health/features/workouts/presentation/pages/workouts_page.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_mapper.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(
          File(
            'packages/health_contract/test/fixtures/valid/workout-session-01.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

class _Repository implements WorkoutRepository {
  final List<WorkoutSession> sessions;
  _Repository(this.sessions);
  @override
  Future<List<WorkoutSession>> getAllSessions() async => sessions;
  @override
  Future<void> saveSessions(List<WorkoutSession> sessions) async {}
}

void main() {
  test('workout preserves envelope, exercise references and nested sets', () {
    final record = fixture();
    final workout = WorkoutSession.fromRecord(record);
    expect(workout.toJson(), record);
    final exercise = (record['data']['exercises'] as List).first;
    expect(workout.exercises.first.ref, exercise['ref']);
    expect(
      workout.exercises.first.sets.first.reps,
      exercise['sets'][0]['reps'],
    );
    expect(workout.duration, workout.endedAt.difference(workout.startedAt));
  });

  test(
    'lowercase contract timestamps parse without changing original envelope',
    () {
      final record = fixture();
      record['data']['startedAt'] = '2026-10-02t18:00:00z';
      record['data']['endedAt'] = '2026-10-02t19:00:00z';
      final workout = WorkoutSession.fromRecord(record);
      expect(workout.duration, const Duration(hours: 1));
      expect(workout.toJson(), record);
    },
  );

  test('integer-valued JSON doubles remain valid repetition counts', () {
    final record = fixture();
    record['data']['exercises'][0]['sets'][0]['reps'] = 8.0;
    expect(
      WorkoutSession.fromRecord(record).exercises.first.sets.first.reps,
      8,
    );
  });

  test('workout rejects reverse time range before persistence', () {
    final record = fixture();
    record['data']['endedAt'] = '2000-01-01T00:00:00Z';
    expect(() => WorkoutSession.fromRecord(record), throwsFormatException);
  });

  test('FHIR activity panel contains seconds and kcal with UCUM units', () {
    final workout = WorkoutSession.fromRecord(fixture())..energyKcal = 310;
    final observation = workoutToObservation(workout);
    expect(observation['resourceType'], 'Observation');
    expect(observation['code']['coding'][0]['code'], '73985-4');
    expect(observation['subject']['identifier']['value'], workout.subject);
    final components = observation['component'] as List;
    expect(components[0]['code']['coding'][0]['code'], '55411-3');
    expect(components[0]['valueQuantity']['value'], workout.duration.inSeconds);
    expect(components[1]['code']['coding'][0]['code'], '41981-2');
    expect(components[1]['valueQuantity']['code'], 'kcal');
    expect(components[1]['valueQuantity']['value'], 310);
  });

  test(
    'FHIR mapping leaves unknown energy absent and imports kcal correctly',
    () {
      final workout = WorkoutSession.fromRecord(fixture())..energyKcal = null;
      expect(workoutToObservation(workout)['component'], hasLength(1));
      workout.energyKcal = 42;
      final vitals = FhirMapper.mapObservation(workoutToObservation(workout));
      expect(vitals.single.type, VitalSignType.activeEnergy);
      expect(vitals.single.value, 42);
      expect(vitals.single.unit, 'kcal');
    },
  );

  test(
    'existing FHIR wallet bundle retains entries and appends workouts',
    () async {
      final service = WorkoutFhirExportService(
        _Repository([WorkoutSession.fromRecord(fixture())]),
      );
      final bundle =
          jsonDecode(
                await service.appendToBundle(
                  jsonEncode({
                    'resourceType': 'Bundle',
                    'type': 'collection',
                    'total': 1,
                    'entry': [
                      {
                        'resource': {
                          'resourceType': 'Patient',
                          'id': 'existing',
                        },
                      },
                    ],
                  }),
                ),
              )
              as Map;
      expect(bundle['total'], 2);
      expect(bundle['entry'][0]['resource']['id'], 'existing');
      expect(bundle['entry'][1]['resource']['resourceType'], 'Observation');
    },
  );

  testWidgets('workout list opens details showing exercise sets', (
    tester,
  ) async {
    final workout = WorkoutSession.fromRecord(fixture());
    await tester.pumpWidget(
      MaterialApp(home: WorkoutsPage(repository: _Repository([workout]))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Entrenamientos'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.text('Entrenamiento'), findsOneWidget);
    expect(find.textContaining('Serie 1:'), findsWidgets);
  });

  testWidgets('empty workout list explains file import', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: WorkoutsPage(repository: _Repository([]))),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('.swalhealth.json'), findsOneWidget);
  });
}
