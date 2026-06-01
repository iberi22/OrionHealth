// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i15;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i10;
import 'package:medical_standards/medical_standards.dart' as _i23;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i55;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i56;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i59;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i60;
import '../../features/auth/application/auth_cubit.dart' as _i86;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i85;
import '../../features/auth/domain/auth_service.dart' as _i63;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i61;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i62;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i3;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i64;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i11;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i4;
import '../../features/calendar_import/data/calendar_repository.dart' as _i6;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i65;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i70;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i13;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i87;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i71;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i72;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i12;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i14;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i37;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i82;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i24;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i17;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i50;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i18;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i74;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i73;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i19;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i76;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i75;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i88;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i25;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i26;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i51;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i22;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i89;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i36;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i79;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i16;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i47;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i52;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i66;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i68;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i67;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i69;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i27;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i29;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i31;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i5;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i78;
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
import '../../features/onboarding/application/onboarding_cubit.dart' as _i38;
import '../../features/onboarding/application/sync_cubit.dart' as _i83;
import '../../features/reports/application/bloc/report_bloc.dart' as _i90;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i40;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i80;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i41;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i81;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i35;
import '../../features/settings/application/llm_settings_cubit.dart' as _i77;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i20;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i8;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i21;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i43;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i57;
import '../../features/ssi/domain/services/ssi_service.dart' as _i45;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i44;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i58;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i42;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i46;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i84;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i48;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i49;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i53;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i54;
import '../services/device_capability_service.dart' as _i7;
import '../services/privacy_anonymizer.dart' as _i39;
import 'database_module.dart' as _i93;
import 'memory_module.dart' as _i92;
import 'network_module.dart' as _i91;

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
    gh.lazySingleton<_i3.BiometricService>(() => _i3.BiometricService());
    gh.lazySingleton<_i4.BleSharingService>(() => _i4.BleSharingService());
    gh.lazySingleton<_i5.BotBypassHandler>(() => _i5.BotBypassHandler());
    gh.lazySingleton<_i6.CalendarRepository>(() => _i6.CalendarRepository());
    gh.lazySingleton<_i7.DeviceCapabilityService>(
        () => _i7.DeviceCapabilityService());
    gh.lazySingleton<_i8.DeviceCapabilityService>(
        () => _i8.DeviceCapabilityService());
    gh.lazySingleton<_i9.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i10.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i11.EncryptionService>(() => _i11.EncryptionService());
    gh.lazySingleton<_i12.FilePickerService>(
        () => _i12.FilePickerServiceImpl());
    gh.lazySingleton<_i13.HealthDataImportService>(
        () => _i13.HealthDataImportService());
    gh.lazySingleton<_i14.ImagePickerService>(
        () => _i14.ImagePickerServiceImpl());
    await gh.factoryAsync<_i15.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i16.LabAnalysisStrategy>(() => _i16.LabAnalysisStrategy());
    gh.lazySingleton<_i17.LlmAdapter>(
      () => _i18.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i17.LlmAdapter>(
      () => _i19.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i20.LlmSettingsRepository>(
        () => _i21.LlmSettingsRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i22.LocalLlmService>(() => _i22.LocalLlmService());
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
              gh<_i9.Dio>(),
              gh<_i5.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i29.MedicalStandardsService>(() =>
        _i30.MedicalStandardsServiceImpl(gh<_i23.MedicalContextProvider>()));
    gh.lazySingleton<_i31.MedicalWebSearchService>(
        () => _i32.MedicalWebSearchServiceImpl(gh<_i9.Dio>()));
    gh.lazySingleton<_i33.MedicationRepository>(
        () => _i34.IsarMedicationRepository(gh<_i15.Isar>()));
    await gh.lazySingletonAsync<_i10.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i15.Isar>(),
        gh<_i10.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i35.MockReportGenerationService>(
      () => _i35.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i36.ModelDownloadService>(
        () => _i36.ModelDownloadService());
    gh.lazySingleton<_i37.OcrService>(() => _i37.MlKitOcrService());
    gh.factory<_i38.OnboardingCubit>(() => _i38.OnboardingCubit());
    gh.lazySingleton<_i39.PromptScrubber>(
        () => _i39.PromptScrubber(gh<_i15.Isar>()));
    gh.lazySingleton<_i40.ReportRepository>(
        () => _i41.IsarReportRepository(gh<_i15.Isar>()));
    gh.lazySingleton<_i42.SidetreeAnchorClient>(
        () => _i42.SidetreeAnchorClient.create());
    gh.lazySingleton<_i43.SsiRepository>(
        () => _i44.IsarSsiRepository(gh<_i15.Isar>()));
    gh.lazySingleton<_i45.SsiService>(() => _i46.SsiServiceImpl(
          gh<_i43.SsiRepository>(),
          gh<_i42.SidetreeAnchorClient>(),
        ));
    gh.factory<_i47.SymptomAnalysisStrategy>(
        () => _i47.SymptomAnalysisStrategy());
    gh.lazySingleton<_i23.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i48.UserProfileRepository>(
        () => _i49.UserProfileRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i50.VectorStoreService>(() => _i51.IsarVectorStoreService(
          gh<_i10.MemoryGraph>(),
          gh<_i24.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i52.VitalAnalysisStrategy>(() => _i52.VitalAnalysisStrategy());
    gh.lazySingleton<_i53.VitalSignRepository>(
        () => _i54.VitalSignRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i55.AllergyRepository>(
        () => _i56.IsarAllergyRepository(gh<_i15.Isar>()));
    gh.lazySingleton<_i57.AnonCredsService>(
        () => _i58.AnonCredsServiceImpl(gh<_i43.SsiRepository>()));
    gh.lazySingleton<_i59.AppointmentRepository>(
        () => _i60.IsarAppointmentRepository(gh<_i15.Isar>()));
    gh.lazySingleton<_i61.AuthRepository>(
        () => _i62.AuthRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i63.AuthService>(
        () => _i63.AuthServiceImpl(gh<_i11.EncryptionService>()));
    gh.lazySingleton<_i64.BleMedicalSharingService>(
        () => _i64.BleMedicalSharingService(
              gh<_i4.BleSharingService>(),
              gh<_i11.EncryptionService>(),
              gh<_i45.SsiService>(),
            ));
    gh.factory<_i65.CalendarImportCubit>(() => _i65.CalendarImportCubit(
          gh<_i6.CalendarRepository>(),
          gh<_i59.AppointmentRepository>(),
          gh<_i48.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i66.ClinicalReasonerService>(() =>
        _i67.SymphonyClinicalReasonerService(
            gh<_i24.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i68.HealthContextService>(
        () => _i69.IsarHealthContextService(
              gh<_i53.VitalSignRepository>(),
              gh<_i33.MedicationRepository>(),
              gh<_i10.MemoryGraph>(),
            ));
    gh.factory<_i70.HealthImportCubit>(() => _i70.HealthImportCubit(
          gh<_i13.HealthDataImportService>(),
          gh<_i53.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i71.HealthRecordRepository>(
        () => _i72.HealthRecordRepositoryImpl(gh<_i15.Isar>()));
    gh.factory<_i17.LlmAdapter>(
      () => _i73.MockLlmAdapter(gh<_i39.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i17.LlmAdapter>(
      () => _i74.GeminiLlmAdapter(
        scrubber: gh<_i39.PromptScrubber>(),
        userProfileRepository: gh<_i48.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i75.LlmService>(() => _i76.GemmaLlmService(
          gh<_i50.VectorStoreService>(),
          gh<_i48.UserProfileRepository>(),
          gh<_i17.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i77.LlmSettingsCubit>(() => _i77.LlmSettingsCubit(
          gh<_i20.LlmSettingsRepository>(),
          gh<_i8.DeviceCapabilityService>(),
          gh<_i17.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i78.MedicalResearchService>(
        () => _i78.MedicalResearchService(
              gh<_i31.MedicalWebSearchService>(),
              gh<_i27.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i79.PatientContextIndexer>(
      () => _i79.PatientContextIndexer(
        gh<_i15.Isar>(),
        gh<_i50.VectorStoreService>(),
        gh<_i71.HealthRecordRepository>(),
        gh<_i33.MedicationRepository>(),
        gh<_i55.AllergyRepository>(),
        gh<_i53.VitalSignRepository>(),
        gh<_i59.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i80.ReportGenerationService>(
        () => _i81.GemmaReportGenerationService(
              gh<_i17.LlmAdapter>(instanceName: 'gemma'),
              gh<_i50.VectorStoreService>(),
              gh<_i48.UserProfileRepository>(),
              gh<_i39.PromptScrubber>(),
            ));
    gh.lazySingleton<_i82.SmartSearchUseCase>(
        () => _i82.SmartSearchUseCase(gh<_i50.VectorStoreService>()));
    gh.factory<_i83.SyncCubit>(() => _i83.SyncCubit(
          gh<_i23.SyncService>(),
          gh<_i50.VectorStoreService>(),
        ));
    gh.factory<_i84.UserProfileCubit>(
        () => _i84.UserProfileCubit(gh<_i48.UserProfileRepository>()));
    gh.factory<_i85.AuthCubit>(() => _i85.AuthCubit(
          gh<_i61.AuthRepository>(),
          gh<_i11.EncryptionService>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i86.AuthCubit>(() => _i86.AuthCubit(gh<_i63.AuthService>()));
    gh.factory<_i87.HealthRecordCubit>(() => _i87.HealthRecordCubit(
          gh<_i71.HealthRecordRepository>(),
          gh<_i12.FilePickerService>(),
          gh<_i14.ImagePickerService>(),
          gh<_i37.OcrService>(),
          gh<_i50.VectorStoreService>(),
        ));
    gh.lazySingleton<_i75.LlmService>(
      () => _i88.RagLlmService(
        gh<_i50.VectorStoreService>(),
        gh<_i78.MedicalResearchService>(),
        gh<_i48.UserProfileRepository>(),
        gh<_i17.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i89.MedicalIndexingService>(
        () => _i89.MedicalIndexingService(
              gh<_i24.MedicalKnowledgeRepository>(),
              gh<_i50.VectorStoreService>(),
              gh<_i79.PatientContextIndexer>(),
            ));
    gh.factory<_i90.ReportBloc>(() => _i90.ReportBloc(
          gh<_i40.ReportRepository>(),
          gh<_i80.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i91.NetworkModule {}

class _$MemoryModule extends _i92.MemoryModule {}

class _$DatabaseModule extends _i93.DatabaseModule {}
