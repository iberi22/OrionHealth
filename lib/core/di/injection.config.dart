// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i13;
import 'package:dio/dio.dart' as _i23;
import 'package:flutter/services.dart' as _i77;
import 'package:flutter_appauth/flutter_appauth.dart' as _i32;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i34;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i36;
import 'package:health_wallet/health_wallet.dart' as _i28;
import 'package:http/http.dart' as _i19;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i50;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i26;
import 'package:medical_standards/medical_standards.dart' as _i58;
import 'package:shared_preferences/shared_preferences.dart' as _i94;

import '../../features/about/application/about_cubit.dart' as _i112;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i113;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i42;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i43;
import '../../features/allergies/application/allergies_cubit.dart' as _i181;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i114;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i115;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i118;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i116;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i129;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i136;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i169;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i117;
import '../../features/auth/application/auth_cubit.dart' as _i183;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i182;
import '../../features/auth/domain/auth_service.dart' as _i121;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i119;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i120;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i9;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i27;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i186;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i16;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i14;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i155;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i12;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i17;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i15;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i187;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i20;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i128;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i127;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i139;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i141;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i185;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i134;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i170;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i180;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i132;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i85;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i90;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i109;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i184;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i52;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i51;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i133;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i86;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i91;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i110;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i135;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i24;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i25;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i188;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i80;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i81;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i126;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i130;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i138;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i82;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i148;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i146;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i38;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i37;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i92;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i147;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i191;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i149;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i150;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i30;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i44;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i83;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i200;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i151;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i39;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i123;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i173;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i174;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i122;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i10;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i76;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i78;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i111;
import '../../features/home/application/home_cubit.dart' as _i192;
import '../../features/home/domain/repositories/home_repository.dart' as _i153;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i190;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i40;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i152;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i41;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i154;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i172;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i124;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i57;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i59;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i53;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i102;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i54;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i33;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i156;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i35;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i157;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i55;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i159;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i158;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i194;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i61;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i60;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i103;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i193;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i56;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i196;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i75;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i166;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i197;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i62;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i64;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i66;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i11;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i162;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i63;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i65;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i67;
import '../../features/medications/application/medications_cubit.dart' as _i70;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i68;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i69;
import '../../features/meditation/application/meditation_cubit.dart' as _i163;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i72;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i125;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i140;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i142;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i87;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i95;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i71;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i73;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i144;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i143;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i145;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i46;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i45;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i47;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i198;
import '../../features/onboarding/application/sync_cubit.dart' as _i175;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i164;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i165;
import '../../features/reports/application/bloc/report_bloc.dart' as _i199;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i88;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i167;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i89;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i168;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i74;
import '../../features/settings/application/llm_settings_cubit.dart' as _i195;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i93;
import '../../features/settings/data/repositories/llm_settings_repository_impl.dart'
    as _i161;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i160;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i22;
import '../../features/sync/application/sync_cubit.dart' as _i189;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i96;
import '../../features/sync/domain/services/sync_service.dart' as _i176;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i131;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i31;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i48;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i97;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i29;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i49;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i79;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i177;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i178;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i98;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i99;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i101;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i100;
import '../../features/vitals/application/vitals_cubit.dart' as _i106;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i104;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i105;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i179;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i107;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i137;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i171;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i18;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i108;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/device_capability_service.dart' as _i21;
import '../services/privacy_anonymizer.dart' as _i84;
import 'calendar_module.dart' as _i202;
import 'database_module.dart' as _i205;
import 'fhir_module.dart' as _i206;
import 'memory_module.dart' as _i204;
import 'network_module.dart' as _i203;
import 'service_module.dart' as _i201;

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
    gh.lazySingleton<_i14.CalendarParserService>(
        () => _i15.CalendarParserServiceImpl());
    gh.lazySingleton<_i16.CalendarRepository>(
        () => _i17.CalendarRepositoryImpl(gh<_i12.CalendarApiDatasource>()));
    gh.lazySingleton<_i18.ChatAiDatasource>(() => _i18.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i19.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i20.DashboardLocalDataSource>(
        () => _i20.DashboardLocalDataSource());
    gh.lazySingleton<_i13.DeviceCalendarPlugin>(
        () => calendarModule.deviceCalendarPlugin);
    gh.lazySingleton<_i21.DeviceCapabilityService>(
        () => _i21.DeviceCapabilityService());
    gh.lazySingleton<_i22.DeviceCapabilityService>(
        () => _i22.DeviceCapabilityService());
    gh.lazySingleton<_i23.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i24.EmailRepository>(() => _i25.EmailRepositoryImpl(
          client: gh<_i19.Client>(),
          deviceCalendarPlugin: gh<_i13.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i26.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i27.EncryptionService>(() => _i27.EncryptionService());
    gh.lazySingleton<_i28.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i29.FhirClient>(
        () => fhirModule.fhirClient(gh<_i19.Client>()));
    gh.lazySingleton<_i30.FilePickerService>(
        () => _i30.FilePickerServiceImpl());
    gh.lazySingleton<_i31.FilecoinDatasource>(() => _i31.FilecoinDatasource());
    gh.lazySingleton<_i32.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i33.FlutterGemmaWrapper>(
        () => _i33.FlutterGemmaWrapper());
    gh.lazySingleton<_i34.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i35.GeminiModelWrapper>(
        () => _i35.GeminiModelWrapper(gh<_i36.GenerativeModel>()));
    gh.lazySingleton<_i37.HealthDataImportService>(
        () => _i37.HealthDataImportService());
    gh.lazySingleton<_i38.HealthDataSensorDataSource>(
        () => _i38.HealthDataSensorDataSource());
    gh.lazySingleton<_i39.HealthSharingRemoteDataSource>(
        () => _i39.HealthSharingRemoteDataSource());
    gh.factory<_i40.HealthSummaryDatasource>(
        () => _i40.HealthSummaryDatasource());
    gh.factory<_i41.HomeRemoteDataSource>(
        () => _i41.HomeRemoteDataSource(gh<_i23.Dio>()));
    gh.lazySingleton<_i42.IAboutRepository>(() => _i43.AboutRepositoryImpl());
    gh.lazySingleton<_i44.ImagePickerService>(
        () => _i44.ImagePickerServiceImpl());
    gh.lazySingleton<_i45.IncentiveDatasource>(
        () => _i45.IncentiveDatasource());
    gh.lazySingleton<_i46.IncentiveRepository>(
        () => _i47.IncentiveRepositoryImpl(gh<_i45.IncentiveDatasource>()));
    gh.lazySingleton<_i48.IpfsDatasource>(
        () => _i48.IpfsDatasource(gh<_i23.Dio>()));
    gh.lazySingleton<_i49.IpfsService>(() => _i49.IpfsService(
          gh<_i48.IpfsDatasource>(),
          gh<_i31.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i50.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i51.LicenseRegistryLocalDataSource>(() {
      final i = _i51.LicenseRegistryLocalDataSource(gh<_i50.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i52.LicenseVerifier>(() async =>
        _i52.LicenseVerifier(
            await getAsync<_i51.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i53.LlmAdapter>(
      () => _i54.FlutterGemmaAdapter(wrapper: gh<_i33.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i53.LlmAdapter>(
      () => _i55.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i56.LocalLlmService>(() => _i56.LocalLlmService());
    gh.lazySingleton<_i57.LocalModelLocalDataSource>(
        () => _i57.LocalModelLocalDataSource());
    gh.lazySingleton<_i58.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i59.MedicalKnowledgeRepository>(
      () => _i60.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i59.MedicalKnowledgeRepository>(
      () => _i61.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i62.MedicalScraperService>(
        () => _i63.MedicalScraperServiceImpl(
              gh<_i23.Dio>(),
              gh<_i11.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i64.MedicalStandardsService>(() =>
        _i65.MedicalStandardsServiceImpl(gh<_i58.MedicalContextProvider>()));
    gh.lazySingleton<_i66.MedicalWebSearchService>(
        () => _i67.MedicalWebSearchServiceImpl(gh<_i23.Dio>()));
    gh.lazySingleton<_i68.MedicationRepository>(
        () => _i69.IsarMedicationRepository(gh<_i50.Isar>()));
    gh.factory<_i70.MedicationsCubit>(
        () => _i70.MedicationsCubit(gh<_i68.MedicationRepository>()));
    gh.lazySingleton<_i71.MeditationLocalDataSource>(
        () => _i71.MeditationLocalDataSource());
    gh.lazySingleton<_i72.MeditationRepository>(() =>
        _i73.MeditationRepositoryImpl(gh<_i71.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i26.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i50.Isar>(),
        gh<_i26.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i74.MockReportGenerationService>(
      () => _i74.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i75.ModelDownloadService>(
        () => _i75.ModelDownloadService());
    gh.lazySingleton<_i76.NfcHandler>(
        () => _i76.NfcHandler(channel: gh<_i77.MethodChannel>()));
    gh.lazySingleton<_i78.NfcSharingService>(
        () => _i78.NfcSharingService(gh<_i76.NfcHandler>()));
    gh.lazySingleton<_i79.NodeDiscoveryService>(
        () => _i79.NodeDiscoveryService());
    gh.lazySingleton<_i80.OAuthLocalDataSource>(
        () => _i80.OAuthLocalDataSource(gh<_i34.FlutterSecureStorage>()));
    gh.lazySingleton<_i81.OAuthRepository>(() => _i82.OAuthRepositoryImpl(
          gh<_i80.OAuthLocalDataSource>(),
          gh<_i23.Dio>(),
          gh<_i32.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i83.OcrService>(() => _i83.MlKitOcrService());
    gh.lazySingleton<_i84.PromptScrubber>(
        () => _i84.PromptScrubber(gh<_i50.Isar>()));
    gh.lazySingleton<_i85.RatingRepository>(
        () => _i86.IsarRatingRepository(gh<_i50.Isar>()));
    gh.lazySingleton<_i87.RecommendScriptUseCase>(
        () => _i87.RecommendScriptUseCase(gh<_i72.MeditationRepository>()));
    gh.lazySingleton<_i88.ReportRepository>(
        () => _i89.IsarReportRepository(gh<_i50.Isar>()));
    gh.lazySingleton<_i90.SecondOpinionRepository>(
        () => _i91.IsarSecondOpinionRepository(gh<_i50.Isar>()));
    gh.lazySingleton<_i92.SensorHealthDataSource>(
        () => _i92.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i93.SettingsLocalDataSource>(
        () => _i93.SettingsLocalDataSource(gh<_i50.Isar>()));
    await gh.factoryAsync<_i94.SharedPreferences>(
      () => serviceModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i95.StartSessionUseCase>(
        () => _i95.StartSessionUseCase(gh<_i72.MeditationRepository>()));
    gh.lazySingleton<_i96.SyncRepository>(() => _i97.SyncRepositoryImpl(
          gh<_i29.FhirClient>(),
          gh<_i50.Isar>(),
          gh<_i34.FlutterSecureStorage>(),
          gh<_i79.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i58.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i98.UserProfileLocalDataSource>(
        () => _i98.UserProfileLocalDataSource(gh<_i50.Isar>()));
    gh.lazySingleton<_i99.UserProfileRepository>(
        () => _i100.UserProfileRepositoryImpl(gh<_i50.Isar>()));
    gh.lazySingleton<_i101.UserProfileService>(
        () => _i101.UserProfileService(gh<_i99.UserProfileRepository>()));
    gh.lazySingleton<_i102.VectorStoreService>(
        () => _i103.IsarVectorStoreService(
              gh<_i26.MemoryGraph>(),
              gh<_i59.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i104.VitalSignRepository>(
        () => _i105.VitalSignRepositoryImpl(gh<_i50.Isar>()));
    gh.factory<_i106.VitalsCubit>(
        () => _i106.VitalsCubit(gh<_i104.VitalSignRepository>()));
    gh.lazySingleton<_i107.VoiceChatRepository>(
        () => _i108.VoiceChatRepositoryImpl(gh<_i18.ChatAiDatasource>()));
    gh.lazySingleton<_i109.VouchRepository>(
        () => _i110.IsarVouchRepository(gh<_i50.Isar>()));
    gh.lazySingleton<_i28.WalletService>(() => databaseModule.walletService(
          gh<_i50.Isar>(),
          gh<_i28.EncryptionService>(),
        ));
    gh.lazySingleton<_i111.WifiDirectService>(() => _i111.WifiDirectService());
    gh.factory<_i112.AboutCubit>(
        () => _i112.AboutCubit(gh<_i42.IAboutRepository>()));
    gh.lazySingleton<_i113.AboutRemoteDataSource>(
        () => _i113.AboutRemoteDataSource(gh<_i23.Dio>()));
    gh.lazySingleton<_i114.AllergyRepository>(
        () => _i115.IsarAllergyRepository(gh<_i50.Isar>()));
    gh.lazySingleton<_i116.AppointmentRepository>(
        () => _i117.IsarAppointmentRepository(gh<_i50.Isar>()));
    gh.factory<_i118.AppointmentsCubit>(
        () => _i118.AppointmentsCubit(gh<_i116.AppointmentRepository>()));
    gh.lazySingleton<_i119.AuthRepository>(
        () => _i120.AuthRepositoryImpl(gh<_i50.Isar>()));
    gh.lazySingleton<_i121.AuthService>(
        () => _i121.AuthServiceImpl(gh<_i27.EncryptionService>()));
    gh.lazySingleton<_i122.BleSharingService>(
        () => _i122.BleSharingService(gh<_i10.BleWrapper>()));
    gh.lazySingleton<_i123.CancelSharingUseCase>(
        () => _i123.CancelSharingUseCase(
              gh<_i122.BleSharingService>(),
              gh<_i78.NfcSharingService>(),
              gh<_i111.WifiDirectService>(),
            ));
    gh.lazySingleton<_i124.ChatMessageLocalDataSource>(
        () => _i124.ChatMessageLocalDataSource(gh<_i50.Isar>()));
    gh.lazySingleton<_i125.CompleteSessionUseCase>(
        () => _i125.CompleteSessionUseCase(gh<_i72.MeditationRepository>()));
    gh.factory<_i126.ConnectProviderUseCase>(() => _i126.ConnectProviderUseCase(
          gh<_i81.OAuthRepository>(),
          gh<_i99.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i127.DashboardRepository>(
        () => _i128.DashboardRepositoryImpl(
              gh<_i104.VitalSignRepository>(),
              gh<_i68.MedicationRepository>(),
              gh<_i88.ReportRepository>(),
            ));
    gh.factory<_i129.DeleteAppointmentUseCase>(() =>
        _i129.DeleteAppointmentUseCase(gh<_i116.AppointmentRepository>()));
    gh.factory<_i130.DisconnectProviderUseCase>(
        () => _i130.DisconnectProviderUseCase(
              gh<_i81.OAuthRepository>(),
              gh<_i99.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i131.DistributedCacheUsecase>(
        () => _i131.DistributedCacheUsecase(gh<_i49.IpfsService>()));
    gh.lazySingleton<_i132.DoctorProfileRepository>(
        () => _i133.IsarDoctorProfileRepository(gh<_i50.Isar>()));
    gh.factoryAsync<_i134.DoctorVerificationCubit>(
        () async => _i134.DoctorVerificationCubit(
              gh<_i132.DoctorProfileRepository>(),
              gh<_i85.RatingRepository>(),
              await getAsync<_i52.LicenseVerifier>(),
            ));
    gh.factory<_i135.EmailCitasCubit>(() => _i135.EmailCitasCubit(
          gh<_i24.EmailRepository>(),
          gh<_i116.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i92.FileHealthDataSource>(
        () => _i92.FileHealthDataSourceImpl(
              gh<_i30.FilePickerService>(),
              gh<_i83.OcrService>(),
            ));
    gh.factory<_i136.GetAllAppointmentsUseCase>(() =>
        _i136.GetAllAppointmentsUseCase(gh<_i116.AppointmentRepository>()));
    gh.factory<_i137.GetChatHistoryUseCase>(
        () => _i137.GetChatHistoryUseCase(gh<_i107.VoiceChatRepository>()));
    gh.factory<_i138.GetConnectionsUseCase>(
        () => _i138.GetConnectionsUseCase(gh<_i81.OAuthRepository>()));
    gh.factory<_i139.GetDashboardStatsUseCase>(
        () => _i139.GetDashboardStatsUseCase(gh<_i127.DashboardRepository>()));
    gh.lazySingleton<_i140.GetProgressUseCase>(
        () => _i140.GetProgressUseCase(gh<_i72.MeditationRepository>()));
    gh.factory<_i141.GetRecentActivityUseCase>(
        () => _i141.GetRecentActivityUseCase(gh<_i127.DashboardRepository>()));
    gh.lazySingleton<_i142.GetScriptsUseCase>(
        () => _i142.GetScriptsUseCase(gh<_i72.MeditationRepository>()));
    gh.lazySingleton<_i143.GovernanceIpfsDatasource>(
        () => _i143.GovernanceIpfsDatasource(gh<_i48.IpfsDatasource>()));
    gh.lazySingleton<_i144.GovernanceRepository>(() =>
        _i145.GovernanceRepositoryImpl(gh<_i143.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i146.HealthDataFileDataSource>(
        () => _i146.HealthDataFileDataSource(
              gh<_i30.FilePickerService>(),
              gh<_i83.OcrService>(),
            ));
    gh.lazySingleton<_i147.HealthDataRepository>(
        () => _i147.HealthDataRepositoryImpl(
              gh<_i92.SensorHealthDataSource>(),
              gh<_i92.FileHealthDataSource>(),
            ));
    gh.factory<_i148.HealthImportCubit>(() => _i148.HealthImportCubit(
          gh<_i37.HealthDataImportService>(),
          gh<_i104.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i149.HealthRecordRepository>(
        () => _i150.HealthRecordRepositoryImpl(gh<_i50.Isar>()));
    gh.lazySingleton<_i151.HealthSharingLocalDataSource>(
        () => _i151.HealthSharingLocalDataSource(gh<_i50.Isar>()));
    gh.factory<_i152.HomeLocalDataSource>(
        () => _i152.HomeLocalDataSource(gh<_i94.SharedPreferences>()));
    gh.lazySingleton<_i153.HomeRepository>(() => _i154.HomeRepositoryImpl(
          gh<_i104.VitalSignRepository>(),
          gh<_i116.AppointmentRepository>(),
          gh<_i68.MedicationRepository>(),
          gh<_i152.HomeLocalDataSource>(),
          gh<_i41.HomeRemoteDataSource>(),
        ));
    gh.factory<_i155.ImportCalendarUseCase>(() => _i155.ImportCalendarUseCase(
          gh<_i16.CalendarRepository>(),
          gh<_i116.AppointmentRepository>(),
          gh<_i99.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i53.LlmAdapter>(
      () => _i156.GeminiLlmAdapter(
        scrubber: gh<_i84.PromptScrubber>(),
        userProfileRepository: gh<_i99.UserProfileRepository>(),
        modelWrapper: gh<_i35.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i53.LlmAdapter>(
      () => _i157.MockLlmAdapter(gh<_i84.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i158.LlmService>(() => _i159.GemmaLlmService(
          gh<_i102.VectorStoreService>(),
          gh<_i99.UserProfileRepository>(),
          gh<_i53.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i160.LlmSettingsRepository>(() =>
        _i161.LlmSettingsRepositoryImpl(gh<_i93.SettingsLocalDataSource>()));
    gh.lazySingleton<_i162.MedicalResearchService>(
        () => _i162.MedicalResearchService(
              gh<_i66.MedicalWebSearchService>(),
              gh<_i62.MedicalScraperService>(),
            ));
    gh.factory<_i163.MeditationCubit>(() => _i163.MeditationCubit(
          gh<_i87.RecommendScriptUseCase>(),
          gh<_i95.StartSessionUseCase>(),
          gh<_i125.CompleteSessionUseCase>(),
          gh<_i140.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i164.OnboardingRepository>(
        () => _i165.OnboardingRepositoryImpl(gh<_i99.UserProfileRepository>()));
    gh.lazySingleton<_i166.PatientContextIndexer>(
      () => _i166.PatientContextIndexer(
        gh<_i50.Isar>(),
        gh<_i102.VectorStoreService>(),
        gh<_i149.HealthRecordRepository>(),
        gh<_i68.MedicationRepository>(),
        gh<_i114.AllergyRepository>(),
        gh<_i104.VitalSignRepository>(),
        gh<_i116.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i167.ReportGenerationService>(
        () => _i168.GemmaReportGenerationService(
              gh<_i53.LlmAdapter>(instanceName: 'gemma'),
              gh<_i102.VectorStoreService>(),
              gh<_i99.UserProfileRepository>(),
              gh<_i84.PromptScrubber>(),
            ));
    gh.factory<_i169.SaveAppointmentUseCase>(
        () => _i169.SaveAppointmentUseCase(gh<_i116.AppointmentRepository>()));
    gh.factory<_i170.SecondOpinionCubit>(
        () => _i170.SecondOpinionCubit(gh<_i90.SecondOpinionRepository>()));
    gh.factory<_i171.SendMessageUseCase>(
        () => _i171.SendMessageUseCase(gh<_i107.VoiceChatRepository>()));
    gh.lazySingleton<_i172.SmartSearchUseCase>(
        () => _i172.SmartSearchUseCase(gh<_i102.VectorStoreService>()));
    gh.lazySingleton<_i173.StartListeningUseCase>(
        () => _i173.StartListeningUseCase(
              gh<_i122.BleSharingService>(),
              gh<_i78.NfcSharingService>(),
              gh<_i111.WifiDirectService>(),
            ));
    gh.lazySingleton<_i174.StartSharingUseCase>(() => _i174.StartSharingUseCase(
          gh<_i122.BleSharingService>(),
          gh<_i78.NfcSharingService>(),
          gh<_i111.WifiDirectService>(),
        ));
    gh.factory<_i175.SyncCubit>(() => _i175.SyncCubit(
          gh<_i58.SyncService>(),
          gh<_i102.VectorStoreService>(),
        ));
    gh.lazySingleton<_i176.SyncService>(() => _i177.SyncServiceImpl(
          gh<_i96.SyncRepository>(),
          gh<_i58.SyncService>(),
        ));
    gh.factory<_i178.UserProfileCubit>(
        () => _i178.UserProfileCubit(gh<_i99.UserProfileRepository>()));
    gh.factory<_i179.VoiceChatCubit>(() => _i179.VoiceChatCubit(
          gh<_i171.SendMessageUseCase>(),
          gh<_i137.GetChatHistoryUseCase>(),
          gh<_i107.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i180.VouchCubit>(
        () => _i180.VouchCubit(gh<_i109.VouchRepository>()));
    gh.factory<_i181.AllergiesCubit>(
        () => _i181.AllergiesCubit(gh<_i114.AllergyRepository>()));
    gh.factory<_i182.AuthCubit>(() => _i182.AuthCubit(
          gh<_i119.AuthRepository>(),
          gh<_i27.EncryptionService>(),
          gh<_i9.BiometricService>(),
        ));
    gh.factory<_i183.AuthCubit>(() => _i183.AuthCubit(gh<_i121.AuthService>()));
    gh.lazySingleton<_i184.BadgeCalculator>(() => _i184.BadgeCalculator(
          gh<_i132.DoctorProfileRepository>(),
          gh<_i85.RatingRepository>(),
          gh<_i109.VouchRepository>(),
        ));
    gh.factory<_i185.BadgeCubit>(
        () => _i185.BadgeCubit(gh<_i184.BadgeCalculator>()));
    gh.factory<_i186.CalendarImportCubit>(() => _i186.CalendarImportCubit(
          gh<_i16.CalendarRepository>(),
          gh<_i155.ImportCalendarUseCase>(),
        ));
    gh.factory<_i187.DashboardCubit>(() => _i187.DashboardCubit(
          gh<_i139.GetDashboardStatsUseCase>(),
          gh<_i141.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i188.EpsConnectionCubit>(() => _i188.EpsConnectionCubit(
          gh<_i138.GetConnectionsUseCase>(),
          gh<_i126.ConnectProviderUseCase>(),
          gh<_i130.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i189.FhirSyncCubit>(() => _i189.FhirSyncCubit(
          gh<_i176.SyncService>(),
          gh<_i79.NodeDiscoveryService>(),
        ));
    gh.factory<_i190.GetHealthSummaryUseCase>(
        () => _i190.GetHealthSummaryUseCase(gh<_i153.HomeRepository>()));
    gh.factory<_i191.HealthRecordCubit>(() => _i191.HealthRecordCubit(
          gh<_i149.HealthRecordRepository>(),
          gh<_i30.FilePickerService>(),
          gh<_i44.ImagePickerService>(),
          gh<_i83.OcrService>(),
          gh<_i102.VectorStoreService>(),
        ));
    gh.factory<_i192.HomeCubit>(() => _i192.HomeCubit(
          gh<_i190.GetHealthSummaryUseCase>(),
          gh<_i153.HomeRepository>(),
        ));
    gh.lazySingleton<_i193.LlmAdapterFactory>(
        () => _i193.LlmAdapterFactory(gh<_i160.LlmSettingsRepository>()));
    gh.lazySingleton<_i158.LlmService>(
      () => _i194.RagLlmService(
        gh<_i102.VectorStoreService>(),
        gh<_i162.MedicalResearchService>(),
        gh<_i99.UserProfileRepository>(),
        gh<_i53.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.factory<_i195.LlmSettingsCubit>(() => _i195.LlmSettingsCubit(
          gh<_i160.LlmSettingsRepository>(),
          gh<_i22.DeviceCapabilityService>(),
          gh<_i53.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i196.MedicalIndexingService>(
        () => _i196.MedicalIndexingService(
              gh<_i59.MedicalKnowledgeRepository>(),
              gh<_i102.VectorStoreService>(),
              gh<_i166.PatientContextIndexer>(),
            ));
    gh.factory<_i197.MedicalResearchCubit>(() => _i197.MedicalResearchCubit(
          gh<_i162.MedicalResearchService>(),
          gh<_i64.MedicalStandardsService>(),
        ));
    gh.factory<_i198.OnboardingCubit>(
        () => _i198.OnboardingCubit(gh<_i164.OnboardingRepository>()));
    gh.factory<_i199.ReportBloc>(() => _i199.ReportBloc(
          gh<_i88.ReportRepository>(),
          gh<_i167.ReportGenerationService>(),
        ));
    gh.factory<_i200.SharingCubit>(() => _i200.SharingCubit(
          bleService: gh<_i122.BleSharingService>(),
          nfcService: gh<_i78.NfcSharingService>(),
          wifiService: gh<_i111.WifiDirectService>(),
          startSharingUseCase: gh<_i174.StartSharingUseCase>(),
          startListeningUseCase: gh<_i173.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i123.CancelSharingUseCase>(),
          walletService: gh<_i28.WalletService>(),
          walletEncryption: gh<_i28.EncryptionService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i201.ServiceModule {}

class _$CalendarModule extends _i202.CalendarModule {}

class _$NetworkModule extends _i203.NetworkModule {}

class _$MemoryModule extends _i204.MemoryModule {}

class _$DatabaseModule extends _i205.DatabaseModule {}

class _$FhirModule extends _i206.FhirModule {}
