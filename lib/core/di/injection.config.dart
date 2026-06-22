// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i13;
import 'package:dio/dio.dart' as _i21;
import 'package:flutter/services.dart' as _i74;
import 'package:flutter_appauth/flutter_appauth.dart' as _i30;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i32;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i34;
import 'package:health_wallet/health_wallet.dart' as _i26;
import 'package:http/http.dart' as _i17;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i47;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i24;
import 'package:medical_standards/medical_standards.dart' as _i55;

import '../../features/about/application/about_cubit.dart' as _i109;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i110;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i39;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i40;
import '../../features/allergies/application/allergies_cubit.dart' as _i178;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i111;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i112;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i115;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i113;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i127;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i134;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i166;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i114;
import '../../features/auth/application/auth_cubit.dart' as _i179;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i180;
import '../../features/auth/domain/auth_service.dart' as _i118;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i116;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i117;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i9;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i25;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i183;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i14;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i152;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i12;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i15;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i184;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i124;
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i18;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i126;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i125;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i137;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i139;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i182;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i132;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i167;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i177;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i130;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i83;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i88;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i106;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i181;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i49;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i48;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i131;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i84;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i89;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i107;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i133;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i22;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i23;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i185;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i77;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i78;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i123;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i128;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i136;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i79;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i146;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i144;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i36;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i35;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i90;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i145;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i188;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i147;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i148;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i28;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i41;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i80;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i196;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i149;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i37;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i120;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i170;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i171;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i119;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i10;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i73;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i75;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i108;
import '../../features/home/application/home_cubit.dart' as _i189;
import '../../features/home/domain/repositories/home_repository.dart' as _i150;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i187;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i38;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i151;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i169;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i121;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i54;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i56;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i50;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i99;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i51;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i31;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i154;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i33;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i153;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i52;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i156;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i155;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i191;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i58;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i57;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i100;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i190;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i53;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i193;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i72;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i163;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i194;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i59;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i61;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i63;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i11;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i159;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i60;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i62;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i64;
import '../../features/medications/application/medications_cubit.dart' as _i67;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i65;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i66;
import '../../features/meditation/application/meditation_cubit.dart' as _i160;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i69;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i122;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i138;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i140;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i85;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i92;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i68;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i70;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i142;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i141;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i143;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i43;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i42;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i44;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i81;
import '../../features/onboarding/application/sync_cubit.dart' as _i172;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i161;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i162;
import '../../features/reports/application/bloc/report_bloc.dart' as _i195;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i86;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i164;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i87;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i165;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i71;
import '../../features/settings/application/llm_settings_cubit.dart' as _i192;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i91;
import '../../features/settings/data/repositories/llm_settings_repository_impl.dart'
    as _i158;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i157;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i20;
import '../../features/sync/application/sync_cubit.dart' as _i186;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i93;
import '../../features/sync/domain/services/sync_service.dart' as _i173;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i129;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i29;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i45;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i94;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i27;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i46;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i76;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i174;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i175;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i95;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i96;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i98;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i97;
import '../../features/vitals/application/vitals_cubit.dart' as _i103;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i101;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i102;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i176;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i104;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i135;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i168;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i16;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i105;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/device_capability_service.dart' as _i19;
import '../services/privacy_anonymizer.dart' as _i82;
import 'calendar_module.dart' as _i198;
import 'database_module.dart' as _i201;
import 'fhir_module.dart' as _i202;
import 'memory_module.dart' as _i200;
import 'network_module.dart' as _i199;
import 'service_module.dart' as _i197;

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
    final serviceModule = _$ServiceModule();
    final calendarModule = _$CalendarModule();
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    final fhirModule = _$FhirModule();
    gh.lazySingleton<_i3.AIService>(() => _i3.AIService());
    gh.lazySingleton<_i4.AboutLocalDataSource>(
        () => _i4.AboutLocalDataSource());
    gh.lazySingleton<_i3.AgentMemoryService>(() => _i3.AgentMemoryService());
    gh.lazySingleton<_i5.AllergyService>(() => _i5.AllergyService());
    gh.lazySingleton<_i6.AppointmentService>(() => _i6.AppointmentService());
    gh.lazySingleton<_i7.AsrService>(() => _i7.AsrService());
    gh.lazySingleton<_i8.AudioService>(() => _i8.AudioService());
    gh.lazySingleton<_i9.BiometricService>(() => _i9.BiometricService());
    gh.lazySingleton<_i10.BleWrapper>(() => _i10.BleWrapper());
    gh.lazySingleton<_i11.BotBypassHandler>(() => _i11.BotBypassHandler());
    gh.factory<_i12.CalendarApiDatasource>(() => _i12.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i13.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i14.CalendarRepository>(
        () => _i15.CalendarRepositoryImpl(gh<_i12.CalendarApiDatasource>()));
    gh.lazySingleton<_i16.ChatAiDatasource>(() => _i16.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i17.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i18.DashboardRemoteDataSource>(
        () => _i18.DashboardRemoteDataSourceImpl());
    gh.lazySingleton<_i13.DeviceCalendarPlugin>(
        () => calendarModule.deviceCalendarPlugin);
    gh.lazySingleton<_i19.DeviceCapabilityService>(
        () => _i19.DeviceCapabilityService());
    gh.lazySingleton<_i20.DeviceCapabilityService>(
        () => _i20.DeviceCapabilityService());
    gh.lazySingleton<_i21.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i22.EmailRepository>(() => _i23.EmailRepositoryImpl(
          client: gh<_i17.Client>(),
          deviceCalendarPlugin: gh<_i13.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i24.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i25.EncryptionService>(() => _i25.EncryptionService());
    gh.lazySingleton<_i26.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i27.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i28.FilePickerService>(
        () => _i28.FilePickerServiceImpl());
    gh.lazySingleton<_i29.FilecoinDatasource>(() => _i29.FilecoinDatasource());
    gh.lazySingleton<_i30.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i31.FlutterGemmaWrapper>(
        () => _i31.FlutterGemmaWrapper());
    gh.lazySingleton<_i32.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i33.GeminiModelWrapper>(
        () => _i33.GeminiModelWrapper(gh<_i34.GenerativeModel>()));
    gh.lazySingleton<_i35.HealthDataImportService>(
        () => _i35.HealthDataImportService());
    gh.lazySingleton<_i36.HealthDataSensorDataSource>(
        () => _i36.HealthDataSensorDataSource());
    gh.lazySingleton<_i37.HealthSharingRemoteDataSource>(
        () => _i37.HealthSharingRemoteDataSource());
    gh.factory<_i38.HealthSummaryDatasource>(
        () => _i38.HealthSummaryDatasource());
    gh.lazySingleton<_i39.IAboutRepository>(() => _i40.AboutRepositoryImpl());
    gh.lazySingleton<_i41.ImagePickerService>(
        () => _i41.ImagePickerServiceImpl());
    gh.lazySingleton<_i42.IncentiveDatasource>(
        () => _i42.IncentiveDatasource());
    gh.lazySingleton<_i43.IncentiveRepository>(
        () => _i44.IncentiveRepositoryImpl(gh<_i42.IncentiveDatasource>()));
    gh.lazySingleton<_i45.IpfsDatasource>(
        () => _i45.IpfsDatasource(gh<_i21.Dio>()));
    gh.lazySingleton<_i46.IpfsService>(() => _i46.IpfsService(
          gh<_i45.IpfsDatasource>(),
          gh<_i29.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i47.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i48.LicenseRegistryLocalDataSource>(() {
      final i = _i48.LicenseRegistryLocalDataSource(gh<_i47.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i49.LicenseVerifier>(() async =>
        _i49.LicenseVerifier(
            await getAsync<_i48.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i50.LlmAdapter>(
      () => _i51.FlutterGemmaAdapter(wrapper: gh<_i31.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i50.LlmAdapter>(
      () => _i52.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i53.LocalLlmService>(() => _i53.LocalLlmService());
    gh.lazySingleton<_i54.LocalModelLocalDataSource>(
        () => _i54.LocalModelLocalDataSource());
    gh.lazySingleton<_i55.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i56.MedicalKnowledgeRepository>(
      () => _i57.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i56.MedicalKnowledgeRepository>(
      () => _i58.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i59.MedicalScraperService>(
        () => _i60.MedicalScraperServiceImpl(
              gh<_i21.Dio>(),
              gh<_i11.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i61.MedicalStandardsService>(() =>
        _i62.MedicalStandardsServiceImpl(gh<_i55.MedicalContextProvider>()));
    gh.lazySingleton<_i63.MedicalWebSearchService>(
        () => _i64.MedicalWebSearchServiceImpl(gh<_i21.Dio>()));
    gh.lazySingleton<_i65.MedicationRepository>(
        () => _i66.IsarMedicationRepository(gh<_i47.Isar>()));
    gh.factory<_i67.MedicationsCubit>(
        () => _i67.MedicationsCubit(gh<_i65.MedicationRepository>()));
    gh.lazySingleton<_i68.MeditationLocalDataSource>(
        () => _i68.MeditationLocalDataSource());
    gh.lazySingleton<_i69.MeditationRepository>(() =>
        _i70.MeditationRepositoryImpl(gh<_i68.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i24.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i47.Isar>(),
        gh<_i24.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i71.MockReportGenerationService>(
      () => _i71.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i72.ModelDownloadService>(
        () => _i72.ModelDownloadService());
    gh.lazySingleton<_i73.NfcHandler>(
        () => _i73.NfcHandler(channel: gh<_i74.MethodChannel>()));
    gh.lazySingleton<_i75.NfcSharingService>(
        () => _i75.NfcSharingService(gh<_i73.NfcHandler>()));
    gh.lazySingleton<_i76.NodeDiscoveryService>(
        () => _i76.NodeDiscoveryService());
    gh.lazySingleton<_i77.OAuthLocalDataSource>(
        () => _i77.OAuthLocalDataSource(gh<_i32.FlutterSecureStorage>()));
    gh.lazySingleton<_i78.OAuthRepository>(() => _i79.OAuthRepositoryImpl(
          gh<_i77.OAuthLocalDataSource>(),
          gh<_i21.Dio>(),
          gh<_i30.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i80.OcrService>(() => _i80.MlKitOcrService());
    gh.factory<_i81.OnboardingCubit>(() => _i81.OnboardingCubit());
    gh.lazySingleton<_i82.PromptScrubber>(
        () => _i82.PromptScrubber(gh<_i47.Isar>()));
    gh.lazySingleton<_i83.RatingRepository>(
        () => _i84.IsarRatingRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i85.RecommendScriptUseCase>(
        () => _i85.RecommendScriptUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i86.ReportRepository>(
        () => _i87.IsarReportRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i88.SecondOpinionRepository>(
        () => _i89.IsarSecondOpinionRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i90.SensorHealthDataSource>(
        () => _i90.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i91.SettingsLocalDataSource>(
        () => _i91.SettingsLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i92.StartSessionUseCase>(
        () => _i92.StartSessionUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i93.SyncRepository>(() => _i94.SyncRepositoryImpl(
          gh<_i27.FhirClient>(),
          gh<_i47.Isar>(),
          gh<_i32.FlutterSecureStorage>(),
          gh<_i76.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i55.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i95.UserProfileLocalDataSource>(
        () => _i95.UserProfileLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i96.UserProfileRepository>(
        () => _i97.UserProfileRepositoryImpl(gh<_i47.Isar>()));
    gh.lazySingleton<_i98.UserProfileService>(
        () => _i98.UserProfileService(gh<_i96.UserProfileRepository>()));
    gh.lazySingleton<_i99.VectorStoreService>(
        () => _i100.IsarVectorStoreService(
              gh<_i24.MemoryGraph>(),
              gh<_i56.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i101.VitalSignRepository>(
        () => _i102.VitalSignRepositoryImpl(gh<_i47.Isar>()));
    gh.factory<_i103.VitalsCubit>(
        () => _i103.VitalsCubit(gh<_i101.VitalSignRepository>()));
    gh.lazySingleton<_i104.VoiceChatRepository>(
        () => _i105.VoiceChatRepositoryImpl(gh<_i16.ChatAiDatasource>()));
    gh.lazySingleton<_i106.VouchRepository>(
        () => _i107.IsarVouchRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i26.WalletService>(() => databaseModule.walletService(
          gh<_i47.Isar>(),
          gh<_i26.EncryptionService>(),
        ));
    gh.lazySingleton<_i108.WifiDirectService>(() => _i108.WifiDirectService());
    gh.factory<_i109.AboutCubit>(
        () => _i109.AboutCubit(gh<_i39.IAboutRepository>()));
    gh.lazySingleton<_i110.AboutRemoteDataSource>(
        () => _i110.AboutRemoteDataSource(gh<_i21.Dio>()));
    gh.lazySingleton<_i111.AllergyRepository>(
        () => _i112.IsarAllergyRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i113.AppointmentRepository>(
        () => _i114.IsarAppointmentRepository(gh<_i47.Isar>()));
    gh.factory<_i115.AppointmentsCubit>(
        () => _i115.AppointmentsCubit(gh<_i113.AppointmentRepository>()));
    gh.lazySingleton<_i116.AuthRepository>(
        () => _i117.AuthRepositoryImpl(gh<_i47.Isar>()));
    gh.lazySingleton<_i118.AuthService>(
        () => _i118.AuthServiceImpl(gh<_i25.EncryptionService>()));
    gh.lazySingleton<_i119.BleSharingService>(
        () => _i119.BleSharingService(gh<_i10.BleWrapper>()));
    gh.lazySingleton<_i120.CancelSharingUseCase>(
        () => _i120.CancelSharingUseCase(
              gh<_i119.BleSharingService>(),
              gh<_i75.NfcSharingService>(),
              gh<_i108.WifiDirectService>(),
            ));
    gh.lazySingleton<_i121.ChatMessageLocalDataSource>(
        () => _i121.ChatMessageLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i122.CompleteSessionUseCase>(
        () => _i122.CompleteSessionUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i123.ConnectProviderUseCase>(() => _i123.ConnectProviderUseCase(
          gh<_i78.OAuthRepository>(),
          gh<_i96.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i124.DashboardLocalDataSource>(
        () => _i124.DashboardLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i125.DashboardRepository>(
        () => _i126.DashboardRepositoryImpl(
              gh<_i124.DashboardLocalDataSource>(),
              gh<_i18.DashboardRemoteDataSource>(),
              gh<_i101.VitalSignRepository>(),
              gh<_i65.MedicationRepository>(),
              gh<_i86.ReportRepository>(),
            ));
    gh.factory<_i127.DeleteAppointmentUseCase>(() =>
        _i127.DeleteAppointmentUseCase(gh<_i113.AppointmentRepository>()));
    gh.factory<_i128.DisconnectProviderUseCase>(
        () => _i128.DisconnectProviderUseCase(
              gh<_i78.OAuthRepository>(),
              gh<_i96.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i129.DistributedCacheUsecase>(
        () => _i129.DistributedCacheUsecase(gh<_i46.IpfsService>()));
    gh.lazySingleton<_i130.DoctorProfileRepository>(
        () => _i131.IsarDoctorProfileRepository(gh<_i47.Isar>()));
    gh.factoryAsync<_i132.DoctorVerificationCubit>(
        () async => _i132.DoctorVerificationCubit(
              gh<_i130.DoctorProfileRepository>(),
              gh<_i83.RatingRepository>(),
              await getAsync<_i49.LicenseVerifier>(),
            ));
    gh.factory<_i133.EmailCitasCubit>(() => _i133.EmailCitasCubit(
          gh<_i22.EmailRepository>(),
          gh<_i113.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i90.FileHealthDataSource>(
        () => _i90.FileHealthDataSourceImpl(
              gh<_i28.FilePickerService>(),
              gh<_i80.OcrService>(),
            ));
    gh.factory<_i134.GetAllAppointmentsUseCase>(() =>
        _i134.GetAllAppointmentsUseCase(gh<_i113.AppointmentRepository>()));
    gh.factory<_i135.GetChatHistoryUseCase>(
        () => _i135.GetChatHistoryUseCase(gh<_i104.VoiceChatRepository>()));
    gh.factory<_i136.GetConnectionsUseCase>(
        () => _i136.GetConnectionsUseCase(gh<_i78.OAuthRepository>()));
    gh.factory<_i137.GetDashboardStatsUseCase>(
        () => _i137.GetDashboardStatsUseCase(gh<_i125.DashboardRepository>()));
    gh.lazySingleton<_i138.GetProgressUseCase>(
        () => _i138.GetProgressUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i139.GetRecentActivityUseCase>(
        () => _i139.GetRecentActivityUseCase(gh<_i125.DashboardRepository>()));
    gh.lazySingleton<_i140.GetScriptsUseCase>(
        () => _i140.GetScriptsUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i141.GovernanceIpfsDatasource>(
        () => _i141.GovernanceIpfsDatasource(gh<_i45.IpfsDatasource>()));
    gh.lazySingleton<_i142.GovernanceRepository>(() =>
        _i143.GovernanceRepositoryImpl(gh<_i141.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i144.HealthDataFileDataSource>(
        () => _i144.HealthDataFileDataSource(
              gh<_i28.FilePickerService>(),
              gh<_i80.OcrService>(),
            ));
    gh.lazySingleton<_i145.HealthDataRepository>(
        () => _i145.HealthDataRepositoryImpl(
              gh<_i90.SensorHealthDataSource>(),
              gh<_i90.FileHealthDataSource>(),
            ));
    gh.factory<_i146.HealthImportCubit>(() => _i146.HealthImportCubit(
          gh<_i35.HealthDataImportService>(),
          gh<_i101.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i147.HealthRecordRepository>(
        () => _i148.HealthRecordRepositoryImpl(gh<_i47.Isar>()));
    gh.lazySingleton<_i149.HealthSharingLocalDataSource>(
        () => _i149.HealthSharingLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i150.HomeRepository>(() => _i151.HomeRepositoryImpl(
          gh<_i101.VitalSignRepository>(),
          gh<_i113.AppointmentRepository>(),
          gh<_i65.MedicationRepository>(),
        ));
    gh.factory<_i152.ImportCalendarUseCase>(() => _i152.ImportCalendarUseCase(
          gh<_i14.CalendarRepository>(),
          gh<_i113.AppointmentRepository>(),
          gh<_i96.UserProfileRepository>(),
        ));
    gh.factory<_i50.LlmAdapter>(
      () => _i153.MockLlmAdapter(gh<_i82.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i50.LlmAdapter>(
      () => _i154.GeminiLlmAdapter(
        scrubber: gh<_i82.PromptScrubber>(),
        userProfileRepository: gh<_i96.UserProfileRepository>(),
        modelWrapper: gh<_i33.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i155.LlmService>(() => _i156.GemmaLlmService(
          gh<_i99.VectorStoreService>(),
          gh<_i96.UserProfileRepository>(),
          gh<_i50.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i157.LlmSettingsRepository>(() =>
        _i158.LlmSettingsRepositoryImpl(gh<_i91.SettingsLocalDataSource>()));
    gh.lazySingleton<_i159.MedicalResearchService>(
        () => _i159.MedicalResearchService(
              gh<_i63.MedicalWebSearchService>(),
              gh<_i59.MedicalScraperService>(),
            ));
    gh.factory<_i160.MeditationCubit>(() => _i160.MeditationCubit(
          gh<_i85.RecommendScriptUseCase>(),
          gh<_i92.StartSessionUseCase>(),
          gh<_i122.CompleteSessionUseCase>(),
          gh<_i138.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i161.OnboardingRepository>(
        () => _i162.OnboardingRepositoryImpl(gh<_i96.UserProfileRepository>()));
    gh.lazySingleton<_i163.PatientContextIndexer>(
      () => _i163.PatientContextIndexer(
        gh<_i47.Isar>(),
        gh<_i99.VectorStoreService>(),
        gh<_i147.HealthRecordRepository>(),
        gh<_i65.MedicationRepository>(),
        gh<_i111.AllergyRepository>(),
        gh<_i101.VitalSignRepository>(),
        gh<_i113.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i164.ReportGenerationService>(
        () => _i165.GemmaReportGenerationService(
              gh<_i50.LlmAdapter>(instanceName: 'gemma'),
              gh<_i99.VectorStoreService>(),
              gh<_i96.UserProfileRepository>(),
              gh<_i82.PromptScrubber>(),
            ));
    gh.factory<_i166.SaveAppointmentUseCase>(
        () => _i166.SaveAppointmentUseCase(gh<_i113.AppointmentRepository>()));
    gh.factory<_i167.SecondOpinionCubit>(
        () => _i167.SecondOpinionCubit(gh<_i88.SecondOpinionRepository>()));
    gh.factory<_i168.SendMessageUseCase>(
        () => _i168.SendMessageUseCase(gh<_i104.VoiceChatRepository>()));
    gh.lazySingleton<_i169.SmartSearchUseCase>(
        () => _i169.SmartSearchUseCase(gh<_i99.VectorStoreService>()));
    gh.lazySingleton<_i170.StartListeningUseCase>(
        () => _i170.StartListeningUseCase(
              gh<_i119.BleSharingService>(),
              gh<_i75.NfcSharingService>(),
              gh<_i108.WifiDirectService>(),
            ));
    gh.lazySingleton<_i171.StartSharingUseCase>(() => _i171.StartSharingUseCase(
          gh<_i119.BleSharingService>(),
          gh<_i75.NfcSharingService>(),
          gh<_i108.WifiDirectService>(),
        ));
    gh.factory<_i172.SyncCubit>(() => _i172.SyncCubit(
          gh<_i55.SyncService>(),
          gh<_i99.VectorStoreService>(),
        ));
    gh.lazySingleton<_i173.SyncService>(() => _i174.SyncServiceImpl(
          gh<_i93.SyncRepository>(),
          gh<_i55.SyncService>(),
        ));
    gh.factory<_i175.UserProfileCubit>(
        () => _i175.UserProfileCubit(gh<_i96.UserProfileRepository>()));
    gh.factory<_i176.VoiceChatCubit>(() => _i176.VoiceChatCubit(
          gh<_i168.SendMessageUseCase>(),
          gh<_i135.GetChatHistoryUseCase>(),
          gh<_i104.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i177.VouchCubit>(
        () => _i177.VouchCubit(gh<_i106.VouchRepository>()));
    gh.factory<_i178.AllergiesCubit>(
        () => _i178.AllergiesCubit(gh<_i111.AllergyRepository>()));
    gh.factory<_i179.AuthCubit>(() => _i179.AuthCubit(gh<_i118.AuthService>()));
    gh.factory<_i180.AuthCubit>(() => _i180.AuthCubit(
          gh<_i116.AuthRepository>(),
          gh<_i25.EncryptionService>(),
          gh<_i9.BiometricService>(),
        ));
    gh.lazySingleton<_i181.BadgeCalculator>(() => _i181.BadgeCalculator(
          gh<_i130.DoctorProfileRepository>(),
          gh<_i83.RatingRepository>(),
          gh<_i106.VouchRepository>(),
        ));
    gh.factory<_i182.BadgeCubit>(
        () => _i182.BadgeCubit(gh<_i181.BadgeCalculator>()));
    gh.factory<_i183.CalendarImportCubit>(() => _i183.CalendarImportCubit(
          gh<_i14.CalendarRepository>(),
          gh<_i152.ImportCalendarUseCase>(),
        ));
    gh.factory<_i184.DashboardCubit>(() => _i184.DashboardCubit(
          gh<_i137.GetDashboardStatsUseCase>(),
          gh<_i139.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i185.EpsConnectionCubit>(() => _i185.EpsConnectionCubit(
          gh<_i136.GetConnectionsUseCase>(),
          gh<_i123.ConnectProviderUseCase>(),
          gh<_i128.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i186.FhirSyncCubit>(() => _i186.FhirSyncCubit(
          gh<_i173.SyncService>(),
          gh<_i76.NodeDiscoveryService>(),
        ));
    gh.factory<_i187.GetHealthSummaryUseCase>(
        () => _i187.GetHealthSummaryUseCase(gh<_i150.HomeRepository>()));
    gh.factory<_i188.HealthRecordCubit>(() => _i188.HealthRecordCubit(
          gh<_i147.HealthRecordRepository>(),
          gh<_i28.FilePickerService>(),
          gh<_i41.ImagePickerService>(),
          gh<_i80.OcrService>(),
          gh<_i99.VectorStoreService>(),
        ));
    gh.factory<_i189.HomeCubit>(() => _i189.HomeCubit(
          gh<_i187.GetHealthSummaryUseCase>(),
          gh<_i150.HomeRepository>(),
        ));
    gh.lazySingleton<_i190.LlmAdapterFactory>(
        () => _i190.LlmAdapterFactory(gh<_i157.LlmSettingsRepository>()));
    gh.lazySingleton<_i155.LlmService>(
      () => _i191.RagLlmService(
        gh<_i99.VectorStoreService>(),
        gh<_i159.MedicalResearchService>(),
        gh<_i96.UserProfileRepository>(),
        gh<_i50.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.factory<_i192.LlmSettingsCubit>(() => _i192.LlmSettingsCubit(
          gh<_i157.LlmSettingsRepository>(),
          gh<_i20.DeviceCapabilityService>(),
          gh<_i50.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i193.MedicalIndexingService>(
        () => _i193.MedicalIndexingService(
              gh<_i56.MedicalKnowledgeRepository>(),
              gh<_i99.VectorStoreService>(),
              gh<_i163.PatientContextIndexer>(),
            ));
    gh.factory<_i194.MedicalResearchCubit>(() => _i194.MedicalResearchCubit(
          gh<_i159.MedicalResearchService>(),
          gh<_i61.MedicalStandardsService>(),
        ));
    gh.factory<_i195.ReportBloc>(() => _i195.ReportBloc(
          gh<_i86.ReportRepository>(),
          gh<_i164.ReportGenerationService>(),
        ));
    gh.factory<_i196.SharingCubit>(() => _i196.SharingCubit(
          bleService: gh<_i119.BleSharingService>(),
          nfcService: gh<_i75.NfcSharingService>(),
          wifiService: gh<_i108.WifiDirectService>(),
          startSharingUseCase: gh<_i171.StartSharingUseCase>(),
          startListeningUseCase: gh<_i170.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i120.CancelSharingUseCase>(),
          walletService: gh<_i26.WalletService>(),
          walletEncryption: gh<_i26.EncryptionService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i197.ServiceModule {}

class _$CalendarModule extends _i198.CalendarModule {}

class _$NetworkModule extends _i199.NetworkModule {}

class _$MemoryModule extends _i200.MemoryModule {}

class _$DatabaseModule extends _i201.DatabaseModule {}

class _$FhirModule extends _i202.FhirModule {}
