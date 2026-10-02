import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_repository.dart';

@LazySingleton(as: WorkoutRepository)
class WorkoutRepositoryImpl implements WorkoutRepository {
  final Isar _isar;
  WorkoutRepositoryImpl(this._isar);

  @override
  Future<void> saveSessions(List<WorkoutSession> sessions) async {
    if (sessions.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.workoutSessions.putAll(sessions);
    });
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() =>
      _isar.workoutSessions.where().sortByStartedAtDesc().findAll();
}
