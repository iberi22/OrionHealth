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
import 'package:medical_standards/medical_standards.dart' as _i19;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i37;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i38;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i39;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i40;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i41;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i8;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i42;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i10;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i52;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i43;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i44;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i9;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i11;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i28;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i53;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i45;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i29;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i46;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i30;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i50;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i13;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i33;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i14;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i15;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i16;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i54;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i55;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i59;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i60;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i34;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i61;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i20;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i22;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i24;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i3;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i48;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i21;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i23;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i25;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i26;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i27;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i49;
import '../../features/settings/application/llm_settings_cubit.dart' as _i47;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i17;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i4;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i18;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i51;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i31;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i32;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i35;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i36;
import '../services/device_capability_service.dart' as _i5;
import 'database_module.dart' as _i58;
import 'memory_module.dart' as _i57;
import 'network_module.dart' as _i56;

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
      () => _i14.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i15.GemmaLlmAdapter(),
      instanceName: 'gemma',
    );
    gh.factory<_i13.LlmAdapter>(
      () => _i16.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i17.LlmSettingsRepository>(
        () => _i18.LlmSettingsRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i19.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.lazySingleton<_i20.MedicalScraperService>(
        () => _i21.MedicalScraperServiceImpl(
              gh<_i6.Dio>(),
              gh<_i3.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i22.MedicalStandardsService>(() =>
        _i23.MedicalStandardsServiceImpl(gh<_i19.MedicalContextProvider>()));
    gh.lazySingleton<_i24.MedicalWebSearchService>(
        () => _i25.MedicalWebSearchServiceImpl(gh<_i6.Dio>()));
    gh.lazySingleton<_i26.MedicationRepository>(
        () => _i27.IsarMedicationRepository(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i7.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i12.Isar>(),
        gh<_i7.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i28.OcrService>(() => _i28.OcrServiceStub());
    gh.lazySingleton<_i29.ReportGenerationService>(
        () => _i30.MockReportGenerationService());
    gh.lazySingleton<_i31.UserProfileRepository>(
        () => _i32.UserProfileRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i59.MedicalKnowledgeRepository>(
        () => _i60.JsonMedicalKnowledgeRepository());
    gh.lazySingleton<_i33.VectorStoreService>(
        () => _i34.IsarVectorStoreService(gh<_i7.MemoryGraph>(), gh<_i59.MedicalKnowledgeRepository>()));
    gh.lazySingleton<_i61.MedicalIndexingService>(
        () => _i61.MedicalIndexingService(gh<_i59.MedicalKnowledgeRepository>(), gh<_i33.VectorStoreService>()));
    gh.lazySingleton<_i35.VitalSignRepository>(
        () => _i36.VitalSignRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i37.AllergyRepository>(
        () => _i38.AllergyRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i39.AppointmentRepository>(
        () => _i40.AppointmentRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i41.BleMedicalSharingService>(
        () => _i41.BleMedicalSharingService(gh<_i8.EncryptionService>()));
    gh.factory<_i42.HealthImportCubit>(() => _i42.HealthImportCubit(
          gh<_i10.HealthDataImportService>(),
          gh<_i35.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i43.HealthRecordRepository>(
        () => _i44.HealthRecordRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i45.HealthReportRepository>(
        () => _i46.IsarHealthReportRepository(gh<_i12.Isar>()));
    gh.factory<_i47.LlmSettingsCubit>(() => _i47.LlmSettingsCubit(
          gh<_i17.LlmSettingsRepository>(),
          gh<_i4.DeviceCapabilityService>(),
        ));
    gh.lazySingleton<_i48.MedicalResearchService>(
        () => _i48.MedicalResearchService(
              gh<_i24.MedicalWebSearchService>(),
              gh<_i20.MedicalScraperService>(),
            ));
    gh.factory<_i49.OnboardingCubit>(
        () => _i49.OnboardingCubit(gh<_i31.UserProfileRepository>()));
    gh.lazySingleton<_i50.SmartSearchUseCase>(
        () => _i50.SmartSearchUseCase(gh<_i33.VectorStoreService>()));
    gh.factory<_i51.UserProfileCubit>(
        () => _i51.UserProfileCubit(gh<_i31.UserProfileRepository>()));
    gh.factory<_i52.HealthRecordCubit>(() => _i52.HealthRecordCubit(
          gh<_i43.HealthRecordRepository>(),
          gh<_i9.FilePickerService>(),
          gh<_i11.ImagePickerService>(),
          gh<_i28.OcrService>(),
          gh<_i33.VectorStoreService>(),
        ));
    gh.factory<_i53.HealthReportBloc>(() => _i53.HealthReportBloc(
          gh<_i45.HealthReportRepository>(),
          gh<_i29.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i54.LlmService>(() => _i55.RagLlmService(
          gh<_i33.VectorStoreService>(),
          gh<_i48.MedicalResearchService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i56.NetworkModule {}

class _$MemoryModule extends _i57.MemoryModule {}

class _$DatabaseModule extends _i58.DatabaseModule {}
