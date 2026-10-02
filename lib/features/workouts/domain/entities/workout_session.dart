import 'dart:convert';
import 'package:isar/isar.dart';

part 'workout_session.g.dart';

/// Local copy of a validated swal.health/v1 workout, owned by this device.
@collection
class WorkoutSession {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String recordId;
  @Index()
  late String subject;
  late DateTime startedAt;
  late DateTime endedAt;
  String? routineId;
  double? energyKcal;
  String? energyMethod;
  double? perceivedEffort;
  String? notes;
  List<WorkoutExercise> exercises = [];

  /// Preserves source provenance, dataset version and timestamp precision.
  late String envelopeJson;

  @ignore
  Duration get duration => endedAt.difference(startedAt);

  WorkoutSession();

  factory WorkoutSession.fromRecord(Map<String, dynamic> record) {
    final data = record['data'] as Map<String, dynamic>;
    final start = DateTime.parse(
      (data['startedAt'] as String)
          .replaceFirst('t', 'T')
          .replaceFirst('z', 'Z'),
    );
    final end = DateTime.parse(
      (data['endedAt'] as String).replaceFirst('t', 'T').replaceFirst('z', 'Z'),
    );
    if (end.isBefore(start)) {
      throw const FormatException('Workout ends before it starts.');
    }
    final energy = data['energy'] as Map<String, dynamic>?;
    return WorkoutSession()
      ..recordId = record['id'] as String
      ..subject = record['subject'] as String
      ..startedAt = start
      ..endedAt = end
      ..routineId = data['routineId'] as String?
      ..energyKcal = (energy?['kcal'] as num?)?.toDouble()
      ..energyMethod = energy?['method'] as String?
      ..perceivedEffort = (data['perceivedEffort'] as num?)?.toDouble()
      ..notes = data['notes'] as String?
      ..exercises = (data['exercises'] as List).map((value) {
        final exercise = value as Map<String, dynamic>;
        return WorkoutExercise()
          ..ref = exercise['ref'] as String
          ..sets = (exercise['sets'] as List).map((value) {
            final set = value as Map<String, dynamic>;
            return WorkoutSet()
              ..reps = (set['reps'] as num?)?.toInt()
              ..weightKg = (set['weightKg'] as num?)?.toDouble()
              ..rpe = (set['rpe'] as num?)?.toDouble()
              ..durationS = (set['durationS'] as num?)?.toDouble()
              ..distanceM = (set['distanceM'] as num?)?.toDouble();
          }).toList();
      }).toList()
      ..envelopeJson = jsonEncode(record);
  }

  Map<String, dynamic> toJson() =>
      jsonDecode(envelopeJson) as Map<String, dynamic>;
}

@embedded
class WorkoutExercise {
  String ref = '';
  List<WorkoutSet> sets = [];
}

@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
  double? rpe;
  double? durationS;
  double? distanceM;
}
