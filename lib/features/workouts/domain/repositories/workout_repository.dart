import '../entities/workout_session.dart';

abstract class WorkoutRepository {
  Future<void> saveSessions(List<WorkoutSession> sessions);
  Future<List<WorkoutSession>> getAllSessions();
}
