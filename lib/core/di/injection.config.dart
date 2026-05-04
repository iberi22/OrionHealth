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
import 'package:medical_standards/medical_standards.dart' as _i17;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i39;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i40;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i41;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i42;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i43;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i8;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i44;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i10;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i61;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i45;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i46;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i9;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i11;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i29;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i62;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i47;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i31;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i48;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i32;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i58;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i18;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i13;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i35;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i50;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i14;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i49;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i52;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i51;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i63;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i19;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i20;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i36;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i54;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i57;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i21;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i23;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i25;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i3;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i55;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i22;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i24;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i26;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i27;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i28;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i56;
import '../../features/onboarding/application/sync_cubit.dart' as _i59;
import '../../features/settings/application/llm_settings_cubit.dart' as _i53;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i15;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i4;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i16;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i60;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i33;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i34;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i37;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i38;
import '../services/device_capability_service.dart' as _i5;
import '../services/privacy_anonymizer.dart' as _i30;
import 'database_module.dart' as _i66;
import 'memory_module.dart' as _i65;
import 'network_module.dart' as _i64;

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
      () => _i14.GemmaLlmAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i15.LlmSettingsRepository>(
        () => _i16.LlmSettingsRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i17.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i18.MedicalKnowledgeRepository>(
      () => _i19.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i18.MedicalKnowledgeRepository>(
        () => _i20.JsonMedicalKnowledgeRepository());
    gh.lazySingleton<_i21.MedicalScraperService>(
        () => _i22.MedicalScraperServiceImpl(
              gh<_i6.Dio>(),
              gh<_i3.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i23.MedicalStandardsService>(() =>
        _i24.MedicalStandardsServiceImpl(gh<_i17.MedicalContextProvider>()));
    gh.lazySingleton<_i25.MedicalWebSearchService>(
        () => _i26.MedicalWebSearchServiceImpl(gh<_i6.Dio>()));
    gh.lazySingleton<_i27.MedicationRepository>(
        () => _i28.IsarMedicationRepository(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i7.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i12.Isar>(),
        gh<_i7.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i29.OcrService>(() => _i29.MlKitOcrService());
    gh.lazySingleton<_i30.PromptScrubber>(
        () => _i30.PromptScrubber(gh<_i12.Isar>()));
    gh.lazySingleton<_i31.ReportGenerationService>(() =>
        _i32.RealReportGenerationService(
            gh<_i13.LlmAdapter>(instanceName: 'gemma')));
    gh.lazySingleton<_i17.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i33.UserProfileRepository>(
        () => _i34.UserProfileRepositoryImpl(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i35.VectorStoreService>(
      () {
        final i = _i36.IsarVectorStoreService(
          gh<_i7.MemoryGraph>(),
          gh<_i18.MedicalKnowledgeRepository>(),
        );
        return i.indexMedicalStandards().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i37.VitalSignRepository>(
        () => _i38.VitalSignRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i39.AllergyRepository>(
        () => _i40.AllergyRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i41.AppointmentRepository>(
        () => _i42.AppointmentRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i43.BleMedicalSharingService>(
        () => _i43.BleMedicalSharingService(gh<_i8.EncryptionService>()));
    gh.factory<_i44.HealthImportCubit>(() => _i44.HealthImportCubit(
          gh<_i10.HealthDataImportService>(),
          gh<_i37.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i45.HealthRecordRepository>(
        () => _i46.HealthRecordRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i47.HealthReportRepository>(
        () => _i48.IsarHealthReportRepository(gh<_i12.Isar>()));
    gh.factory<_i13.LlmAdapter>(
      () => _i49.MockLlmAdapter(gh<_i30.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i50.GeminiLlmAdapter(
        scrubber: gh<_i30.PromptScrubber>(),
        userProfileRepository: gh<_i33.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i51.LlmService>(() => _i52.GemmaLlmService(
          gh<_i35.VectorStoreService>(),
          gh<_i33.UserProfileRepository>(),
          gh<_i13.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i53.LlmSettingsCubit>(() => _i53.LlmSettingsCubit(
          gh<_i15.LlmSettingsRepository>(),
          gh<_i4.DeviceCapabilityService>(),
        ));
    gh.lazySingleton<_i54.MedicalIndexingService>(
        () => _i54.MedicalIndexingService(
              gh<_i18.MedicalKnowledgeRepository>(),
              gh<_i35.VectorStoreService>(),
            ));
    gh.lazySingleton<_i55.MedicalResearchService>(
        () => _i55.MedicalResearchService(
              gh<_i25.MedicalWebSearchService>(),
              gh<_i21.MedicalScraperService>(),
            ));
    gh.factory<_i56.OnboardingCubit>(
        () => _i56.OnboardingCubit(gh<_i33.UserProfileRepository>()));
    gh.lazySingleton<_i57.RiskCalculator>(
        () => _i57.RiskCalculator(gh<_i33.UserProfileRepository>()));
    gh.lazySingleton<_i58.SmartSearchUseCase>(
        () => _i58.SmartSearchUseCase(gh<_i35.VectorStoreService>()));
    gh.factory<_i59.SyncCubit>(() => _i59.SyncCubit(
          gh<_i17.SyncService>(),
          gh<_i35.VectorStoreService>(),
        ));
    gh.factory<_i60.UserProfileCubit>(
        () => _i60.UserProfileCubit(gh<_i33.UserProfileRepository>()));
    gh.factory<_i61.HealthRecordCubit>(() => _i61.HealthRecordCubit(
          gh<_i45.HealthRecordRepository>(),
          gh<_i9.FilePickerService>(),
          gh<_i11.ImagePickerService>(),
          gh<_i29.OcrService>(),
          gh<_i35.VectorStoreService>(),
        ));
    gh.factory<_i62.HealthReportBloc>(() => _i62.HealthReportBloc(
          gh<_i47.HealthReportRepository>(),
          gh<_i31.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i51.LlmService>(
      () => _i63.RagLlmService(
        gh<_i35.VectorStoreService>(),
        gh<_i55.MedicalResearchService>(),
        gh<_i33.UserProfileRepository>(),
        gh<_i13.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    return this;
  }
}

class _$NetworkModule extends _i64.NetworkModule {}

class _$MemoryModule extends _i65.MemoryModule {}

class _$DatabaseModule extends _i66.DatabaseModule {}
