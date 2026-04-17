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
import 'package:isar/isar.dart' as _i9;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i5;
import 'package:medical_standards/medical_standards.dart' as _i14;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i32;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i33;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i34;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i35;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i36;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i6;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i44;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i37;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i38;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i7;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i8;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i23;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i45;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i39;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i24;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i40;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i25;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i42;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i10;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i28;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i13;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i12;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i11;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i46;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i47;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i29;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i15;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i17;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i19;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i3;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i41;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i16;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i18;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i20;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i21;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i22;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i43;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i26;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i27;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i30;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i31;
import 'database_module.dart' as _i50;
import 'memory_module.dart' as _i49;
import 'network_module.dart' as _i48;

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
    gh.lazySingleton<_i8.ImagePickerService>(
        () => _i8.ImagePickerServiceImpl());
    await gh.factoryAsync<_i9.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i10.LlmAdapter>(
      () => _i11.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i10.LlmAdapter>(
      () => _i12.GemmaLlmAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i10.LlmAdapter>(
      () => _i13.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i14.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.lazySingleton<_i15.MedicalScraperService>(
        () => _i16.MedicalScraperServiceImpl(
              gh<_i4.Dio>(),
              gh<_i3.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i17.MedicalStandardsService>(() =>
        _i18.MedicalStandardsServiceImpl(gh<_i14.MedicalContextProvider>()));
    gh.lazySingleton<_i19.MedicalWebSearchService>(
        () => _i20.MedicalWebSearchServiceImpl(gh<_i4.Dio>()));
    gh.lazySingleton<_i21.MedicationRepository>(
        () => _i22.IsarMedicationRepository(gh<_i9.Isar>()));
    await gh.lazySingletonAsync<_i5.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i9.Isar>(),
        gh<_i5.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i23.OcrService>(() => _i23.OcrServiceStub());
    gh.lazySingleton<_i24.ReportGenerationService>(
        () => _i25.MockReportGenerationService());
    gh.lazySingleton<_i26.UserProfileRepository>(
        () => _i27.UserProfileRepositoryImpl(gh<_i9.Isar>()));
    gh.lazySingleton<_i28.VectorStoreService>(
        () => _i29.IsarVectorStoreService(gh<_i5.MemoryGraph>()));
    gh.lazySingleton<_i30.VitalSignRepository>(
        () => _i31.VitalSignRepositoryImpl(gh<_i9.Isar>()));
    gh.lazySingleton<_i32.AllergyRepository>(
        () => _i33.AllergyRepositoryImpl(gh<_i9.Isar>()));
    gh.lazySingleton<_i34.AppointmentRepository>(
        () => _i35.AppointmentRepositoryImpl(gh<_i9.Isar>()));
    gh.lazySingleton<_i36.BleMedicalSharingService>(
        () => _i36.BleMedicalSharingService(gh<_i6.EncryptionService>()));
    gh.lazySingleton<_i37.HealthRecordRepository>(
        () => _i38.HealthRecordRepositoryImpl(gh<_i9.Isar>()));
    gh.lazySingleton<_i39.HealthReportRepository>(
        () => _i40.IsarHealthReportRepository(gh<_i9.Isar>()));
    gh.lazySingleton<_i41.MedicalResearchService>(
        () => _i41.MedicalResearchService(
              gh<_i19.MedicalWebSearchService>(),
              gh<_i15.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i42.SmartSearchUseCase>(
        () => _i42.SmartSearchUseCase(gh<_i28.VectorStoreService>()));
    gh.factory<_i43.UserProfileCubit>(
        () => _i43.UserProfileCubit(gh<_i26.UserProfileRepository>()));
    gh.factory<_i44.HealthRecordCubit>(() => _i44.HealthRecordCubit(
          gh<_i37.HealthRecordRepository>(),
          gh<_i7.FilePickerService>(),
          gh<_i8.ImagePickerService>(),
          gh<_i23.OcrService>(),
          gh<_i28.VectorStoreService>(),
        ));
    gh.factory<_i45.HealthReportBloc>(() => _i45.HealthReportBloc(
          gh<_i39.HealthReportRepository>(),
          gh<_i24.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i46.LlmService>(() => _i47.RagLlmService(
          gh<_i28.VectorStoreService>(),
          gh<_i41.MedicalResearchService>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i48.NetworkModule {}

class _$MemoryModule extends _i49.MemoryModule {}

class _$DatabaseModule extends _i50.DatabaseModule {}
