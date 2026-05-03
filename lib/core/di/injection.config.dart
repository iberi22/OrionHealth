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
    as _i41;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i42;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i43;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i44;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i45;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i8;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i46;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i10;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i58;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i47;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i48;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i9;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i11;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i29;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i56;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i18;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i13;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i37;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i49;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i14;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i50;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i59;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i60;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i20;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i19;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i38;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i52;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i21;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i23;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i25;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i3;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i53;
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
import '../../features/onboarding/application/onboarding_cubit.dart' as _i54;
import '../../features/reports/application/bloc/report_bloc.dart' as _i55;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i33;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i31;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i34;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i32;
import '../../features/settings/application/llm_settings_cubit.dart' as _i51;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i15;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i4;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i16;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i57;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i35;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i36;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i39;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i40;
import '../services/device_capability_service.dart' as _i5;
import '../services/privacy_anonymizer.dart' as _i30;
import 'database_module.dart' as _i63;
import 'memory_module.dart' as _i62;
import 'network_module.dart' as _i61;

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
      () => _i19.JsonMedicalKnowledgeRepository(basePath: gh<String>()),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i18.MedicalKnowledgeRepository>(
      () => _i20.AssetMedicalKnowledgeRepository(assetBasePath: gh<String>()),
      registerFor: {_mobile},
    );
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
    gh.lazySingleton<_i29.OcrService>(() => _i29.OcrServiceStub());
    gh.lazySingleton<_i30.PromptScrubber>(
        () => _i30.PromptScrubber(gh<_i12.Isar>()));
    gh.lazySingleton<_i31.ReportGenerationService>(
        () => _i32.MockReportGenerationService());
    gh.lazySingleton<_i33.ReportRepository>(
        () => _i34.IsarReportRepository(gh<_i12.Isar>()));
    gh.lazySingleton<_i35.UserProfileRepository>(
        () => _i36.UserProfileRepositoryImpl(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i37.VectorStoreService>(
      () {
        final i = _i38.IsarVectorStoreService(
          gh<_i7.MemoryGraph>(),
          gh<_i18.MedicalKnowledgeRepository>(),
        );
        return i.indexMedicalStandards().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i39.VitalSignRepository>(
        () => _i40.VitalSignRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i41.AllergyRepository>(
        () => _i42.AllergyRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i43.AppointmentRepository>(
        () => _i44.AppointmentRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i45.BleMedicalSharingService>(
        () => _i45.BleMedicalSharingService(gh<_i8.EncryptionService>()));
    gh.factory<_i46.HealthImportCubit>(() => _i46.HealthImportCubit(
          gh<_i10.HealthDataImportService>(),
          gh<_i39.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i47.HealthRecordRepository>(
        () => _i48.HealthRecordRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i49.GeminiLlmAdapter(
        apiKey: gh<String>(),
        scrubber: gh<_i30.PromptScrubber>(),
        userProfileRepository: gh<_i35.UserProfileRepository>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i13.LlmAdapter>(
      () => _i50.MockLlmAdapter(gh<_i30.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.factory<_i51.LlmSettingsCubit>(() => _i51.LlmSettingsCubit(
          gh<_i15.LlmSettingsRepository>(),
          gh<_i4.DeviceCapabilityService>(),
        ));
    gh.lazySingleton<_i52.MedicalIndexingService>(
        () => _i52.MedicalIndexingService(
              gh<_i18.MedicalKnowledgeRepository>(),
              gh<_i37.VectorStoreService>(),
            ));
    gh.lazySingleton<_i53.MedicalResearchService>(
        () => _i53.MedicalResearchService(
              gh<_i25.MedicalWebSearchService>(),
              gh<_i21.MedicalScraperService>(),
            ));
    gh.factory<_i54.OnboardingCubit>(
        () => _i54.OnboardingCubit(gh<_i35.UserProfileRepository>()));
    gh.factory<_i55.ReportBloc>(() => _i55.ReportBloc(
          gh<_i33.ReportRepository>(),
          gh<_i31.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i56.SmartSearchUseCase>(
        () => _i56.SmartSearchUseCase(gh<_i37.VectorStoreService>()));
    gh.factory<_i57.UserProfileCubit>(
        () => _i57.UserProfileCubit(gh<_i35.UserProfileRepository>()));
    gh.factory<_i58.HealthRecordCubit>(() => _i58.HealthRecordCubit(
          gh<_i47.HealthRecordRepository>(),
          gh<_i9.FilePickerService>(),
          gh<_i11.ImagePickerService>(),
          gh<_i29.OcrService>(),
          gh<_i37.VectorStoreService>(),
        ));
    gh.lazySingleton<_i59.LlmService>(() => _i60.RagLlmService(
          gh<_i37.VectorStoreService>(),
          gh<_i53.MedicalResearchService>(),
          gh<_i35.UserProfileRepository>(),
          gh<_i13.LlmAdapter>(instanceName: 'gemma'),
        ));
    return this;
  }
}

class _$NetworkModule extends _i61.NetworkModule {}

class _$MemoryModule extends _i62.MemoryModule {}

class _$DatabaseModule extends _i63.DatabaseModule {}
