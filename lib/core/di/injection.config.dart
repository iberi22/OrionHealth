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
    as _i35;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i36;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i37;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i38;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i39;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i8;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i40;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i10;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i49;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i41;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i42;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i9;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i11;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i26;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i50;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i43;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i27;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i44;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i28;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i47;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i13;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i31;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i16;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i15;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i14;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i51;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i52;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i32;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i18;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i20;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i22;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i4;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i45;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i19;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i21;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i23;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i24;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i25;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i46;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i48;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i29;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i30;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i33;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i34;
import '../device/device_capability.dart' as _i5;
import '../services/aicore_service.dart' as _i3;
import 'database_module.dart' as _i55;
import 'memory_module.dart' as _i54;
import 'network_module.dart' as _i53;

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
    gh.lazySingleton<_i3.AicoreService>(() => _i3.AicoreService());
    gh.lazySingleton<_i4.BotBypassHandler>(() => _i4.BotBypassHandler());
    gh.lazySingleton<_i5.DeviceCapabilityService>(
        () => _i5.DeviceCapabilityService(gh<_i3.AicoreService>()));
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
    gh.factory<_i13.LlmAdapter>(
      () => _i14.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i15.GemmaLlmAdapter(gh<_i3.AicoreService>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i13.LlmAdapter>(
      () => _i16.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i17.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.lazySingleton<_i18.MedicalScraperService>(
        () => _i19.MedicalScraperServiceImpl(
              gh<_i6.Dio>(),
              gh<_i4.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i20.MedicalStandardsService>(() =>
        _i21.MedicalStandardsServiceImpl(gh<_i17.MedicalContextProvider>()));
    gh.lazySingleton<_i22.MedicalWebSearchService>(
        () => _i23.MedicalWebSearchServiceImpl(gh<_i6.Dio>()));
    gh.lazySingleton<_i24.MedicationRepository>(
        () => _i25.IsarMedicationRepository(gh<_i12.Isar>()));
    await gh.lazySingletonAsync<_i7.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i12.Isar>(),
        gh<_i7.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i26.OcrService>(() => _i26.OcrServiceStub());
    gh.lazySingleton<_i27.ReportGenerationService>(
        () => _i28.MockReportGenerationService());
    gh.lazySingleton<_i29.UserProfileRepository>(
        () => _i30.UserProfileRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i31.VectorStoreService>(
        () => _i32.IsarVectorStoreService(gh<_i7.MemoryGraph>()));
    gh.lazySingleton<_i33.VitalSignRepository>(
        () => _i34.VitalSignRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i35.AllergyRepository>(
        () => _i36.AllergyRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i37.AppointmentRepository>(
        () => _i38.AppointmentRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i39.BleMedicalSharingService>(
        () => _i39.BleMedicalSharingService(gh<_i8.EncryptionService>()));
    gh.factory<_i40.HealthImportCubit>(() => _i40.HealthImportCubit(
          gh<_i10.HealthDataImportService>(),
          gh<_i33.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i41.HealthRecordRepository>(
        () => _i42.HealthRecordRepositoryImpl(gh<_i12.Isar>()));
    gh.lazySingleton<_i43.HealthReportRepository>(
        () => _i44.IsarHealthReportRepository(gh<_i12.Isar>()));
    gh.lazySingleton<_i45.MedicalResearchService>(
        () => _i45.MedicalResearchService(
              gh<_i22.MedicalWebSearchService>(),
              gh<_i18.MedicalScraperService>(),
            ));
    gh.factory<_i46.OnboardingCubit>(
        () => _i46.OnboardingCubit(gh<_i29.UserProfileRepository>()));
    gh.lazySingleton<_i47.SmartSearchUseCase>(
        () => _i47.SmartSearchUseCase(gh<_i31.VectorStoreService>()));
    gh.factory<_i48.UserProfileCubit>(() => _i48.UserProfileCubit(
          gh<_i29.UserProfileRepository>(),
          gh<_i5.DeviceCapabilityService>(),
        ));
    gh.factory<_i49.HealthRecordCubit>(() => _i49.HealthRecordCubit(
          gh<_i41.HealthRecordRepository>(),
          gh<_i9.FilePickerService>(),
          gh<_i11.ImagePickerService>(),
          gh<_i26.OcrService>(),
          gh<_i31.VectorStoreService>(),
        ));
    gh.factory<_i50.HealthReportBloc>(() => _i50.HealthReportBloc(
          gh<_i43.HealthReportRepository>(),
          gh<_i27.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i51.LlmService>(() => _i52.RagLlmService(
          gh<_i31.VectorStoreService>(),
          gh<_i45.MedicalResearchService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i53.NetworkModule {}

class _$MemoryModule extends _i54.MemoryModule {}

class _$DatabaseModule extends _i55.DatabaseModule {}
