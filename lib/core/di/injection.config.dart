// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i15;
import 'package:dio/dio.dart' as _i25;
import 'package:flutter/services.dart' as _i80;
import 'package:flutter_appauth/flutter_appauth.dart' as _i34;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i36;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i38;
import 'package:health_wallet/health_wallet.dart' as _i30;
import 'package:http/http.dart' as _i21;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i53;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i28;
import 'package:just_audio/just_audio.dart' as _i9;
import 'package:medical_standards/medical_standards.dart' as _i61;
import 'package:shared_preferences/shared_preferences.dart' as _i44;

import '../../features/about/application/about_cubit.dart' as _i117;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i118;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i46;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i47;
import '../../features/allergies/application/allergies_cubit.dart' as _i192;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i193;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i119;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i120;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i123;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i194;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i121;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i135;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i144;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i179;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i122;
import '../../features/auth/application/auth_cubit.dart' as _i196;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i195;
import '../../features/auth/domain/auth_service.dart' as _i126;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i124;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i125;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i11;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i29;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i199;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i18;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i16;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i164;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i14;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i19;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i17;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i200;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i132;
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i22;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i134;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i133;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i147;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i149;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i198;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i141;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i180;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i191;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i139;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i89;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i95;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i114;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i197;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i55;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i54;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i140;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i90;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i96;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i115;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i142;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i143;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i26;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i100;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i27;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i202;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i203;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i84;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i85;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i131;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i136;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i146;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i86;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i157;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i158;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i154;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i40;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i155;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i39;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i94;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i97;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i156;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i206;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i159;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i160;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i32;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i48;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i87;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i215;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i161;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i41;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i128;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i183;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i184;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i127;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i12;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i79;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i81;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i116;
import '../../features/home/application/home_cubit.dart' as _i207;
import '../../features/home/domain/repositories/home_repository.dart' as _i162;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i205;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i42;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i43;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i45;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i163;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i182;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i129;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i60;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i62;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i56;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i107;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i57;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i35;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i166;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i37;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i165;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i58;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i168;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i167;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i209;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i64;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i63;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i108;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i208;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i59;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i211;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i78;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i176;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i212;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i65;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i67;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i69;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i13;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i171;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i66;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i68;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i70;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i172;
import '../../features/medications/application/medications_cubit.dart' as _i73;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i71;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i72;
import '../../features/meditation/application/meditation_cubit.dart' as _i173;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i75;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i130;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i148;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i150;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i91;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i99;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i74;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i76;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i152;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i151;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i153;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i50;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i49;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i51;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i213;
import '../../features/onboarding/application/sync_cubit.dart' as _i185;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i174;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i175;
import '../../features/reports/application/bloc/report_bloc.dart' as _i214;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i92;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i177;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i93;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i178;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i77;
import '../../features/settings/application/llm_settings_cubit.dart' as _i210;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i98;
import '../../features/settings/data/repositories/llm_settings_repository_impl.dart'
    as _i170;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i169;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i23;
import '../../features/sync/application/sync_cubit.dart' as _i204;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i101;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i137;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i82;
import '../../features/sync/domain/services/sync_service.dart' as _i186;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i201;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i33;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i52;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i102;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i31;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i138;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i83;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i187;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i188;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i103;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i104;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i106;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i105;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i189;
import '../../features/vitals/application/vitals_cubit.dart' as _i111;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i109;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i110;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i190;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i112;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i145;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i181;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i20;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i113;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/audio/audio_recorder_service.dart' as _i10;
import '../services/device_capability_service.dart' as _i24;
import '../services/privacy_anonymizer.dart' as _i88;
import 'database_module.dart' as _i219;
import 'fhir_module.dart' as _i220;
import 'memory_module.dart' as _i218;
import 'network_module.dart' as _i217;
import 'service_module.dart' as _i216;

const String _desktop = 'desktop';
const String _test = 'test';
const String _mobile = 'mobile';

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
    gh.lazySingleton<_i8.AudioService>(() => _i8.AudioService(
          player: gh<_i9.AudioPlayer>(),
          recorder: gh<_i10.AudioRecorderService>(),
        ));
    gh.lazySingleton<_i11.BiometricService>(() => _i11.BiometricService());
    gh.lazySingleton<_i12.BleWrapper>(() => _i12.BleWrapper());
    gh.lazySingleton<_i13.BotBypassHandler>(() => _i13.BotBypassHandler());
    gh.factory<_i14.CalendarApiDatasource>(() => _i14.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i15.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i16.CalendarParserService>(
        () => _i17.CalendarParserServiceImpl());
    gh.lazySingleton<_i18.CalendarRepository>(
        () => _i19.CalendarRepositoryImpl(gh<_i14.CalendarApiDatasource>()));
    gh.lazySingleton<_i20.ChatAiDatasource>(() => _i20.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i21.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i22.DashboardRemoteDataSource>(
        () => _i22.DashboardRemoteDataSourceImpl());
    gh.lazySingleton<_i23.DeviceCapabilityService>(
        () => _i23.DeviceCapabilityService());
    gh.lazySingleton<_i24.DeviceCapabilityService>(
        () => _i24.DeviceCapabilityService());
    gh.lazySingleton<_i25.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i26.EmailRepository>(() => _i27.EmailRepositoryImpl(
          gh<_i21.Client>(),
          gh<_i15.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i28.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i29.EncryptionService>(() => _i29.EncryptionService());
    gh.lazySingleton<_i30.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i31.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i32.FilePickerService>(
        () => _i32.FilePickerServiceImpl());
    gh.lazySingleton<_i33.FilecoinDatasource>(() => _i33.FilecoinDatasource());
    gh.lazySingleton<_i34.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i35.FlutterGemmaWrapper>(
        () => _i35.FlutterGemmaWrapper());
    gh.lazySingleton<_i36.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i37.GeminiModelWrapper>(
        () => _i37.GeminiModelWrapper(gh<_i38.GenerativeModel>()));
    gh.lazySingleton<_i39.HealthDataImportService>(
        () => _i39.HealthDataImportService());
    gh.lazySingleton<_i40.HealthDataSensorDataSource>(
        () => _i40.HealthDataSensorDataSource());
    gh.lazySingleton<_i41.HealthSharingRemoteDataSource>(
        () => _i41.HealthSharingRemoteDataSource());
    gh.factory<_i42.HealthSummaryDatasource>(
        () => _i42.HealthSummaryDatasource());
    gh.factory<_i43.HomeLocalDataSource>(
        () => _i43.HomeLocalDataSource(gh<_i44.SharedPreferences>()));
    gh.factory<_i45.HomeRemoteDataSource>(
        () => _i45.HomeRemoteDataSource(gh<_i25.Dio>()));
    gh.lazySingleton<_i46.IAboutRepository>(() => _i47.AboutRepositoryImpl());
    gh.lazySingleton<_i48.ImagePickerService>(
        () => _i48.ImagePickerServiceImpl());
    gh.lazySingleton<_i49.IncentiveDatasource>(
        () => _i49.IncentiveDatasource());
    gh.lazySingleton<_i50.IncentiveRepository>(
        () => _i51.IncentiveRepositoryImpl(gh<_i49.IncentiveDatasource>()));
    gh.lazySingleton<_i52.IpfsDatasource>(
        () => _i52.IpfsDatasource(gh<_i25.Dio>()));
    await gh.factoryAsync<_i53.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i54.LicenseRegistryLocalDataSource>(() {
      final i = _i54.LicenseRegistryLocalDataSource(gh<_i53.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i55.LicenseVerifier>(() async =>
        _i55.LicenseVerifier(
            await getAsync<_i54.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i56.LlmAdapter>(
      () => _i57.FlutterGemmaAdapter(wrapper: gh<_i35.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i56.LlmAdapter>(
      () => _i58.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i59.LocalLlmService>(() => _i59.LocalLlmService());
    gh.lazySingleton<_i60.LocalModelLocalDataSource>(
        () => _i60.LocalModelLocalDataSource());
    gh.lazySingleton<_i61.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i62.MedicalKnowledgeRepository>(
      () => _i63.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i62.MedicalKnowledgeRepository>(
      () => _i64.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i65.MedicalScraperService>(
        () => _i66.MedicalScraperServiceImpl(
              gh<_i25.Dio>(),
              gh<_i13.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i67.MedicalStandardsService>(() =>
        _i68.MedicalStandardsServiceImpl(gh<_i61.MedicalContextProvider>()));
    gh.lazySingleton<_i69.MedicalWebSearchService>(
        () => _i70.MedicalWebSearchServiceImpl(gh<_i25.Dio>()));
    gh.lazySingleton<_i71.MedicationRepository>(
        () => _i72.IsarMedicationRepository(gh<_i53.Isar>()));
    gh.factory<_i73.MedicationsCubit>(
        () => _i73.MedicationsCubit(gh<_i71.MedicationRepository>()));
    gh.lazySingleton<_i74.MeditationLocalDataSource>(
        () => _i74.MeditationLocalDataSource());
    gh.lazySingleton<_i75.MeditationRepository>(() =>
        _i76.MeditationRepositoryImpl(gh<_i74.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i28.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i53.Isar>(),
        gh<_i28.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i77.MockReportGenerationService>(
      () => _i77.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i78.ModelDownloadService>(
        () => _i78.ModelDownloadService());
    gh.lazySingleton<_i79.NfcHandler>(
        () => _i79.NfcHandler(channel: gh<_i80.MethodChannel>()));
    gh.lazySingleton<_i81.NfcSharingService>(
        () => _i81.NfcSharingService(gh<_i79.NfcHandler>()));
    gh.lazySingleton<_i82.NodeDiscoveryService>(
        () => _i83.NodeDiscoveryService());
    gh.lazySingleton<_i84.OAuthLocalDataSource>(
        () => _i84.OAuthLocalDataSource(gh<_i36.FlutterSecureStorage>()));
    gh.lazySingleton<_i85.OAuthRepository>(() => _i86.OAuthRepositoryImpl(
          gh<_i84.OAuthLocalDataSource>(),
          gh<_i25.Dio>(),
          gh<_i34.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i87.OcrService>(() => _i87.MlKitOcrService());
    gh.lazySingleton<_i88.PromptScrubber>(
        () => _i88.PromptScrubber(gh<_i53.Isar>()));
    gh.lazySingleton<_i89.RatingRepository>(
        () => _i90.IsarRatingRepository(gh<_i53.Isar>()));
    gh.lazySingleton<_i91.RecommendScriptUseCase>(
        () => _i91.RecommendScriptUseCase(gh<_i75.MeditationRepository>()));
    gh.lazySingleton<_i92.ReportRepository>(
        () => _i93.IsarReportRepository(gh<_i53.Isar>()));
    gh.factory<_i94.RequestHealthAuthUseCase>(() =>
        _i94.RequestHealthAuthUseCase(gh<_i39.HealthDataImportService>()));
    gh.lazySingleton<_i95.SecondOpinionRepository>(
        () => _i96.IsarSecondOpinionRepository(gh<_i53.Isar>()));
    gh.lazySingleton<_i97.SensorHealthDataSource>(
        () => _i97.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i98.SettingsLocalDataSource>(
        () => _i98.SettingsLocalDataSource(gh<_i53.Isar>()));
    gh.lazySingleton<_i99.StartSessionUseCase>(
        () => _i99.StartSessionUseCase(gh<_i75.MeditationRepository>()));
    gh.factory<_i100.SyncEmailAppointmentsUseCase>(
        () => _i100.SyncEmailAppointmentsUseCase(gh<_i26.EmailRepository>()));
    gh.lazySingleton<_i101.SyncRepository>(() => _i102.SyncRepositoryImpl(
          gh<_i31.FhirClient>(),
          gh<_i53.Isar>(),
          gh<_i36.FlutterSecureStorage>(),
          gh<_i82.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i61.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i103.UserProfileLocalDataSource>(
        () => _i103.UserProfileLocalDataSource(gh<_i53.Isar>()));
    gh.lazySingleton<_i104.UserProfileRepository>(
        () => _i105.UserProfileRepositoryImpl(gh<_i53.Isar>()));
    gh.lazySingleton<_i106.UserProfileService>(
        () => _i106.UserProfileService(gh<_i104.UserProfileRepository>()));
    gh.lazySingleton<_i107.VectorStoreService>(
        () => _i108.IsarVectorStoreService(
              gh<_i28.MemoryGraph>(),
              gh<_i62.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i109.VitalSignRepository>(
        () => _i110.VitalSignRepositoryImpl(gh<_i53.Isar>()));
    gh.factory<_i111.VitalsCubit>(
        () => _i111.VitalsCubit(gh<_i109.VitalSignRepository>()));
    gh.lazySingleton<_i112.VoiceChatRepository>(
        () => _i113.VoiceChatRepositoryImpl(gh<_i20.ChatAiDatasource>()));
    gh.lazySingleton<_i114.VouchRepository>(
        () => _i115.IsarVouchRepository(gh<_i53.Isar>()));
    gh.lazySingleton<_i30.WalletService>(() => databaseModule.walletService(
          gh<_i53.Isar>(),
          gh<_i30.EncryptionService>(),
        ));
    gh.lazySingleton<_i116.WifiDirectService>(() => _i116.WifiDirectService());
    gh.factory<_i117.AboutCubit>(
        () => _i117.AboutCubit(gh<_i46.IAboutRepository>()));
    gh.lazySingleton<_i118.AboutRemoteDataSource>(
        () => _i118.AboutRemoteDataSource(gh<_i25.Dio>()));
    gh.lazySingleton<_i119.AllergyRepository>(
        () => _i120.IsarAllergyRepository(gh<_i53.Isar>()));
    gh.lazySingleton<_i121.AppointmentRepository>(
        () => _i122.IsarAppointmentRepository(gh<_i53.Isar>()));
    gh.factory<_i123.AppointmentsCubit>(
        () => _i123.AppointmentsCubit(gh<_i121.AppointmentRepository>()));
    gh.lazySingleton<_i124.AuthRepository>(
        () => _i125.AuthRepositoryImpl(gh<_i53.Isar>()));
    gh.lazySingleton<_i126.AuthService>(
        () => _i126.AuthServiceImpl(gh<_i29.EncryptionService>()));
    gh.lazySingleton<_i127.BleSharingService>(
        () => _i127.BleSharingService(gh<_i12.BleWrapper>()));
    gh.lazySingleton<_i128.CancelSharingUseCase>(
        () => _i128.CancelSharingUseCase(
              gh<_i127.BleSharingService>(),
              gh<_i81.NfcSharingService>(),
              gh<_i116.WifiDirectService>(),
            ));
    gh.lazySingleton<_i129.ChatMessageLocalDataSource>(
        () => _i129.ChatMessageLocalDataSource(gh<_i53.Isar>()));
    gh.lazySingleton<_i130.CompleteSessionUseCase>(
        () => _i130.CompleteSessionUseCase(gh<_i75.MeditationRepository>()));
    gh.factory<_i100.ConnectEmailProviderUseCase>(
        () => _i100.ConnectEmailProviderUseCase(gh<_i26.EmailRepository>()));
    gh.factory<_i131.ConnectProviderUseCase>(() => _i131.ConnectProviderUseCase(
          gh<_i85.OAuthRepository>(),
          gh<_i104.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i132.DashboardLocalDataSource>(
        () => _i132.DashboardLocalDataSource(gh<_i53.Isar>()));
    gh.lazySingleton<_i133.DashboardRepository>(
        () => _i134.DashboardRepositoryImpl(
              gh<_i132.DashboardLocalDataSource>(),
              gh<_i22.DashboardRemoteDataSource>(),
              gh<_i109.VitalSignRepository>(),
              gh<_i71.MedicationRepository>(),
              gh<_i92.ReportRepository>(),
            ));
    gh.factory<_i135.DeleteAppointmentUseCase>(() =>
        _i135.DeleteAppointmentUseCase(gh<_i121.AppointmentRepository>()));
    gh.factory<_i136.DisconnectProviderUseCase>(
        () => _i136.DisconnectProviderUseCase(
              gh<_i85.OAuthRepository>(),
              gh<_i104.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i137.DistributedStorageService>(() => _i138.IpfsService(
          gh<_i52.IpfsDatasource>(),
          gh<_i33.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i139.DoctorProfileRepository>(
        () => _i140.IsarDoctorProfileRepository(gh<_i53.Isar>()));
    gh.factoryAsync<_i141.DoctorVerificationCubit>(
        () async => _i141.DoctorVerificationCubit(
              gh<_i139.DoctorProfileRepository>(),
              gh<_i89.RatingRepository>(),
              await getAsync<_i55.LicenseVerifier>(),
            ));
    gh.factory<_i142.EmailCitasBloc>(() => _i142.EmailCitasBloc(
          gh<_i100.ConnectEmailProviderUseCase>(),
          gh<_i100.SyncEmailAppointmentsUseCase>(),
          gh<_i26.EmailRepository>(),
          gh<_i121.AppointmentRepository>(),
        ));
    gh.factory<_i143.EmailCitasCubit>(() => _i143.EmailCitasCubit(
          gh<_i26.EmailRepository>(),
          gh<_i121.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i97.FileHealthDataSource>(
        () => _i97.FileHealthDataSourceImpl(
              gh<_i32.FilePickerService>(),
              gh<_i87.OcrService>(),
            ));
    gh.factory<_i144.GetAllAppointmentsUseCase>(() =>
        _i144.GetAllAppointmentsUseCase(gh<_i121.AppointmentRepository>()));
    gh.factory<_i94.GetAvailableSourcesUseCase>(() =>
        _i94.GetAvailableSourcesUseCase(gh<_i39.HealthDataImportService>()));
    gh.factory<_i145.GetChatHistoryUseCase>(
        () => _i145.GetChatHistoryUseCase(gh<_i112.VoiceChatRepository>()));
    gh.factory<_i146.GetConnectionsUseCase>(
        () => _i146.GetConnectionsUseCase(gh<_i85.OAuthRepository>()));
    gh.factory<_i147.GetDashboardStatsUseCase>(
        () => _i147.GetDashboardStatsUseCase(gh<_i133.DashboardRepository>()));
    gh.lazySingleton<_i148.GetProgressUseCase>(
        () => _i148.GetProgressUseCase(gh<_i75.MeditationRepository>()));
    gh.factory<_i149.GetRecentActivityUseCase>(
        () => _i149.GetRecentActivityUseCase(gh<_i133.DashboardRepository>()));
    gh.lazySingleton<_i150.GetScriptsUseCase>(
        () => _i150.GetScriptsUseCase(gh<_i75.MeditationRepository>()));
    gh.lazySingleton<_i151.GovernanceIpfsDatasource>(
        () => _i151.GovernanceIpfsDatasource(gh<_i52.IpfsDatasource>()));
    gh.lazySingleton<_i152.GovernanceRepository>(() =>
        _i153.GovernanceRepositoryImpl(gh<_i151.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i154.HealthDataFileDataSource>(
        () => _i154.HealthDataFileDataSource(
              gh<_i32.FilePickerService>(),
              gh<_i87.OcrService>(),
            ));
    gh.lazySingleton<_i155.HealthDataImportRepository>(
        () => _i156.HealthDataImportRepositoryImpl(
              gh<_i97.SensorHealthDataSource>(),
              gh<_i97.FileHealthDataSource>(),
            ));
    gh.factory<_i157.HealthImportBloc>(() => _i157.HealthImportBloc(
          gh<_i94.GetAvailableSourcesUseCase>(),
          gh<_i94.RequestHealthAuthUseCase>(),
          gh<_i39.HealthDataImportService>(),
          gh<_i109.VitalSignRepository>(),
        ));
    gh.factory<_i158.HealthImportCubit>(() => _i158.HealthImportCubit(
          gh<_i39.HealthDataImportService>(),
          gh<_i109.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i159.HealthRecordRepository>(
        () => _i160.HealthRecordRepositoryImpl(gh<_i53.Isar>()));
    gh.lazySingleton<_i161.HealthSharingLocalDataSource>(
        () => _i161.HealthSharingLocalDataSource(gh<_i53.Isar>()));
    gh.lazySingleton<_i162.HomeRepository>(() => _i163.HomeRepositoryImpl(
          gh<_i109.VitalSignRepository>(),
          gh<_i121.AppointmentRepository>(),
          gh<_i71.MedicationRepository>(),
          gh<_i43.HomeLocalDataSource>(),
          gh<_i45.HomeRemoteDataSource>(),
        ));
    gh.factory<_i164.ImportCalendarUseCase>(() => _i164.ImportCalendarUseCase(
          gh<_i18.CalendarRepository>(),
          gh<_i121.AppointmentRepository>(),
          gh<_i104.UserProfileRepository>(),
        ));
    gh.factory<_i56.LlmAdapter>(
      () => _i165.MockLlmAdapter(gh<_i88.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i56.LlmAdapter>(
      () => _i166.GeminiLlmAdapter(
        scrubber: gh<_i88.PromptScrubber>(),
        userProfileRepository: gh<_i104.UserProfileRepository>(),
        modelWrapper: gh<_i37.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i167.LlmService>(() => _i168.GemmaLlmService(
          gh<_i107.VectorStoreService>(),
          gh<_i104.UserProfileRepository>(),
          gh<_i56.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i169.LlmSettingsRepository>(() =>
        _i170.LlmSettingsRepositoryImpl(gh<_i98.SettingsLocalDataSource>()));
    gh.lazySingleton<_i171.MedicalResearchService>(
        () => _i171.MedicalResearchService(
              gh<_i69.MedicalWebSearchService>(),
              gh<_i65.MedicalScraperService>(),
            ));
    gh.factory<_i172.MedicationBloc>(
        () => _i172.MedicationBloc(gh<_i71.MedicationRepository>()));
    gh.factory<_i173.MeditationCubit>(() => _i173.MeditationCubit(
          gh<_i91.RecommendScriptUseCase>(),
          gh<_i99.StartSessionUseCase>(),
          gh<_i130.CompleteSessionUseCase>(),
          gh<_i148.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i174.OnboardingRepository>(() =>
        _i175.OnboardingRepositoryImpl(gh<_i104.UserProfileRepository>()));
    gh.lazySingleton<_i176.PatientContextIndexer>(
      () => _i176.PatientContextIndexer(
        gh<_i53.Isar>(),
        gh<_i107.VectorStoreService>(),
        gh<_i159.HealthRecordRepository>(),
        gh<_i71.MedicationRepository>(),
        gh<_i119.AllergyRepository>(),
        gh<_i109.VitalSignRepository>(),
        gh<_i121.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i177.ReportGenerationService>(
        () => _i178.GemmaReportGenerationService(
              gh<_i56.LlmAdapter>(instanceName: 'gemma'),
              gh<_i107.VectorStoreService>(),
              gh<_i104.UserProfileRepository>(),
              gh<_i88.PromptScrubber>(),
            ));
    gh.factory<_i179.SaveAppointmentUseCase>(
        () => _i179.SaveAppointmentUseCase(gh<_i121.AppointmentRepository>()));
    gh.factory<_i180.SecondOpinionCubit>(
        () => _i180.SecondOpinionCubit(gh<_i95.SecondOpinionRepository>()));
    gh.factory<_i181.SendMessageUseCase>(
        () => _i181.SendMessageUseCase(gh<_i112.VoiceChatRepository>()));
    gh.lazySingleton<_i182.SmartSearchUseCase>(
        () => _i182.SmartSearchUseCase(gh<_i107.VectorStoreService>()));
    gh.lazySingleton<_i183.StartListeningUseCase>(
        () => _i183.StartListeningUseCase(
              gh<_i127.BleSharingService>(),
              gh<_i81.NfcSharingService>(),
              gh<_i116.WifiDirectService>(),
            ));
    gh.lazySingleton<_i184.StartSharingUseCase>(() => _i184.StartSharingUseCase(
          gh<_i127.BleSharingService>(),
          gh<_i81.NfcSharingService>(),
          gh<_i116.WifiDirectService>(),
        ));
    gh.factory<_i185.SyncCubit>(() => _i185.SyncCubit(
          gh<_i61.SyncService>(),
          gh<_i107.VectorStoreService>(),
        ));
    gh.lazySingleton<_i186.SyncService>(() => _i187.SyncServiceImpl(
          gh<_i101.SyncRepository>(),
          gh<_i61.SyncService>(),
        ));
    gh.factory<_i188.UserProfileCubit>(
        () => _i188.UserProfileCubit(gh<_i104.UserProfileRepository>()));
    gh.factory<_i189.VitalSignBloc>(
        () => _i189.VitalSignBloc(gh<_i109.VitalSignRepository>()));
    gh.factory<_i190.VoiceChatCubit>(() => _i190.VoiceChatCubit(
          gh<_i181.SendMessageUseCase>(),
          gh<_i145.GetChatHistoryUseCase>(),
          gh<_i112.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i191.VouchCubit>(
        () => _i191.VouchCubit(gh<_i114.VouchRepository>()));
    gh.factory<_i192.AllergiesCubit>(
        () => _i192.AllergiesCubit(gh<_i119.AllergyRepository>()));
    gh.factory<_i193.AllergyBloc>(
        () => _i193.AllergyBloc(gh<_i119.AllergyRepository>()));
    gh.factory<_i194.AppointmentBloc>(
        () => _i194.AppointmentBloc(gh<_i121.AppointmentRepository>()));
    gh.factory<_i195.AuthCubit>(() => _i195.AuthCubit(
          gh<_i124.AuthRepository>(),
          gh<_i29.EncryptionService>(),
          gh<_i11.BiometricService>(),
        ));
    gh.factory<_i196.AuthCubit>(() => _i196.AuthCubit(gh<_i126.AuthService>()));
    gh.lazySingleton<_i197.BadgeCalculator>(() => _i197.BadgeCalculator(
          gh<_i139.DoctorProfileRepository>(),
          gh<_i89.RatingRepository>(),
          gh<_i114.VouchRepository>(),
        ));
    gh.factory<_i198.BadgeCubit>(
        () => _i198.BadgeCubit(gh<_i197.BadgeCalculator>()));
    gh.factory<_i199.CalendarImportCubit>(() => _i199.CalendarImportCubit(
          gh<_i18.CalendarRepository>(),
          gh<_i164.ImportCalendarUseCase>(),
        ));
    gh.factory<_i200.DashboardCubit>(() => _i200.DashboardCubit(
          gh<_i147.GetDashboardStatsUseCase>(),
          gh<_i149.GetRecentActivityUseCase>(),
        ));
    gh.lazySingleton<_i201.DistributedCacheUsecase>(() =>
        _i201.DistributedCacheUsecase(gh<_i137.DistributedStorageService>()));
    gh.factory<_i202.EpsConnectionBloc>(() => _i202.EpsConnectionBloc(
          gh<_i146.GetConnectionsUseCase>(),
          gh<_i131.ConnectProviderUseCase>(),
          gh<_i136.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i203.EpsConnectionCubit>(() => _i203.EpsConnectionCubit(
          gh<_i146.GetConnectionsUseCase>(),
          gh<_i131.ConnectProviderUseCase>(),
          gh<_i136.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i204.FhirSyncCubit>(() => _i204.FhirSyncCubit(
          gh<_i186.SyncService>(),
          gh<_i82.NodeDiscoveryService>(),
        ));
    gh.factory<_i205.GetHealthSummaryUseCase>(
        () => _i205.GetHealthSummaryUseCase(gh<_i162.HomeRepository>()));
    gh.factory<_i206.HealthRecordCubit>(() => _i206.HealthRecordCubit(
          gh<_i159.HealthRecordRepository>(),
          gh<_i32.FilePickerService>(),
          gh<_i48.ImagePickerService>(),
          gh<_i87.OcrService>(),
          gh<_i107.VectorStoreService>(),
        ));
    gh.factory<_i207.HomeCubit>(() => _i207.HomeCubit(
          gh<_i205.GetHealthSummaryUseCase>(),
          gh<_i162.HomeRepository>(),
        ));
    gh.lazySingleton<_i208.LlmAdapterFactory>(
        () => _i208.LlmAdapterFactory(gh<_i169.LlmSettingsRepository>()));
    gh.lazySingleton<_i167.LlmService>(
      () => _i209.RagLlmService(
        gh<_i107.VectorStoreService>(),
        gh<_i171.MedicalResearchService>(),
        gh<_i104.UserProfileRepository>(),
        gh<_i56.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.factory<_i210.LlmSettingsCubit>(() => _i210.LlmSettingsCubit(
          gh<_i169.LlmSettingsRepository>(),
          gh<_i23.DeviceCapabilityService>(),
          gh<_i56.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i211.MedicalIndexingService>(
        () => _i211.MedicalIndexingService(
              gh<_i62.MedicalKnowledgeRepository>(),
              gh<_i107.VectorStoreService>(),
              gh<_i176.PatientContextIndexer>(),
            ));
    gh.factory<_i212.MedicalResearchCubit>(() => _i212.MedicalResearchCubit(
          gh<_i171.MedicalResearchService>(),
          gh<_i67.MedicalStandardsService>(),
        ));
    gh.factory<_i213.OnboardingCubit>(
        () => _i213.OnboardingCubit(gh<_i174.OnboardingRepository>()));
    gh.factory<_i214.ReportBloc>(() => _i214.ReportBloc(
          gh<_i92.ReportRepository>(),
          gh<_i177.ReportGenerationService>(),
        ));
    gh.factory<_i215.SharingCubit>(() => _i215.SharingCubit(
          bleService: gh<_i127.BleSharingService>(),
          nfcService: gh<_i81.NfcSharingService>(),
          wifiService: gh<_i116.WifiDirectService>(),
          startSharingUseCase: gh<_i184.StartSharingUseCase>(),
          startListeningUseCase: gh<_i183.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i128.CancelSharingUseCase>(),
          walletService: gh<_i30.WalletService>(),
          walletEncryption: gh<_i30.EncryptionService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i216.ServiceModule {}

class _$NetworkModule extends _i217.NetworkModule {}

class _$MemoryModule extends _i218.MemoryModule {}

class _$DatabaseModule extends _i219.DatabaseModule {}

class _$FhirModule extends _i220.FhirModule {}
