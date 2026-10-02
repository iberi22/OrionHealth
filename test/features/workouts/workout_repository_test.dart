import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/workouts/domain/entities/workout_session.dart';
import 'package:orionhealth_health/features/workouts/infrastructure/repositories/workout_repository_impl.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late WorkoutRepositoryImpl repository;
  Map<String, dynamic> record() =>
      jsonDecode(
            File(
              'packages/health_contract/test/fixtures/valid/workout-session-01.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  setUpAll(() async {
    // Native test setup must provide the cached Isar binary; never download PHI dependencies.
    await Isar.initializeIsarCore(download: false);
    directory = await Directory.systemTemp.createTemp('orion_workouts_');
    isar = await Isar.open(
      [WorkoutSessionSchema],
      directory: directory.path,
      name: 'workout_tests',
    );
    repository = WorkoutRepositoryImpl(isar);
  });
  setUp(() async => isar.writeTxn(() => isar.workoutSessions.clear()));
  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test(
    'embedded exercises and original provenance survive persistence',
    () async {
      final original = record();
      await repository.saveSessions([WorkoutSession.fromRecord(original)]);
      final restored = (await repository.getAllSessions()).single;
      expect(restored.toJson(), original);
      expect(restored.exercises.single.sets, hasLength(3));
      expect(restored.exercises.single.sets[0].weightKg, 60);
      expect(restored.exercises.single.sets[1].durationS, 45);
      expect(restored.exercises.single.sets[2].distanceM, 400);
    },
  );

  test(
    'repeat imports replace same record rather than duplicate history',
    () async {
      await repository.saveSessions([WorkoutSession.fromRecord(record())]);
      final updated = record();
      updated['data']['notes'] = 'Updated locally received record';
      await repository.saveSessions([WorkoutSession.fromRecord(updated)]);
      final restored = await repository.getAllSessions();
      expect(restored, hasLength(1));
      expect(restored.single.notes, 'Updated locally received record');
      expect(restored.single.toJson(), updated);
    },
  );
}
