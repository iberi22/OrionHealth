// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i10;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i52;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i7;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i17;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i11;
import 'package:medical_standards/medical_standards.dart' as _i25;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i60;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i61;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i64;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i65;
import '../../features/auth/application/auth_cubit.dart' as _i93;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i92;
import '../../features/auth/domain/auth_service.dart' as _i68;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i66;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i67;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i3;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i69;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i12;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i4;
import '../../features/calendar_import/data/calendar_repository.dart' as _i6;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i70;
import '../../features/eps_connection/data/oauth_repository.dart' as _i39;
import '../../features/eps_connection/domain/eps_connection_cubit.dart' as _i73;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i77;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i15;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i94;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i78;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i79;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i14;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i16;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i40;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i89;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i26;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i19;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i55;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i21;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i80;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i81;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i20;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i83;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i82;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i95;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i28;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i27;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i56;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i24;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i96;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i38;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i86;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i18;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i50;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i57;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i71;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i75;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i72;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i76;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i29;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i31;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i33;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i5;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i85;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i30;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i32;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i34;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i35;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i36;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i41;
import '../../features/onboarding/application/sync_cubit.dart' as _i90;
import '../../features/reports/application/bloc/report_bloc.dart' as _i97;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i43;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i87;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i44;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i88;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i37;
import '../../features/settings/application/llm_settings_cubit.dart' as _i84;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i22;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i8;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i23;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i46;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i62;
import '../../features/ssi/domain/services/ssi_service.dart' as _i48;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i47;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i63;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i45;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i49;
import '../../features/sync/data/fhir_client.dart' as _i13;
import '../../features/sync/data/sync_repository.dart' as _i51;
import '../../features/sync/domain/sync_cubit.dart' as _i74;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i91;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i53;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i54;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i58;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i59;
import '../services/device_capability_service.dart' as _i9;
import '../services/privacy_anonymizer.dart' as _i42;
import 'database_module.dart' as _i101;
import 'fhir_module.dart' as _i98;
import 'memory_module.dart' as _i100;
import 'network_module.dart' as _i99;

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
    gh.lazySingleton<_i19.LlmAdapter>(
      () => _i20.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i19.LlmAdapter>(
      () => _i21.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i22.LlmSettingsRepository>(
        () => _i23.LlmSettingsRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i24.LocalLlmService>(() => _i24.LocalLlmService());
    gh.lazySingleton<_i25.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i26.MedicalKnowledgeRepository>(
      () => _i27.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i26.MedicalKnowledgeRepository>(
      () => _i28.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i29.MedicalScraperService>(
        () => _i30.MedicalScraperServiceImpl(
              gh<_i10.Dio>(),
              gh<_i5.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i31.MedicalStandardsService>(() =>
        _i32.MedicalStandardsServiceImpl(gh<_i25.MedicalContextProvider>()));
    gh.lazySingleton<_i33.MedicalWebSearchService>(
        () => _i34.MedicalWebSearchServiceImpl(gh<_i10.Dio>()));
    gh.lazySingleton<_i35.MedicationRepository>(
        () => _i36.IsarMedicationRepository(gh<_i17.Isar>()));
    await gh.lazySingletonAsync<_i11.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i17.Isar>(),
        gh<_i11.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i37.MockReportGenerationService>(
      () => _i37.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i38.ModelDownloadService>(
        () => _i38.ModelDownloadService());
    gh.lazySingleton<_i39.OAuthRepository>(() => _i39.OAuthRepositoryImpl());
    gh.lazySingleton<_i40.OcrService>(() => _i40.MlKitOcrService());
    gh.factory<_i41.OnboardingCubit>(() => _i41.OnboardingCubit());
    gh.lazySingleton<_i42.PromptScrubber>(
        () => _i42.PromptScrubber(gh<_i17.Isar>()));
    gh.lazySingleton<_i43.ReportRepository>(
        () => _i44.IsarReportRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i45.SidetreeAnchorClient>(
        () => _i45.SidetreeAnchorClient.create());
    gh.lazySingleton<_i46.SsiRepository>(
        () => _i47.IsarSsiRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i48.SsiService>(() => _i49.SsiServiceImpl(
          gh<_i46.SsiRepository>(),
          gh<_i45.SidetreeAnchorClient>(),
        ));
    gh.factory<_i50.SymptomAnalysisStrategy>(
        () => _i50.SymptomAnalysisStrategy());
    gh.lazySingleton<_i51.SyncRepository>(() => _i51.SyncRepository(
          gh<_i13.FhirClient>(),
          gh<_i17.Isar>(),
          gh<_i52.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i25.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i53.UserProfileRepository>(
        () => _i54.UserProfileRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i55.VectorStoreService>(() => _i56.IsarVectorStoreService(
          gh<_i11.MemoryGraph>(),
          gh<_i26.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i57.VitalAnalysisStrategy>(() => _i57.VitalAnalysisStrategy());
    gh.lazySingleton<_i58.VitalSignRepository>(
        () => _i59.VitalSignRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i60.AllergyRepository>(
        () => _i61.IsarAllergyRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i62.AnonCredsService>(
        () => _i63.AnonCredsServiceImpl(gh<_i46.SsiRepository>()));
    gh.lazySingleton<_i64.AppointmentRepository>(
        () => _i65.IsarAppointmentRepository(gh<_i17.Isar>()));
    gh.lazySingleton<_i66.AuthRepository>(
        () => _i67.AuthRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i68.AuthService>(
        () => _i68.AuthServiceImpl(gh<_i12.EncryptionService>()));
    gh.lazySingleton<_i69.BleMedicalSharingService>(
        () => _i69.BleMedicalSharingService(
              gh<_i4.BleSharingService>(),
              gh<_i12.EncryptionService>(),
              gh<_i48.SsiService>(),
            ));
    gh.factory<_i70.CalendarImportCubit>(() => _i70.CalendarImportCubit(
          gh<_i6.CalendarRepository>(),
          gh<_i64.AppointmentRepository>(),
          gh<_i53.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i71.ClinicalReasonerService>(
        () => _i72.SymphonyClinicalReasonerService(
              gh<_i26.MedicalKnowledgeRepository>(),
              gh<_i42.PromptScrubber>(),
            ));
    gh.factory<_i73.EpsConnectionCubit>(() => _i73.EpsConnectionCubit(
          gh<_i39.OAuthRepository>(),
          gh<_i53.UserProfileRepository>(),
        ));
    gh.factory<_i74.FhirSyncCubit>(
        () => _i74.FhirSyncCubit(gh<_i51.SyncRepository>()));
    gh.lazySingleton<_i75.HealthContextService>(
        () => _i76.IsarHealthContextService(
              gh<_i58.VitalSignRepository>(),
              gh<_i35.MedicationRepository>(),
              gh<_i11.MemoryGraph>(),
            ));
    gh.factory<_i77.HealthImportCubit>(() => _i77.HealthImportCubit(
          gh<_i15.HealthDataImportService>(),
          gh<_i58.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i78.HealthRecordRepository>(
        () => _i79.HealthRecordRepositoryImpl(gh<_i17.Isar>()));
    gh.lazySingleton<_i19.LlmAdapter>(
      () => _i80.GeminiLlmAdapter(
        scrubber: gh<_i42.PromptScrubber>(),
        userProfileRepository: gh<_i53.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i19.LlmAdapter>(
      () => _i81.MockLlmAdapter(gh<_i42.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i82.LlmService>(() => _i83.GemmaLlmService(
          gh<_i55.VectorStoreService>(),
          gh<_i53.UserProfileRepository>(),
          gh<_i19.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i84.LlmSettingsCubit>(() => _i84.LlmSettingsCubit(
          gh<_i22.LlmSettingsRepository>(),
          gh<_i8.DeviceCapabilityService>(),
          gh<_i19.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i85.MedicalResearchService>(
        () => _i85.MedicalResearchService(
              gh<_i33.MedicalWebSearchService>(),
              gh<_i29.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i86.PatientContextIndexer>(
      () => _i86.PatientContextIndexer(
        gh<_i17.Isar>(),
        gh<_i55.VectorStoreService>(),
        gh<_i78.HealthRecordRepository>(),
        gh<_i35.MedicationRepository>(),
        gh<_i60.AllergyRepository>(),
        gh<_i58.VitalSignRepository>(),
        gh<_i64.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i87.ReportGenerationService>(
        () => _i88.GemmaReportGenerationService(
              gh<_i19.LlmAdapter>(instanceName: 'gemma'),
              gh<_i55.VectorStoreService>(),
              gh<_i53.UserProfileRepository>(),
              gh<_i42.PromptScrubber>(),
            ));
    gh.lazySingleton<_i89.SmartSearchUseCase>(
        () => _i89.SmartSearchUseCase(gh<_i55.VectorStoreService>()));
    gh.factory<_i90.SyncCubit>(() => _i90.SyncCubit(
          gh<_i25.SyncService>(),
          gh<_i55.VectorStoreService>(),
        ));
    gh.factory<_i91.UserProfileCubit>(
        () => _i91.UserProfileCubit(gh<_i53.UserProfileRepository>()));
    gh.factory<_i92.AuthCubit>(() => _i92.AuthCubit(
          gh<_i66.AuthRepository>(),
          gh<_i12.EncryptionService>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i93.AuthCubit>(() => _i93.AuthCubit(gh<_i68.AuthService>()));
    gh.factory<_i94.HealthRecordCubit>(() => _i94.HealthRecordCubit(
          gh<_i78.HealthRecordRepository>(),
          gh<_i14.FilePickerService>(),
          gh<_i16.ImagePickerService>(),
          gh<_i40.OcrService>(),
          gh<_i55.VectorStoreService>(),
        ));
    gh.lazySingleton<_i82.LlmService>(
      () => _i95.RagLlmService(
        gh<_i55.VectorStoreService>(),
        gh<_i85.MedicalResearchService>(),
        gh<_i53.UserProfileRepository>(),
        gh<_i19.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i96.MedicalIndexingService>(
        () => _i96.MedicalIndexingService(
              gh<_i26.MedicalKnowledgeRepository>(),
              gh<_i55.VectorStoreService>(),
              gh<_i86.PatientContextIndexer>(),
            ));
    gh.factory<_i97.ReportBloc>(() => _i97.ReportBloc(
          gh<_i43.ReportRepository>(),
          gh<_i87.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i98.FhirModule {}

class _$NetworkModule extends _i99.NetworkModule {}

class _$MemoryModule extends _i100.MemoryModule {}

class _$DatabaseModule extends _i101.DatabaseModule {}
