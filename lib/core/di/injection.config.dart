// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i15;
import 'package:dio/dio.dart' as _i28;
import 'package:flutter/services.dart' as _i86;
import 'package:flutter_appauth/flutter_appauth.dart' as _i37;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i39;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i41;
import 'package:health_wallet/health_wallet.dart' as _i33;
import 'package:http/http.dart' as _i22;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i59;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i31;
import 'package:just_audio/just_audio.dart' as _i9;
import 'package:medical_standards/medical_standards.dart' as _i67;
import 'package:shared_preferences/shared_preferences.dart' as _i50;

import '../../features/about/application/about_cubit.dart' as _i129;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i130;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i52;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i53;
import '../../features/allergies/application/allergies_cubit.dart' as _i205;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i206;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i131;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i133;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i132;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i137;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i207;
import '../../features/appointments/data/datasources/appointment_local_datasource.dart'
    as _i134;
import '../../features/appointments/data/repositories/appointment_repository_impl.dart'
    as _i136;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i135;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i150;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i160;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i194;
import '../../features/auth/application/auth_cubit.dart' as _i208;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i209;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i138;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i140;
import '../../features/auth/domain/auth_service.dart' as _i141;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i139;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i11;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i32;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i212;
import '../../features/calendar_import/data/datasources/calendar_local_datasource.dart'
    as _i16;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i19;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i17;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i179;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i14;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i20;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i18;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i213;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i147;
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i25;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i149;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i148;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i163;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i165;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i211;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i156;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i195;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i204;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i154;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i95;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i101;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i126;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i210;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i61;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i60;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i155;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i96;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i102;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i127;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i157;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i158;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i29;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i110;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i30;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i215;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i216;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i90;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i91;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i146;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i151;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i162;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i92;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i173;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i174;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i170;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i45;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i171;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i44;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i100;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i103;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i172;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i218;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i175;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i176;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i35;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i54;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i93;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i227;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i46;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i47;
import '../../features/health_sharing/data/repositories/health_sharing_repository_impl.dart'
    as _i108;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i107;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i143;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i198;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i199;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i142;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i12;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i85;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i87;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i128;
import '../../features/home/application/home_cubit.dart' as _i219;
import '../../features/home/domain/repositories/home_repository.dart' as _i177;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i217;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i48;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i49;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i51;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i178;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i197;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i144;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i66;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i68;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i62;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i119;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i64;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i38;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i181;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i40;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i180;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i63;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i184;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i183;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i220;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i69;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i70;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i120;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i182;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i65;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i221;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i84;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i191;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i229;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i222;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i71;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i73;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i75;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i228;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i226;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i13;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i186;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i72;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i74;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i76;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i223;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i187;
import '../../features/medications/application/medications_cubit.dart' as _i79;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i77;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i78;
import '../../features/meditation/application/meditation_cubit.dart' as _i188;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i81;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i145;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i164;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i166;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i97;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i109;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i80;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i82;
import '../../features/network/domain/repositories/network_repository.dart'
    as _i24;
import '../../features/network/domain/usecases/connect_node.dart' as _i23;
import '../../features/network/domain/usecases/get_network_health.dart' as _i42;
import '../../features/network/domain/usecases/get_node_stats.dart' as _i43;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i168;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i167;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i169;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i56;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i55;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i57;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i224;
import '../../features/onboarding/application/sync_cubit.dart' as _i200;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i189;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i190;
import '../../features/reports/application/bloc/report_bloc.dart' as _i225;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i98;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i192;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i99;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i193;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i83;
import '../../features/settings/application/llm_settings_cubit.dart' as _i185;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i105;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i26;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i104;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i106;
import '../../features/sync/application/sync_cubit.dart' as _i159;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i111;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i152;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i88;
import '../../features/sync/domain/services/sync_service.dart' as _i113;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i214;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i36;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i58;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i112;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i34;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i153;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i89;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i114;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i201;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i115;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i116;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i118;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i117;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i202;
import '../../features/vitals/application/vitals_cubit.dart' as _i123;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i121;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i122;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i203;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i124;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i161;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i196;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i21;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i125;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/audio/audio_recorder_service.dart' as _i10;
import '../services/device_capability_service.dart' as _i27;
import '../services/privacy_anonymizer.dart' as _i94;
import 'database_module.dart' as _i233;
import 'fhir_module.dart' as _i234;
import 'memory_module.dart' as _i232;
import 'network_module.dart' as _i231;
import 'service_module.dart' as _i230;

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
    gh.lazySingleton<_i16.CalendarLocalDataSource>(
        () => _i16.CalendarLocalDataSource());
    gh.lazySingleton<_i17.CalendarParserService>(
        () => _i18.CalendarParserServiceImpl());
    gh.lazySingleton<_i19.CalendarRepository>(
        () => _i20.CalendarRepositoryImpl(gh<_i14.CalendarApiDatasource>()));
    gh.lazySingleton<_i21.ChatAiDatasource>(() => _i21.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i22.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i23.ConnectNode>(
        () => _i23.ConnectNode(gh<_i24.NetworkRepository>()));
    gh.lazySingleton<_i25.DashboardRemoteDataSource>(
        () => _i25.DashboardRemoteDataSourceImpl());
    gh.lazySingleton<_i26.DeviceCapabilityService>(
        () => _i26.DeviceCapabilityService());
    gh.lazySingleton<_i27.DeviceCapabilityService>(
        () => _i27.DeviceCapabilityService());
    gh.lazySingleton<_i28.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i29.EmailRepository>(() => _i30.EmailRepositoryImpl(
          gh<_i22.Client>(),
          gh<_i15.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i31.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i32.EncryptionService>(() => _i32.EncryptionService());
    gh.lazySingleton<_i33.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i34.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i35.FilePickerService>(
        () => _i35.FilePickerServiceImpl());
    gh.lazySingleton<_i36.FilecoinDatasource>(() => _i36.FilecoinDatasource());
    gh.lazySingleton<_i37.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i38.FlutterGemmaWrapper>(
        () => _i38.FlutterGemmaWrapper());
    gh.lazySingleton<_i39.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i40.GeminiModelWrapper>(
        () => _i40.GeminiModelWrapper(gh<_i41.GenerativeModel>()));
    gh.lazySingleton<_i42.GetNetworkHealth>(
        () => _i42.GetNetworkHealth(gh<_i24.NetworkRepository>()));
    gh.lazySingleton<_i43.GetNodeStats>(
        () => _i43.GetNodeStats(gh<_i24.NetworkRepository>()));
    gh.lazySingleton<_i44.HealthDataImportService>(
        () => _i44.HealthDataImportService());
    gh.lazySingleton<_i45.HealthDataSensorDataSource>(
        () => _i45.HealthDataSensorDataSource());
    gh.lazySingleton<_i46.HealthSharingLocalDataSource>(
        () => _i46.HealthSharingLocalDataSource());
    gh.lazySingleton<_i47.HealthSharingRemoteDataSource>(
        () => _i47.HealthSharingRemoteDataSource());
    gh.factory<_i48.HealthSummaryDatasource>(
        () => _i48.HealthSummaryDatasource());
    gh.factory<_i49.HomeLocalDataSource>(
        () => _i49.HomeLocalDataSource(gh<_i50.SharedPreferences>()));
    gh.factory<_i51.HomeRemoteDataSource>(() => _i51.HomeRemoteDataSource());
    gh.lazySingleton<_i52.IAboutRepository>(() => _i53.AboutRepositoryImpl());
    gh.lazySingleton<_i54.ImagePickerService>(
        () => _i54.ImagePickerServiceImpl());
    gh.lazySingleton<_i55.IncentiveDatasource>(
        () => _i55.IncentiveDatasource());
    gh.lazySingleton<_i56.IncentiveRepository>(
        () => _i57.IncentiveRepositoryImpl(gh<_i55.IncentiveDatasource>()));
    gh.lazySingleton<_i58.IpfsDatasource>(
        () => _i58.IpfsDatasource(gh<_i28.Dio>()));
    await gh.factoryAsync<_i59.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i60.LicenseRegistryLocalDataSource>(() {
      final i = _i60.LicenseRegistryLocalDataSource(gh<_i59.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i61.LicenseVerifier>(() async =>
        _i61.LicenseVerifier(
            await getAsync<_i60.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i62.LlmAdapter>(
      () => _i63.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i62.LlmAdapter>(
      () => _i64.FlutterGemmaAdapter(wrapper: gh<_i38.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i65.LocalLlmService>(() => _i65.LocalLlmService());
    gh.lazySingleton<_i66.LocalModelLocalDataSource>(
        () => _i66.LocalModelLocalDataSource());
    gh.lazySingleton<_i67.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i68.MedicalKnowledgeRepository>(
      () => _i69.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i68.MedicalKnowledgeRepository>(
      () => _i70.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i71.MedicalScraperService>(
        () => _i72.MedicalScraperServiceImpl(
              gh<_i28.Dio>(),
              gh<_i13.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i73.MedicalStandardsService>(() =>
        _i74.MedicalStandardsServiceImpl(gh<_i67.MedicalContextProvider>()));
    gh.lazySingleton<_i75.MedicalWebSearchService>(
        () => _i76.MedicalWebSearchServiceImpl(gh<_i28.Dio>()));
    gh.lazySingleton<_i77.MedicationRepository>(
        () => _i78.IsarMedicationRepository(gh<_i59.Isar>()));
    gh.factory<_i79.MedicationsCubit>(
        () => _i79.MedicationsCubit(gh<_i77.MedicationRepository>()));
    gh.lazySingleton<_i80.MeditationLocalDataSource>(
        () => _i80.MeditationLocalDataSource());
    gh.lazySingleton<_i81.MeditationRepository>(() =>
        _i82.MeditationRepositoryImpl(gh<_i80.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i31.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i59.Isar>(),
        gh<_i31.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i83.MockReportGenerationService>(
      () => _i83.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i84.ModelDownloadService>(
        () => _i84.ModelDownloadService());
    gh.lazySingleton<_i85.NfcHandler>(
        () => _i85.NfcHandler(channel: gh<_i86.MethodChannel>()));
    gh.lazySingleton<_i87.NfcSharingService>(
        () => _i87.NfcSharingService(gh<_i85.NfcHandler>()));
    gh.lazySingleton<_i88.NodeDiscoveryService>(
        () => _i89.NodeDiscoveryService());
    gh.lazySingleton<_i90.OAuthLocalDataSource>(
        () => _i90.OAuthLocalDataSource(gh<_i39.FlutterSecureStorage>()));
    gh.lazySingleton<_i91.OAuthRepository>(() => _i92.OAuthRepositoryImpl(
          gh<_i90.OAuthLocalDataSource>(),
          gh<_i28.Dio>(),
          gh<_i37.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i93.OcrService>(() => _i93.MlKitOcrService());
    gh.lazySingleton<_i94.PromptScrubber>(
        () => _i94.PromptScrubber(gh<_i59.Isar>()));
    gh.lazySingleton<_i95.RatingRepository>(
        () => _i96.IsarRatingRepository(gh<_i59.Isar>()));
    gh.lazySingleton<_i97.RecommendScriptUseCase>(
        () => _i97.RecommendScriptUseCase(gh<_i81.MeditationRepository>()));
    gh.lazySingleton<_i98.ReportRepository>(
        () => _i99.IsarReportRepository(gh<_i59.Isar>()));
    gh.factory<_i100.RequestHealthAuthUseCase>(() =>
        _i100.RequestHealthAuthUseCase(gh<_i44.HealthDataImportService>()));
    gh.lazySingleton<_i101.SecondOpinionRepository>(
        () => _i102.IsarSecondOpinionRepository(gh<_i59.Isar>()));
    gh.lazySingleton<_i103.SensorHealthDataSource>(
        () => _i103.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i104.SettingsLocalDataSource>(
        () => _i104.SettingsLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i105.SettingsRepository>(() =>
        _i106.SettingsRepositoryImpl(gh<_i104.SettingsLocalDataSource>()));
    gh.lazySingleton<_i107.SharingRepository>(() =>
        _i108.HealthSharingRepositoryImpl(
            gh<_i46.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i109.StartSessionUseCase>(
        () => _i109.StartSessionUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i110.SyncEmailAppointmentsUseCase>(
        () => _i110.SyncEmailAppointmentsUseCase(gh<_i29.EmailRepository>()));
    gh.lazySingleton<_i111.SyncRepository>(() => _i112.SyncRepositoryImpl(
          gh<_i34.FhirClient>(),
          gh<_i59.Isar>(),
          gh<_i39.FlutterSecureStorage>(),
          gh<_i88.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i67.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i113.SyncService>(() => _i114.SyncServiceImpl(
          gh<_i111.SyncRepository>(),
          gh<_i67.SyncService>(),
        ));
    gh.lazySingleton<_i115.UserProfileLocalDataSource>(
        () => _i115.UserProfileLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i116.UserProfileRepository>(
        () => _i117.UserProfileRepositoryImpl(gh<_i59.Isar>()));
    gh.lazySingleton<_i118.UserProfileService>(
        () => _i118.UserProfileService(gh<_i116.UserProfileRepository>()));
    gh.lazySingleton<_i119.VectorStoreService>(
        () => _i120.IsarVectorStoreService(
              gh<_i31.MemoryGraph>(),
              gh<_i68.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i121.VitalSignRepository>(
        () => _i122.VitalSignRepositoryImpl(gh<_i59.Isar>()));
    gh.factory<_i123.VitalsCubit>(
        () => _i123.VitalsCubit(gh<_i121.VitalSignRepository>()));
    gh.lazySingleton<_i124.VoiceChatRepository>(
        () => _i125.VoiceChatRepositoryImpl(gh<_i21.ChatAiDatasource>()));
    gh.lazySingleton<_i126.VouchRepository>(
        () => _i127.IsarVouchRepository(gh<_i59.Isar>()));
    gh.lazySingleton<_i33.WalletService>(() => databaseModule.walletService(
          gh<_i59.Isar>(),
          gh<_i33.EncryptionService>(),
        ));
    gh.lazySingleton<_i128.WifiDirectService>(() => _i128.WifiDirectService());
    gh.factory<_i129.AboutCubit>(
        () => _i129.AboutCubit(gh<_i52.IAboutRepository>()));
    gh.lazySingleton<_i130.AboutRemoteDataSource>(
        () => _i130.AboutRemoteDataSource(gh<_i28.Dio>()));
    gh.lazySingleton<_i131.AllergyLocalDataSource>(
        () => _i131.AllergyLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i132.AllergyRepository>(
        () => _i133.AllergyRepositoryImpl(gh<_i131.AllergyLocalDataSource>()));
    gh.lazySingleton<_i134.AppointmentLocalDataSource>(
        () => _i134.AppointmentLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i135.AppointmentRepository>(() =>
        _i136.AppointmentRepositoryImpl(
            gh<_i134.AppointmentLocalDataSource>()));
    gh.factory<_i137.AppointmentsCubit>(
        () => _i137.AppointmentsCubit(gh<_i135.AppointmentRepository>()));
    gh.lazySingleton<_i138.AuthLocalDataSource>(
        () => _i138.AuthLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i139.AuthRepository>(
        () => _i140.AuthRepositoryImpl(gh<_i138.AuthLocalDataSource>()));
    gh.lazySingleton<_i141.AuthService>(
        () => _i141.AuthServiceImpl(gh<_i32.EncryptionService>()));
    gh.lazySingleton<_i142.BleSharingService>(
        () => _i142.BleSharingService(gh<_i12.BleWrapper>()));
    gh.lazySingleton<_i143.CancelSharingUseCase>(
        () => _i143.CancelSharingUseCase(
              gh<_i142.BleSharingService>(),
              gh<_i87.NfcSharingService>(),
              gh<_i128.WifiDirectService>(),
            ));
    gh.lazySingleton<_i144.ChatMessageLocalDataSource>(
        () => _i144.ChatMessageLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i145.CompleteSessionUseCase>(
        () => _i145.CompleteSessionUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i110.ConnectEmailProviderUseCase>(
        () => _i110.ConnectEmailProviderUseCase(gh<_i29.EmailRepository>()));
    gh.factory<_i146.ConnectProviderUseCase>(() => _i146.ConnectProviderUseCase(
          gh<_i91.OAuthRepository>(),
          gh<_i116.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i147.DashboardLocalDataSource>(
        () => _i147.DashboardLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i148.DashboardRepository>(
        () => _i149.DashboardRepositoryImpl(
              gh<_i25.DashboardRemoteDataSource>(),
              gh<_i121.VitalSignRepository>(),
              gh<_i77.MedicationRepository>(),
              gh<_i98.ReportRepository>(),
            ));
    gh.factory<_i150.DeleteAppointmentUseCase>(() =>
        _i150.DeleteAppointmentUseCase(gh<_i135.AppointmentRepository>()));
    gh.factory<_i151.DisconnectProviderUseCase>(
        () => _i151.DisconnectProviderUseCase(
              gh<_i91.OAuthRepository>(),
              gh<_i116.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i152.DistributedStorageService>(() => _i153.IpfsService(
          gh<_i58.IpfsDatasource>(),
          gh<_i36.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i154.DoctorProfileRepository>(
        () => _i155.IsarDoctorProfileRepository(gh<_i59.Isar>()));
    gh.factoryAsync<_i156.DoctorVerificationCubit>(
        () async => _i156.DoctorVerificationCubit(
              gh<_i154.DoctorProfileRepository>(),
              gh<_i95.RatingRepository>(),
              await getAsync<_i61.LicenseVerifier>(),
            ));
    gh.factory<_i157.EmailCitasBloc>(() => _i157.EmailCitasBloc(
          gh<_i110.ConnectEmailProviderUseCase>(),
          gh<_i110.SyncEmailAppointmentsUseCase>(),
          gh<_i29.EmailRepository>(),
          gh<_i135.AppointmentRepository>(),
        ));
    gh.factory<_i158.EmailCitasCubit>(() => _i158.EmailCitasCubit(
          gh<_i29.EmailRepository>(),
          gh<_i135.AppointmentRepository>(),
        ));
    gh.factory<_i159.FhirSyncCubit>(() => _i159.FhirSyncCubit(
          gh<_i113.SyncService>(),
          gh<_i88.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i103.FileHealthDataSource>(
        () => _i103.FileHealthDataSourceImpl(
              gh<_i35.FilePickerService>(),
              gh<_i93.OcrService>(),
            ));
    gh.factory<_i160.GetAllAppointmentsUseCase>(() =>
        _i160.GetAllAppointmentsUseCase(gh<_i135.AppointmentRepository>()));
    gh.factory<_i100.GetAvailableSourcesUseCase>(() =>
        _i100.GetAvailableSourcesUseCase(gh<_i44.HealthDataImportService>()));
    gh.factory<_i161.GetChatHistoryUseCase>(
        () => _i161.GetChatHistoryUseCase(gh<_i124.VoiceChatRepository>()));
    gh.factory<_i162.GetConnectionsUseCase>(
        () => _i162.GetConnectionsUseCase(gh<_i91.OAuthRepository>()));
    gh.factory<_i163.GetDashboardStatsUseCase>(
        () => _i163.GetDashboardStatsUseCase(gh<_i148.DashboardRepository>()));
    gh.lazySingleton<_i164.GetProgressUseCase>(
        () => _i164.GetProgressUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i165.GetRecentActivityUseCase>(
        () => _i165.GetRecentActivityUseCase(gh<_i148.DashboardRepository>()));
    gh.lazySingleton<_i166.GetScriptsUseCase>(
        () => _i166.GetScriptsUseCase(gh<_i81.MeditationRepository>()));
    gh.lazySingleton<_i167.GovernanceIpfsDatasource>(
        () => _i167.GovernanceIpfsDatasource(gh<_i58.IpfsDatasource>()));
    gh.lazySingleton<_i168.GovernanceRepository>(() =>
        _i169.GovernanceRepositoryImpl(gh<_i167.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i170.HealthDataFileDataSource>(
        () => _i170.HealthDataFileDataSource(
              gh<_i35.FilePickerService>(),
              gh<_i93.OcrService>(),
            ));
    gh.lazySingleton<_i171.HealthDataImportRepository>(
        () => _i172.HealthDataImportRepositoryImpl(
              gh<_i103.SensorHealthDataSource>(),
              gh<_i103.FileHealthDataSource>(),
            ));
    gh.factory<_i173.HealthImportBloc>(() => _i173.HealthImportBloc(
          gh<_i100.GetAvailableSourcesUseCase>(),
          gh<_i100.RequestHealthAuthUseCase>(),
          gh<_i44.HealthDataImportService>(),
          gh<_i121.VitalSignRepository>(),
        ));
    gh.factory<_i174.HealthImportCubit>(() => _i174.HealthImportCubit(
          gh<_i44.HealthDataImportService>(),
          gh<_i121.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i175.HealthRecordRepository>(
        () => _i176.HealthRecordRepositoryImpl(gh<_i59.Isar>()));
    gh.lazySingleton<_i177.HomeRepository>(() => _i178.HomeRepositoryImpl(
          gh<_i121.VitalSignRepository>(),
          gh<_i135.AppointmentRepository>(),
          gh<_i77.MedicationRepository>(),
          gh<_i49.HomeLocalDataSource>(),
          gh<_i51.HomeRemoteDataSource>(),
        ));
    gh.factory<_i179.ImportCalendarUseCase>(() => _i179.ImportCalendarUseCase(
          gh<_i19.CalendarRepository>(),
          gh<_i135.AppointmentRepository>(),
          gh<_i116.UserProfileRepository>(),
        ));
    gh.factory<_i62.LlmAdapter>(
      () => _i180.MockLlmAdapter(gh<_i94.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i62.LlmAdapter>(
      () => _i181.GeminiLlmAdapter(
        scrubber: gh<_i94.PromptScrubber>(),
        userProfileRepository: gh<_i116.UserProfileRepository>(),
        modelWrapper: gh<_i40.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i182.LlmAdapterFactory>(
        () => _i182.LlmAdapterFactory(gh<_i105.SettingsRepository>()));
    gh.lazySingleton<_i183.LlmService>(() => _i184.GemmaLlmService(
          gh<_i119.VectorStoreService>(),
          gh<_i116.UserProfileRepository>(),
          gh<_i62.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i185.LlmSettingsCubit>(() => _i185.LlmSettingsCubit(
          gh<_i105.SettingsRepository>(),
          gh<_i26.DeviceCapabilityService>(),
          gh<_i62.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i186.MedicalResearchService>(
        () => _i186.MedicalResearchService(
              gh<_i75.MedicalWebSearchService>(),
              gh<_i71.MedicalScraperService>(),
            ));
    gh.factory<_i187.MedicationBloc>(
        () => _i187.MedicationBloc(gh<_i77.MedicationRepository>()));
    gh.factory<_i188.MeditationCubit>(() => _i188.MeditationCubit(
          gh<_i97.RecommendScriptUseCase>(),
          gh<_i109.StartSessionUseCase>(),
          gh<_i145.CompleteSessionUseCase>(),
          gh<_i164.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i189.OnboardingRepository>(() =>
        _i190.OnboardingRepositoryImpl(gh<_i116.UserProfileRepository>()));
    gh.lazySingleton<_i191.PatientContextIndexer>(
      () => _i191.PatientContextIndexer(
        gh<_i59.Isar>(),
        gh<_i119.VectorStoreService>(),
        gh<_i175.HealthRecordRepository>(),
        gh<_i77.MedicationRepository>(),
        gh<_i132.AllergyRepository>(),
        gh<_i121.VitalSignRepository>(),
        gh<_i135.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i192.ReportGenerationService>(
        () => _i193.GemmaReportGenerationService(
              gh<_i62.LlmAdapter>(instanceName: 'gemma'),
              gh<_i119.VectorStoreService>(),
              gh<_i116.UserProfileRepository>(),
              gh<_i94.PromptScrubber>(),
            ));
    gh.factory<_i194.SaveAppointmentUseCase>(
        () => _i194.SaveAppointmentUseCase(gh<_i135.AppointmentRepository>()));
    gh.factory<_i195.SecondOpinionCubit>(
        () => _i195.SecondOpinionCubit(gh<_i101.SecondOpinionRepository>()));
    gh.factory<_i196.SendMessageUseCase>(
        () => _i196.SendMessageUseCase(gh<_i124.VoiceChatRepository>()));
    gh.lazySingleton<_i197.SmartSearchUseCase>(
        () => _i197.SmartSearchUseCase(gh<_i119.VectorStoreService>()));
    gh.lazySingleton<_i198.StartListeningUseCase>(
        () => _i198.StartListeningUseCase(
              gh<_i142.BleSharingService>(),
              gh<_i87.NfcSharingService>(),
              gh<_i128.WifiDirectService>(),
            ));
    gh.lazySingleton<_i199.StartSharingUseCase>(() => _i199.StartSharingUseCase(
          gh<_i142.BleSharingService>(),
          gh<_i87.NfcSharingService>(),
          gh<_i128.WifiDirectService>(),
        ));
    gh.factory<_i200.SyncCubit>(() => _i200.SyncCubit(
          gh<_i67.SyncService>(),
          gh<_i119.VectorStoreService>(),
        ));
    gh.factory<_i201.UserProfileCubit>(
        () => _i201.UserProfileCubit(gh<_i116.UserProfileRepository>()));
    gh.factory<_i202.VitalSignBloc>(
        () => _i202.VitalSignBloc(gh<_i121.VitalSignRepository>()));
    gh.factory<_i203.VoiceChatCubit>(() => _i203.VoiceChatCubit(
          gh<_i196.SendMessageUseCase>(),
          gh<_i161.GetChatHistoryUseCase>(),
          gh<_i124.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i204.VouchCubit>(
        () => _i204.VouchCubit(gh<_i126.VouchRepository>()));
    gh.factory<_i205.AllergiesCubit>(
        () => _i205.AllergiesCubit(gh<_i132.AllergyRepository>()));
    gh.factory<_i206.AllergyBloc>(
        () => _i206.AllergyBloc(gh<_i132.AllergyRepository>()));
    gh.factory<_i207.AppointmentBloc>(
        () => _i207.AppointmentBloc(gh<_i135.AppointmentRepository>()));
    gh.factory<_i208.AuthCubit>(() => _i208.AuthCubit(gh<_i141.AuthService>()));
    gh.factory<_i209.AuthCubit>(() => _i209.AuthCubit(
          gh<_i139.AuthRepository>(),
          gh<_i32.EncryptionService>(),
          gh<_i11.BiometricService>(),
        ));
    gh.lazySingleton<_i210.BadgeCalculator>(() => _i210.BadgeCalculator(
          gh<_i154.DoctorProfileRepository>(),
          gh<_i95.RatingRepository>(),
          gh<_i126.VouchRepository>(),
        ));
    gh.factory<_i211.BadgeCubit>(
        () => _i211.BadgeCubit(gh<_i210.BadgeCalculator>()));
    gh.factory<_i212.CalendarImportCubit>(() => _i212.CalendarImportCubit(
          gh<_i19.CalendarRepository>(),
          gh<_i179.ImportCalendarUseCase>(),
        ));
    gh.factory<_i213.DashboardCubit>(() => _i213.DashboardCubit(
          gh<_i163.GetDashboardStatsUseCase>(),
          gh<_i165.GetRecentActivityUseCase>(),
        ));
    gh.lazySingleton<_i214.DistributedCacheUsecase>(() =>
        _i214.DistributedCacheUsecase(gh<_i152.DistributedStorageService>()));
    gh.factory<_i215.EpsConnectionBloc>(() => _i215.EpsConnectionBloc(
          gh<_i162.GetConnectionsUseCase>(),
          gh<_i146.ConnectProviderUseCase>(),
          gh<_i151.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i216.EpsConnectionCubit>(() => _i216.EpsConnectionCubit(
          gh<_i162.GetConnectionsUseCase>(),
          gh<_i146.ConnectProviderUseCase>(),
          gh<_i151.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i217.GetHealthSummaryUseCase>(
        () => _i217.GetHealthSummaryUseCase(gh<_i177.HomeRepository>()));
    gh.factory<_i218.HealthRecordCubit>(() => _i218.HealthRecordCubit(
          gh<_i175.HealthRecordRepository>(),
          gh<_i35.FilePickerService>(),
          gh<_i54.ImagePickerService>(),
          gh<_i93.OcrService>(),
          gh<_i119.VectorStoreService>(),
        ));
    gh.factory<_i219.HomeCubit>(() => _i219.HomeCubit(
          gh<_i217.GetHealthSummaryUseCase>(),
          gh<_i177.HomeRepository>(),
        ));
    gh.lazySingleton<_i183.LlmService>(
      () => _i220.RagLlmService(
        gh<_i119.VectorStoreService>(),
        gh<_i186.MedicalResearchService>(),
        gh<_i116.UserProfileRepository>(),
        gh<_i62.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i221.MedicalIndexingService>(
        () => _i221.MedicalIndexingService(
              gh<_i68.MedicalKnowledgeRepository>(),
              gh<_i119.VectorStoreService>(),
              gh<_i191.PatientContextIndexer>(),
            ));
    gh.lazySingleton<_i222.MedicalResearchRepository>(
        () => _i223.MedicalResearchRepositoryImpl(
              gh<_i186.MedicalResearchService>(),
              gh<_i59.Isar>(),
            ));
    gh.factory<_i224.OnboardingCubit>(
        () => _i224.OnboardingCubit(gh<_i189.OnboardingRepository>()));
    gh.factory<_i225.ReportBloc>(() => _i225.ReportBloc(
          gh<_i98.ReportRepository>(),
          gh<_i192.ReportGenerationService>(),
        ));
    gh.factory<_i226.SearchMedicalResearch>(() =>
        _i226.SearchMedicalResearch(gh<_i222.MedicalResearchRepository>()));
    gh.factory<_i227.SharingCubit>(() => _i227.SharingCubit(
          bleService: gh<_i142.BleSharingService>(),
          nfcService: gh<_i87.NfcSharingService>(),
          wifiService: gh<_i128.WifiDirectService>(),
          startSharingUseCase: gh<_i199.StartSharingUseCase>(),
          startListeningUseCase: gh<_i198.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i143.CancelSharingUseCase>(),
          walletService: gh<_i33.WalletService>(),
          walletEncryption: gh<_i33.EncryptionService>(),
        ));
    gh.factory<_i228.GetResearchHistory>(
        () => _i228.GetResearchHistory(gh<_i222.MedicalResearchRepository>()));
    gh.factory<_i229.MedicalResearchCubit>(() => _i229.MedicalResearchCubit(
          gh<_i226.SearchMedicalResearch>(),
          gh<_i228.GetResearchHistory>(),
          gh<_i73.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i230.ServiceModule {}

class _$NetworkModule extends _i231.NetworkModule {}

class _$MemoryModule extends _i232.MemoryModule {}

class _$DatabaseModule extends _i233.DatabaseModule {}

class _$FhirModule extends _i234.FhirModule {}
