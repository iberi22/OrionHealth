// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i5;

import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i16;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i13;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i14;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i3;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i4;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i8;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i11;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i6;
import '../../features/local_agent/infrastructure/mock_llm_service.dart' as _i7;
import '../../features/local_agent/infrastructure/services/mock_vector_store_service.dart'
    as _i12;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i15;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i9;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i10;
import 'database_module.dart' as _i17;

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
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.FilePickerService>(() => _i3.FilePickerServiceImpl());
    gh.lazySingleton<_i4.ImagePickerService>(
        () => _i4.ImagePickerServiceImpl());
    await gh.factoryAsync<_i5.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i6.LlmService>(() => _i7.MockLlmService());
    gh.lazySingleton<_i8.OcrService>(() => _i8.OcrServiceStub());
    gh.lazySingleton<_i9.UserProfileRepository>(
        () => _i10.UserProfileRepositoryImpl(gh<_i5.Isar>()));
    gh.lazySingleton<_i11.VectorStoreService>(
        () => _i12.MockVectorStoreService());
    gh.lazySingleton<_i13.HealthRecordRepository>(
        () => _i14.HealthRecordRepositoryImpl(gh<_i5.Isar>()));
    gh.factory<_i15.UserProfileCubit>(
        () => _i15.UserProfileCubit(gh<_i9.UserProfileRepository>()));
    gh.factory<_i16.HealthRecordCubit>(() => _i16.HealthRecordCubit(
          gh<_i13.HealthRecordRepository>(),
          gh<_i3.FilePickerService>(),
          gh<_i4.ImagePickerService>(),
          gh<_i8.OcrService>(),
        ));
    return this;
  }
}

class _$DatabaseModule extends _i17.DatabaseModule {}
