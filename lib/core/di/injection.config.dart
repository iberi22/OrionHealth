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
    as _i27;
import '../../features/allergies/infrastructure/repositories/allergy_repository_impl.dart'
    as _i28;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i29;
import '../../features/appointments/infrastructure/repositories/appointment_repository_impl.dart'
    as _i30;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i31;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i5;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i40;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i32;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i33;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i6;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i7;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i16;
import '../../features/health_report/application/bloc/health_report_bloc.dart'
    as _i41;
import '../../features/health_report/domain/repositories/health_report_repository.dart'
    as _i34;
import '../../features/health_report/domain/services/report_generation_service.dart'
    as _i17;
import '../../features/health_report/infrastructure/repositories/isar_health_report_repository.dart'
    as _i35;
import '../../features/health_report/infrastructure/services/mock_report_generation_service.dart'
    as _i18;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i19;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i3;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i15;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i26;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i38;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i9;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i22;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i10;
import '../../features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart'
    as _i12;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i11;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i36;
import '../../features/local_agent/infrastructure/rag_llm_service.dart' as _i37;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i23;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i13;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i14;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i39;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i20;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i21;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i24;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i25;
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
    gh.lazySingleton<_i3.BleSharingService>(() => _i3.BleSharingService());
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
    gh.lazySingleton<_i9.LlmAdapter>(
      () => _i10.GeminiLlmAdapter(apiKey: gh<String>()),
      instanceName: 'gemini',
    );
    gh.factory<_i9.LlmAdapter>(
      () => _i11.MockLlmAdapter(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i9.LlmAdapter>(
      () => _i12.GemmaLlmAdapter(),
      instanceName: 'gemma',
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
    gh.lazySingleton<_i15.NfcSharingService>(() => _i15.NfcSharingService());
    gh.lazySingleton<_i16.OcrService>(() => _i16.OcrServiceStub());
    gh.lazySingleton<_i17.ReportGenerationService>(
        () => _i18.MockReportGenerationService());
    gh.factory<_i19.SharingCubit>(() => _i19.SharingCubit(
          gh<_i3.BleSharingService>(),
          gh<_i5.EncryptionService>(),
        ));
    gh.lazySingleton<_i20.UserProfileRepository>(
        () => _i21.UserProfileRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i22.VectorStoreService>(
        () => _i23.IsarVectorStoreService(gh<_i4.MemoryGraph>()));
    gh.lazySingleton<_i24.VitalSignRepository>(
        () => _i25.VitalSignRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i26.WifiDirectService>(() => _i26.WifiDirectService());
    gh.lazySingleton<_i27.AllergyRepository>(
        () => _i28.AllergyRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i29.AppointmentRepository>(
        () => _i30.AppointmentRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i31.BleMedicalSharingService>(
        () => _i31.BleMedicalSharingService(gh<_i5.EncryptionService>()));
    gh.lazySingleton<_i32.HealthRecordRepository>(
        () => _i33.HealthRecordRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i34.HealthReportRepository>(
        () => _i35.IsarHealthReportRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i36.LlmService>(
        () => _i37.RagLlmService(gh<_i22.VectorStoreService>()));
    gh.lazySingleton<_i38.SmartSearchUseCase>(
        () => _i38.SmartSearchUseCase(gh<_i22.VectorStoreService>()));
    gh.factory<_i39.UserProfileCubit>(
        () => _i39.UserProfileCubit(gh<_i20.UserProfileRepository>()));
    gh.factory<_i40.HealthRecordCubit>(() => _i40.HealthRecordCubit(
          gh<_i32.HealthRecordRepository>(),
          gh<_i6.FilePickerService>(),
          gh<_i7.ImagePickerService>(),
          gh<_i16.OcrService>(),
          gh<_i22.VectorStoreService>(),
        ));
    gh.factory<_i41.HealthReportBloc>(() => _i41.HealthReportBloc(
          gh<_i34.HealthReportRepository>(),
          gh<_i17.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$MemoryModule extends _i42.MemoryModule {}

class _$DatabaseModule extends _i43.DatabaseModule {}
