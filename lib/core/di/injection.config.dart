// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i37;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i13;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i8;
import 'package:medical_standards/medical_standards.dart' as _i19;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i48;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i49;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i52;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i53;
import '../../features/auth/application/auth_cubit.dart' as _i77;
import '../../features/auth/domain/auth_service.dart' as _i54;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i55;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i9;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i3;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i60;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i11;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i78;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i61;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i62;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i10;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i12;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i32;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i74;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i20;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i14;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i44;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i16;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i64;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i63;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i15;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i66;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i65;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i79;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i22;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i21;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i45;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i68;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i56;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i58;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i73;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i57;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i59;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i23;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i25;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i27;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i4;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i69;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i24;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i26;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i28;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i29;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i30;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i70;
import '../../features/onboarding/application/sync_cubit.dart' as _i75;
import '../../features/reports/application/bloc/report_bloc.dart' as _i80;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i34;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i71;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i35;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i72;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i31;
import '../../features/settings/application/llm_settings_cubit.dart' as _i67;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i17;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i6;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i18;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i38;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i50;
import '../../features/ssi/domain/services/ssi_service.dart' as _i40;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i39;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i51;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i36;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i41;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i76;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i42;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i43;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i46;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i47;
import '../services/device_capability_service.dart' as _i5;
import '../services/privacy_anonymizer.dart' as _i33;
import 'database_module.dart' as _i83;
import 'memory_module.dart' as _i82;
import 'network_module.dart' as _i81;

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
    gh.lazySingleton<_i14.LlmAdapter>(
      () => _i15.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i14.LlmAdapter>(
      () => _i16.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i17.LlmSettingsRepository>(
        () => _i18.LlmSettingsRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i19.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i20.MedicalKnowledgeRepository>(
      () => _i21.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i20.MedicalKnowledgeRepository>(
      () => _i22.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i23.MedicalScraperService>(
        () => _i24.MedicalScraperServiceImpl(
              gh<_i7.Dio>(),
              gh<_i4.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i25.MedicalStandardsService>(() =>
        _i26.MedicalStandardsServiceImpl(gh<_i19.MedicalContextProvider>()));
    gh.lazySingleton<_i27.MedicalWebSearchService>(
        () => _i28.MedicalWebSearchServiceImpl(gh<_i7.Dio>()));
    gh.lazySingleton<_i29.MedicationRepository>(
        () => _i30.IsarMedicationRepository(gh<_i13.Isar>()));
    await gh.lazySingletonAsync<_i8.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i13.Isar>(),
        gh<_i8.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i31.MockReportGenerationService>(
      () => _i31.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i32.OcrService>(() => _i32.MlKitOcrService());
    gh.lazySingleton<_i33.PromptScrubber>(
        () => _i33.PromptScrubber(gh<_i13.Isar>()));
    gh.lazySingleton<_i34.ReportRepository>(
        () => _i35.IsarReportRepository(gh<_i13.Isar>()));
    gh.lazySingleton<_i36.SidetreeAnchorClient>(() => _i36.SidetreeAnchorClient(
          ionNodeUrl: gh<String>(),
          httpClient: gh<_i37.Client>(),
        ));
    gh.lazySingleton<_i38.SsiRepository>(
        () => _i39.IsarSsiRepository(gh<_i13.Isar>()));
    gh.lazySingleton<_i40.SsiService>(() => _i41.SsiServiceImpl(
          gh<_i38.SsiRepository>(),
          gh<_i36.SidetreeAnchorClient>(),
        ));
    gh.lazySingleton<_i19.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i42.UserProfileRepository>(
        () => _i43.UserProfileRepositoryImpl(gh<_i13.Isar>()));
    await gh.lazySingletonAsync<_i44.VectorStoreService>(
      () {
        final i = _i45.IsarVectorStoreService(
          gh<_i8.MemoryGraph>(),
          gh<_i20.MedicalKnowledgeRepository>(),
        );
        return i.indexMedicalStandards().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i46.VitalSignRepository>(
        () => _i47.VitalSignRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i48.AllergyRepository>(
        () => _i49.AllergyRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i50.AnonCredsService>(
        () => _i51.AnonCredsServiceImpl(gh<_i38.SsiRepository>()));
    gh.lazySingleton<_i52.AppointmentRepository>(
        () => _i53.AppointmentRepositoryImpl(gh<_i13.Isar>()));
    gh.lazySingleton<_i54.AuthService>(
        () => _i54.AuthServiceImpl(gh<_i9.EncryptionService>()));
    gh.lazySingleton<_i55.BleMedicalSharingService>(
        () => _i55.BleMedicalSharingService(
              gh<_i3.BleSharingService>(),
              gh<_i9.EncryptionService>(),
              gh<_i40.SsiService>(),
            ));
    gh.lazySingleton<_i56.ClinicalReasonerService>(() =>
        _i57.SymphonyClinicalReasonerService(
            gh<_i20.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i58.HealthContextService>(
        () => _i59.IsarHealthContextService(
              gh<_i46.VitalSignRepository>(),
              gh<_i29.MedicationRepository>(),
              gh<_i8.MemoryGraph>(),
            ));
    gh.factory<_i60.HealthImportCubit>(() => _i60.HealthImportCubit(
          gh<_i11.HealthDataImportService>(),
          gh<_i46.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i61.HealthRecordRepository>(
        () => _i62.HealthRecordRepositoryImpl(gh<_i13.Isar>()));
    gh.factory<_i14.LlmAdapter>(
      () => _i63.MockLlmAdapter(gh<_i33.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i14.LlmAdapter>(
      () => _i64.GeminiLlmAdapter(
        scrubber: gh<_i33.PromptScrubber>(),
        userProfileRepository: gh<_i42.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i65.LlmService>(() => _i66.GemmaLlmService(
          gh<_i44.VectorStoreService>(),
          gh<_i42.UserProfileRepository>(),
          gh<_i14.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i67.LlmSettingsCubit>(() => _i67.LlmSettingsCubit(
          gh<_i17.LlmSettingsRepository>(),
          gh<_i6.DeviceCapabilityService>(),
          gh<_i14.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i68.MedicalIndexingService>(
        () => _i68.MedicalIndexingService(
              gh<_i20.MedicalKnowledgeRepository>(),
              gh<_i44.VectorStoreService>(),
            ));
    gh.lazySingleton<_i69.MedicalResearchService>(
        () => _i69.MedicalResearchService(
              gh<_i27.MedicalWebSearchService>(),
              gh<_i23.MedicalScraperService>(),
            ));
    gh.factory<_i70.OnboardingCubit>(
        () => _i70.OnboardingCubit(gh<_i42.UserProfileRepository>()));
    gh.lazySingleton<_i71.ReportGenerationService>(
        () => _i72.GemmaReportGenerationService(
              gh<_i14.LlmAdapter>(instanceName: 'gemma'),
              gh<_i44.VectorStoreService>(),
              gh<_i42.UserProfileRepository>(),
              gh<_i33.PromptScrubber>(),
            ));
    gh.lazySingleton<_i73.RiskCalculator>(
        () => _i73.RiskCalculator(gh<_i42.UserProfileRepository>()));
    gh.lazySingleton<_i74.SmartSearchUseCase>(
        () => _i74.SmartSearchUseCase(gh<_i44.VectorStoreService>()));
    gh.factory<_i75.SyncCubit>(() => _i75.SyncCubit(
          gh<_i19.SyncService>(),
          gh<_i44.VectorStoreService>(),
        ));
    gh.factory<_i76.UserProfileCubit>(
        () => _i76.UserProfileCubit(gh<_i42.UserProfileRepository>()));
    gh.factory<_i77.AuthCubit>(() => _i77.AuthCubit(gh<_i54.AuthService>()));
    gh.factory<_i78.HealthRecordCubit>(() => _i78.HealthRecordCubit(
          gh<_i61.HealthRecordRepository>(),
          gh<_i10.FilePickerService>(),
          gh<_i12.ImagePickerService>(),
          gh<_i32.OcrService>(),
          gh<_i44.VectorStoreService>(),
        ));
    gh.lazySingleton<_i65.LlmService>(
      () => _i79.RagLlmService(
        gh<_i44.VectorStoreService>(),
        gh<_i69.MedicalResearchService>(),
        gh<_i42.UserProfileRepository>(),
        gh<_i14.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.factory<_i80.ReportBloc>(() => _i80.ReportBloc(
          gh<_i34.ReportRepository>(),
          gh<_i71.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i81.NetworkModule {}

class _$MemoryModule extends _i82.MemoryModule {}

class _$DatabaseModule extends _i83.DatabaseModule {}
