/// Smart onboarding module for selective medical context download.
///
/// This module enables downloading only the medical standards relevant to
/// a user's profile, rather than the full ~3GB dataset.
///
/// ## Usage
///
/// ```dart
/// import 'package:medical_standards/onboarding.dart';
///
/// // 1. Analyze the user's profile to determine relevant categories
/// final analyzer = ProfileAnalyzer();
/// final relevant = await analyzer.analyzeProfile(
///   age: 55,
///   sex: 'male',
///   currentConditions: ['Type 2 diabetes', 'Hypertension'],
///   currentMedications: ['Metformin', 'Lisinopril'],
///   familyHistory: ['Heart disease'],
/// );
///
/// // 2. Sync only the relevant medical context
/// final cache = FileCacheStorage(basePath: '/data/medical_cache');
/// final syncService = SelectiveSyncService(cache: cache);
/// final context = await syncService.syncRelevantContext(
///   relevant,
///   onProgress: (p) => print('${(p.overallFraction * 100).toInt()}% - ${p.message}'),
/// );
///
/// // 3. Query context during AI inference
/// if (!context.hasContextFor('diabetes')) {
///   await syncService.fetchAdditionalContext(MedicalContextCategory.diabetes);
/// }
/// final result = context.getContextFor('metformin');
/// ```

export 'medical_context_categories.dart';
export 'profile_analyzer.dart';
export 'selective_sync_service.dart';
export 'local_medical_context.dart';
