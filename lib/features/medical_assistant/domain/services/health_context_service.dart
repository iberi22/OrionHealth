import 'package:equatable/equatable.dart';

/// Immutable value object representing a user's consolidated health context.
///
/// This is the primary data structure passed to the clinical engine.
/// All fields are read-only snapshots taken at query time.
class HealthContext extends Equatable {
  /// Most recent lab values keyed by LOINC code.
  /// Example: {'2339-0': 5.4} (glucose in mmol/L)
  final Map<String, double> labValues;

  /// Most recent vital signs keyed by type name.
  /// Example: {'systolic': 130, 'heartRate': 78}
  final Map<String, double> vitals;

  /// Known chronic conditions as ICD-10 codes (raw strings).
  final List<String> conditions;

  /// Active medication names (from user's medication list).
  final List<String> medications;

  /// Free-text episodic notes recalled from memory (max 3).
  final List<String> episodicNotes;

  const HealthContext({
    this.labValues = const {},
    this.vitals = const {},
    this.conditions = const [],
    this.medications = const [],
    this.episodicNotes = const [],
  });

  /// Empty context — returned when no user or no stored data.
  factory HealthContext.empty() => const HealthContext();

  /// Converts to the legacy Map format expected by [MedicalLlmAdapter].
  Map<String, dynamic> toContextMap() => {
        'labs': labValues,
        'vitals': vitals,
        'conditions': conditions,
        'medications': medications,
        'episodicNotes': episodicNotes,
      };

  bool get isEmpty =>
      labValues.isEmpty &&
      vitals.isEmpty &&
      conditions.isEmpty &&
      medications.isEmpty &&
      episodicNotes.isEmpty;

  @override
  List<Object?> get props =>
      [labValues, vitals, conditions, medications, episodicNotes];
}

/// Domain contract for retrieving and persisting user health context.
abstract class HealthContextService {
  /// Returns a consolidated [HealthContext] for [userId].
  /// Returns [HealthContext.empty()] if no data is stored.
  Future<HealthContext> getContextForUser(String userId);

  /// Records a new episodic health note in long-term memory.
  Future<void> recordNote(String userId, String note);
}
