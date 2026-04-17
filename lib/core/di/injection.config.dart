// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i10;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i5;
import 'package:medical_standards/medical_standards.dart' as _i15;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i34;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i35;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i36;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i37;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i38;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i6;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i39;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i8;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i48;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i40;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i41;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i7;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i9;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i24;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i49;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i42;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i26;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i43;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i27;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i46;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i11;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i30;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i12;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i13;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i14;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i50;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i51;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i31;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i16;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i18;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i20;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i3;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i44;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i17;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i19;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i21;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i22;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i23;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i45;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i47;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i28;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i29;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i32;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i33;
import '../services/privacy_anonymizer.dart' as _i25;
import 'database_module.dart' as _i54;
import 'memory_module.dart' as _i53;
import 'network_module.dart' as _i52;

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
    gh.lazySingleton<_i4.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i5.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i6.EncryptionService>(() => _i6.EncryptionServiceImpl());
    gh.lazySingleton<_i7.FilePickerService>(() => _i7.FilePickerServiceImpl());
    gh.lazySingleton<_i8.HealthDataImportService>(
        () => _i8.HealthDataImportService());
    gh.lazySingleton<_i9.ImagePickerService>(
        () => _i9.ImagePickerServiceImpl());
    await gh.factoryAsync<_i10.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i11.LlmAdapter>(
      () => _i12.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i11.LlmAdapter>(
      () => _i13.GemmaLlmAdapter(aicoreService: gh<InvalidType>()),
      instanceName: 'gemma',
    );
    gh.factory<_i11.LlmAdapter>(
      () => _i14.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i15.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.lazySingleton<_i16.MedicalScraperService>(
        () => _i17.MedicalScraperServiceImpl(
              gh<_i4.Dio>(),
              gh<_i3.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i18.MedicalStandardsService>(() =>
        _i19.MedicalStandardsServiceImpl(gh<_i15.MedicalContextProvider>()));
    gh.lazySingleton<_i20.MedicalWebSearchService>(
        () => _i21.MedicalWebSearchServiceImpl(gh<_i4.Dio>()));
    gh.lazySingleton<_i22.MedicationRepository>(
        () => _i23.IsarMedicationRepository(gh<_i10.Isar>()));
    await gh.lazySingletonAsync<_i5.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i10.Isar>(),
        gh<_i5.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i24.OcrService>(() => _i24.OcrServiceStub());
    gh.lazySingleton<_i25.PromptScrubber>(
        () => _i25.PromptScrubber(gh<_i10.Isar>()));
    gh.lazySingleton<_i26.ReportGenerationService>(
        () => _i27.MockReportGenerationService());
    gh.lazySingleton<_i28.UserProfileRepository>(
        () => _i29.UserProfileRepositoryImpl(gh<_i10.Isar>()));
    gh.lazySingleton<_i30.VectorStoreService>(
        () => _i31.IsarVectorStoreService(gh<_i5.MemoryGraph>()));
    gh.lazySingleton<_i32.VitalSignRepository>(
        () => _i33.VitalSignRepositoryImpl(gh<_i10.Isar>()));
    gh.lazySingleton<_i34.AllergyRepository>(
        () => _i35.AllergyRepositoryImpl(gh<_i10.Isar>()));
    gh.lazySingleton<_i36.AppointmentRepository>(
        () => _i37.AppointmentRepositoryImpl(gh<_i10.Isar>()));
    gh.lazySingleton<_i38.BleMedicalSharingService>(
        () => _i38.BleMedicalSharingService(gh<_i6.EncryptionService>()));
    gh.factory<_i39.HealthImportCubit>(() => _i39.HealthImportCubit(
          gh<_i8.HealthDataImportService>(),
          gh<_i32.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i40.HealthRecordRepository>(
        () => _i41.HealthRecordRepositoryImpl(gh<_i10.Isar>()));
    gh.lazySingleton<_i42.HealthReportRepository>(
        () => _i43.IsarHealthReportRepository(gh<_i10.Isar>()));
    gh.lazySingleton<_i44.MedicalResearchService>(
        () => _i44.MedicalResearchService(
              gh<_i20.MedicalWebSearchService>(),
              gh<_i16.MedicalScraperService>(),
            ));
    gh.factory<_i45.OnboardingCubit>(
        () => _i45.OnboardingCubit(gh<_i28.UserProfileRepository>()));
    gh.lazySingleton<_i46.SmartSearchUseCase>(
        () => _i46.SmartSearchUseCase(gh<_i30.VectorStoreService>()));
    gh.factory<_i47.UserProfileCubit>(
        () => _i47.UserProfileCubit(gh<_i28.UserProfileRepository>()));
    gh.factory<_i48.HealthRecordCubit>(() => _i48.HealthRecordCubit(
          gh<_i40.HealthRecordRepository>(),
          gh<_i7.FilePickerService>(),
          gh<_i9.ImagePickerService>(),
          gh<_i24.OcrService>(),
          gh<_i30.VectorStoreService>(),
        ));
    gh.factory<_i49.HealthReportBloc>(() => _i49.HealthReportBloc(
          gh<_i42.HealthReportRepository>(),
          gh<_i26.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i50.LlmService>(() => _i51.RagLlmService(
          gh<_i30.VectorStoreService>(),
          gh<_i44.MedicalResearchService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i52.NetworkModule {}

class _$MemoryModule extends _i53.MemoryModule {}

class _$DatabaseModule extends _i54.DatabaseModule {}
