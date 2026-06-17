// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i15;
import 'package:flutter_appauth/flutter_appauth.dart' as _i58;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i56;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i11;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i28;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i18;
import 'package:medical_standards/medical_standards.dart' as _i37;

import '../../features/about/application/about_cubit.dart' as _i79;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i3;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i4;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i25;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i26;
import '../../features/allergies/application/allergies_cubit.dart' as _i121;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i80;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i81;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i84;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i82;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i83;
import '../../features/auth/application/auth_cubit.dart' as _i123;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i122;
import '../../features/auth/domain/auth_service.dart' as _i87;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i85;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i86;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i7;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i19;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i124;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i100;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i99;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i125;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i12;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i89;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i90;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i91;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i16;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i17;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i92;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i55;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i57;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i95;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i93;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i23;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i22;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i64;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i94;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i127;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i96;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i97;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i21;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i27;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i59;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i66;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i98;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i24;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i8;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i9;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i53;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i52;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i67;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i114;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i88;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i36;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i38;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i29;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i74;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i30;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i31;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i101;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i102;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i103;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i32;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i106;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i105;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i128;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i39;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i40;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i75;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i104;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i35;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i129;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i51;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i111;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i130;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i41;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i43;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i45;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i10;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i108;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i42;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i44;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i46;
import '../../features/medications/application/medications_cubit.dart' as _i49;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i47;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i48;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i60;
import '../../features/onboarding/application/sync_cubit.dart' as _i115;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i109;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i110;
import '../../features/reports/application/bloc/report_bloc.dart' as _i131;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i62;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i112;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i63;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i113;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i50;
import '../../features/settings/application/llm_settings_cubit.dart' as _i107;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i65;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i33;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i13;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i34;
import '../../features/sync/application/sync_cubit.dart' as _i126;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i118;
import '../../features/sync/domain/services/sync_service.dart' as _i116;
import '../../features/sync/domain/sync_repository.dart' as _i68;
import '../../features/sync/domain/sync_service.dart' as _i119;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i69;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i20;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i54;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i117;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i120;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i70;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i71;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i73;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i72;
import '../../features/vitals/application/vitals_cubit.dart' as _i78;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i76;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i77;
import '../services/device_capability_service.dart' as _i14;
import '../services/privacy_anonymizer.dart' as _i61;
import 'database_module.dart' as _i135;
import 'fhir_module.dart' as _i132;
import 'memory_module.dart' as _i134;
import 'network_module.dart' as _i133;

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
    gh.lazySingleton<_i22.HealthDataImportService>(
        () => _i22.HealthDataImportService());
    gh.lazySingleton<_i23.HealthDataSensorDataSource>(
        () => _i23.HealthDataSensorDataSource());
    gh.lazySingleton<_i24.HealthSharingRemoteDataSource>(
        () => _i24.HealthSharingRemoteDataSource());
    gh.lazySingleton<_i25.IAboutRepository>(() => _i26.AboutRepositoryImpl());
    gh.lazySingleton<_i27.ImagePickerService>(
        () => _i27.ImagePickerServiceImpl());
    await gh.factoryAsync<_i28.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i29.LlmAdapter>(
      () => _i30.FlutterGemmaAdapter(wrapper: gh<_i31.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i29.LlmAdapter>(
      () => _i32.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i33.LlmSettingsRepository>(
        () => _i34.LlmSettingsRepositoryImpl(gh<_i28.Isar>()));
    gh.lazySingleton<_i35.LocalLlmService>(() => _i35.LocalLlmService());
    gh.lazySingleton<_i36.LocalModelLocalDataSource>(
        () => _i36.LocalModelLocalDataSource());
    gh.lazySingleton<_i37.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i38.MedicalKnowledgeRepository>(
      () => _i39.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i38.MedicalKnowledgeRepository>(
      () => _i40.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i41.MedicalScraperService>(
        () => _i42.MedicalScraperServiceImpl(
              gh<_i15.Dio>(),
              gh<_i10.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i43.MedicalStandardsService>(() =>
        _i44.MedicalStandardsServiceImpl(gh<_i37.MedicalContextProvider>()));
    gh.lazySingleton<_i45.MedicalWebSearchService>(
        () => _i46.MedicalWebSearchServiceImpl(gh<_i15.Dio>()));
    gh.lazySingleton<_i47.MedicationRepository>(
        () => _i48.IsarMedicationRepository(gh<_i28.Isar>()));
    gh.factory<_i49.MedicationsCubit>(
        () => _i49.MedicationsCubit(gh<_i47.MedicationRepository>()));
    await gh.lazySingletonAsync<_i18.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i28.Isar>(),
        gh<_i18.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i50.MockReportGenerationService>(
      () => _i50.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i51.ModelDownloadService>(
        () => _i51.ModelDownloadService());
    gh.lazySingleton<_i52.NfcSharingService>(
        () => _i52.NfcSharingService(nfcHandler: gh<_i53.NfcHandler>()));
    gh.lazySingleton<_i54.NodeDiscoveryService>(
        () => _i54.NodeDiscoveryService());
    gh.lazySingleton<_i55.OAuthLocalDataSource>(() =>
        _i55.OAuthLocalDataSource(storage: gh<_i56.FlutterSecureStorage>()));
    gh.lazySingleton<_i57.OAuthRepository>(() => _i57.OAuthRepositoryImpl(
          appAuth: gh<_i58.FlutterAppAuth>(),
          secureStorage: gh<_i56.FlutterSecureStorage>(),
          clientId: gh<String>(),
          redirectUrl: gh<String>(),
          discoveryUrl: gh<String>(),
          scopes: gh<List<String>>(),
          accessTokenKey: gh<String>(),
          idTokenKey: gh<String>(),
          refreshTokenKey: gh<String>(),
        ));
    gh.lazySingleton<_i59.OcrService>(() => _i59.MlKitOcrService());
    gh.factory<_i60.OnboardingCubit>(() => _i60.OnboardingCubit());
    gh.lazySingleton<_i61.PromptScrubber>(
        () => _i61.PromptScrubber(gh<_i28.Isar>()));
    gh.lazySingleton<_i62.ReportRepository>(
        () => _i63.IsarReportRepository(gh<_i28.Isar>()));
    gh.lazySingleton<_i64.SensorHealthDataSource>(
        () => _i64.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i65.SettingsLocalDataSource>(
        () => _i65.SettingsLocalDataSource(gh<_i28.Isar>()));
    gh.factory<_i66.SharingCubit>(() => _i66.SharingCubit(
          bleService: gh<_i8.BleSharingService>(),
          nfcService: gh<_i52.NfcSharingService>(),
          wifiService: gh<_i67.WifiDirectService>(),
        ));
    gh.lazySingleton<_i68.SyncRepository>(() => _i69.SyncRepositoryImpl(
          gh<_i20.FhirClient>(),
          gh<_i28.Isar>(),
          gh<_i56.FlutterSecureStorage>(),
          gh<_i54.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i37.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i70.UserProfileLocalDataSource>(
        () => _i70.UserProfileLocalDataSource(gh<_i28.Isar>()));
    gh.lazySingleton<_i71.UserProfileRepository>(
        () => _i72.UserProfileRepositoryImpl(gh<_i28.Isar>()));
    gh.lazySingleton<_i73.UserProfileService>(
        () => _i73.UserProfileService(gh<_i71.UserProfileRepository>()));
    gh.lazySingleton<_i74.VectorStoreService>(() => _i75.IsarVectorStoreService(
          gh<_i18.MemoryGraph>(),
          gh<_i38.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i76.VitalSignRepository>(
        () => _i77.VitalSignRepositoryImpl(gh<_i28.Isar>()));
    gh.factory<_i78.VitalsCubit>(
        () => _i78.VitalsCubit(gh<_i76.VitalSignRepository>()));
    gh.lazySingleton<_i67.WifiDirectService>(() => _i67.WifiDirectService());
    gh.factory<_i79.AboutCubit>(
        () => _i79.AboutCubit(gh<_i25.IAboutRepository>()));
    gh.lazySingleton<_i80.AllergyRepository>(
        () => _i81.IsarAllergyRepository(gh<_i28.Isar>()));
    gh.lazySingleton<_i82.AppointmentRepository>(
        () => _i83.IsarAppointmentRepository(gh<_i28.Isar>()));
    gh.factory<_i84.AppointmentsCubit>(
        () => _i84.AppointmentsCubit(gh<_i82.AppointmentRepository>()));
    gh.lazySingleton<_i85.AuthRepository>(
        () => _i86.AuthRepositoryImpl(gh<_i28.Isar>()));
    gh.lazySingleton<_i87.AuthService>(
        () => _i87.AuthServiceImpl(gh<_i19.EncryptionService>()));
    gh.lazySingleton<_i88.ChatMessageLocalDataSource>(
        () => _i88.ChatMessageLocalDataSource(gh<_i28.Isar>()));
    gh.lazySingleton<_i89.DashboardRepository>(
        () => _i90.DashboardRepositoryImpl(
              gh<_i76.VitalSignRepository>(),
              gh<_i47.MedicationRepository>(),
              gh<_i62.ReportRepository>(),
            ));
    gh.factory<_i91.EmailCitasCubit>(() => _i91.EmailCitasCubit(
          gh<_i16.EmailRepository>(),
          gh<_i82.AppointmentRepository>(),
        ));
    gh.factory<_i92.EpsConnectionCubit>(() => _i92.EpsConnectionCubit(
          gh<_i57.OAuthRepository>(),
          gh<_i71.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i64.FileHealthDataSource>(
        () => _i64.FileHealthDataSourceImpl(
              gh<_i21.FilePickerService>(),
              gh<_i59.OcrService>(),
            ));
    gh.lazySingleton<_i93.HealthDataFileDataSource>(
        () => _i93.HealthDataFileDataSource(
              gh<_i21.FilePickerService>(),
              gh<_i59.OcrService>(),
            ));
    gh.lazySingleton<_i94.HealthDataRepository>(
        () => _i94.HealthDataRepositoryImpl(
              gh<_i64.SensorHealthDataSource>(),
              gh<_i64.FileHealthDataSource>(),
            ));
    gh.factory<_i95.HealthImportCubit>(() => _i95.HealthImportCubit(
          gh<_i22.HealthDataImportService>(),
          gh<_i76.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i96.HealthRecordRepository>(
        () => _i97.HealthRecordRepositoryImpl(gh<_i28.Isar>()));
    gh.lazySingleton<_i98.HealthSharingLocalDataSource>(
        () => _i98.HealthSharingLocalDataSource(gh<_i28.Isar>()));
    gh.factory<_i99.ImportCalendarUseCase>(() => _i99.ImportCalendarUseCase(
          gh<_i100.CalendarRepository>(),
          gh<_i82.AppointmentRepository>(),
          gh<_i71.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i29.LlmAdapter>(
      () => _i101.GeminiLlmAdapter(
        scrubber: gh<_i61.PromptScrubber>(),
        userProfileRepository: gh<_i71.UserProfileRepository>(),
        modelWrapper: gh<_i102.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i29.LlmAdapter>(
      () => _i103.MockLlmAdapter(gh<_i61.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i104.LlmAdapterFactory>(
        () => _i104.LlmAdapterFactory(gh<_i33.LlmSettingsRepository>()));
    gh.lazySingleton<_i105.LlmService>(() => _i106.GemmaLlmService(
          gh<_i74.VectorStoreService>(),
          gh<_i71.UserProfileRepository>(),
          gh<_i29.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i107.LlmSettingsCubit>(() => _i107.LlmSettingsCubit(
          gh<_i33.LlmSettingsRepository>(),
          gh<_i13.DeviceCapabilityService>(),
          gh<_i29.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i108.MedicalResearchService>(
        () => _i108.MedicalResearchService(
              gh<_i45.MedicalWebSearchService>(),
              gh<_i41.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i109.OnboardingRepository>(
        () => _i110.OnboardingRepositoryImpl(gh<_i71.UserProfileRepository>()));
    gh.lazySingleton<_i111.PatientContextIndexer>(
      () => _i111.PatientContextIndexer(
        gh<_i28.Isar>(),
        gh<_i74.VectorStoreService>(),
        gh<_i96.HealthRecordRepository>(),
        gh<_i47.MedicationRepository>(),
        gh<_i80.AllergyRepository>(),
        gh<_i76.VitalSignRepository>(),
        gh<_i82.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i112.ReportGenerationService>(
        () => _i113.GemmaReportGenerationService(
              gh<_i29.LlmAdapter>(instanceName: 'gemma'),
              gh<_i74.VectorStoreService>(),
              gh<_i71.UserProfileRepository>(),
              gh<_i61.PromptScrubber>(),
            ));
    gh.lazySingleton<_i114.SmartSearchUseCase>(
        () => _i114.SmartSearchUseCase(gh<_i74.VectorStoreService>()));
    gh.factory<_i115.SyncCubit>(() => _i115.SyncCubit(
          gh<_i37.SyncService>(),
          gh<_i74.VectorStoreService>(),
        ));
    gh.lazySingleton<_i116.SyncService>(() => _i117.SyncServiceImpl(
          gh<_i118.SyncRepository>(),
          gh<_i37.SyncService>(),
        ));
    gh.lazySingleton<_i119.SyncService>(() => _i119.SyncService(
          gh<_i68.SyncRepository>(),
          gh<_i71.UserProfileRepository>(),
        ));
    gh.factory<_i120.UserProfileCubit>(
        () => _i120.UserProfileCubit(gh<_i71.UserProfileRepository>()));
    gh.factory<_i121.AllergiesCubit>(
        () => _i121.AllergiesCubit(gh<_i80.AllergyRepository>()));
    gh.factory<_i122.AuthCubit>(() => _i122.AuthCubit(
          gh<_i85.AuthRepository>(),
          gh<_i19.EncryptionService>(),
          gh<_i7.BiometricService>(),
        ));
    gh.factory<_i123.AuthCubit>(() => _i123.AuthCubit(gh<_i87.AuthService>()));
    gh.factory<_i124.CalendarImportCubit>(() => _i124.CalendarImportCubit(
          gh<_i100.CalendarRepository>(),
          gh<_i99.ImportCalendarUseCase>(),
        ));
    gh.factory<_i125.DashboardCubit>(
        () => _i125.DashboardCubit(gh<_i89.DashboardRepository>()));
    gh.factory<_i126.FhirSyncCubit>(
        () => _i126.FhirSyncCubit(gh<_i116.SyncService>()));
    gh.factory<_i127.HealthRecordCubit>(() => _i127.HealthRecordCubit(
          gh<_i96.HealthRecordRepository>(),
          gh<_i21.FilePickerService>(),
          gh<_i27.ImagePickerService>(),
          gh<_i59.OcrService>(),
          gh<_i74.VectorStoreService>(),
        ));
    gh.lazySingleton<_i105.LlmService>(
      () => _i128.RagLlmService(
        gh<_i74.VectorStoreService>(),
        gh<_i108.MedicalResearchService>(),
        gh<_i71.UserProfileRepository>(),
        gh<_i29.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i129.MedicalIndexingService>(
        () => _i129.MedicalIndexingService(
              gh<_i38.MedicalKnowledgeRepository>(),
              gh<_i74.VectorStoreService>(),
              gh<_i111.PatientContextIndexer>(),
            ));
    gh.factory<_i130.MedicalResearchCubit>(() => _i130.MedicalResearchCubit(
          gh<_i108.MedicalResearchService>(),
          gh<_i43.MedicalStandardsService>(),
        ));
    gh.factory<_i131.ReportBloc>(() => _i131.ReportBloc(
          gh<_i62.ReportRepository>(),
          gh<_i112.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i132.FhirModule {}

class _$NetworkModule extends _i133.NetworkModule {}

class _$MemoryModule extends _i134.MemoryModule {}

class _$DatabaseModule extends _i135.DatabaseModule {}
