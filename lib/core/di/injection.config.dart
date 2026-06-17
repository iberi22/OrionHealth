// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i15;
import 'package:flutter_appauth/flutter_appauth.dart' as _i61;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i59;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i11;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i31;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i18;
import 'package:medical_standards/medical_standards.dart' as _i40;

import '../../features/about/application/about_cubit.dart' as _i82;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i3;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i4;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i26;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i27;
import '../../features/allergies/application/allergies_cubit.dart' as _i125;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i83;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i84;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i87;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i85;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i86;
import '../../features/auth/application/auth_cubit.dart' as _i127;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i126;
import '../../features/auth/domain/auth_service.dart' as _i90;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i88;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i89;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i7;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i19;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i128;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i104;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i103;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i129;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i12;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i92;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i93;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i95;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i16;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i17;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i96;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i58;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i60;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i99;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i97;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i24;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i23;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i67;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i98;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i131;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i100;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i101;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i21;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i28;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i62;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i69;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i102;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i25;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i8;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i9;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i56;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i55;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i70;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i118;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i91;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i39;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i41;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i32;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i77;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i34;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i35;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i105;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i106;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i107;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i33;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i110;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i109;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i132;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i43;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i42;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i78;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i108;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i38;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i133;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i54;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i115;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i134;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i44;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i46;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i48;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i10;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i112;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i45;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i47;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i49;
import '../../features/medications/application/medications_cubit.dart' as _i52;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i50;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i51;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i63;
import '../../features/onboarding/application/sync_cubit.dart' as _i119;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i113;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i114;
import '../../features/reports/application/bloc/report_bloc.dart' as _i135;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i65;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i116;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i66;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i117;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i53;
import '../../features/settings/application/llm_settings_cubit.dart' as _i111;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i68;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i36;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i14;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i37;
import '../../features/sync/application/sync_cubit.dart' as _i130;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i123;
import '../../features/sync/domain/services/sync_service.dart' as _i121;
import '../../features/sync/domain/sync_repository.dart' as _i71;
import '../../features/sync/domain/sync_service.dart' as _i120;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i94;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i22;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i29;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i72;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i20;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i30;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i57;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i122;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i124;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i73;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i74;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i76;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i75;
import '../../features/vitals/application/vitals_cubit.dart' as _i81;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i79;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i80;
import '../services/device_capability_service.dart' as _i13;
import '../services/privacy_anonymizer.dart' as _i64;
import 'database_module.dart' as _i139;
import 'fhir_module.dart' as _i136;
import 'memory_module.dart' as _i138;
import 'network_module.dart' as _i137;

const String _mobile = 'mobile';
const String _desktop = 'desktop';
const String _test = 'test';

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
    final fhirModule = _$FhirModule();
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.AboutLocalDataSource>(
        () => _i3.AboutLocalDataSource());
    gh.lazySingleton<_i4.AboutRemoteDataSource>(
        () => _i4.AboutRemoteDataSource());
    gh.lazySingleton<_i5.AllergyService>(() => _i5.AllergyService());
    gh.lazySingleton<_i6.AppointmentService>(() => _i6.AppointmentService());
    gh.lazySingleton<_i7.BiometricService>(() => _i7.BiometricService());
    gh.lazySingleton<_i8.BleSharingService>(
        () => _i8.BleSharingService(bleWrapper: gh<_i9.BleWrapper>()));
    gh.lazySingleton<_i9.BleWrapper>(() => _i9.BleWrapper());
    gh.lazySingleton<_i10.BotBypassHandler>(() => _i10.BotBypassHandler());
    gh.lazySingleton<_i11.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i12.DashboardLocalDataSource>(
        () => _i12.DashboardLocalDataSource());
    gh.lazySingleton<_i13.DeviceCapabilityService>(
        () => _i13.DeviceCapabilityService());
    gh.lazySingleton<_i14.DeviceCapabilityService>(
        () => _i14.DeviceCapabilityService());
    gh.lazySingleton<_i15.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i16.EmailRepository>(
        () => _i17.EmailRepositoryImpl(client: gh<_i11.Client>()));
    gh.lazySingleton<_i18.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i19.EncryptionService>(() => _i19.EncryptionService());
    gh.lazySingleton<_i20.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i21.FilePickerService>(
        () => _i21.FilePickerServiceImpl());
    gh.lazySingleton<_i22.FilecoinDatasource>(() => _i22.FilecoinDatasource());
    gh.lazySingleton<_i23.HealthDataImportService>(
        () => _i23.HealthDataImportService());
    gh.lazySingleton<_i24.HealthDataSensorDataSource>(
        () => _i24.HealthDataSensorDataSource());
    gh.lazySingleton<_i25.HealthSharingRemoteDataSource>(
        () => _i25.HealthSharingRemoteDataSource());
    gh.lazySingleton<_i26.IAboutRepository>(() => _i27.AboutRepositoryImpl());
    gh.lazySingleton<_i28.ImagePickerService>(
        () => _i28.ImagePickerServiceImpl());
    gh.lazySingleton<_i29.IpfsDatasource>(
        () => _i29.IpfsDatasource(gh<_i15.Dio>()));
    gh.lazySingleton<_i30.IpfsService>(() => _i30.IpfsService(
          gh<_i29.IpfsDatasource>(),
          gh<_i22.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i31.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i32.LlmAdapter>(
      () => _i33.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i32.LlmAdapter>(
      () => _i34.FlutterGemmaAdapter(wrapper: gh<_i35.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i36.LlmSettingsRepository>(
        () => _i37.LlmSettingsRepositoryImpl(gh<_i31.Isar>()));
    gh.lazySingleton<_i38.LocalLlmService>(() => _i38.LocalLlmService());
    gh.lazySingleton<_i39.LocalModelLocalDataSource>(
        () => _i39.LocalModelLocalDataSource());
    gh.lazySingleton<_i40.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i41.MedicalKnowledgeRepository>(
      () => _i42.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i41.MedicalKnowledgeRepository>(
      () => _i43.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i44.MedicalScraperService>(
        () => _i45.MedicalScraperServiceImpl(
              gh<_i15.Dio>(),
              gh<_i10.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i46.MedicalStandardsService>(() =>
        _i47.MedicalStandardsServiceImpl(gh<_i40.MedicalContextProvider>()));
    gh.lazySingleton<_i48.MedicalWebSearchService>(
        () => _i49.MedicalWebSearchServiceImpl(gh<_i15.Dio>()));
    gh.lazySingleton<_i50.MedicationRepository>(
        () => _i51.IsarMedicationRepository(gh<_i31.Isar>()));
    gh.factory<_i52.MedicationsCubit>(
        () => _i52.MedicationsCubit(gh<_i50.MedicationRepository>()));
    await gh.lazySingletonAsync<_i18.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i31.Isar>(),
        gh<_i18.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i53.MockReportGenerationService>(
      () => _i53.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i54.ModelDownloadService>(
        () => _i54.ModelDownloadService());
    gh.lazySingleton<_i55.NfcSharingService>(
        () => _i55.NfcSharingService(nfcHandler: gh<_i56.NfcHandler>()));
    gh.lazySingleton<_i57.NodeDiscoveryService>(
        () => _i57.NodeDiscoveryService());
    gh.lazySingleton<_i58.OAuthLocalDataSource>(() =>
        _i58.OAuthLocalDataSource(storage: gh<_i59.FlutterSecureStorage>()));
    gh.lazySingleton<_i60.OAuthRepository>(() => _i60.OAuthRepositoryImpl(
          appAuth: gh<_i61.FlutterAppAuth>(),
          secureStorage: gh<_i59.FlutterSecureStorage>(),
          clientId: gh<String>(),
          redirectUrl: gh<String>(),
          discoveryUrl: gh<String>(),
          scopes: gh<List<String>>(),
          accessTokenKey: gh<String>(),
          idTokenKey: gh<String>(),
          refreshTokenKey: gh<String>(),
        ));
    gh.lazySingleton<_i62.OcrService>(() => _i62.MlKitOcrService());
    gh.factory<_i63.OnboardingCubit>(() => _i63.OnboardingCubit());
    gh.lazySingleton<_i64.PromptScrubber>(
        () => _i64.PromptScrubber(gh<_i31.Isar>()));
    gh.lazySingleton<_i65.ReportRepository>(
        () => _i66.IsarReportRepository(gh<_i31.Isar>()));
    gh.lazySingleton<_i67.SensorHealthDataSource>(
        () => _i67.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i68.SettingsLocalDataSource>(
        () => _i68.SettingsLocalDataSource(gh<_i31.Isar>()));
    gh.factory<_i69.SharingCubit>(() => _i69.SharingCubit(
          bleService: gh<_i8.BleSharingService>(),
          nfcService: gh<_i55.NfcSharingService>(),
          wifiService: gh<_i70.WifiDirectService>(),
        ));
    gh.lazySingleton<_i71.SyncRepository>(() => _i72.SyncRepositoryImpl(
          gh<_i20.FhirClient>(),
          gh<_i31.Isar>(),
          gh<_i59.FlutterSecureStorage>(),
          gh<_i57.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i40.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i73.UserProfileLocalDataSource>(
        () => _i73.UserProfileLocalDataSource(gh<_i31.Isar>()));
    gh.lazySingleton<_i74.UserProfileRepository>(
        () => _i75.UserProfileRepositoryImpl(gh<_i31.Isar>()));
    gh.lazySingleton<_i76.UserProfileService>(
        () => _i76.UserProfileService(gh<_i74.UserProfileRepository>()));
    gh.lazySingleton<_i77.VectorStoreService>(() => _i78.IsarVectorStoreService(
          gh<_i18.MemoryGraph>(),
          gh<_i41.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i79.VitalSignRepository>(
        () => _i80.VitalSignRepositoryImpl(gh<_i31.Isar>()));
    gh.factory<_i81.VitalsCubit>(
        () => _i81.VitalsCubit(gh<_i79.VitalSignRepository>()));
    gh.lazySingleton<_i70.WifiDirectService>(() => _i70.WifiDirectService());
    gh.factory<_i82.AboutCubit>(
        () => _i82.AboutCubit(gh<_i26.IAboutRepository>()));
    gh.lazySingleton<_i83.AllergyRepository>(
        () => _i84.IsarAllergyRepository(gh<_i31.Isar>()));
    gh.lazySingleton<_i85.AppointmentRepository>(
        () => _i86.IsarAppointmentRepository(gh<_i31.Isar>()));
    gh.factory<_i87.AppointmentsCubit>(
        () => _i87.AppointmentsCubit(gh<_i85.AppointmentRepository>()));
    gh.lazySingleton<_i88.AuthRepository>(
        () => _i89.AuthRepositoryImpl(gh<_i31.Isar>()));
    gh.lazySingleton<_i90.AuthService>(
        () => _i90.AuthServiceImpl(gh<_i19.EncryptionService>()));
    gh.lazySingleton<_i91.ChatMessageLocalDataSource>(
        () => _i91.ChatMessageLocalDataSource(gh<_i31.Isar>()));
    gh.lazySingleton<_i92.DashboardRepository>(
        () => _i93.DashboardRepositoryImpl(
              gh<_i79.VitalSignRepository>(),
              gh<_i50.MedicationRepository>(),
              gh<_i65.ReportRepository>(),
            ));
    gh.lazySingleton<_i94.DistributedCacheUsecase>(
        () => _i94.DistributedCacheUsecase(gh<_i30.IpfsService>()));
    gh.factory<_i95.EmailCitasCubit>(() => _i95.EmailCitasCubit(
          gh<_i16.EmailRepository>(),
          gh<_i85.AppointmentRepository>(),
        ));
    gh.factory<_i96.EpsConnectionCubit>(() => _i96.EpsConnectionCubit(
          gh<_i60.OAuthRepository>(),
          gh<_i74.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i67.FileHealthDataSource>(
        () => _i67.FileHealthDataSourceImpl(
              gh<_i21.FilePickerService>(),
              gh<_i62.OcrService>(),
            ));
    gh.lazySingleton<_i97.HealthDataFileDataSource>(
        () => _i97.HealthDataFileDataSource(
              gh<_i21.FilePickerService>(),
              gh<_i62.OcrService>(),
            ));
    gh.lazySingleton<_i98.HealthDataRepository>(
        () => _i98.HealthDataRepositoryImpl(
              gh<_i67.SensorHealthDataSource>(),
              gh<_i67.FileHealthDataSource>(),
            ));
    gh.factory<_i99.HealthImportCubit>(() => _i99.HealthImportCubit(
          gh<_i23.HealthDataImportService>(),
          gh<_i79.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i100.HealthRecordRepository>(
        () => _i101.HealthRecordRepositoryImpl(gh<_i31.Isar>()));
    gh.lazySingleton<_i102.HealthSharingLocalDataSource>(
        () => _i102.HealthSharingLocalDataSource(gh<_i31.Isar>()));
    gh.factory<_i103.ImportCalendarUseCase>(() => _i103.ImportCalendarUseCase(
          gh<_i104.CalendarRepository>(),
          gh<_i85.AppointmentRepository>(),
          gh<_i74.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i32.LlmAdapter>(
      () => _i105.GeminiLlmAdapter(
        scrubber: gh<_i64.PromptScrubber>(),
        userProfileRepository: gh<_i74.UserProfileRepository>(),
        modelWrapper: gh<_i106.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i32.LlmAdapter>(
      () => _i107.MockLlmAdapter(gh<_i64.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i108.LlmAdapterFactory>(
        () => _i108.LlmAdapterFactory(gh<_i36.LlmSettingsRepository>()));
    gh.lazySingleton<_i109.LlmService>(() => _i110.GemmaLlmService(
          gh<_i77.VectorStoreService>(),
          gh<_i74.UserProfileRepository>(),
          gh<_i32.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i111.LlmSettingsCubit>(() => _i111.LlmSettingsCubit(
          gh<_i36.LlmSettingsRepository>(),
          gh<_i14.DeviceCapabilityService>(),
          gh<_i32.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i112.MedicalResearchService>(
        () => _i112.MedicalResearchService(
              gh<_i48.MedicalWebSearchService>(),
              gh<_i44.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i113.OnboardingRepository>(
        () => _i114.OnboardingRepositoryImpl(gh<_i74.UserProfileRepository>()));
    gh.lazySingleton<_i115.PatientContextIndexer>(
      () => _i115.PatientContextIndexer(
        gh<_i31.Isar>(),
        gh<_i77.VectorStoreService>(),
        gh<_i100.HealthRecordRepository>(),
        gh<_i50.MedicationRepository>(),
        gh<_i83.AllergyRepository>(),
        gh<_i79.VitalSignRepository>(),
        gh<_i85.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i116.ReportGenerationService>(
        () => _i117.GemmaReportGenerationService(
              gh<_i32.LlmAdapter>(instanceName: 'gemma'),
              gh<_i77.VectorStoreService>(),
              gh<_i74.UserProfileRepository>(),
              gh<_i64.PromptScrubber>(),
            ));
    gh.lazySingleton<_i118.SmartSearchUseCase>(
        () => _i118.SmartSearchUseCase(gh<_i77.VectorStoreService>()));
    gh.factory<_i119.SyncCubit>(() => _i119.SyncCubit(
          gh<_i40.SyncService>(),
          gh<_i77.VectorStoreService>(),
        ));
    gh.lazySingleton<_i120.SyncService>(() => _i120.SyncService(
          gh<_i71.SyncRepository>(),
          gh<_i74.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i121.SyncService>(() => _i122.SyncServiceImpl(
          gh<_i123.SyncRepository>(),
          gh<_i40.SyncService>(),
        ));
    gh.factory<_i124.UserProfileCubit>(
        () => _i124.UserProfileCubit(gh<_i74.UserProfileRepository>()));
    gh.factory<_i125.AllergiesCubit>(
        () => _i125.AllergiesCubit(gh<_i83.AllergyRepository>()));
    gh.factory<_i126.AuthCubit>(() => _i126.AuthCubit(
          gh<_i88.AuthRepository>(),
          gh<_i19.EncryptionService>(),
          gh<_i7.BiometricService>(),
        ));
    gh.factory<_i127.AuthCubit>(() => _i127.AuthCubit(gh<_i90.AuthService>()));
    gh.factory<_i128.CalendarImportCubit>(() => _i128.CalendarImportCubit(
          gh<_i104.CalendarRepository>(),
          gh<_i103.ImportCalendarUseCase>(),
        ));
    gh.factory<_i129.DashboardCubit>(
        () => _i129.DashboardCubit(gh<_i92.DashboardRepository>()));
    gh.factory<_i130.FhirSyncCubit>(
        () => _i130.FhirSyncCubit(gh<_i121.SyncService>()));
    gh.factory<_i131.HealthRecordCubit>(() => _i131.HealthRecordCubit(
          gh<_i100.HealthRecordRepository>(),
          gh<_i21.FilePickerService>(),
          gh<_i28.ImagePickerService>(),
          gh<_i62.OcrService>(),
          gh<_i77.VectorStoreService>(),
        ));
    gh.lazySingleton<_i109.LlmService>(
      () => _i132.RagLlmService(
        gh<_i77.VectorStoreService>(),
        gh<_i112.MedicalResearchService>(),
        gh<_i74.UserProfileRepository>(),
        gh<_i32.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i133.MedicalIndexingService>(
        () => _i133.MedicalIndexingService(
              gh<_i41.MedicalKnowledgeRepository>(),
              gh<_i77.VectorStoreService>(),
              gh<_i115.PatientContextIndexer>(),
            ));
    gh.factory<_i134.MedicalResearchCubit>(() => _i134.MedicalResearchCubit(
          gh<_i112.MedicalResearchService>(),
          gh<_i46.MedicalStandardsService>(),
        ));
    gh.factory<_i135.ReportBloc>(() => _i135.ReportBloc(
          gh<_i65.ReportRepository>(),
          gh<_i116.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i136.FhirModule {}

class _$NetworkModule extends _i137.NetworkModule {}

class _$MemoryModule extends _i138.MemoryModule {}

class _$DatabaseModule extends _i139.DatabaseModule {}
