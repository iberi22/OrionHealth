// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i10;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i56;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i7;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i17;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i11;
import 'package:medical_standards/medical_standards.dart' as _i27;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i65;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i66;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i69;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i70;
import '../../features/auth/application/auth_cubit.dart' as _i99;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i98;
import '../../features/auth/domain/auth_service.dart' as _i73;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i71;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i72;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i3;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i74;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i12;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i4;
import '../../features/calendar_import/data/calendar_repository.dart' as _i6;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i75;
import '../../features/eps_connection/data/oauth_repository.dart' as _i42;
import '../../features/eps_connection/domain/eps_connection_cubit.dart' as _i78;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i82;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i15;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i100;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i83;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i84;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i14;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i16;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i43;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i95;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i28;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i20;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i59;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i21;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i85;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i86;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i22;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i88;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i87;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i101;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i29;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i30;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i60;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i25;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i102;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i41;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i92;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i90;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i18;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i54;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i61;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i76;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i80;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i26;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i19;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i48;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i62;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i31;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i77;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i81;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i32;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i34;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i36;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i5;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i91;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i33;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i35;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i37;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i38;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i39;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i44;
import '../../features/onboarding/application/sync_cubit.dart' as _i96;
import '../../features/reports/application/bloc/report_bloc.dart' as _i103;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i46;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i93;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i47;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i94;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i40;
import '../../features/settings/application/llm_settings_cubit.dart' as _i89;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i23;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i8;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i24;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i50;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i67;
import '../../features/ssi/domain/services/ssi_service.dart' as _i52;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i51;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i68;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i49;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i53;
import '../../features/sync/data/fhir_client.dart' as _i13;
import '../../features/sync/data/sync_repository.dart' as _i55;
import '../../features/sync/domain/sync_cubit.dart' as _i79;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i97;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i57;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i58;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i63;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i64;
import '../services/device_capability_service.dart' as _i9;
import '../services/privacy_anonymizer.dart' as _i45;
import 'database_module.dart' as _i107;
import 'fhir_module.dart' as _i104;
import 'memory_module.dart' as _i106;
import 'network_module.dart' as _i105;

const String _mobile = 'mobile';
const String _desktop = 'desktop';
const String _test = 'test';

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final fhirModule = _$FhirModule();
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.BiometricService>(() => _i3.BiometricService());
    gh.lazySingleton<_i4.BleSharingService>(() => _i4.BleSharingService());
    gh.lazySingleton<_i5.BotBypassHandler>(() => _i5.BotBypassHandler());
    gh.lazySingleton<_i6.CalendarRepository>(() => _i6.CalendarRepository());
    gh.lazySingleton<_i7.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i8.DeviceCapabilityService>(
        () => _i8.DeviceCapabilityService());
    gh.lazySingleton<_i9.DeviceCapabilityService>(
        () => _i9.DeviceCapabilityService());
    gh.lazySingleton<_i10.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i11.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i12.EncryptionService>(() => _i12.EncryptionService());
    gh.lazySingleton<_i13.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i14.FilePickerService>(
        () => _i14.FilePickerServiceImpl());
    gh.lazySingleton<_i15.HealthDataImportService>(
        () => _i15.HealthDataImportService());
    gh.lazySingleton<_i16.ImagePickerService>(
        () => _i16.ImagePickerServiceImpl());
    await gh.factoryAsync<_i17.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i18.LabAnalysisStrategy>(() => _i18.LabAnalysisStrategy());
    gh.factory<_i19.LabInterpreter>(() => _i19.LabInterpreter());
    gh.lazySingleton<_i20.LlmAdapter>(
      () => _i21.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i20.LlmAdapter>(
      () => _i22.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i23.LlmSettingsRepository>(
        () => _i24.LlmSettingsRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i25.LocalLlmService>(() => _i25.LocalLlmService());
    gh.factory<_i26.MedicalAnalysisService>(
        () => _i26.MedicalAnalysisService());
    gh.lazySingleton<_i27.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i28.MedicalKnowledgeRepository>(
      () => _i29.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i28.MedicalKnowledgeRepository>(
      () => _i30.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i31.MedicalLlmAdapter>(() => _i31.MedicalLlmAdapter());
    gh.lazySingleton<_i32.MedicalScraperService>(
        () => _i33.MedicalScraperServiceImpl(
              gh<_i10.Dio>(),
              gh<_i5.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i34.MedicalStandardsService>(() =>
        _i35.MedicalStandardsServiceImpl(gh<_i27.MedicalContextProvider>()));
    gh.lazySingleton<_i36.MedicalWebSearchService>(
        () => _i37.MedicalWebSearchServiceImpl(gh<_i10.Dio>()));
    gh.lazySingleton<_i38.MedicationRepository>(
        () => _i39.IsarMedicationRepository(gh<_i17.Isar>()));
    await gh.lazySingletonAsync<_i11.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i17.Isar>(),
        gh<_i11.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i40.MockReportGenerationService>(
      () => _i40.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i41.ModelDownloadService>(
        () => _i41.ModelDownloadService());
    gh.lazySingleton<_i42.OAuthRepository>(() => _i42.OAuthRepositoryImpl());
    gh.lazySingleton<_i43.OcrService>(() => _i43.MlKitOcrService());
    gh.factory<_i44.OnboardingCubit>(() => _i44.OnboardingCubit());
    gh.lazySingleton<_i45.PromptScrubber>(
        () => _i45.PromptScrubber(gh<_i17.Isar>()));
    gh.lazySingleton<_i46.ReportRepository>(
        () => _i47.IsarReportRepository(gh<_i17.Isar>()));
    gh.factory<_i48.RiskCalculator>(() => _i48.RiskCalculator());
    gh.lazySingleton<_i49.SidetreeAnchorClient>(
        () => _i49.SidetreeAnchorClient.create());
    gh.lazySingleton<_i50.SsiRepository>(
        () => _i51.IsarSsiRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i52.SsiService>(() => _i53.SsiServiceImpl(
          gh<_i50.SsiRepository>(),
          gh<_i49.SidetreeAnchorClient>(),
        ));
    gh.factory<_i54.SymptomAnalysisStrategy>(
        () => _i54.SymptomAnalysisStrategy());
    gh.lazySingleton<_i55.SyncRepository>(() => _i55.SyncRepository(
          gh<_i13.FhirClient>(),
          gh<_i17.Isar>(),
          gh<_i56.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i27.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i57.UserProfileRepository>(
        () => _i58.UserProfileRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i59.VectorStoreService>(() => _i60.IsarVectorStoreService(
          gh<_i11.MemoryGraph>(),
          gh<_i28.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i61.VitalAnalysisStrategy>(() => _i61.VitalAnalysisStrategy());
    gh.factory<_i62.VitalSignAnalyzer>(() => _i62.VitalSignAnalyzer());
    gh.lazySingleton<_i63.VitalSignRepository>(
        () => _i64.VitalSignRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i65.AllergyRepository>(
        () => _i66.IsarAllergyRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i67.AnonCredsService>(
        () => _i68.AnonCredsServiceImpl(gh<_i50.SsiRepository>()));
    gh.lazySingleton<_i69.AppointmentRepository>(
        () => _i70.IsarAppointmentRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i71.AuthRepository>(
        () => _i72.AuthRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i73.AuthService>(
        () => _i73.AuthServiceImpl(gh<_i12.EncryptionService>()));
    gh.lazySingleton<_i74.BleMedicalSharingService>(
        () => _i74.BleMedicalSharingService(
              gh<_i4.BleSharingService>(),
              gh<_i12.EncryptionService>(),
              gh<_i52.SsiService>(),
            ));
    gh.factory<_i75.CalendarImportCubit>(() => _i75.CalendarImportCubit(
          gh<_i6.CalendarRepository>(),
          gh<_i69.AppointmentRepository>(),
          gh<_i57.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i76.ClinicalReasonerService>(
        () => _i77.SymphonyClinicalReasonerService(
              gh<_i28.MedicalKnowledgeRepository>(),
              gh<_i45.PromptScrubber>(),
            ));
    gh.factory<_i78.EpsConnectionCubit>(() => _i78.EpsConnectionCubit(
          gh<_i42.OAuthRepository>(),
          gh<_i57.UserProfileRepository>(),
        ));
    gh.factory<_i79.FhirSyncCubit>(
        () => _i79.FhirSyncCubit(gh<_i55.SyncRepository>()));
    gh.lazySingleton<_i80.HealthContextService>(
        () => _i81.IsarHealthContextService(
              gh<_i63.VitalSignRepository>(),
              gh<_i38.MedicationRepository>(),
              gh<_i57.UserProfileRepository>(),
              gh<_i11.MemoryGraph>(),
            ));
    gh.factory<_i82.HealthImportCubit>(() => _i82.HealthImportCubit(
          gh<_i15.HealthDataImportService>(),
          gh<_i63.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i83.HealthRecordRepository>(
        () => _i84.HealthRecordRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i20.LlmAdapter>(
      () => _i85.GeminiLlmAdapter(
        scrubber: gh<_i45.PromptScrubber>(),
        userProfileRepository: gh<_i57.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i20.LlmAdapter>(
      () => _i86.MockLlmAdapter(gh<_i45.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i87.LlmService>(() => _i88.GemmaLlmService(
          gh<_i59.VectorStoreService>(),
          gh<_i57.UserProfileRepository>(),
          gh<_i20.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i89.LlmSettingsCubit>(() => _i89.LlmSettingsCubit(
          gh<_i23.LlmSettingsRepository>(),
          gh<_i8.DeviceCapabilityService>(),
          gh<_i20.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i90.MedicalAssistantCubit>(() => _i90.MedicalAssistantCubit(
          llmAdapter: gh<_i31.MedicalLlmAdapter>(),
          analysisService: gh<_i26.MedicalAnalysisService>(),
          healthContextService: gh<_i80.HealthContextService>(),
          labInterpreter: gh<_i19.LabInterpreter>(),
          vitalAnalyzer: gh<_i62.VitalSignAnalyzer>(),
          riskCalculator: gh<_i48.RiskCalculator>(),
        ));
    gh.lazySingleton<_i91.MedicalResearchService>(
        () => _i91.MedicalResearchService(
              gh<_i36.MedicalWebSearchService>(),
              gh<_i32.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i92.PatientContextIndexer>(
      () => _i92.PatientContextIndexer(
        gh<_i17.Isar>(),
        gh<_i59.VectorStoreService>(),
        gh<_i83.HealthRecordRepository>(),
        gh<_i38.MedicationRepository>(),
        gh<_i65.AllergyRepository>(),
        gh<_i63.VitalSignRepository>(),
        gh<_i69.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i93.ReportGenerationService>(
        () => _i94.GemmaReportGenerationService(
              gh<_i20.LlmAdapter>(instanceName: 'gemma'),
              gh<_i59.VectorStoreService>(),
              gh<_i57.UserProfileRepository>(),
              gh<_i45.PromptScrubber>(),
            ));
    gh.lazySingleton<_i95.SmartSearchUseCase>(
        () => _i95.SmartSearchUseCase(gh<_i59.VectorStoreService>()));
    gh.factory<_i96.SyncCubit>(() => _i96.SyncCubit(
          gh<_i27.SyncService>(),
          gh<_i59.VectorStoreService>(),
        ));
    gh.factory<_i97.UserProfileCubit>(
        () => _i97.UserProfileCubit(gh<_i57.UserProfileRepository>()));
    gh.factory<_i98.AuthCubit>(() => _i98.AuthCubit(
          gh<_i71.AuthRepository>(),
          gh<_i12.EncryptionService>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i99.AuthCubit>(() => _i99.AuthCubit(gh<_i73.AuthService>()));
    gh.factory<_i100.HealthRecordCubit>(() => _i100.HealthRecordCubit(
          gh<_i83.HealthRecordRepository>(),
          gh<_i14.FilePickerService>(),
          gh<_i16.ImagePickerService>(),
          gh<_i43.OcrService>(),
          gh<_i59.VectorStoreService>(),
        ));
    gh.lazySingleton<_i87.LlmService>(
      () => _i101.RagLlmService(
        gh<_i59.VectorStoreService>(),
        gh<_i91.MedicalResearchService>(),
        gh<_i57.UserProfileRepository>(),
        gh<_i20.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i102.MedicalIndexingService>(
        () => _i102.MedicalIndexingService(
              gh<_i28.MedicalKnowledgeRepository>(),
              gh<_i59.VectorStoreService>(),
              gh<_i92.PatientContextIndexer>(),
            ));
    gh.factory<_i103.ReportBloc>(() => _i103.ReportBloc(
          gh<_i46.ReportRepository>(),
          gh<_i93.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i104.FhirModule {}

class _$NetworkModule extends _i105.NetworkModule {}

class _$MemoryModule extends _i106.MemoryModule {}

class _$DatabaseModule extends _i107.DatabaseModule {}
