// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i11;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i57;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i8;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i18;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i12;
import 'package:medical_standards/medical_standards.dart' as _i28;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i66;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i67;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i70;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i3;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i71;
import '../../features/auth/application/auth_cubit.dart' as _i99;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i100;
import '../../features/auth/domain/auth_service.dart' as _i74;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i72;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i73;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i4;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i75;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i13;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i5;
import '../../features/calendar_import/data/calendar_repository.dart' as _i7;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i76;
import '../../features/eps_connection/data/oauth_repository.dart' as _i43;
import '../../features/eps_connection/domain/eps_connection_cubit.dart' as _i79;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i83;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i16;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i101;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i84;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i85;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i15;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i17;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i44;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i96;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i29;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i21;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i60;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i22;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i86;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i87;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i23;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i89;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i88;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i102;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i31;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i30;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i61;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i26;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i103;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i42;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i93;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i91;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i19;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i55;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i62;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i77;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i81;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i27;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i20;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i49;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i63;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i32;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i78;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i82;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i33;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i35;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i37;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i6;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i92;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i34;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i36;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i38;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i39;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i40;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i45;
import '../../features/onboarding/application/sync_cubit.dart' as _i97;
import '../../features/reports/application/bloc/report_bloc.dart' as _i104;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i47;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i94;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i48;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i95;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i41;
import '../../features/settings/application/llm_settings_cubit.dart' as _i90;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i24;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i10;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i25;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i51;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i68;
import '../../features/ssi/domain/services/ssi_service.dart' as _i53;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i52;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i69;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i50;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i54;
import '../../features/sync/data/fhir_client.dart' as _i14;
import '../../features/sync/data/sync_repository.dart' as _i56;
import '../../features/sync/domain/sync_cubit.dart' as _i80;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i98;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i58;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i59;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i64;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i65;
import '../services/device_capability_service.dart' as _i9;
import '../services/privacy_anonymizer.dart' as _i46;
import 'database_module.dart' as _i108;
import 'fhir_module.dart' as _i105;
import 'memory_module.dart' as _i107;
import 'network_module.dart' as _i106;

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
    gh.lazySingleton<_i3.AppointmentService>(() => _i3.AppointmentService());
    gh.lazySingleton<_i4.BiometricService>(() => _i4.BiometricService());
    gh.lazySingleton<_i5.BleSharingService>(() => _i5.BleSharingService());
    gh.lazySingleton<_i6.BotBypassHandler>(() => _i6.BotBypassHandler());
    gh.lazySingleton<_i7.CalendarRepository>(() => _i7.CalendarRepository());
    gh.lazySingleton<_i8.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i9.DeviceCapabilityService>(
        () => _i9.DeviceCapabilityService());
    gh.lazySingleton<_i10.DeviceCapabilityService>(
        () => _i10.DeviceCapabilityService());
    gh.lazySingleton<_i11.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i12.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i13.EncryptionService>(() => _i13.EncryptionService());
    gh.lazySingleton<_i14.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i15.FilePickerService>(
        () => _i15.FilePickerServiceImpl());
    gh.lazySingleton<_i16.HealthDataImportService>(
        () => _i16.HealthDataImportService());
    gh.lazySingleton<_i17.ImagePickerService>(
        () => _i17.ImagePickerServiceImpl());
    await gh.factoryAsync<_i18.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i19.LabAnalysisStrategy>(() => _i19.LabAnalysisStrategy());
    gh.factory<_i20.LabInterpreter>(() => _i20.LabInterpreter());
    gh.lazySingleton<_i21.LlmAdapter>(
      () => _i22.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i21.LlmAdapter>(
      () => _i23.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i24.LlmSettingsRepository>(
        () => _i25.LlmSettingsRepositoryImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i26.LocalLlmService>(() => _i26.LocalLlmService());
    gh.factory<_i27.MedicalAnalysisService>(
        () => _i27.MedicalAnalysisService());
    gh.lazySingleton<_i28.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i29.MedicalKnowledgeRepository>(
      () => _i30.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i29.MedicalKnowledgeRepository>(
      () => _i31.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i32.MedicalLlmAdapter>(() => _i32.MedicalLlmAdapter());
    gh.lazySingleton<_i33.MedicalScraperService>(
        () => _i34.MedicalScraperServiceImpl(
              gh<_i11.Dio>(),
              gh<_i6.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i35.MedicalStandardsService>(() =>
        _i36.MedicalStandardsServiceImpl(gh<_i28.MedicalContextProvider>()));
    gh.lazySingleton<_i37.MedicalWebSearchService>(
        () => _i38.MedicalWebSearchServiceImpl(gh<_i11.Dio>()));
    gh.lazySingleton<_i39.MedicationRepository>(
        () => _i40.IsarMedicationRepository(gh<_i18.Isar>()));
    await gh.lazySingletonAsync<_i12.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i18.Isar>(),
        gh<_i12.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i41.MockReportGenerationService>(
      () => _i41.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i42.ModelDownloadService>(
        () => _i42.ModelDownloadService());
    gh.lazySingleton<_i43.OAuthRepository>(() => _i43.OAuthRepositoryImpl());
    gh.lazySingleton<_i44.OcrService>(() => _i44.MlKitOcrService());
    gh.factory<_i45.OnboardingCubit>(() => _i45.OnboardingCubit());
    gh.lazySingleton<_i46.PromptScrubber>(
        () => _i46.PromptScrubber(gh<_i18.Isar>()));
    gh.lazySingleton<_i47.ReportRepository>(
        () => _i48.IsarReportRepository(gh<_i18.Isar>()));
    gh.factory<_i49.RiskCalculator>(() => _i49.RiskCalculator());
    gh.lazySingleton<_i50.SidetreeAnchorClient>(
        () => _i50.SidetreeAnchorClient.create());
    gh.lazySingleton<_i51.SsiRepository>(
        () => _i52.IsarSsiRepository(gh<_i18.Isar>()));
    gh.lazySingleton<_i53.SsiService>(() => _i54.SsiServiceImpl(
          gh<_i51.SsiRepository>(),
          gh<_i50.SidetreeAnchorClient>(),
        ));
    gh.factory<_i55.SymptomAnalysisStrategy>(
        () => _i55.SymptomAnalysisStrategy());
    gh.lazySingleton<_i56.SyncRepository>(() => _i56.SyncRepository(
          gh<_i14.FhirClient>(),
          gh<_i18.Isar>(),
          gh<_i57.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i28.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i58.UserProfileRepository>(
        () => _i59.UserProfileRepositoryImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i60.VectorStoreService>(() => _i61.IsarVectorStoreService(
          gh<_i12.MemoryGraph>(),
          gh<_i29.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i62.VitalAnalysisStrategy>(() => _i62.VitalAnalysisStrategy());
    gh.factory<_i63.VitalSignAnalyzer>(() => _i63.VitalSignAnalyzer());
    gh.lazySingleton<_i64.VitalSignRepository>(
        () => _i65.VitalSignRepositoryImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i66.AllergyRepository>(
        () => _i67.IsarAllergyRepository(gh<_i18.Isar>()));
    gh.lazySingleton<_i68.AnonCredsService>(
        () => _i69.AnonCredsServiceImpl(gh<_i51.SsiRepository>()));
    gh.lazySingleton<_i70.AppointmentRepository>(
        () => _i71.IsarAppointmentRepository(gh<_i18.Isar>()));
    gh.lazySingleton<_i72.AuthRepository>(
        () => _i73.AuthRepositoryImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i74.AuthService>(
        () => _i74.AuthServiceImpl(gh<_i13.EncryptionService>()));
    gh.lazySingleton<_i75.BleMedicalSharingService>(
        () => _i75.BleMedicalSharingService(
              gh<_i5.BleSharingService>(),
              gh<_i13.EncryptionService>(),
              gh<_i53.SsiService>(),
            ));
    gh.factory<_i76.CalendarImportCubit>(() => _i76.CalendarImportCubit(
          gh<_i7.CalendarRepository>(),
          gh<_i70.AppointmentRepository>(),
          gh<_i58.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i77.ClinicalReasonerService>(
        () => _i78.SymphonyClinicalReasonerService(
              gh<_i29.MedicalKnowledgeRepository>(),
              gh<_i46.PromptScrubber>(),
            ));
    gh.factory<_i79.EpsConnectionCubit>(() => _i79.EpsConnectionCubit(
          gh<_i43.OAuthRepository>(),
          gh<_i58.UserProfileRepository>(),
        ));
    gh.factory<_i80.FhirSyncCubit>(
        () => _i80.FhirSyncCubit(gh<_i56.SyncRepository>()));
    gh.lazySingleton<_i81.HealthContextService>(
        () => _i82.IsarHealthContextService(
              gh<_i64.VitalSignRepository>(),
              gh<_i39.MedicationRepository>(),
              gh<_i58.UserProfileRepository>(),
              gh<_i12.MemoryGraph>(),
            ));
    gh.factory<_i83.HealthImportCubit>(() => _i83.HealthImportCubit(
          gh<_i16.HealthDataImportService>(),
          gh<_i64.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i84.HealthRecordRepository>(
        () => _i85.HealthRecordRepositoryImpl(gh<_i18.Isar>()));
    gh.lazySingleton<_i21.LlmAdapter>(
      () => _i86.GeminiLlmAdapter(
        scrubber: gh<_i46.PromptScrubber>(),
        userProfileRepository: gh<_i58.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i21.LlmAdapter>(
      () => _i87.MockLlmAdapter(gh<_i46.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i88.LlmService>(() => _i89.GemmaLlmService(
          gh<_i60.VectorStoreService>(),
          gh<_i58.UserProfileRepository>(),
          gh<_i21.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i90.LlmSettingsCubit>(() => _i90.LlmSettingsCubit(
          gh<_i24.LlmSettingsRepository>(),
          gh<_i10.DeviceCapabilityService>(),
          gh<_i21.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i91.MedicalAssistantCubit>(() => _i91.MedicalAssistantCubit(
          llmAdapter: gh<_i32.MedicalLlmAdapter>(),
          analysisService: gh<_i27.MedicalAnalysisService>(),
          healthContextService: gh<_i81.HealthContextService>(),
          labInterpreter: gh<_i20.LabInterpreter>(),
          vitalAnalyzer: gh<_i63.VitalSignAnalyzer>(),
          riskCalculator: gh<_i49.RiskCalculator>(),
        ));
    gh.lazySingleton<_i92.MedicalResearchService>(
        () => _i92.MedicalResearchService(
              gh<_i37.MedicalWebSearchService>(),
              gh<_i33.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i93.PatientContextIndexer>(
      () => _i93.PatientContextIndexer(
        gh<_i18.Isar>(),
        gh<_i60.VectorStoreService>(),
        gh<_i84.HealthRecordRepository>(),
        gh<_i39.MedicationRepository>(),
        gh<_i66.AllergyRepository>(),
        gh<_i64.VitalSignRepository>(),
        gh<_i70.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i94.ReportGenerationService>(
        () => _i95.GemmaReportGenerationService(
              gh<_i21.LlmAdapter>(instanceName: 'gemma'),
              gh<_i60.VectorStoreService>(),
              gh<_i58.UserProfileRepository>(),
              gh<_i46.PromptScrubber>(),
            ));
    gh.lazySingleton<_i96.SmartSearchUseCase>(
        () => _i96.SmartSearchUseCase(gh<_i60.VectorStoreService>()));
    gh.factory<_i97.SyncCubit>(() => _i97.SyncCubit(
          gh<_i28.SyncService>(),
          gh<_i60.VectorStoreService>(),
        ));
    gh.factory<_i98.UserProfileCubit>(
        () => _i98.UserProfileCubit(gh<_i58.UserProfileRepository>()));
    gh.factory<_i99.AuthCubit>(() => _i99.AuthCubit(gh<_i74.AuthService>()));
    gh.factory<_i100.AuthCubit>(() => _i100.AuthCubit(
          gh<_i72.AuthRepository>(),
          gh<_i13.EncryptionService>(),
          gh<_i4.BiometricService>(),
        ));
    gh.factory<_i101.HealthRecordCubit>(() => _i101.HealthRecordCubit(
          gh<_i84.HealthRecordRepository>(),
          gh<_i15.FilePickerService>(),
          gh<_i17.ImagePickerService>(),
          gh<_i44.OcrService>(),
          gh<_i60.VectorStoreService>(),
        ));
    gh.lazySingleton<_i88.LlmService>(
      () => _i102.RagLlmService(
        gh<_i60.VectorStoreService>(),
        gh<_i92.MedicalResearchService>(),
        gh<_i58.UserProfileRepository>(),
        gh<_i21.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i103.MedicalIndexingService>(
        () => _i103.MedicalIndexingService(
              gh<_i29.MedicalKnowledgeRepository>(),
              gh<_i60.VectorStoreService>(),
              gh<_i93.PatientContextIndexer>(),
            ));
    gh.factory<_i104.ReportBloc>(() => _i104.ReportBloc(
          gh<_i47.ReportRepository>(),
          gh<_i94.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i105.FhirModule {}

class _$NetworkModule extends _i106.NetworkModule {}

class _$MemoryModule extends _i107.MemoryModule {}

class _$DatabaseModule extends _i108.DatabaseModule {}
