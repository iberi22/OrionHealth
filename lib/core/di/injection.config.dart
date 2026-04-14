// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i8;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i4;

import '../../features/auth/application/bloc/auth_cubit.dart' as _i32;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i22;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i23;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i3;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i5;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i33;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i24;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i25;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i6;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i7;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i15;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i34;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i26;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i16;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i27;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i17;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i30;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i9;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i20;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i12;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i11;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i10;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i28;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i29;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i21;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i13;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i14;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i31;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i18;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i19;
import 'database_module.dart' as _i36;
import 'memory_module.dart' as _i35;

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
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.BiometricService>(() => _i3.BiometricService());
    gh.lazySingleton<_i4.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i5.EncryptionService>(() => _i5.EncryptionService());
    gh.lazySingleton<_i6.FilePickerService>(() => _i6.FilePickerServiceImpl());
    gh.lazySingleton<_i7.ImagePickerService>(
        () => _i7.ImagePickerServiceImpl());
    await gh.factoryAsync<_i8.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i9.LlmAdapter>(
      () => _i10.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i9.LlmAdapter>(
      () => _i11.GemmaLlmAdapter(),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i9.LlmAdapter>(
      () => _i12.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i13.MedicationRepository>(
        () => _i14.IsarMedicationRepository(gh<_i8.Isar>()));
    await gh.lazySingletonAsync<_i4.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i8.Isar>(),
        gh<_i4.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i15.OcrService>(() => _i15.OcrServiceStub());
    gh.lazySingleton<_i16.ReportGenerationService>(
        () => _i17.MockReportGenerationService());
    gh.lazySingleton<_i18.UserProfileRepository>(
        () => _i19.UserProfileRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i20.VectorStoreService>(
        () => _i21.IsarVectorStoreService(gh<_i4.MemoryGraph>()));
    gh.lazySingleton<_i22.AuthRepository>(
        () => _i23.AuthRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i24.HealthRecordRepository>(
        () => _i25.HealthRecordRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i26.HealthReportRepository>(
        () => _i27.IsarHealthReportRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i28.LlmService>(
        () => _i29.RagLlmService(gh<_i20.VectorStoreService>()));
    gh.lazySingleton<_i30.SmartSearchUseCase>(
        () => _i30.SmartSearchUseCase(gh<_i20.VectorStoreService>()));
    gh.factory<_i31.UserProfileCubit>(
        () => _i31.UserProfileCubit(gh<_i18.UserProfileRepository>()));
    gh.factory<_i32.AuthCubit>(() => _i32.AuthCubit(
          gh<_i22.AuthRepository>(),
          gh<_i5.EncryptionService>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i33.HealthRecordCubit>(() => _i33.HealthRecordCubit(
          gh<_i24.HealthRecordRepository>(),
          gh<_i6.FilePickerService>(),
          gh<_i7.ImagePickerService>(),
          gh<_i15.OcrService>(),
          gh<_i20.VectorStoreService>(),
        ));
    gh.factory<_i34.HealthReportBloc>(() => _i34.HealthReportBloc(
          gh<_i26.HealthReportRepository>(),
          gh<_i16.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$MemoryModule extends _i35.MemoryModule {}

class _$DatabaseModule extends _i36.DatabaseModule {}
