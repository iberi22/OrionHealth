import 'dart:async';
import 'package:medical_standards/medical_standards.dart' hide VitalSign;
import '../../domain/repositories/home_repository.dart';
import '../../domain/services/icd10_catalog.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../vitals/domain/entities/vital_sign.dart' as entity;
import '../../../local_agent/infrastructure/services/medical_indexing_service.dart';
import '../../../medical_assistant/domain/services/medical_analysis_service.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../medical_assistant/domain/entities/medical_insight.dart';

/// Data-layer implementation of [HomeRepository].
///
/// Aggregates vitals, indexing, analysis services for the home screen.
class HomeRepositoryImpl implements HomeRepository {
  final VitalSignRepository _vitalSignRepository;
  final MedicalIndexingService _indexingService;
  final MedicalAnalysisService _analysisService;
  final UserProfileRepository _userProfileRepository;

  HomeRepositoryImpl(
    this._vitalSignRepository,
    this._indexingService,
    this._analysisService,
    this._userProfileRepository,
  );

  @override
  bool get hasIndexed => _indexingService.hasIndexed;

  @override
  Stream<bool> get indexingStatusStream => _indexingService.statusStream;

  @override
  Future<bool> retryIndexing() async {
    try {
      final result = await _indexingService.indexAll(force: true);
      return result.success;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<entity.VitalSignType, entity.VitalSign?>> getLatestVitals() async {
    return await _vitalSignRepository.getLatestVitals();
  }

  @override
  Future<List<MedicalInsight>> getRecentInsights() async {
    final vitals = await _vitalSignRepository.getLatestVitals();
    final vitalsMap = <String, double>{};

    final hr = vitals[entity.VitalSignType.heartRate];
    if (hr != null) vitalsMap['heartRate'] = hr.value;

    final systolic = vitals[entity.VitalSignType.bloodPressureSystolic];
    if (systolic != null) vitalsMap['systolic'] = systolic.value;

    final diastolic = vitals[entity.VitalSignType.bloodPressureDiastolic];
    if (diastolic != null) vitalsMap['diastolic'] = diastolic.value;

    final temp = vitals[entity.VitalSignType.temperature];
    if (temp != null) vitalsMap['temperature'] = temp.value;

    final spo2 = vitals[entity.VitalSignType.oxygenSaturation];
    if (spo2 != null) vitalsMap['oxygenSaturation'] = spo2.value;

    final userProfile = await _userProfileRepository.getUserProfile();
    final chronicConditions = <Icd10Code>[];
    if (userProfile != null && userProfile.medicalConditions.isNotEmpty) {
      for (final s in userProfile.medicalConditions) {
        final code = Icd10Catalog.findByCode(s);
        if (code != null) chronicConditions.add(code);
      }
    }

    final vitalInsights = await _analysisService.analyzeVitals(
      vitals: vitalsMap,
      chronicConditions: chronicConditions,
    );

    final riskInsights = await _analysisService.calculateRisks(
      labValues: {},
      vitals: vitalsMap,
      conditions: chronicConditions,
    );

    final allInsights = [...vitalInsights, ...riskInsights];
    allInsights.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return allInsights;
  }
}
