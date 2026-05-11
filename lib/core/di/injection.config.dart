// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i39;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i15;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i10;
import 'package:medical_standards/medical_standards.dart' as _i21;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i50;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i51;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i52;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i53;
import '../../features/auth/application/auth_cubit.dart' as _i77;
import '../../features/auth/domain/auth_service.dart' as _i54;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i55;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i11;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i5;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i60;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i13;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i78;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i61;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i62;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i12;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i14;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i34;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i74;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i22;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i16;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i46;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i18;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i64;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i63;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i17;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i66;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i65;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i79;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i23;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i24;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i47;
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
    as _i25;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i27;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i29;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i6;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i69;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i26;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i28;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i30;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i31;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i32;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i70;
import '../../features/onboarding/application/sync_cubit.dart' as _i75;
import '../../features/reports/application/bloc/report_bloc.dart' as _i80;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i36;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i71;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i37;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i72;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i33;
import '../../features/settings/application/llm_settings_cubit.dart' as _i67;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i19;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i7;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i20;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i40;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i3;
import '../../features/ssi/domain/services/ssi_service.dart' as _i42;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i41;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i4;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i38;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i43;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i76;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i44;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i45;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i48;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i49;
import '../services/device_capability_service.dart' as _i8;
import '../services/privacy_anonymizer.dart' as _i35;
import 'database_module.dart' as _i83;
import 'memory_module.dart' as _i82;
import 'network_module.dart' as _i81;

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
    gh.lazySingleton<_i3.AnonCredsService>(() => _i4.AnonCredsServiceImpl());
    gh.lazySingleton<_i5.BleSharingService>(() => _i5.BleSharingService());
    gh.lazySingleton<_i6.BotBypassHandler>(() => _i6.BotBypassHandler());
    gh.lazySingleton<_i7.DeviceCapabilityService>(
        () => _i7.DeviceCapabilityService());
    gh.lazySingleton<_i8.DeviceCapabilityService>(
        () => _i8.DeviceCapabilityService());
    gh.lazySingleton<_i9.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i10.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i11.EncryptionService>(
        () => _i11.EncryptionServiceImpl());
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
    gh.lazySingleton<_i16.LlmAdapter>(
      () => _i17.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i16.LlmAdapter>(
      () => _i18.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i19.LlmSettingsRepository>(
        () => _i20.LlmSettingsRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i21.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i22.MedicalKnowledgeRepository>(
      () => _i23.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i22.MedicalKnowledgeRepository>(
      () => _i24.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i25.MedicalScraperService>(
        () => _i26.MedicalScraperServiceImpl(
              gh<_i9.Dio>(),
              gh<_i6.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i27.MedicalStandardsService>(() =>
        _i28.MedicalStandardsServiceImpl(gh<_i21.MedicalContextProvider>()));
    gh.lazySingleton<_i29.MedicalWebSearchService>(
        () => _i30.MedicalWebSearchServiceImpl(gh<_i9.Dio>()));
    gh.lazySingleton<_i31.MedicationRepository>(
        () => _i32.IsarMedicationRepository(gh<_i15.Isar>()));
    await gh.lazySingletonAsync<_i10.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i15.Isar>(),
        gh<_i10.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i33.MockReportGenerationService>(
      () => _i33.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i34.OcrService>(() => _i34.MlKitOcrService());
    gh.lazySingleton<_i35.PromptScrubber>(
        () => _i35.PromptScrubber(gh<_i15.Isar>()));
    gh.lazySingleton<_i36.ReportRepository>(
        () => _i37.IsarReportRepository(gh<_i15.Isar>()));
    gh.lazySingleton<_i38.SidetreeAnchorClient>(() => _i38.SidetreeAnchorClient(
          ionNodeUrl: gh<String>(),
          httpClient: gh<_i39.Client>(),
        ));
    gh.lazySingleton<_i40.SsiRepository>(
        () => _i41.IsarSsiRepository(gh<_i15.Isar>()));
    gh.lazySingleton<_i42.SsiService>(() => _i43.SsiServiceImpl(
          gh<_i40.SsiRepository>(),
          gh<_i38.SidetreeAnchorClient>(),
        ));
    gh.lazySingleton<_i21.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i44.UserProfileRepository>(
        () => _i45.UserProfileRepositoryImpl(gh<_i15.Isar>()));
    await gh.lazySingletonAsync<_i46.VectorStoreService>(
      () {
        final i = _i47.IsarVectorStoreService(
          gh<_i10.MemoryGraph>(),
          gh<_i22.MedicalKnowledgeRepository>(),
        );
        return i.indexMedicalStandards().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i48.VitalSignRepository>(
        () => _i49.VitalSignRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i50.AllergyRepository>(
        () => _i51.AllergyRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i52.AppointmentRepository>(
        () => _i53.AppointmentRepositoryImpl(gh<_i15.Isar>()));
    gh.lazySingleton<_i54.AuthService>(
        () => _i54.AuthServiceImpl(gh<_i11.EncryptionService>()));
    gh.lazySingleton<_i55.BleMedicalSharingService>(
        () => _i55.BleMedicalSharingService(
              gh<_i5.BleSharingService>(),
              gh<_i11.EncryptionService>(),
              gh<_i42.SsiService>(),
            ));
    gh.lazySingleton<_i56.ClinicalReasonerService>(() =>
        _i57.SymphonyClinicalReasonerService(
            gh<_i22.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i58.HealthContextService>(
        () => _i59.IsarHealthContextService(
              gh<_i48.VitalSignRepository>(),
              gh<_i31.MedicationRepository>(),
              gh<_i10.MemoryGraph>(),
            ));
    gh.factory<_i60.HealthImportCubit>(() => _i60.HealthImportCubit(
          gh<_i13.HealthDataImportService>(),
          gh<_i48.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i61.HealthRecordRepository>(
        () => _i62.HealthRecordRepositoryImpl(gh<_i15.Isar>()));
    gh.factory<_i16.LlmAdapter>(
      () => _i63.MockLlmAdapter(gh<_i35.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i16.LlmAdapter>(
      () => _i64.GeminiLlmAdapter(
        scrubber: gh<_i35.PromptScrubber>(),
        userProfileRepository: gh<_i44.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i65.LlmService>(() => _i66.GemmaLlmService(
          gh<_i46.VectorStoreService>(),
          gh<_i44.UserProfileRepository>(),
          gh<_i16.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i67.LlmSettingsCubit>(() => _i67.LlmSettingsCubit(
          gh<_i19.LlmSettingsRepository>(),
          gh<_i7.DeviceCapabilityService>(),
        ));
    gh.lazySingleton<_i68.MedicalIndexingService>(
        () => _i68.MedicalIndexingService(
              gh<_i22.MedicalKnowledgeRepository>(),
              gh<_i46.VectorStoreService>(),
            ));
    gh.lazySingleton<_i69.MedicalResearchService>(
        () => _i69.MedicalResearchService(
              gh<_i29.MedicalWebSearchService>(),
              gh<_i25.MedicalScraperService>(),
            ));
    gh.factory<_i70.OnboardingCubit>(
        () => _i70.OnboardingCubit(gh<_i44.UserProfileRepository>()));
    gh.lazySingleton<_i71.ReportGenerationService>(
        () => _i72.GemmaReportGenerationService(
              gh<_i16.LlmAdapter>(instanceName: 'gemma'),
              gh<_i46.VectorStoreService>(),
              gh<_i44.UserProfileRepository>(),
              gh<_i35.PromptScrubber>(),
            ));
    gh.lazySingleton<_i73.RiskCalculator>(
        () => _i73.RiskCalculator(gh<_i44.UserProfileRepository>()));
    gh.lazySingleton<_i74.SmartSearchUseCase>(
        () => _i74.SmartSearchUseCase(gh<_i46.VectorStoreService>()));
    gh.factory<_i75.SyncCubit>(() => _i75.SyncCubit(
          gh<_i21.SyncService>(),
          gh<_i46.VectorStoreService>(),
        ));
    gh.factory<_i76.UserProfileCubit>(
        () => _i76.UserProfileCubit(gh<_i44.UserProfileRepository>()));
    gh.factory<_i77.AuthCubit>(() => _i77.AuthCubit(gh<_i54.AuthService>()));
    gh.factory<_i78.HealthRecordCubit>(() => _i78.HealthRecordCubit(
          gh<_i61.HealthRecordRepository>(),
          gh<_i12.FilePickerService>(),
          gh<_i14.ImagePickerService>(),
          gh<_i34.OcrService>(),
          gh<_i46.VectorStoreService>(),
        ));
    gh.lazySingleton<_i65.LlmService>(
      () => _i79.RagLlmService(
        gh<_i46.VectorStoreService>(),
        gh<_i69.MedicalResearchService>(),
        gh<_i44.UserProfileRepository>(),
        gh<_i16.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.factory<_i80.ReportBloc>(() => _i80.ReportBloc(
          gh<_i36.ReportRepository>(),
          gh<_i71.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i81.NetworkModule {}

class _$MemoryModule extends _i82.MemoryModule {}

class _$DatabaseModule extends _i83.DatabaseModule {}
