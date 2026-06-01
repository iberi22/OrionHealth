import 'package:injectable/injectable.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:medical_standards/medical_standards.dart' show Icd10Code;

import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../domain/services/health_context_service.dart';
import '../../../../core/services/app_logger.dart';

/// Infrastructure implementation of [HealthContextService].
///
/// Strategy (Option A — Typed Repos + MemoryGraph for notes):
/// - Structured vitals → [VitalSignRepository.getLatestVitals()]
/// - Active medications → [MedicationRepository.getAllMedications()]
/// - Conditions → derived from VitalSign notes + memory tags
/// - Episodic notes → [MemoryGraph.hybridSearch] with user tag
///
/// All reads are non-blocking. Failures are gracefully caught and logged.
@LazySingleton(as: HealthContextService)
class IsarHealthContextService implements HealthContextService {
  static const _tag = 'HealthContext';
  static const _maxNotes = 3;

  final VitalSignRepository _vitalRepo;
  final MedicationRepository _medicationRepo;
  final MemoryGraph _memoryGraph;

  IsarHealthContextService(
    this._vitalRepo,
    this._medicationRepo,
    this._memoryGraph,
  );

  @override
  Future<HealthContext> getContextForUser(String userId) async {
    AppLogger.d(_tag, 'Loading health context for user=$userId');

    try {
      // 1. Latest vitals → Map<String, double>
      final vitalsMap = await _loadVitals();

      // 2. Active medications → List<String> (names for now, RxNorm lookup optional)
      final medications = await _loadMedications();

      // 3. Conditions — currently no dedicated repo; derive from memory tags
      final conditions = <Icd10Code>[];

      // 4. Episodic notes from MemoryGraph (free-text health notes)
      final notes = await _loadEpisodicNotes(userId);

      final ctx = HealthContext(
        vitals: vitalsMap,
        conditions: conditions,
        medications: medications,
        episodicNotes: notes,
      );

      AppLogger.i(_tag,
          'Context ready: ${vitalsMap.length} vitals, ${medications.length} meds, ${notes.length} notes');
      return ctx;
    } catch (e, st) {
      AppLogger.e(_tag, 'Failed to load context — returning empty', error: e, stackTrace: st);
      return HealthContext.empty();
    }
  }

  @override
  Future<void> recordNote(String userId, String note) async {
    try {
      await _memoryGraph.storeNodeWithEmbedding(
        content: note,
        type: 'health_note',
        metadata: {
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'user_input',
        },
      );
      AppLogger.d(_tag, 'Episodic note stored for user=$userId');
    } catch (e) {
      AppLogger.e(_tag, 'Failed to store episodic note', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, double>> _loadVitals() async {
    final latestVitals = await _vitalRepo.getLatestVitals();
    final result = <String, double>{};

    for (final entry in latestVitals.entries) {
      final vital = entry.value;
      if (vital?.value == null) continue;

      // Map VitalSignType enum to string keys expected by the clinical engine
      final key = _vitalTypeToKey(entry.key);
      result[key] = vital!.value!;
    }
    return result;
  }

  Future<List<String>> _loadMedications() async {
    final meds = await _medicationRepo.getAllMedications();
    return meds
        .where((m) => m.isActive)
        .map((m) => m.name)
        .toList();
  }

  Future<List<String>> _loadEpisodicNotes(String userId) async {
    try {
      final results = await _memoryGraph.hybridSearch(
        'health_note $userId',
        topK: _maxNotes,
        alpha: 0.4, // favour text match for notes
      );
      return results.map((r) => r.node.content).toList();
    } catch (e) {
      AppLogger.w(_tag, 'Memory search failed for notes: $e');
      return [];
    }
  }

  String _vitalTypeToKey(VitalSignType type) {
    switch (type) {
      case VitalSignType.heartRate:
        return 'heartRate';
      case VitalSignType.bloodPressureSystolic:
        return 'systolic';
      case VitalSignType.bloodPressureDiastolic:
        return 'diastolic';
      case VitalSignType.temperature:
        return 'temperature';
      case VitalSignType.spO2:
      case VitalSignType.oxygenSaturation:
        return 'oxygenSaturation';
      case VitalSignType.steps:
        return 'steps';
      case VitalSignType.sleep:
        return 'sleep';
      case VitalSignType.bloodGlucose:
        return 'bloodGlucose';
    }
  }
}
