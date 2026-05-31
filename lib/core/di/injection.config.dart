// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i41;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i13;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i8;
import 'package:medical_standards/medical_standards.dart' as _i23;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i52;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i53;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i56;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i57;
import '../../features/auth/application/auth_cubit.dart' as _i81;
import '../../features/auth/domain/auth_service.dart' as _i58;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i59;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i9;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i3;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i64;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i11;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i82;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i65;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i66;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i10;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i12;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i36;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i78;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i24;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i15;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i48;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i17;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i68;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i67;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i16;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i70;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i69;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i83;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i25;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i26;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i49;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i84;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i74;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i14;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i22;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i21;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i60;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i62;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i20;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i77;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i61;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i63;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i27;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i29;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i31;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i4;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i72;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i28;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i30;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i32;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i33;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i34;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i73;
import '../../features/onboarding/application/sync_cubit.dart' as _i79;
import '../../features/reports/application/bloc/report_bloc.dart' as _i85;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i38;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i75;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i39;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i76;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i35;
import '../../features/settings/application/llm_settings_cubit.dart' as _i71;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i18;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i6;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i19;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i42;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i54;
import '../../features/ssi/domain/services/ssi_service.dart' as _i44;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i43;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i55;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i40;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i45;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i80;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i46;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i47;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i50;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i51;
import '../services/device_capability_service.dart' as _i5;
import '../services/privacy_anonymizer.dart' as _i37;
import 'database_module.dart' as _i88;
import 'memory_module.dart' as _i87;
import 'network_module.dart' as _i86;

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
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.BleSharingService>(() => _i3.BleSharingService());
    gh.lazySingleton<_i4.BotBypassHandler>(() => _i4.BotBypassHandler());
    gh.lazySingleton<_i5.DeviceCapabilityService>(
        () => _i5.DeviceCapabilityService());
    gh.lazySingleton<_i6.DeviceCapabilityService>(
        () => _i6.DeviceCapabilityService());
    gh.lazySingleton<_i7.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i8.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i9.EncryptionService>(() => _i9.EncryptionServiceImpl());
    gh.lazySingleton<_i10.FilePickerService>(
        () => _i10.FilePickerServiceImpl());
    gh.lazySingleton<_i11.HealthDataImportService>(
        () => _i11.HealthDataImportService());
    gh.lazySingleton<_i12.ImagePickerService>(
        () => _i12.ImagePickerServiceImpl());
    await gh.factoryAsync<_i13.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i14.LabAnalysisStrategy>(() => _i14.LabAnalysisStrategy());
    gh.lazySingleton<_i15.LlmAdapter>(
      () => _i16.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i15.LlmAdapter>(
      () => _i17.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i18.LlmSettingsRepository>(
        () => _i19.LlmSettingsRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i20.MedicalAnalysisService>(
        () => _i20.MedicalAnalysisService(
              labStrategy: gh<_i14.LabAnalysisStrategy>(),
              vitalStrategy: gh<_i21.VitalAnalysisStrategy>(),
              symptomStrategy: gh<_i22.SymptomAnalysisStrategy>(),
            ));
    gh.lazySingleton<_i23.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i24.MedicalKnowledgeRepository>(
      () => _i25.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i24.MedicalKnowledgeRepository>(
      () => _i26.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i27.MedicalScraperService>(
        () => _i28.MedicalScraperServiceImpl(
              gh<_i7.Dio>(),
              gh<_i4.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i29.MedicalStandardsService>(() =>
        _i30.MedicalStandardsServiceImpl(gh<_i23.MedicalContextProvider>()));
    gh.lazySingleton<_i31.MedicalWebSearchService>(
        () => _i32.MedicalWebSearchServiceImpl(gh<_i7.Dio>()));
    gh.lazySingleton<_i33.MedicationRepository>(
        () => _i34.IsarMedicationRepository(gh<_i13.Isar>()));
    await gh.lazySingletonAsync<_i8.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i13.Isar>(),
        gh<_i8.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i35.MockReportGenerationService>(
      () => _i35.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i36.OcrService>(() => _i36.MlKitOcrService());
    gh.lazySingleton<_i37.PromptScrubber>(
        () => _i37.PromptScrubber(gh<_i13.Isar>()));
    gh.lazySingleton<_i38.ReportRepository>(
        () => _i39.IsarReportRepository(gh<_i13.Isar>()));
    gh.lazySingleton<_i40.SidetreeAnchorClient>(() => _i40.SidetreeAnchorClient(
          ionNodeUrl: gh<String>(),
          httpClient: gh<_i41.Client>(),
        ));
    gh.lazySingleton<_i42.SsiRepository>(
        () => _i43.IsarSsiRepository(gh<_i13.Isar>()));
    gh.lazySingleton<_i44.SsiService>(() => _i45.SsiServiceImpl(
          gh<_i42.SsiRepository>(),
          gh<_i40.SidetreeAnchorClient>(),
        ));
    gh.factory<_i22.SymptomAnalysisStrategy>(
        () => _i22.SymptomAnalysisStrategy());
    gh.lazySingleton<_i23.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i46.UserProfileRepository>(
        () => _i47.UserProfileRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i48.VectorStoreService>(() => _i49.IsarVectorStoreService(
          gh<_i8.MemoryGraph>(),
          gh<_i24.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i21.VitalAnalysisStrategy>(() => _i21.VitalAnalysisStrategy());
    gh.lazySingleton<_i50.VitalSignRepository>(
        () => _i51.VitalSignRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i52.AllergyRepository>(
        () => _i53.AllergyRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i54.AnonCredsService>(
        () => _i55.AnonCredsServiceImpl(gh<_i42.SsiRepository>()));
    gh.lazySingleton<_i56.AppointmentRepository>(
        () => _i57.AppointmentRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i58.AuthService>(
        () => _i58.AuthServiceImpl(gh<_i9.EncryptionService>()));
    gh.lazySingleton<_i59.BleMedicalSharingService>(
        () => _i59.BleMedicalSharingService(
              gh<_i3.BleSharingService>(),
              gh<_i9.EncryptionService>(),
              gh<_i44.SsiService>(),
            ));
    gh.lazySingleton<_i60.ClinicalReasonerService>(() =>
        _i61.SymphonyClinicalReasonerService(
            gh<_i24.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i62.HealthContextService>(
        () => _i63.IsarHealthContextService(
              gh<_i50.VitalSignRepository>(),
              gh<_i33.MedicationRepository>(),
              gh<_i8.MemoryGraph>(),
            ));
    gh.factory<_i64.HealthImportCubit>(() => _i64.HealthImportCubit(
          gh<_i11.HealthDataImportService>(),
          gh<_i50.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i65.HealthRecordRepository>(
        () => _i66.HealthRecordRepositoryImpl(gh<_i13.Isar>()));
    gh.factory<_i15.LlmAdapter>(
      () => _i67.MockLlmAdapter(gh<_i37.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i15.LlmAdapter>(
      () => _i68.GeminiLlmAdapter(
        scrubber: gh<_i37.PromptScrubber>(),
        userProfileRepository: gh<_i46.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i69.LlmService>(() => _i70.GemmaLlmService(
          gh<_i48.VectorStoreService>(),
          gh<_i46.UserProfileRepository>(),
          gh<_i15.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i71.LlmSettingsCubit>(() => _i71.LlmSettingsCubit(
          gh<_i18.LlmSettingsRepository>(),
          gh<_i6.DeviceCapabilityService>(),
          gh<_i15.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i72.MedicalResearchService>(
        () => _i72.MedicalResearchService(
              gh<_i31.MedicalWebSearchService>(),
              gh<_i27.MedicalScraperService>(),
            ));
    gh.factory<_i73.OnboardingCubit>(
        () => _i73.OnboardingCubit(gh<_i46.UserProfileRepository>()));
    gh.lazySingleton<_i74.PatientContextIndexer>(
      () => _i74.PatientContextIndexer(
        gh<_i13.Isar>(),
        gh<_i48.VectorStoreService>(),
        gh<_i65.HealthRecordRepository>(),
        gh<_i33.MedicationRepository>(),
        gh<_i52.AllergyRepository>(),
        gh<_i50.VitalSignRepository>(),
        gh<_i56.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i75.ReportGenerationService>(
        () => _i76.GemmaReportGenerationService(
              gh<_i15.LlmAdapter>(instanceName: 'gemma'),
              gh<_i48.VectorStoreService>(),
              gh<_i46.UserProfileRepository>(),
              gh<_i37.PromptScrubber>(),
            ));
    gh.lazySingleton<_i77.RiskCalculator>(
        () => _i77.RiskCalculator(gh<_i46.UserProfileRepository>()));
    gh.lazySingleton<_i78.SmartSearchUseCase>(
        () => _i78.SmartSearchUseCase(gh<_i48.VectorStoreService>()));
    gh.factory<_i79.SyncCubit>(() => _i79.SyncCubit(
          gh<_i23.SyncService>(),
          gh<_i48.VectorStoreService>(),
        ));
    gh.factory<_i80.UserProfileCubit>(
        () => _i80.UserProfileCubit(gh<_i46.UserProfileRepository>()));
    gh.factory<_i81.AuthCubit>(() => _i81.AuthCubit(gh<_i58.AuthService>()));
    gh.factory<_i82.HealthRecordCubit>(() => _i82.HealthRecordCubit(
          gh<_i65.HealthRecordRepository>(),
          gh<_i10.FilePickerService>(),
          gh<_i12.ImagePickerService>(),
          gh<_i36.OcrService>(),
          gh<_i48.VectorStoreService>(),
        ));
    gh.lazySingleton<_i69.LlmService>(
      () => _i83.RagLlmService(
        gh<_i48.VectorStoreService>(),
        gh<_i72.MedicalResearchService>(),
        gh<_i46.UserProfileRepository>(),
        gh<_i15.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i84.MedicalIndexingService>(
        () => _i84.MedicalIndexingService(
              gh<_i24.MedicalKnowledgeRepository>(),
              gh<_i48.VectorStoreService>(),
              gh<_i74.PatientContextIndexer>(),
            ));
    gh.factory<_i85.ReportBloc>(() => _i85.ReportBloc(
          gh<_i38.ReportRepository>(),
          gh<_i75.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i86.NetworkModule {}

class _$MemoryModule extends _i87.MemoryModule {}

class _$DatabaseModule extends _i88.DatabaseModule {}
