// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i14;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i9;
import 'package:medical_standards/medical_standards.dart' as _i22;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i54;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i55;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i58;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i59;
import '../../features/auth/application/auth_cubit.dart' as _i83;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i84;
import '../../features/auth/domain/auth_service.dart' as _i62;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i60;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i61;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i3;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i63;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i10;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i4;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i68;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i12;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i85;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i69;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i70;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i11;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i13;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i36;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i80;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i23;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i16;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i49;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i17;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i72;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i71;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i18;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i74;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i73;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i86;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i24;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i25;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i50;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i21;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i87;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i35;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i77;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i15;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i46;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i51;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i64;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i66;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i65;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i67;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i26;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i28;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i30;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i5;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i76;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i27;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i29;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i31;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i32;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i33;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i37;
import '../../features/onboarding/application/sync_cubit.dart' as _i81;
import '../../features/reports/application/bloc/report_bloc.dart' as _i88;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i39;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i78;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i40;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i79;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i34;
import '../../features/settings/application/llm_settings_cubit.dart' as _i75;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i19;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i7;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i20;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i42;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i56;
import '../../features/ssi/domain/services/ssi_service.dart' as _i44;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i43;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i57;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i41;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i45;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i82;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i47;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i48;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i52;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i53;
import '../services/device_capability_service.dart' as _i6;
import '../services/privacy_anonymizer.dart' as _i38;
import 'database_module.dart' as _i91;
import 'memory_module.dart' as _i90;
import 'network_module.dart' as _i89;

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
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.BiometricService>(() => _i3.BiometricService());
    gh.lazySingleton<_i4.BleSharingService>(() => _i4.BleSharingService());
    gh.lazySingleton<_i5.BotBypassHandler>(() => _i5.BotBypassHandler());
    gh.lazySingleton<_i6.DeviceCapabilityService>(
        () => _i6.DeviceCapabilityService());
    gh.lazySingleton<_i7.DeviceCapabilityService>(
        () => _i7.DeviceCapabilityService());
    gh.lazySingleton<_i8.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i9.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i10.EncryptionService>(() => _i10.EncryptionService());
    gh.lazySingleton<_i11.FilePickerService>(
        () => _i11.FilePickerServiceImpl());
    gh.lazySingleton<_i12.HealthDataImportService>(
        () => _i12.HealthDataImportService());
    gh.lazySingleton<_i13.ImagePickerService>(
        () => _i13.ImagePickerServiceImpl());
    await gh.factoryAsync<_i14.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i15.LabAnalysisStrategy>(() => _i15.LabAnalysisStrategy());
    gh.lazySingleton<_i16.LlmAdapter>(
      () => _i17.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i16.LlmAdapter>(
      () => _i18.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i19.LlmSettingsRepository>(
        () => _i20.LlmSettingsRepositoryImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i21.LocalLlmService>(() => _i21.LocalLlmService());
    gh.lazySingleton<_i22.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i23.MedicalKnowledgeRepository>(
      () => _i24.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i23.MedicalKnowledgeRepository>(
      () => _i25.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i26.MedicalScraperService>(
        () => _i27.MedicalScraperServiceImpl(
              gh<_i8.Dio>(),
              gh<_i5.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i28.MedicalStandardsService>(() =>
        _i29.MedicalStandardsServiceImpl(gh<_i22.MedicalContextProvider>()));
    gh.lazySingleton<_i30.MedicalWebSearchService>(
        () => _i31.MedicalWebSearchServiceImpl(gh<_i8.Dio>()));
    gh.lazySingleton<_i32.MedicationRepository>(
        () => _i33.IsarMedicationRepository(gh<_i14.Isar>()));
    await gh.lazySingletonAsync<_i9.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i14.Isar>(),
        gh<_i9.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i34.MockReportGenerationService>(
      () => _i34.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i35.ModelDownloadService>(
        () => _i35.ModelDownloadService());
    gh.lazySingleton<_i36.OcrService>(() => _i36.MlKitOcrService());
    gh.factory<_i37.OnboardingCubit>(() => _i37.OnboardingCubit());
    gh.lazySingleton<_i38.PromptScrubber>(
        () => _i38.PromptScrubber(gh<_i14.Isar>()));
    gh.lazySingleton<_i39.ReportRepository>(
        () => _i40.IsarReportRepository(gh<_i14.Isar>()));
    gh.lazySingleton<_i41.SidetreeAnchorClient>(
        () => _i41.SidetreeAnchorClient.create());
    gh.lazySingleton<_i42.SsiRepository>(
        () => _i43.IsarSsiRepository(gh<_i14.Isar>()));
    gh.lazySingleton<_i44.SsiService>(() => _i45.SsiServiceImpl(
          gh<_i42.SsiRepository>(),
          gh<_i41.SidetreeAnchorClient>(),
        ));
    gh.factory<_i46.SymptomAnalysisStrategy>(
        () => _i46.SymptomAnalysisStrategy());
    gh.lazySingleton<_i22.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i47.UserProfileRepository>(
        () => _i48.UserProfileRepositoryImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i49.VectorStoreService>(() => _i50.IsarVectorStoreService(
          gh<_i9.MemoryGraph>(),
          gh<_i23.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i51.VitalAnalysisStrategy>(() => _i51.VitalAnalysisStrategy());
    gh.lazySingleton<_i52.VitalSignRepository>(
        () => _i53.VitalSignRepositoryImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i54.AllergyRepository>(
        () => _i55.IsarAllergyRepository(gh<_i14.Isar>()));
    gh.lazySingleton<_i56.AnonCredsService>(
        () => _i57.AnonCredsServiceImpl(gh<_i42.SsiRepository>()));
    gh.lazySingleton<_i58.AppointmentRepository>(
        () => _i59.IsarAppointmentRepository(gh<_i14.Isar>()));
    gh.lazySingleton<_i60.AuthRepository>(
        () => _i61.AuthRepositoryImpl(gh<_i14.Isar>()));
    gh.lazySingleton<_i62.AuthService>(
        () => _i62.AuthServiceImpl(gh<_i10.EncryptionService>()));
    gh.lazySingleton<_i63.BleMedicalSharingService>(
        () => _i63.BleMedicalSharingService(
              gh<_i4.BleSharingService>(),
              gh<_i10.EncryptionService>(),
              gh<_i44.SsiService>(),
            ));
    gh.lazySingleton<_i64.ClinicalReasonerService>(() =>
        _i65.SymphonyClinicalReasonerService(
            gh<_i23.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i66.HealthContextService>(
        () => _i67.IsarHealthContextService(
              gh<_i52.VitalSignRepository>(),
              gh<_i32.MedicationRepository>(),
              gh<_i9.MemoryGraph>(),
            ));
    gh.factory<_i68.HealthImportCubit>(() => _i68.HealthImportCubit(
          gh<_i12.HealthDataImportService>(),
          gh<_i52.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i69.HealthRecordRepository>(
        () => _i70.HealthRecordRepositoryImpl(gh<_i14.Isar>()));
    gh.factory<_i16.LlmAdapter>(
      () => _i71.MockLlmAdapter(gh<_i38.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i16.LlmAdapter>(
      () => _i72.GeminiLlmAdapter(
        scrubber: gh<_i38.PromptScrubber>(),
        userProfileRepository: gh<_i47.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i73.LlmService>(() => _i74.GemmaLlmService(
          gh<_i49.VectorStoreService>(),
          gh<_i47.UserProfileRepository>(),
          gh<_i16.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i75.LlmSettingsCubit>(() => _i75.LlmSettingsCubit(
          gh<_i19.LlmSettingsRepository>(),
          gh<_i7.DeviceCapabilityService>(),
          gh<_i16.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i76.MedicalResearchService>(
        () => _i76.MedicalResearchService(
              gh<_i30.MedicalWebSearchService>(),
              gh<_i26.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i77.PatientContextIndexer>(
      () => _i77.PatientContextIndexer(
        gh<_i14.Isar>(),
        gh<_i49.VectorStoreService>(),
        gh<_i69.HealthRecordRepository>(),
        gh<_i32.MedicationRepository>(),
        gh<_i54.AllergyRepository>(),
        gh<_i52.VitalSignRepository>(),
        gh<_i58.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i78.ReportGenerationService>(
        () => _i79.GemmaReportGenerationService(
              gh<_i16.LlmAdapter>(instanceName: 'gemma'),
              gh<_i49.VectorStoreService>(),
              gh<_i47.UserProfileRepository>(),
              gh<_i38.PromptScrubber>(),
            ));
    gh.lazySingleton<_i80.SmartSearchUseCase>(
        () => _i80.SmartSearchUseCase(gh<_i49.VectorStoreService>()));
    gh.factory<_i81.SyncCubit>(() => _i81.SyncCubit(
          gh<_i22.SyncService>(),
          gh<_i49.VectorStoreService>(),
        ));
    gh.factory<_i82.UserProfileCubit>(
        () => _i82.UserProfileCubit(gh<_i47.UserProfileRepository>()));
    gh.factory<_i83.AuthCubit>(() => _i83.AuthCubit(gh<_i62.AuthService>()));
    gh.factory<_i84.AuthCubit>(() => _i84.AuthCubit(
          gh<_i60.AuthRepository>(),
          gh<_i10.EncryptionService>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i85.HealthRecordCubit>(() => _i85.HealthRecordCubit(
          gh<_i69.HealthRecordRepository>(),
          gh<_i11.FilePickerService>(),
          gh<_i13.ImagePickerService>(),
          gh<_i36.OcrService>(),
          gh<_i49.VectorStoreService>(),
        ));
    gh.lazySingleton<_i73.LlmService>(
      () => _i86.RagLlmService(
        gh<_i49.VectorStoreService>(),
        gh<_i76.MedicalResearchService>(),
        gh<_i47.UserProfileRepository>(),
        gh<_i16.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i87.MedicalIndexingService>(
        () => _i87.MedicalIndexingService(
              gh<_i23.MedicalKnowledgeRepository>(),
              gh<_i49.VectorStoreService>(),
              gh<_i77.PatientContextIndexer>(),
            ));
    gh.factory<_i88.ReportBloc>(() => _i88.ReportBloc(
          gh<_i39.ReportRepository>(),
          gh<_i78.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i89.NetworkModule {}

class _$MemoryModule extends _i90.MemoryModule {}

class _$DatabaseModule extends _i91.DatabaseModule {}
