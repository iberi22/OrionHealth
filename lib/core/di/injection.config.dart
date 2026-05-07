// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i12;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i7;
import 'package:medical_standards/medical_standards.dart' as _i18;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i40;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i41;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i42;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i43;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i44;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i8;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i49;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i10;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i66;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i50;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i51;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i9;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i11;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i30;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i63;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i19;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i13;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i36;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i15;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i54;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i55;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i14;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i57;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i56;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i68;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i20;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i21;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i37;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i59;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i45;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i47;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i62;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i46;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i48;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i22;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i24;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i26;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i3;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i60;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i23;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i25;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i27;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i28;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i29;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i61;
import '../../features/onboarding/application/sync_cubit.dart' as _i64;
import '../../features/settings/application/llm_settings_cubit.dart' as _i58;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i16;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i5;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i17;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i65;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i34;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i35;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i38;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i39;
import '../services/device_capability_service.dart' as _i4;
import '../services/privacy_anonymizer.dart' as _i31;
import 'database_module.dart' as _i71;
import 'memory_module.dart' as _i70;
import 'network_module.dart' as _i69;

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
    gh.lazySingleton<_i3.BotBypassHandler>(() => _i3.BotBypassHandler());
    gh.lazySingleton<_i4.DeviceCapabilityService>(
        () => _i4.DeviceCapabilityService());
    gh.lazySingleton<_i5.DeviceCapabilityService>(
        () => _i5.DeviceCapabilityService());
    gh.lazySingleton<_i6.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i7.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i8.EncryptionService>(() => _i8.EncryptionServiceImpl());
    gh.lazySingleton<_i9.FilePickerService>(() => _i9.FilePickerServiceImpl());
    gh.lazySingleton<_i10.HealthDataImportService>(
        () => _i10.HealthDataImportService());
    gh.lazySingleton<_i11.ImagePickerService>(
        () => _i11.ImagePickerServiceImpl());
    await gh.factoryAsync<_i12.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i14.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i15.FlutterGemmaAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i16.LlmSettingsRepository>(
        () => _i17.LlmSettingsRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i18.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i19.MedicalKnowledgeRepository>(
      () => _i20.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i19.MedicalKnowledgeRepository>(
        () => _i21.JsonMedicalKnowledgeRepository());
    gh.lazySingleton<_i22.MedicalScraperService>(
        () => _i23.MedicalScraperServiceImpl(
              gh<_i6.Dio>(),
              gh<_i3.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i24.MedicalStandardsService>(() =>
        _i25.MedicalStandardsServiceImpl(gh<_i18.MedicalContextProvider>()));
    gh.lazySingleton<_i26.MedicalWebSearchService>(
        () => _i27.MedicalWebSearchServiceImpl(gh<_i6.Dio>()));
    gh.lazySingleton<_i28.MedicationRepository>(
        () => _i29.IsarMedicationRepository(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i7.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i12.Isar>(),
        gh<_i7.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i30.OcrService>(() => _i30.MlKitOcrService());
    gh.lazySingleton<_i31.PromptScrubber>(
        () => _i31.PromptScrubber(gh<_i12.Isar>()));
    gh.lazySingleton<_i18.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i34.UserProfileRepository>(
        () => _i35.UserProfileRepositoryImpl(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i36.VectorStoreService>(
      () {
        final i = _i37.IsarVectorStoreService(
          gh<_i7.MemoryGraph>(),
          gh<_i19.MedicalKnowledgeRepository>(),
        );
        return i.indexMedicalStandards().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i38.VitalSignRepository>(
        () => _i39.VitalSignRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i40.AllergyRepository>(
        () => _i41.AllergyRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i42.AppointmentRepository>(
        () => _i43.AppointmentRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i44.BleMedicalSharingService>(
        () => _i44.BleMedicalSharingService(gh<_i8.EncryptionService>()));
    gh.lazySingleton<_i45.ClinicalReasonerService>(() =>
        _i46.SymphonyClinicalReasonerService(
            gh<_i19.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i47.HealthContextService>(
        () => _i48.IsarHealthContextService(
              gh<_i38.VitalSignRepository>(),
              gh<_i28.MedicationRepository>(),
              gh<_i7.MemoryGraph>(),
            ));
    gh.factory<_i49.HealthImportCubit>(() => _i49.HealthImportCubit(
          gh<_i10.HealthDataImportService>(),
          gh<_i38.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i50.HealthRecordRepository>(
        () => _i51.HealthRecordRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i54.GeminiLlmAdapter(
        scrubber: gh<_i31.PromptScrubber>(),
        userProfileRepository: gh<_i34.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i13.LlmAdapter>(
      () => _i55.MockLlmAdapter(gh<_i31.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i56.LlmService>(() => _i57.GemmaLlmService(
          gh<_i36.VectorStoreService>(),
          gh<_i34.UserProfileRepository>(),
          gh<_i13.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i58.LlmSettingsCubit>(() => _i58.LlmSettingsCubit(
          gh<_i16.LlmSettingsRepository>(),
          gh<_i5.DeviceCapabilityService>(),
        ));
    gh.lazySingleton<_i59.MedicalIndexingService>(
        () => _i59.MedicalIndexingService(
              gh<_i19.MedicalKnowledgeRepository>(),
              gh<_i36.VectorStoreService>(),
            ));
    gh.lazySingleton<_i60.MedicalResearchService>(
        () => _i60.MedicalResearchService(
              gh<_i26.MedicalWebSearchService>(),
              gh<_i22.MedicalScraperService>(),
            ));
    gh.factory<_i61.OnboardingCubit>(
        () => _i61.OnboardingCubit(gh<_i34.UserProfileRepository>()));
    gh.lazySingleton<_i62.RiskCalculator>(
        () => _i62.RiskCalculator(gh<_i34.UserProfileRepository>()));
    gh.lazySingleton<_i63.SmartSearchUseCase>(
        () => _i63.SmartSearchUseCase(gh<_i36.VectorStoreService>()));
    gh.factory<_i64.SyncCubit>(() => _i64.SyncCubit(
          gh<_i18.SyncService>(),
          gh<_i36.VectorStoreService>(),
        ));
    gh.factory<_i65.UserProfileCubit>(
        () => _i65.UserProfileCubit(gh<_i34.UserProfileRepository>()));
    gh.factory<_i66.HealthRecordCubit>(() => _i66.HealthRecordCubit(
          gh<_i50.HealthRecordRepository>(),
          gh<_i9.FilePickerService>(),
          gh<_i11.ImagePickerService>(),
          gh<_i30.OcrService>(),
          gh<_i36.VectorStoreService>(),
        ));
    gh.lazySingleton<_i56.LlmService>(
      () => _i68.RagLlmService(
        gh<_i36.VectorStoreService>(),
        gh<_i60.MedicalResearchService>(),
        gh<_i34.UserProfileRepository>(),
        gh<_i13.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    return this;
  }
}

class _$NetworkModule extends _i69.NetworkModule {}

class _$MemoryModule extends _i70.MemoryModule {}

class _$DatabaseModule extends _i71.DatabaseModule {}
