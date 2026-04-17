import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'injection.config.dart';
import '../../features/settings/application/llm_settings_cubit.dart';
import '../../features/settings/domain/repositories/llm_settings_repository.dart';
import '../../features/settings/domain/services/device_capability_service.dart';
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  await getIt.init();
  
  // Register Settings feature dependencies manually
  final isar = getIt<Isar>();
  
  getIt.lazySingleton<LlmSettingsRepository>(
    () => LlmSettingsRepositoryImpl(isar),
  );
  
  getIt.lazySingleton<DeviceCapabilityService>(
    () => DeviceCapabilityService(),
  );
  
  getIt.factory<LlmSettingsCubit>(
    () => LlmSettingsCubit(
      getIt<LlmSettingsRepository>(),
      getIt<DeviceCapabilityService>(),
    ),
  );
}
