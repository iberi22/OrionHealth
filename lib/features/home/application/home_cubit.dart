import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_standards/medical_standards.dart';
import '../domain/services/icd10_catalog.dart';
import '../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../vitals/domain/entities/vital_sign.dart' as entity;
import '../../local_agent/infrastructure/services/medical_indexing_service.dart';
import '../../medical_assistant/domain/services/medical_analysis_service.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VitalSignRepository _vitalSignRepository;
  final MedicalIndexingService _indexingService;
  final MedicalAnalysisService _analysisService;
  final UserProfileRepository _userProfileRepository;
  StreamSubscription<bool>? _indexingSubscription;

  HomeCubit(
    this._vitalSignRepository,
    this._indexingService,
    this._analysisService,
    this._userProfileRepository,
  ) : super(const HomeState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(isIndexing: !_indexingService.hasIndexed));

    _indexingSubscription = _indexingService.statusStream.listen((isDone) {
      emit(state.copyWith(
        isIndexing: !isDone,
        indexingError: false,
      ));
    });

    loadVitals();
  }

  Future<void> retryIndexing() async {
    emit(state.copyWith(isIndexing: true, indexingError: false));
    try {
      final result = await _indexingService.indexAll(force: true);
      if (!result.success) {
        emit(state.copyWith(isIndexing: false, indexingError: true));
      }
    } catch (e) {
      emit(state.copyWith(isIndexing: false, indexingError: true));
    }
  }

  Future<void> loadVitals() async {
    emit(state.copyWith(isLoadingVitals: true));
    try {
      final vitals = await _vitalSignRepository.getLatestVitals();

      // Convert latest vitals to a map suitable for MedicalAnalysisService
      final vitalsMap = <String, double>{};
      final hr = vitals[entity.VitalSignType.heartRate];
      if (hr != null) {
        vitalsMap['heartRate'] = hr.value;
      }
      final systolic = vitals[entity.VitalSignType.bloodPressureSystolic];
      if (systolic != null) {
        vitalsMap['systolic'] = systolic.value;
      }
      final diastolic = vitals[entity.VitalSignType.bloodPressureDiastolic];
      if (diastolic != null) {
        vitalsMap['diastolic'] = diastolic.value;
      }
      final temp = vitals[entity.VitalSignType.temperature];
      if (temp != null) {
        vitalsMap['temperature'] = temp.value;
      }
      final spo2 = vitals[entity.VitalSignType.oxygenSaturation];
      if (spo2 != null) {
        vitalsMap['oxygenSaturation'] = spo2.value;
      }

      // Load chronic conditions from user profile (parallelized)
      final userProfile = await _userProfileRepository.getUserProfile();
      final chronicConditions = <Icd10Code>[];
      if (userProfile != null && userProfile.medicalConditions.isNotEmpty) {
        for (final s in userProfile.medicalConditions) {
          final code = Icd10Catalog.findByCode(s);
          if (code != null) chronicConditions.add(code);
        }
      }

      // Perform analysis
      final vitalInsights = await _analysisService.analyzeVitals(
        vitals: vitalsMap,
        chronicConditions: chronicConditions,
      );

      final riskInsights = await _analysisService.calculateRisks(
        labValues: {}, // Home dashboard focus on vitals for now
        vitals: vitalsMap,
        conditions: chronicConditions,
      );

      final allInsights = [...vitalInsights, ...riskInsights];
      // Sort by severity (critical > alert > warning > info)
      allInsights.sort((a, b) => b.severity.index.compareTo(a.severity.index));

      emit(state.copyWith(
        latestVitals: vitals,
        recentInsights: allInsights,
        isLoadingVitals: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingVitals: false));
    }
  }

  @override
  Future<void> close() {
    _indexingSubscription?.cancel();
    return super.close();
  }
}
