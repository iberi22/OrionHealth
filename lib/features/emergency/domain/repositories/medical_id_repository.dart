/// FEAT-022: Abstract repository for Medical ID
///
/// One per user (current_user_id scoped). Used by both:
/// - Mobile (Isar implementation)
/// - Web (SharedPreferences implementation)
///
/// All write operations are append-only with `lastUpdated` timestamp.
library;

import '../entities/medical_id.dart';

abstract class MedicalIdRepository {
  /// Returns the current Medical ID, or null if not set.
  Future<MedicalIdEntity?> getByUser(String userId);

  /// Creates or updates the Medical ID for [userId].
  Future<void> save(MedicalIdEntity medicalId);

  /// Deletes the Medical ID for [userId] (irreversible).
  Future<void> delete(String userId);

  /// Returns the list of critical fields for lock-screen display.
  /// Equivalent to getByUser().toCriticalCard() but optimized.
  Future<List<String>> getCriticalFields(String userId);
}
