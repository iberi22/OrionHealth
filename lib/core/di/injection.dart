// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'injection.config.dart';
import '../../features/settings/application/llm_settings_cubit.dart';
import '../../features/settings/domain/repositories/llm_settings_repository.dart';
import '../../features/settings/domain/services/device_capability_service.dart';
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart';
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies({String? geminiApiKey}) async {
  if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
    getIt.registerLazySingleton<String>(
      () => geminiApiKey,
      instanceName: 'gemini_api_key',
    );
  }

  await getIt.init();

  // Register Settings feature dependencies manually
  final isar = getIt<Isar>();

  getIt.registerLazySingleton<LlmSettingsRepository>(
    () => LlmSettingsRepositoryImpl(isar),
  );

  getIt.registerLazySingleton<DeviceCapabilityService>(
    () => DeviceCapabilityService(),
  );

  getIt.registerFactory<LlmSettingsCubit>(
    () => LlmSettingsCubit(
      getIt<LlmSettingsRepository>(),
      getIt<DeviceCapabilityService>(),
    ),
  );

  // Initialize vector store indexing on startup (RAG pipeline)
  if (getIt.isRegistered<IsarVectorStoreService>()) {
    final vectorStore = getIt<IsarVectorStoreService>();
    await vectorStore.indexMedicalStandards();
  }
}
