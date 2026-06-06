// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i13;
import 'package:flutter_appauth/flutter_appauth.dart' as _i48;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i49;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i10;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i20;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i14;
import 'package:medical_standards/medical_standards.dart' as _i31;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i73;
import '../../features/allergies/domain/services/allergy_service.dart' as _i3;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i74;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i77;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i4;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i78;
import '../../features/auth/application/auth_cubit.dart' as _i109;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i108;
import '../../features/auth/domain/auth_service.dart' as _i81;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i79;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i80;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i5;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i82;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i15;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i6;
import '../../features/ble_sharing/domain/ble_wrapper.dart' as _i7;
import '../../features/calendar_import/data/calendar_repository.dart' as _i9;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i83;
import '../../features/eps_connection/domain/eps_connection_cubit.dart' as _i86;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i47;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i90;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i18;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i110;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i91;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i92;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i17;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i19;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i50;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i105;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i33;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i23;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i67;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i24;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i25;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i94;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i95;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i93;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i26;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i98;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i97;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i111;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i34;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i35;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i68;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i96;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i29;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i112;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i46;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i102;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i100;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i21;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i62;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i69;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i84;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i88;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i30;
import '../../features/medical_assistant/domain/services/medical_guidelines_service.dart'
    as _i32;
import '../../features/medical_assistant/domain/services/risk_calculator_service.dart'
    as _i56;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i22;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i55;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i70;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i36;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i85;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i89;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i37;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i39;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i41;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i8;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i101;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i38;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i40;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i42;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i43;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i44;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i51;
import '../../features/onboarding/application/sync_cubit.dart' as _i106;
import '../../features/reports/application/bloc/report_bloc.dart' as _i113;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i53;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i103;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i54;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i104;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i45;
import '../../features/settings/application/llm_settings_cubit.dart' as _i99;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i27;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i12;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i28;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i58;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i75;
import '../../features/ssi/domain/services/ssi_service.dart' as _i60;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i59;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i76;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i57;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i61;
import '../../features/sync/data/fhir_client.dart' as _i16;
import '../../features/sync/data/sync_repository.dart' as _i63;
import '../../features/sync/domain/sync_cubit.dart' as _i87;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i107;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i64;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i66;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i65;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i71;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i72;
import '../services/device_capability_service.dart' as _i11;
import '../services/privacy_anonymizer.dart' as _i52;
import 'database_module.dart' as _i117;
import 'fhir_module.dart' as _i114;
import 'memory_module.dart' as _i116;
import 'network_module.dart' as _i115;

const String _desktop = 'desktop';
const String _test = 'test';
const String _mobile = 'mobile';

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
    gh.lazySingleton<_i3.AllergyService>(() => _i3.AllergyService());
    gh.lazySingleton<_i4.AppointmentService>(() => _i4.AppointmentService());
    gh.lazySingleton<_i5.BiometricService>(() => _i5.BiometricService());
    gh.lazySingleton<_i6.BleSharingService>(
        () => _i6.BleSharingService(bleWrapper: gh<_i7.BleWrapper>()));
    gh.lazySingleton<_i7.BleWrapper>(() => _i7.BleWrapper());
    gh.lazySingleton<_i8.BotBypassHandler>(() => _i8.BotBypassHandler());
    gh.lazySingleton<_i9.CalendarRepository>(() => _i9.CalendarRepository());
    gh.lazySingleton<_i10.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i11.DeviceCapabilityService>(
        () => _i11.DeviceCapabilityService());
    gh.lazySingleton<_i12.DeviceCapabilityService>(
        () => _i12.DeviceCapabilityService());
    gh.lazySingleton<_i13.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i14.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i15.EncryptionService>(() => _i15.EncryptionService());
    gh.lazySingleton<_i16.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i17.FilePickerService>(
        () => _i17.FilePickerServiceImpl());
    gh.lazySingleton<_i18.HealthDataImportService>(
        () => _i18.HealthDataImportService());
    gh.lazySingleton<_i19.ImagePickerService>(
        () => _i19.ImagePickerServiceImpl());
    await gh.factoryAsync<_i20.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i21.LabAnalysisStrategy>(() => _i21.LabAnalysisStrategy());
    gh.factory<_i22.LabInterpreter>(() => _i22.LabInterpreter());
    gh.lazySingleton<_i23.LlmAdapter>(
      () => _i24.FlutterGemmaAdapter(wrapper: gh<_i25.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i23.LlmAdapter>(
      () => _i26.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i27.LlmSettingsRepository>(
        () => _i28.LlmSettingsRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i29.LocalLlmService>(() => _i29.LocalLlmService());
    gh.factory<_i30.MedicalAnalysisService>(
        () => _i30.MedicalAnalysisService());
    gh.lazySingleton<_i31.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i32.MedicalGuidelinesService>(
        () => _i32.MedicalGuidelinesService());
    gh.factory<_i33.MedicalKnowledgeRepository>(
      () => _i34.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i33.MedicalKnowledgeRepository>(
      () => _i35.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i36.MedicalLlmAdapter>(() => _i36.MedicalLlmAdapter());
    gh.lazySingleton<_i37.MedicalScraperService>(
        () => _i38.MedicalScraperServiceImpl(
              gh<_i13.Dio>(),
              gh<_i8.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i39.MedicalStandardsService>(() =>
        _i40.MedicalStandardsServiceImpl(gh<_i31.MedicalContextProvider>()));
    gh.lazySingleton<_i41.MedicalWebSearchService>(
        () => _i42.MedicalWebSearchServiceImpl(gh<_i13.Dio>()));
    gh.lazySingleton<_i43.MedicationRepository>(
        () => _i44.IsarMedicationRepository(gh<_i20.Isar>()));
    await gh.lazySingletonAsync<_i14.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i20.Isar>(),
        gh<_i14.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i45.MockReportGenerationService>(
      () => _i45.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i46.ModelDownloadService>(
        () => _i46.ModelDownloadService());
    gh.lazySingleton<_i47.OAuthRepository>(() => _i47.OAuthRepositoryImpl(
          appAuth: gh<_i48.FlutterAppAuth>(),
          secureStorage: gh<_i49.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i50.OcrService>(() => _i50.MlKitOcrService());
    gh.factory<_i51.OnboardingCubit>(() => _i51.OnboardingCubit());
    gh.lazySingleton<_i52.PromptScrubber>(
        () => _i52.PromptScrubber(gh<_i20.Isar>()));
    gh.lazySingleton<_i53.ReportRepository>(
        () => _i54.IsarReportRepository(gh<_i20.Isar>()));
    gh.factory<_i55.RiskCalculator>(() => _i55.RiskCalculator());
    gh.factory<_i56.RiskCalculatorService>(() =>
        _i56.RiskCalculatorService(calculator: gh<_i55.RiskCalculator>()));
    gh.lazySingleton<_i57.SidetreeAnchorClient>(
        () => _i57.SidetreeAnchorClient.create());
    gh.lazySingleton<_i58.SsiRepository>(
        () => _i59.IsarSsiRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i60.SsiService>(() => _i61.SsiServiceImpl(
          gh<_i58.SsiRepository>(),
          gh<_i57.SidetreeAnchorClient>(),
        ));
    gh.factory<_i62.SymptomAnalysisStrategy>(
        () => _i62.SymptomAnalysisStrategy());
    gh.lazySingleton<_i63.SyncRepository>(() => _i63.SyncRepository(
          gh<_i16.FhirClient>(),
          gh<_i20.Isar>(),
          gh<_i49.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i31.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i64.UserProfileRepository>(
        () => _i65.UserProfileRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i66.UserProfileService>(
        () => _i66.UserProfileService(gh<_i64.UserProfileRepository>()));
    gh.lazySingleton<_i67.VectorStoreService>(() => _i68.IsarVectorStoreService(
          gh<_i14.MemoryGraph>(),
          gh<_i33.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i69.VitalAnalysisStrategy>(() => _i69.VitalAnalysisStrategy());
    gh.factory<_i70.VitalSignAnalyzer>(() => _i70.VitalSignAnalyzer());
    gh.lazySingleton<_i71.VitalSignRepository>(
        () => _i72.VitalSignRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i73.AllergyRepository>(
        () => _i74.IsarAllergyRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i75.AnonCredsService>(
        () => _i76.AnonCredsServiceImpl(gh<_i58.SsiRepository>()));
    gh.lazySingleton<_i77.AppointmentRepository>(
        () => _i78.IsarAppointmentRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i79.AuthRepository>(
        () => _i80.AuthRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i81.AuthService>(
        () => _i81.AuthServiceImpl(gh<_i15.EncryptionService>()));
    gh.lazySingleton<_i82.BleMedicalSharingService>(
        () => _i82.BleMedicalSharingService(
              gh<_i6.BleSharingService>(),
              gh<_i15.EncryptionService>(),
              gh<_i60.SsiService>(),
            ));
    gh.factory<_i83.CalendarImportCubit>(() => _i83.CalendarImportCubit(
          gh<_i9.CalendarRepository>(),
          gh<_i77.AppointmentRepository>(),
          gh<_i64.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i84.ClinicalReasonerService>(
        () => _i85.SymphonyClinicalReasonerService(
              gh<_i33.MedicalKnowledgeRepository>(),
              gh<_i52.PromptScrubber>(),
            ));
    gh.factory<_i86.EpsConnectionCubit>(() => _i86.EpsConnectionCubit(
          gh<_i47.OAuthRepository>(),
          gh<_i64.UserProfileRepository>(),
        ));
    gh.factory<_i87.FhirSyncCubit>(
        () => _i87.FhirSyncCubit(gh<_i63.SyncRepository>()));
    gh.lazySingleton<_i88.HealthContextService>(
        () => _i89.IsarHealthContextService(
              gh<_i71.VitalSignRepository>(),
              gh<_i43.MedicationRepository>(),
              gh<_i64.UserProfileRepository>(),
              gh<_i14.MemoryGraph>(),
            ));
    gh.factory<_i90.HealthImportCubit>(() => _i90.HealthImportCubit(
          gh<_i18.HealthDataImportService>(),
          gh<_i71.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i91.HealthRecordRepository>(
        () => _i92.HealthRecordRepositoryImpl(gh<_i20.Isar>()));
    gh.factory<_i23.LlmAdapter>(
      () => _i93.MockLlmAdapter(gh<_i52.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i23.LlmAdapter>(
      () => _i94.GeminiLlmAdapter(
        scrubber: gh<_i52.PromptScrubber>(),
        userProfileRepository: gh<_i64.UserProfileRepository>(),
        modelWrapper: gh<_i95.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i96.LlmAdapterFactory>(
        () => _i96.LlmAdapterFactory(gh<_i27.LlmSettingsRepository>()));
    gh.lazySingleton<_i97.LlmService>(() => _i98.GemmaLlmService(
          gh<_i67.VectorStoreService>(),
          gh<_i64.UserProfileRepository>(),
          gh<_i23.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i99.LlmSettingsCubit>(() => _i99.LlmSettingsCubit(
          gh<_i27.LlmSettingsRepository>(),
          gh<_i12.DeviceCapabilityService>(),
          gh<_i23.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i100.MedicalAssistantCubit>(() => _i100.MedicalAssistantCubit(
          llmAdapter: gh<_i36.MedicalLlmAdapter>(),
          analysisService: gh<_i30.MedicalAnalysisService>(),
          healthContextService: gh<_i88.HealthContextService>(),
          labInterpreter: gh<_i22.LabInterpreter>(),
          vitalAnalyzer: gh<_i70.VitalSignAnalyzer>(),
          riskCalculator: gh<_i55.RiskCalculator>(),
        ));
    gh.lazySingleton<_i101.MedicalResearchService>(
        () => _i101.MedicalResearchService(
              gh<_i41.MedicalWebSearchService>(),
              gh<_i37.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i102.PatientContextIndexer>(
      () => _i102.PatientContextIndexer(
        gh<_i20.Isar>(),
        gh<_i67.VectorStoreService>(),
        gh<_i91.HealthRecordRepository>(),
        gh<_i43.MedicationRepository>(),
        gh<_i73.AllergyRepository>(),
        gh<_i71.VitalSignRepository>(),
        gh<_i77.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i103.ReportGenerationService>(
        () => _i104.GemmaReportGenerationService(
              gh<_i23.LlmAdapter>(instanceName: 'gemma'),
              gh<_i67.VectorStoreService>(),
              gh<_i64.UserProfileRepository>(),
              gh<_i52.PromptScrubber>(),
            ));
    gh.lazySingleton<_i105.SmartSearchUseCase>(
        () => _i105.SmartSearchUseCase(gh<_i67.VectorStoreService>()));
    gh.factory<_i106.SyncCubit>(() => _i106.SyncCubit(
          gh<_i31.SyncService>(),
          gh<_i67.VectorStoreService>(),
        ));
    gh.factory<_i107.UserProfileCubit>(
        () => _i107.UserProfileCubit(gh<_i64.UserProfileRepository>()));
    gh.factory<_i108.AuthCubit>(() => _i108.AuthCubit(
          gh<_i79.AuthRepository>(),
          gh<_i15.EncryptionService>(),
          gh<_i5.BiometricService>(),
        ));
    gh.factory<_i109.AuthCubit>(() => _i109.AuthCubit(gh<_i81.AuthService>()));
    gh.factory<_i110.HealthRecordCubit>(() => _i110.HealthRecordCubit(
          gh<_i91.HealthRecordRepository>(),
          gh<_i17.FilePickerService>(),
          gh<_i19.ImagePickerService>(),
          gh<_i50.OcrService>(),
          gh<_i67.VectorStoreService>(),
        ));
    gh.lazySingleton<_i97.LlmService>(
      () => _i111.RagLlmService(
        gh<_i67.VectorStoreService>(),
        gh<_i101.MedicalResearchService>(),
        gh<_i64.UserProfileRepository>(),
        gh<_i23.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i112.MedicalIndexingService>(
        () => _i112.MedicalIndexingService(
              gh<_i33.MedicalKnowledgeRepository>(),
              gh<_i67.VectorStoreService>(),
              gh<_i102.PatientContextIndexer>(),
            ));
    gh.factory<_i113.ReportBloc>(() => _i113.ReportBloc(
          gh<_i53.ReportRepository>(),
          gh<_i103.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i114.FhirModule {}

class _$NetworkModule extends _i115.NetworkModule {}

class _$MemoryModule extends _i116.MemoryModule {}

class _$DatabaseModule extends _i117.DatabaseModule {}
