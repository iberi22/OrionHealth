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

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i23;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i24;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i25;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i26;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i39;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i27;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i28;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i3;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i29;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i5;
import '../../features/dashboard/application/bloc/dashboard_cubit.dart' as _i30;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i40;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i31;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i32;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i6;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i7;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i14;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i41;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i33;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i15;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i34;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i16;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i37;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i9;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i19;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i11;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i10;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i35;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i36;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i20;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i12;
import '../../features/medications/infrastructure/repositories/medication_repository_impl.dart'
    as _i13;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i38;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i17;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i18;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i21;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i22;
import 'database_module.dart' as _i43;
import 'memory_module.dart' as _i42;

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
      () => _i11.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i12.MedicationRepository>(
        () => _i13.MedicationRepositoryImpl(gh<_i8.Isar>()));
    await gh.lazySingletonAsync<_i4.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i8.Isar>(),
        gh<_i4.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i14.OcrService>(() => _i14.OcrServiceStub());
    gh.lazySingleton<_i15.ReportGenerationService>(
        () => _i16.MockReportGenerationService());
    gh.lazySingleton<_i17.UserProfileRepository>(
        () => _i18.UserProfileRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i19.VectorStoreService>(
        () => _i20.IsarVectorStoreService(gh<_i4.MemoryGraph>()));
    gh.lazySingleton<_i21.VitalSignRepository>(
        () => _i22.VitalSignRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i23.AllergyRepository>(
        () => _i24.AllergyRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i25.AppointmentRepository>(
        () => _i26.AppointmentRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i27.AuthRepository>(
        () => _i28.AuthRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i29.BleMedicalSharingService>(
        () => _i29.BleMedicalSharingService(gh<_i5.EncryptionService>()));
    gh.factory<_i30.DashboardCubit>(() => _i30.DashboardCubit(
          gh<_i17.UserProfileRepository>(),
          gh<_i23.AllergyRepository>(),
          gh<_i21.VitalSignRepository>(),
          gh<_i25.AppointmentRepository>(),
          gh<_i12.MedicationRepository>(),
        ));
    gh.lazySingleton<_i31.HealthRecordRepository>(
        () => _i32.HealthRecordRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i33.HealthReportRepository>(
        () => _i34.IsarHealthReportRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i35.LlmService>(
        () => _i36.RagLlmService(gh<_i19.VectorStoreService>()));
    gh.lazySingleton<_i37.SmartSearchUseCase>(
        () => _i37.SmartSearchUseCase(gh<_i19.VectorStoreService>()));
    gh.factory<_i38.UserProfileCubit>(
        () => _i38.UserProfileCubit(gh<_i17.UserProfileRepository>()));
    gh.factory<_i39.AuthCubit>(() => _i39.AuthCubit(
          gh<_i27.AuthRepository>(),
          gh<_i5.EncryptionService>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i40.HealthRecordCubit>(() => _i40.HealthRecordCubit(
          gh<_i31.HealthRecordRepository>(),
          gh<_i6.FilePickerService>(),
          gh<_i7.ImagePickerService>(),
          gh<_i14.OcrService>(),
          gh<_i19.VectorStoreService>(),
        ));
    gh.factory<_i41.HealthReportBloc>(() => _i41.HealthReportBloc(
          gh<_i33.HealthReportRepository>(),
          gh<_i15.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$MemoryModule extends _i42.MemoryModule {}

class _$DatabaseModule extends _i43.DatabaseModule {}
