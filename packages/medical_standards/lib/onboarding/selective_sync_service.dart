/// Service for selectively syncing only relevant medical data.
///
/// Downloads and caches only the medical standards relevant to a user's
/// profile, avoiding the full ~3GB download. Supports on-demand fetching
/// when the AI needs context beyond what was pre-downloaded.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../icd10/icd10.dart';
import '../loinc/loinc.dart';
import '../medications/medications.dart';
import '../guidelines/guidelines.dart';
import 'medical_context_categories.dart';
import 'local_medical_context.dart';

/// Cache storage adapter (platform-specific implementation)
abstract class CacheStorage {
  Future<void> write(String path, List<int> bytes);
  Future<List<int>?> read(String path);
  Future<bool> exists(String path);
  Future<void> delete(String path);
  Future<List<String>> listCategories();
}

/// File-system based cache implementation
class FileCacheStorage implements CacheStorage {
  final String basePath;

  FileCacheStorage({required this.basePath});

  @override
  Future<void> write(String path, List<int> bytes) async {
    final file = File(p.join(basePath, path));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  @override
  Future<List<int>?> read(String path) async {
    final file = File(p.join(basePath, path));
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  @override
  Future<bool> exists(String path) async {
    return File(p.join(basePath, path)).exists();
  }

  @override
  Future<void> delete(String path) async {
    final file = File(p.join(basePath, path));
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<String>> listCategories() async {
    final dir = Directory(basePath);
    if (!await dir.exists()) return [];
    final entries = await dir.list().toList();
    return entries
        .whereType<Directory>()
        .map((d) => p.basename(d.path))
        .toList();
  }
}

/// Sync progress state
class SyncProgress {
  final MedicalContextCategory? currentCategory;
  final double overallFraction; // 0.0 – 1.0
  final String message;

  const SyncProgress({
    this.currentCategory,
    required this.overallFraction,
    required this.message,
  });
}

/// Service for selectively syncing only relevant medical data.
class SelectiveSyncService {
  final CacheStorage _cache;
  final String _cacheVersion;

  LocalMedicalContext? _cachedContext;

  SelectiveSyncService({
    required CacheStorage cache,
    String cacheVersion = '1.0',
  })  : _cache = cache,
        _cacheVersion = cacheVersion;

  /// Download only the standards relevant to this profile.
  ///
  /// Downloads tier1 categories immediately, then background-syncs tier2.
  /// Reports progress via [onProgress].
  Future<LocalMedicalContext> syncRelevantContext(
    RelevantStandards standards, {
    void Function(SyncProgress progress)? onProgress,
  }) async {
    final allCategories = [...standards.tier1, ...standards.tier2];
    final total = allCategories.length;
    var completed = 0;

    final icd10Map = <String, Icd10Code>{};
    final loincMap = <String, LoincCode>{};
    final medMap = <String, MedicationReference>{};
    final guidelineMap = <String, ClinicalGuidelineReference>{};
    final downloaded = <MedicalContextCategory>{};

    void reportProgress(MedicalContextCategory cat, String msg) {
      final fraction = total > 0 ? completed / total : 0.0;
      onProgress?.call(SyncProgress(
        currentCategory: cat,
        overallFraction: fraction,
        message: msg,
      ));
    }

    // === Tier 1: sync immediately ===
    for (final cat in standards.tier1) {
      reportProgress(cat, 'Syncing ${cat.name}...');
      final result = await _syncCategory(cat);
      icd10Map.addAll(result.icd10);
      loincMap.addAll(result.loinc);
      medMap.addAll(result.meds);
      guidelineMap.addAll(result.guidelines);
      downloaded.add(cat);
      completed++;
    }

    // === Tier 2: sync in background (simulate async batch) ===
    for (final cat in standards.tier2) {
      reportProgress(cat, 'Background sync ${cat.name}...');
      // Simulate async work; in production this would be a separate isolate
      await Future.delayed(const Duration(milliseconds: 50));
      final result = await _syncCategory(cat);
      icd10Map.addAll(result.icd10);
      loincMap.addAll(result.loinc);
      medMap.addAll(result.meds);
      guidelineMap.addAll(result.guidelines);
      downloaded.add(cat);
      completed++;
    }

    onProgress?.call(SyncProgress(
      currentCategory: null,
      overallFraction: 1.0,
      message: 'Sync complete',
    ));

    _cachedContext = LocalMedicalContext(
      icd10Codes: icd10Map,
      loincCodes: loincMap,
      medications: medMap,
      guidelines: guidelineMap,
      downloadedCategories: downloaded,
    );

    return _cachedContext!;
  }

  /// Sync a single category: load from cache or build from static data.
  Future<_CategorySyncResult> _syncCategory(MedicalContextCategory cat) async {
    final cacheKey = '${cat.name}_$_cacheVersion.json';
    final cached = await _cache.read(cacheKey);

    if (cached != null) {
      try {
        final json = jsonDecode(utf8.decode(cached)) as Map<String, dynamic>;
        return _CategorySyncResult.fromJson(json, cat);
      } catch (_) {
        // Cache corrupted — rebuild
      }
    }

    // Build from static library data
    final result = _buildFromStatic(cat);

    // Persist to cache
    try {
      await _cache.write(cacheKey, utf8.encode(jsonEncode(result.toJson())));
    } catch (_) {
      // Storage write failed — continue without caching
    }

    return result;
  }

  _CategorySyncResult _buildFromStatic(MedicalContextCategory cat) {
    final icd10Map = <String, Icd10Code>{};
    final loincMap = <String, LoincCode>{};
    final medMap = <String, MedicationReference>{};
    final guidelineMap = <String, ClinicalGuidelineReference>{};

    // ICD-10 codes
    final icd10Codes = CategoryIcd10.forCategory(cat);
    for (final codeStr in icd10Codes) {
      // Try to find in static catalog — match by code prefix
      final found = _findIcd10ByCode(codeStr);
      if (found != null) icd10Map[found.code] = found;
    }

    // LOINC codes
    final loincCodes = CategoryLoinc.forCategory(cat);
    for (final codeStr in loincCodes) {
      final found = LoincCommonLabs.findByCode(codeStr);
      if (found != null) loincMap[found.code] = found;
    }

    // Medications by drug class
    final classes = CategoryMedications.forCategory(cat);
    for (final med in MedicationCatalog.all) {
      if (med.drugClass != null && classes.any((c) => med.drugClass!.contains(c))) {
        medMap[med.code] = med;
      }
    }

    // Guidelines for applicable conditions
    for (final code in icd10Codes) {
      final applicableGuidelines = ClinicalGuidelines.findForCondition(code);
      for (final g in applicableGuidelines) {
        guidelineMap[g.code] = g;
      }
    }

    return _CategorySyncResult(
      icd10: icd10Map,
      loinc: loincMap,
      meds: medMap,
      guidelines: guidelineMap,
    );
  }

  /// Try to match an ICD-10 code string to a static Icd10Code object.
  /// Uses code prefix matching (E10 → E10, E10.1, etc.)
  Icd10Code? _findIcd10ByCode(String codeStr) {
    // Match via reflection-like lookup — static maps are final
    final allCodes = _staticIcd10Map();
    // Direct or prefix match
    for (final entry in allCodes.entries) {
      if (entry.key == codeStr || entry.key.startsWith('$codeStr.')) {
        return entry.value;
      }
    }
    return null;
  }

  /// Static ICD-10 catalog lookup map
  static Map<String, Icd10Code> _staticIcd10Map() {
    return {
      'E10': Icd10ChronicConditions.diabetesType1,
      'E11': Icd10ChronicConditions.diabetesType2,
      'E08': Icd10ChronicConditions.diabetesDueToUnderlyingCondition,
      'E09': Icd10ChronicConditions.drugInducedDiabetes,
      'E12': Icd10ChronicConditions.malnutritionRelatedDiabetes,
      'E13': Icd10ChronicConditions.otherSpecifiedDiabetes,
      'E14': Icd10ChronicConditions.unspecifiedDiabetes,
      'E10.1': Icd10ChronicConditions.diabetesWithKetoacidosis,
      'E11.21': Icd10ChronicConditions.diabetesWithNephropathy,
      'E11.31': Icd10ChronicConditions.diabetesWithRetinopathy,
      'E11.4': Icd10ChronicConditions.diabetesWithNeuropathy,
      'E11.51': Icd10ChronicConditions.diabetesWithPeripheralAngiopathy,
      'E05.90': Icd10ChronicConditions.hyperthyroidism,
      'E03.9': Icd10ChronicConditions.hypothyroidism,
      'E04.9': Icd10ChronicConditions.thyroidNodule,
      'C73': Icd10ChronicConditions.thyroidCancer,
      'E87.5': Icd10ChronicConditions.hyperkalemia,
      'E87.6': Icd10ChronicConditions.hypokalemia,
      'E87.1': Icd10ChronicConditions.hyponatremia,
      'E87.0': Icd10ChronicConditions.hypernatremia,
      'E83.52': Icd10ChronicConditions.hypercalcemia,
      'E83.51': Icd10ChronicConditions.hypocalcemia,
      'E88.81': Icd10ChronicConditions.metabolicSyndrome,
      'E27.40': Icd10ChronicConditions.adrenalInsufficiency,
      'E24.9': Icd10ChronicConditions.cushingSyndrome,
      'E28.2': Icd10ChronicConditions.polycysticOvarySyndrome,
      'E55.9': Icd10ChronicConditions.vitaminDDeficiency,
      'E79.0': Icd10ChronicConditions.hyperuricemia,
      'I10': Icd10ChronicConditions.hypertension,
      'I16.1': Icd10ChronicConditions.hypertensiveEmergency,
      'I48.91': Icd10ChronicConditions.atrialFibrillation,
      'I48.3': Icd10ChronicConditions.atrialFlutter,
      'I50.9': Icd10ChronicConditions.heartFailure,
      'I50.22': Icd10ChronicConditions.heartFailureReducedEF,
      'I50.30': Icd10ChronicConditions.heartFailurePreservedEF,
      'I21.9': Icd10ChronicConditions.acuteMyocardialInfarction,
      'I25.10': Icd10ChronicConditions.stableAngina,
      'I25.9': Icd10ChronicConditions.coronaryArteryDisease,
      'I73.9': Icd10ChronicConditions.peripheralVascularDisease,
      'I65.29': Icd10ChronicConditions.carotidArteryStenosis,
      'I71.9': Icd10ChronicConditions.aorticAneurysm,
      'I71.00': Icd10ChronicConditions.aorticDissection,
      'I83.90': Icd10ChronicConditions.varicoseVeins,
      'I89.0': Icd10ChronicConditions.lymphedema,
      'I82.409': Icd10ChronicConditions.dvt,
      'I26.99': Icd10ChronicConditions.pulmonaryEmbolism,
      'E66.9': Icd10ChronicConditions.obesity,
      'E66.01': Icd10ChronicConditions.severeObesity,
      'E78.5': Icd10ChronicConditions.hyperlipidemia,
      'E78.0': Icd10ChronicConditions.hypercholesterolemia,
      'E78.1': Icd10ChronicConditions.hypertriglyceridemia,
      'E78.2': Icd10ChronicConditions.mixedHyperlipidemia,
      'J40': Icd10ChronicConditions.acuteBronchitis,
      'J41.0': Icd10ChronicConditions.simpleChronicBronchitis,
      'J41.1': Icd10ChronicConditions.mucopurulentChronicBronchitis,
      'J41.8': Icd10ChronicConditions.mixedChronicBronchitis,
      'J42': Icd10ChronicConditions.unspecifiedChronicBronchitis,
      'J43.9': Icd10ChronicConditions.emphysema,
      'J43.8': Icd10ChronicConditions.otherEmphysema,
      'J44.0': Icd10ChronicConditions.copdAcuteBronchitis,
      'J44.1': Icd10ChronicConditions.copdAcuteExacerbation,
      'J47.9': Icd10ChronicConditions.bronchiectasis,
      'J45.909': Icd10ChronicConditions.asthmaUnspecified,
      'J45.41': Icd10ChronicConditions.asthmaAcuteExacerbation,
      'J45.20': Icd10ChronicConditions.asthmaMildIntermittent,
      'J45.30': Icd10ChronicConditions.asthmaModeratePersistent,
      'J45.5': Icd10ChronicConditions.asthmaSeverePersistent,
      'J96.90': Icd10ChronicConditions.respiratoryFailure,
      'J80': Icd10ChronicConditions.ards,
      'J18.9': Icd10ChronicConditions.pneumoniaUnspecified,
      'J12.89': Icd10ChronicConditions.viralPneumonia,
      'J91.8': Icd10ChronicConditions.pleuralEffusion,
      'J93.9': Icd10ChronicConditions.pneumothorax,
      'N17.9': Icd10ChronicConditions.acuteKidneyFailure,
      'N17.0': Icd10ChronicConditions.acuteTubularNecrosis,
      'N00.9': Icd10ChronicConditions.acuteGlomerulonephritis,
      'N18.9': Icd10ChronicConditions.chronicKidneyDisease,
      'N18.1': Icd10ChronicConditions.ckdStage1,
      'N18.2': Icd10ChronicConditions.ckdStage2,
      'N18.3': Icd10ChronicConditions.ckdStage3,
      'N18.4': Icd10ChronicConditions.ckdStage4,
      'N18.5': Icd10ChronicConditions.ckdStage5,
      'N18.6': Icd10ChronicConditions.endStageRenalDisease,
      'N04.9': Icd10ChronicConditions.nephroticSyndrome,
      'N39.0': Icd10ChronicConditions.urinaryTractInfection,
      'N40.1': Icd10ChronicConditions.benignProstaticHyperplasia,
      'N23': Icd10ChronicConditions.renalColic,
      'N13.9': Icd10ChronicConditions.hydronephrosis,
      'N05.9': Icd10ChronicConditions.glomerulonephritis,
      'N20.9': Icd10ChronicConditions.kidneyStone,
      'K70.30': Icd10ChronicConditions.alcoholicLiverDisease,
      'K70.0': Icd10ChronicConditions.alcoholicFattyLiver,
      'K70.1': Icd10ChronicConditions.alcoholicHepatitis,
      'K70.2': Icd10ChronicConditions.alcoholicCirrhosis,
      'K72.90': Icd10ChronicConditions.hepaticFailure,
      'K72.10': Icd10ChronicConditions.chronicHepaticFailure,
      'K72.91': Icd10ChronicConditions.hepaticEncephalopathy,
      'K76.0': Icd10ChronicConditions.nafld,
      'B18.1': Icd10ChronicConditions.hepatitisB,
      'B18.2': Icd10ChronicConditions.hepatitisC,
      'B15.9': Icd10ChronicConditions.hepatitisA,
      'K74.60': Icd10ChronicConditions.liverCirrhosis,
      'K76.6': Icd10ChronicConditions.portalHypertension,
      'K81.0': Icd10ChronicConditions.cholecystitis,
      'K80.20': Icd10ChronicConditions.cholelithiasis,
      'K76.89': Icd10ChronicConditions.liverLesion,
      'K76.82': Icd10ChronicConditions.ascites,
      'D50.9': Icd10ChronicConditions.ironDeficiencyAnemia,
      'D50.0': Icd10ChronicConditions.ironDeficiencyAnemiaBloodLoss,
      'D51.9': Icd10ChronicConditions.vitaminB12DeficiencyAnemia,
      'D52.9': Icd10ChronicConditions.folateDeficiencyAnemia,
      'D59.9': Icd10ChronicConditions.hemolyticAnemia,
      'D57.00': Icd10ChronicConditions.sickleCellDisease,
      'D56.9': Icd10ChronicConditions.thalassemia,
      'D61.9': Icd10ChronicConditions.aplasticAnemia,
      'D63.1': Icd10ChronicConditions.anemiaOfCkd,
      'D63.0': Icd10ChronicConditions.anemiaOfMalignancy,
      'D61.818': Icd10ChronicConditions.pancytopenia,
      'D70.9': Icd10ChronicConditions.neutropenia,
      'D69.6': Icd10ChronicConditions.thrombocytopenia,
      'D68.9': Icd10ChronicConditions.coagulationDefect,
      'D66': Icd10ChronicConditions.hemophilia,
      'D68.0': Icd10ChronicConditions.vonWillebrandDisease,
      'D45': Icd10ChronicConditions.polycythemiaVera,
      'D47.3': Icd10ChronicConditions.thrombocythemia,
      'C79.9': Icd10ChronicConditions.secondaryMalignantNeoplasm,
      'C34.90': Icd10ChronicConditions.lungCancer,
      'C50.919': Icd10ChronicConditions.breastCancer,
      'C18.9': Icd10ChronicConditions.colonCancer,
      'C61': Icd10ChronicConditions.prostateCancer,
    };
  }

  /// Check if we have context for a specific category
  Future<bool> hasContext(MedicalContextCategory category) async {
    if (_cachedContext != null) {
      return _cachedContext!.downloadedCategories.contains(category);
    }
    final cacheKey = '${category.name}_$_cacheVersion.json';
    return _cache.exists(cacheKey);
  }

  /// Fetch additional context on-demand when AI needs it.
  /// Merges new data into existing context.
  Future<LocalMedicalContext> fetchAdditionalContext(
    MedicalContextCategory category,
  ) async {
    final result = await _syncCategory(category);

    if (_cachedContext == null) {
      _cachedContext = LocalMedicalContext(
        icd10Codes: result.icd10,
        loincCodes: result.loinc,
        medications: result.meds,
        guidelines: result.guidelines,
        downloadedCategories: {category},
      );
    } else {
      _cachedContext = LocalMedicalContext(
        icd10Codes: {..._cachedContext!.icd10Codes, ...result.icd10},
        loincCodes: {..._cachedContext!.loincCodes, ...result.loinc},
        medications: {..._cachedContext!.medications, ...result.meds},
        guidelines: {..._cachedContext!.guidelines, ...result.guidelines},
        downloadedCategories: {
          ..._cachedContext!.downloadedCategories,
          category,
        },
      );
    }

    return _cachedContext!;
  }

  /// Get the currently cached context (null if not yet synced)
  LocalMedicalContext? get currentContext => _cachedContext;

  /// Clear all cached data
  Future<void> clearCache() async {
    final categories = await _cache.listCategories();
    for (final cat in categories) {
      await _cache.delete('${cat}_$_cacheVersion.json');
    }
    _cachedContext = null;
  }
}

/// Result of syncing a single category
class _CategorySyncResult {
  final Map<String, Icd10Code> icd10;
  final Map<String, LoincCode> loinc;
  final Map<String, MedicationReference> meds;
  final Map<String, ClinicalGuidelineReference> guidelines;

  const _CategorySyncResult({
    required this.icd10,
    required this.loinc,
    required this.meds,
    required this.guidelines,
  });

  Map<String, dynamic> toJson() => {
        'icd10': icd10.map((k, v) => MapEntry(k, v.code)),
        'loinc': loinc.map((k, v) => MapEntry(k, v.code)),
        'meds': meds.map((k, v) => MapEntry(k, v.code)),
        'guidelines': guidelines.map((k, v) => MapEntry(k, v.code)),
      };

  factory _CategorySyncResult.fromJson(
    Map<String, dynamic> json,
    MedicalContextCategory cat,
  ) {
    // Reconstruct from code strings using static catalogs
    final icd10Map = <String, Icd10Code>{};
    final staticIcd10 = SelectiveSyncService._staticIcd10Map();
    final codes = json['icd10'] as Map<String, dynamic>?;
    if (codes != null) {
      for (final entry in codes.entries) {
        final found = staticIcd10[entry.value];
        if (found != null) icd10Map[entry.key] = found;
      }
    }

    final loincMap = <String, LoincCode>{};
    final loincData = json['loinc'] as Map<String, dynamic>?;
    if (loincData != null) {
      for (final entry in loincData.entries) {
        final found = LoincCommonLabs.findByCode(entry.value);
        if (found != null) loincMap[entry.key] = found;
      }
    }

    final medMap = <String, MedicationReference>{};
    final medData = json['meds'] as Map<String, dynamic>?;
    if (medData != null) {
      for (final entry in medData.entries) {
        final found = MedicationCatalog.findByCode(entry.value);
        if (found != null) medMap[entry.key] = found;
      }
    }

    return _CategorySyncResult(
      icd10: icd10Map,
      loinc: loincMap,
      meds: medMap,
      guidelines: {},
    );
  }
}
