// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i7;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i3;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i22;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i23;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i24;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i25;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i34;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i26;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i27;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i5;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i6;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i13;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i35;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i28;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i14;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i29;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i15;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i32;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i8;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i18;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i10;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i9;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i30;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i31;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i19;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i11;
import '../../features/medications/infrastructure/repositories/medication_repository_impl.dart'
    as _i12;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i33;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i16;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i17;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i20;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i21;
import '../services/encryption_service.dart' as _i4;
import 'database_module.dart' as _i37;
import 'memory_module.dart' as _i36;

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
    gh.lazySingleton<_i3.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i4.EncryptionService>(() => _i4.EncryptionService());
    gh.lazySingleton<_i5.FilePickerService>(() => _i5.FilePickerServiceImpl());
    gh.lazySingleton<_i6.ImagePickerService>(
        () => _i6.ImagePickerServiceImpl());
    await gh.factoryAsync<_i7.Isar>(
      () => databaseModule.isar(gh<_i4.EncryptionService>()),
      preResolve: true,
    );
    gh.factory<_i8.LlmAdapter>(
      () => _i9.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i8.LlmAdapter>(
      () => _i10.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i11.MedicationRepository>(
        () => _i12.MedicationRepositoryImpl(gh<_i7.Isar>()));
    await gh.lazySingletonAsync<_i3.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i7.Isar>(),
        gh<_i3.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i13.OcrService>(() => _i13.OcrServiceStub());
    gh.lazySingleton<_i14.ReportGenerationService>(
        () => _i15.MockReportGenerationService());
    gh.lazySingleton<_i16.UserProfileRepository>(
        () => _i17.UserProfileRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i18.VectorStoreService>(
        () => _i19.IsarVectorStoreService(gh<_i3.MemoryGraph>()));
    gh.lazySingleton<_i20.VitalSignRepository>(
        () => _i21.VitalSignRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i22.AllergyRepository>(
        () => _i23.AllergyRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i24.AppointmentRepository>(
        () => _i25.AppointmentRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i26.HealthRecordRepository>(
        () => _i27.HealthRecordRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i28.HealthReportRepository>(
        () => _i29.IsarHealthReportRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i30.LlmService>(
        () => _i31.RagLlmService(gh<_i18.VectorStoreService>()));
    gh.lazySingleton<_i32.SmartSearchUseCase>(
        () => _i32.SmartSearchUseCase(gh<_i18.VectorStoreService>()));
    gh.factory<_i33.UserProfileCubit>(
        () => _i33.UserProfileCubit(gh<_i16.UserProfileRepository>()));
    gh.factory<_i34.HealthRecordCubit>(() => _i34.HealthRecordCubit(
          gh<_i26.HealthRecordRepository>(),
          gh<_i5.FilePickerService>(),
          gh<_i6.ImagePickerService>(),
          gh<_i13.OcrService>(),
          gh<_i18.VectorStoreService>(),
        ));
    gh.factory<_i35.HealthReportBloc>(() => _i35.HealthReportBloc(
          gh<_i28.HealthReportRepository>(),
          gh<_i14.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$MemoryModule extends _i36.MemoryModule {}

class _$DatabaseModule extends _i37.DatabaseModule {}
