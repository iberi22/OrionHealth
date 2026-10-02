import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../workouts/domain/entities/workout_session.dart';
import '../domain/services/ecosystem_import_service.dart';
import 'models/meal_log.dart';

@LazySingleton(as: EcosystemRecordStore)
class IsarEcosystemRecordStore implements EcosystemRecordStore {
  final Isar _isar;
  IsarEcosystemRecordStore(this._isar);

  @override
  Future<void> save(List<Map<String, dynamic>> records) async {
    // Materialize first so conversion failures never write a partial batch.
    final meals = <MealLog>[];
    final workouts = <WorkoutSession>[];
    final profiles = <EcosystemDietaryProfile>[];
    for (final record in records) {
      switch (record['schema']) {
        case 'swal.health/v1/meal-log':
          meals.add(MealLog.fromRecord(record));
        case 'swal.health/v1/workout-session':
          workouts.add(WorkoutSession.fromRecord(record));
        case 'swal.health/v1/dietary-profile':
          profiles.add(EcosystemDietaryProfile.fromRecord(record));
        default:
          throw const FormatException('Unsupported ecosystem record.');
      }
    }
    await _isar.writeTxn(() async {
      await _isar.mealLogs.putAll(meals);
      await _isar.workoutSessions.putAll(workouts);
      await _isar.ecosystemDietaryProfiles.putAll(profiles);
    });
  }

  @override
  Future<String?> latestDataset() async {
    // Compare envelope timestamps rather than import order.
    final envelopes = <String>[
      ...(await _isar.mealLogs.where().findAll()).map((e) => e.envelopeJson),
      ...(await _isar.workoutSessions.where().findAll()).map(
        (e) => e.envelopeJson,
      ),
      ...(await _isar.ecosystemDietaryProfiles.where().findAll()).map(
        (e) => e.envelopeJson,
      ),
    ].map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    envelopes.sort(
      (a, b) => parseEcosystemTimestamp(
        b['createdAt'] as String,
      ).compareTo(parseEcosystemTimestamp(a['createdAt'] as String)),
    );
    return envelopes.isEmpty ? null : envelopes.first['gosDataset'] as String;
  }
}
