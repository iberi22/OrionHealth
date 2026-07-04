// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i15;
import 'package:dio/dio.dart' as _i27;
import 'package:flutter/services.dart' as _i84;
import 'package:flutter_appauth/flutter_appauth.dart' as _i36;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i38;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i40;
import 'package:health_wallet/health_wallet.dart' as _i31;
import 'package:http/http.dart' as _i21;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i57;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i30;
import 'package:just_audio/just_audio.dart' as _i9;
import 'package:medical_standards/medical_standards.dart' as _i65;
import 'package:shared_preferences/shared_preferences.dart' as _i48;

import '../../features/about/application/about_cubit.dart' as _i125;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i50;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i126;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i51;
import '../../features/allergies/application/allergies_cubit.dart' as _i200;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i201;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i127;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i129;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i128;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i132;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i202;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i130;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i145;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i154;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i187;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i131;
import '../../features/auth/application/auth_cubit.dart' as _i203;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i204;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i133;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i135;
import '../../features/auth/domain/auth_service.dart' as _i136;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i134;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i11;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i32;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i207;
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i16;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i18;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i172;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i14;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i17;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i19;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i208;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i143;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i157;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i159;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
    as _i142;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i24;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i144;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i206;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i151;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i188;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i199;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i149;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i93;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i99;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i122;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i205;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i59;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i58;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i150;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i94;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i100;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i123;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i152;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i153;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i28;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i108;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i29;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i210;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i211;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i89;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i141;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i146;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i156;
import '../../features/eps_connection/infrastructure/datasources/oauth_local_datasource.dart'
    as _i88;
import '../../features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart'
    as _i90;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i166;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i167;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i164;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i43;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i98;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i101;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i165;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i214;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i168;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i169;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i34;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i52;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i91;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i223;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i105;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i138;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i191;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i192;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i137;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i12;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i44;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart'
    as _i45;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i83;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i85;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i106;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i124;
import '../../features/home/application/home_cubit.dart' as _i215;
import '../../features/home/domain/repositories/home_repository.dart' as _i170;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i213;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i46;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i47;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i49;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i171;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i190;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i139;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i64;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i66;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i60;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i115;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i61;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i37;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i173;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i39;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i174;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i62;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i177;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i176;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i216;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i68;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i67;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i116;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i175;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i63;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i217;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i82;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i184;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i225;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i218;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i69;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i71;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i73;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i224;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i222;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i13;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i179;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i70;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i72;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i74;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i219;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i180;
import '../../features/medications/application/medications_cubit.dart' as _i77;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i75;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i76;
import '../../features/meditation/application/meditation_cubit.dart' as _i181;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i79;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i140;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i158;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i160;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i95;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i107;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i78;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i80;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i162;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i161;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i163;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i54;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i53;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i55;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i23;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i22;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i41;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i42;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i220;
import '../../features/onboarding/application/sync_cubit.dart' as _i193;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i182;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i183;
import '../../features/reports/application/bloc/report_bloc.dart' as _i221;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i96;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i185;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i97;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i186;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i81;
import '../../features/settings/application/llm_settings_cubit.dart' as _i178;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i103;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i25;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i102;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i104;
import '../../features/sync/application/sync_cubit.dart' as _i212;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i109;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i147;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i86;
import '../../features/sync/domain/services/sync_service.dart' as _i194;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i209;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i35;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i56;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i110;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i33;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i148;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i87;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i195;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i196;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i111;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i112;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i114;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i113;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i197;
import '../../features/vitals/application/vitals_cubit.dart' as _i119;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i117;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i118;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i198;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i120;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i155;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i189;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i20;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i121;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/audio/audio_recorder_service.dart' as _i10;
import '../services/device_capability_service.dart' as _i26;
import '../services/privacy_anonymizer.dart' as _i92;
import 'database_module.dart' as _i229;
import 'fhir_module.dart' as _i230;
import 'memory_module.dart' as _i228;
import 'network_module.dart' as _i227;
import 'service_module.dart' as _i226;

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
    gh.lazySingleton<_i16.CalendarImportRepository>(() =>
        _i17.CalendarImportRepositoryImpl(gh<_i14.CalendarApiDatasource>()));
    gh.lazySingleton<_i18.CalendarParserService>(
        () => _i19.CalendarParserServiceImpl());
    gh.lazySingleton<_i20.ChatAiDatasource>(() => _i20.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i21.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i22.ConnectNode>(
        () => _i22.ConnectNode(gh<_i23.NetworkRepository>()));
    gh.lazySingleton<_i24.DashboardRemoteDataSource>(
        () => _i24.DashboardRemoteDataSourceImpl());
    gh.lazySingleton<_i25.DeviceCapabilityService>(
        () => _i25.DeviceCapabilityService());
    gh.lazySingleton<_i26.DeviceCapabilityService>(
        () => _i26.DeviceCapabilityService());
    gh.lazySingleton<_i27.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i28.EmailRepository>(() => _i29.EmailRepositoryImpl(
          gh<_i21.Client>(),
          gh<_i15.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i30.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i31.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i32.EncryptionService>(() => _i32.EncryptionService());
    gh.lazySingleton<_i33.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i34.FilePickerService>(
        () => _i34.FilePickerServiceImpl());
    gh.lazySingleton<_i35.FilecoinDatasource>(() => _i35.FilecoinDatasource());
    gh.lazySingleton<_i36.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i37.FlutterGemmaWrapper>(
        () => _i37.FlutterGemmaWrapper());
    gh.lazySingleton<_i38.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i39.GeminiModelWrapper>(
        () => _i39.GeminiModelWrapper(gh<_i40.GenerativeModel>()));
    gh.lazySingleton<_i41.GetNetworkHealth>(
        () => _i41.GetNetworkHealth(gh<_i23.NetworkRepository>()));
    gh.lazySingleton<_i42.GetNodeStats>(
        () => _i42.GetNodeStats(gh<_i23.NetworkRepository>()));
    gh.lazySingleton<_i43.HealthDataImportService>(
        () => _i43.HealthDataImportService());
    gh.lazySingleton<_i44.HealthSharingLocalDataSource>(
        () => _i44.HealthSharingLocalDataSource());
    gh.lazySingleton<_i45.HealthSharingRemoteDataSource>(
        () => _i45.HealthSharingRemoteDataSource());
    gh.factory<_i46.HealthSummaryDatasource>(
        () => _i46.HealthSummaryDatasource());
    gh.factory<_i47.HomeLocalDataSource>(
        () => _i47.HomeLocalDataSource(gh<_i48.SharedPreferences>()));
    gh.factory<_i49.HomeRemoteDataSource>(() => _i49.HomeRemoteDataSource());
    gh.lazySingleton<_i50.IAboutRepository>(
        () => _i51.AboutRepositoryImpl(gh<_i4.AboutLocalDataSource>()));
    gh.lazySingleton<_i52.ImagePickerService>(
        () => _i52.ImagePickerServiceImpl());
    gh.lazySingleton<_i53.IncentiveDatasource>(
        () => _i53.IncentiveDatasource());
    gh.lazySingleton<_i54.IncentiveRepository>(
        () => _i55.IncentiveRepositoryImpl(gh<_i53.IncentiveDatasource>()));
    gh.lazySingleton<_i56.IpfsDatasource>(
        () => _i56.IpfsDatasource(gh<_i27.Dio>()));
    await gh.factoryAsync<_i57.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i58.LicenseRegistryLocalDataSource>(() {
      final i = _i58.LicenseRegistryLocalDataSource(gh<_i57.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i59.LicenseVerifier>(() async =>
        _i59.LicenseVerifier(
            await getAsync<_i58.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i60.LlmAdapter>(
      () => _i61.FlutterGemmaAdapter(wrapper: gh<_i37.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i60.LlmAdapter>(
      () => _i62.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i63.LocalLlmService>(() => _i63.LocalLlmService());
    gh.lazySingleton<_i64.LocalModelLocalDataSource>(
        () => _i64.LocalModelLocalDataSource());
    gh.lazySingleton<_i65.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i66.MedicalKnowledgeRepository>(
      () => _i67.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i66.MedicalKnowledgeRepository>(
      () => _i68.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i69.MedicalScraperService>(
        () => _i70.MedicalScraperServiceImpl(
              gh<_i27.Dio>(),
              gh<_i13.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i71.MedicalStandardsService>(() =>
        _i72.MedicalStandardsServiceImpl(gh<_i65.MedicalContextProvider>()));
    gh.lazySingleton<_i73.MedicalWebSearchService>(
        () => _i74.MedicalWebSearchServiceImpl(gh<_i27.Dio>()));
    gh.lazySingleton<_i75.MedicationRepository>(
        () => _i76.IsarMedicationRepository(gh<_i57.Isar>()));
    gh.factory<_i77.MedicationsCubit>(
        () => _i77.MedicationsCubit(gh<_i75.MedicationRepository>()));
    gh.lazySingleton<_i78.MeditationLocalDataSource>(
        () => _i78.MeditationLocalDataSource());
    gh.lazySingleton<_i79.MeditationRepository>(() =>
        _i80.MeditationRepositoryImpl(gh<_i78.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i30.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i57.Isar>(),
        gh<_i30.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i81.MockReportGenerationService>(
      () => _i81.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i82.ModelDownloadService>(
        () => _i82.ModelDownloadService());
    gh.lazySingleton<_i83.NfcHandler>(
        () => _i83.NfcHandler(channel: gh<_i84.MethodChannel>()));
    gh.lazySingleton<_i85.NfcSharingService>(
        () => _i85.NfcSharingService(gh<_i83.NfcHandler>()));
    gh.lazySingleton<_i86.NodeDiscoveryService>(
        () => _i87.NodeDiscoveryService());
    gh.lazySingleton<_i88.OAuthLocalDataSource>(
        () => _i88.OAuthLocalDataSource(gh<_i38.FlutterSecureStorage>()));
    gh.lazySingleton<_i89.OAuthRepository>(() => _i90.OAuthRepositoryImpl(
          gh<_i88.OAuthLocalDataSource>(),
          gh<_i27.Dio>(),
          gh<_i36.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i91.OcrService>(() => _i91.MlKitOcrService());
    gh.lazySingleton<_i92.PromptScrubber>(
        () => _i92.PromptScrubber(gh<_i57.Isar>()));
    gh.lazySingleton<_i93.RatingRepository>(
        () => _i94.IsarRatingRepository(gh<_i57.Isar>()));
    gh.lazySingleton<_i95.RecommendScriptUseCase>(
        () => _i95.RecommendScriptUseCase(gh<_i79.MeditationRepository>()));
    gh.lazySingleton<_i96.ReportRepository>(
        () => _i97.IsarReportRepository(gh<_i57.Isar>()));
    gh.factory<_i98.RequestHealthAuthUseCase>(() =>
        _i98.RequestHealthAuthUseCase(gh<_i43.HealthDataImportService>()));
    gh.lazySingleton<_i99.SecondOpinionRepository>(
        () => _i100.IsarSecondOpinionRepository(gh<_i57.Isar>()));
    gh.lazySingleton<_i101.SensorHealthDataSource>(
        () => _i101.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i102.SettingsLocalDataSource>(
        () => _i102.SettingsLocalDataSource(gh<_i57.Isar>()));
    gh.lazySingleton<_i103.SettingsRepository>(() =>
        _i104.SettingsRepositoryImpl(gh<_i102.SettingsLocalDataSource>()));
    gh.lazySingleton<_i105.SharingRepository>(() =>
        _i106.HealthSharingRepositoryImpl(
            gh<_i44.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i107.StartSessionUseCase>(
        () => _i107.StartSessionUseCase(gh<_i79.MeditationRepository>()));
    gh.factory<_i108.SyncEmailAppointmentsUseCase>(
        () => _i108.SyncEmailAppointmentsUseCase(gh<_i28.EmailRepository>()));
    gh.lazySingleton<_i109.SyncRepository>(() => _i110.SyncRepositoryImpl(
          gh<_i33.FhirClient>(),
          gh<_i57.Isar>(),
          gh<_i38.FlutterSecureStorage>(),
          gh<_i86.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i65.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i111.UserProfileLocalDataSource>(
        () => _i111.UserProfileLocalDataSource(gh<_i57.Isar>()));
    gh.lazySingleton<_i112.UserProfileRepository>(
        () => _i113.UserProfileRepositoryImpl(gh<_i57.Isar>()));
    gh.lazySingleton<_i114.UserProfileService>(
        () => _i114.UserProfileService(gh<_i112.UserProfileRepository>()));
    gh.lazySingleton<_i115.VectorStoreService>(
        () => _i116.IsarVectorStoreService(
              gh<_i30.MemoryGraph>(),
              gh<_i66.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i117.VitalSignRepository>(
        () => _i118.VitalSignRepositoryImpl(gh<_i57.Isar>()));
    gh.factory<_i119.VitalsCubit>(
        () => _i119.VitalsCubit(gh<_i117.VitalSignRepository>()));
    gh.lazySingleton<_i120.VoiceChatRepository>(
        () => _i121.VoiceChatRepositoryImpl(gh<_i20.ChatAiDatasource>()));
    gh.lazySingleton<_i122.VouchRepository>(
        () => _i123.IsarVouchRepository(gh<_i57.Isar>()));
    gh.lazySingleton<_i31.WalletService>(() => databaseModule.walletService(
          gh<_i57.Isar>(),
          gh<_i31.EncryptionService>(),
        ));
    gh.lazySingleton<_i124.WifiDirectService>(() => _i124.WifiDirectService());
    gh.factory<_i125.AboutCubit>(
        () => _i125.AboutCubit(gh<_i50.IAboutRepository>()));
    gh.lazySingleton<_i126.AboutRemoteDataSource>(
        () => _i126.AboutRemoteDataSource(gh<_i27.Dio>()));
    gh.lazySingleton<_i127.AllergyLocalDataSource>(
        () => _i127.AllergyLocalDataSource(gh<_i57.Isar>()));
    gh.lazySingleton<_i128.AllergyRepository>(
        () => _i129.AllergyRepositoryImpl(gh<_i127.AllergyLocalDataSource>()));
    gh.lazySingleton<_i130.AppointmentRepository>(
        () => _i131.IsarAppointmentRepository(gh<_i57.Isar>()));
    gh.factory<_i132.AppointmentsCubit>(
        () => _i132.AppointmentsCubit(gh<_i130.AppointmentRepository>()));
    gh.lazySingleton<_i133.AuthLocalDataSource>(
        () => _i133.AuthLocalDataSource(gh<_i57.Isar>()));
    gh.lazySingleton<_i134.AuthRepository>(
        () => _i135.AuthRepositoryImpl(gh<_i133.AuthLocalDataSource>()));
    gh.lazySingleton<_i136.AuthService>(
        () => _i136.AuthServiceImpl(gh<_i32.EncryptionService>()));
    gh.lazySingleton<_i137.BleSharingService>(
        () => _i137.BleSharingService(gh<_i12.BleWrapper>()));
    gh.lazySingleton<_i138.CancelSharingUseCase>(
        () => _i138.CancelSharingUseCase(
              gh<_i137.BleSharingService>(),
              gh<_i85.NfcSharingService>(),
              gh<_i124.WifiDirectService>(),
            ));
    gh.lazySingleton<_i139.ChatMessageLocalDataSource>(
        () => _i139.ChatMessageLocalDataSource(gh<_i57.Isar>()));
    gh.lazySingleton<_i140.CompleteSessionUseCase>(
        () => _i140.CompleteSessionUseCase(gh<_i79.MeditationRepository>()));
    gh.factory<_i108.ConnectEmailProviderUseCase>(
        () => _i108.ConnectEmailProviderUseCase(gh<_i28.EmailRepository>()));
    gh.factory<_i141.ConnectProviderUseCase>(() => _i141.ConnectProviderUseCase(
          gh<_i89.OAuthRepository>(),
          gh<_i112.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i142.DashboardLocalDataSource>(
        () => _i142.DashboardLocalDataSource(gh<_i57.Isar>()));
    gh.lazySingleton<_i143.DashboardRepository>(
        () => _i144.DashboardRepositoryImpl(
              gh<_i24.DashboardRemoteDataSource>(),
              gh<_i117.VitalSignRepository>(),
              gh<_i75.MedicationRepository>(),
              gh<_i96.ReportRepository>(),
            ));
    gh.factory<_i145.DeleteAppointmentUseCase>(() =>
        _i145.DeleteAppointmentUseCase(gh<_i130.AppointmentRepository>()));
    gh.factory<_i146.DisconnectProviderUseCase>(
        () => _i146.DisconnectProviderUseCase(
              gh<_i89.OAuthRepository>(),
              gh<_i112.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i147.DistributedStorageService>(() => _i148.IpfsService(
          gh<_i56.IpfsDatasource>(),
          gh<_i35.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i149.DoctorProfileRepository>(
        () => _i150.IsarDoctorProfileRepository(gh<_i57.Isar>()));
    gh.factoryAsync<_i151.DoctorVerificationCubit>(
        () async => _i151.DoctorVerificationCubit(
              gh<_i149.DoctorProfileRepository>(),
              gh<_i93.RatingRepository>(),
              await getAsync<_i59.LicenseVerifier>(),
            ));
    gh.factory<_i152.EmailCitasBloc>(() => _i152.EmailCitasBloc(
          gh<_i108.ConnectEmailProviderUseCase>(),
          gh<_i108.SyncEmailAppointmentsUseCase>(),
          gh<_i28.EmailRepository>(),
          gh<_i130.AppointmentRepository>(),
        ));
    gh.factory<_i153.EmailCitasCubit>(() => _i153.EmailCitasCubit(
          gh<_i28.EmailRepository>(),
          gh<_i130.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i101.FileHealthDataSource>(
        () => _i101.FileHealthDataSourceImpl(
              gh<_i34.FilePickerService>(),
              gh<_i91.OcrService>(),
            ));
    gh.factory<_i154.GetAllAppointmentsUseCase>(() =>
        _i154.GetAllAppointmentsUseCase(gh<_i130.AppointmentRepository>()));
    gh.factory<_i98.GetAvailableSourcesUseCase>(() =>
        _i98.GetAvailableSourcesUseCase(gh<_i43.HealthDataImportService>()));
    gh.factory<_i155.GetChatHistoryUseCase>(
        () => _i155.GetChatHistoryUseCase(gh<_i120.VoiceChatRepository>()));
    gh.factory<_i156.GetConnectionsUseCase>(
        () => _i156.GetConnectionsUseCase(gh<_i89.OAuthRepository>()));
    gh.factory<_i157.GetDashboardStatsUseCase>(
        () => _i157.GetDashboardStatsUseCase(gh<_i143.DashboardRepository>()));
    gh.lazySingleton<_i158.GetProgressUseCase>(
        () => _i158.GetProgressUseCase(gh<_i79.MeditationRepository>()));
    gh.factory<_i159.GetRecentActivityUseCase>(
        () => _i159.GetRecentActivityUseCase(gh<_i143.DashboardRepository>()));
    gh.lazySingleton<_i160.GetScriptsUseCase>(
        () => _i160.GetScriptsUseCase(gh<_i79.MeditationRepository>()));
    gh.lazySingleton<_i161.GovernanceIpfsDatasource>(
        () => _i161.GovernanceIpfsDatasource(gh<_i56.IpfsDatasource>()));
    gh.lazySingleton<_i162.GovernanceRepository>(() =>
        _i163.GovernanceRepositoryImpl(gh<_i161.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i164.HealthDataImportRepository>(
        () => _i165.HealthDataImportRepositoryImpl(
              gh<_i101.SensorHealthDataSource>(),
              gh<_i101.FileHealthDataSource>(),
            ));
    gh.factory<_i166.HealthImportBloc>(() => _i166.HealthImportBloc(
          gh<_i98.GetAvailableSourcesUseCase>(),
          gh<_i98.RequestHealthAuthUseCase>(),
          gh<_i43.HealthDataImportService>(),
          gh<_i117.VitalSignRepository>(),
        ));
    gh.factory<_i167.HealthImportCubit>(() => _i167.HealthImportCubit(
          gh<_i43.HealthDataImportService>(),
          gh<_i117.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i168.HealthRecordRepository>(
        () => _i169.HealthRecordRepositoryImpl(gh<_i57.Isar>()));
    gh.lazySingleton<_i170.HomeRepository>(() => _i171.HomeRepositoryImpl(
          gh<_i117.VitalSignRepository>(),
          gh<_i130.AppointmentRepository>(),
          gh<_i75.MedicationRepository>(),
          gh<_i47.HomeLocalDataSource>(),
          gh<_i49.HomeRemoteDataSource>(),
        ));
    gh.factory<_i172.ImportCalendarUseCase>(() => _i172.ImportCalendarUseCase(
          gh<_i16.CalendarImportRepository>(),
          gh<_i130.AppointmentRepository>(),
          gh<_i112.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i60.LlmAdapter>(
      () => _i173.GeminiLlmAdapter(
        scrubber: gh<_i92.PromptScrubber>(),
        userProfileRepository: gh<_i112.UserProfileRepository>(),
        modelWrapper: gh<_i39.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i60.LlmAdapter>(
      () => _i174.MockLlmAdapter(gh<_i92.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i175.LlmAdapterFactory>(
        () => _i175.LlmAdapterFactory(gh<_i103.SettingsRepository>()));
    gh.lazySingleton<_i176.LlmService>(() => _i177.GemmaLlmService(
          gh<_i115.VectorStoreService>(),
          gh<_i112.UserProfileRepository>(),
          gh<_i60.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i178.LlmSettingsCubit>(() => _i178.LlmSettingsCubit(
          gh<_i103.SettingsRepository>(),
          gh<_i25.DeviceCapabilityService>(),
          gh<_i60.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i179.MedicalResearchService>(
        () => _i179.MedicalResearchService(
              gh<_i73.MedicalWebSearchService>(),
              gh<_i69.MedicalScraperService>(),
            ));
    gh.factory<_i180.MedicationBloc>(
        () => _i180.MedicationBloc(gh<_i75.MedicationRepository>()));
    gh.factory<_i181.MeditationCubit>(() => _i181.MeditationCubit(
          gh<_i95.RecommendScriptUseCase>(),
          gh<_i107.StartSessionUseCase>(),
          gh<_i140.CompleteSessionUseCase>(),
          gh<_i158.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i182.OnboardingRepository>(() =>
        _i183.OnboardingRepositoryImpl(gh<_i112.UserProfileRepository>()));
    gh.lazySingleton<_i184.PatientContextIndexer>(
      () => _i184.PatientContextIndexer(
        gh<_i57.Isar>(),
        gh<_i115.VectorStoreService>(),
        gh<_i168.HealthRecordRepository>(),
        gh<_i75.MedicationRepository>(),
        gh<_i128.AllergyRepository>(),
        gh<_i117.VitalSignRepository>(),
        gh<_i130.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i185.ReportGenerationService>(
        () => _i186.GemmaReportGenerationService(
              gh<_i60.LlmAdapter>(instanceName: 'gemma'),
              gh<_i115.VectorStoreService>(),
              gh<_i112.UserProfileRepository>(),
              gh<_i92.PromptScrubber>(),
            ));
    gh.factory<_i187.SaveAppointmentUseCase>(
        () => _i187.SaveAppointmentUseCase(gh<_i130.AppointmentRepository>()));
    gh.factory<_i188.SecondOpinionCubit>(
        () => _i188.SecondOpinionCubit(gh<_i99.SecondOpinionRepository>()));
    gh.factory<_i189.SendMessageUseCase>(
        () => _i189.SendMessageUseCase(gh<_i120.VoiceChatRepository>()));
    gh.lazySingleton<_i190.SmartSearchUseCase>(
        () => _i190.SmartSearchUseCase(gh<_i115.VectorStoreService>()));
    gh.lazySingleton<_i191.StartListeningUseCase>(
        () => _i191.StartListeningUseCase(
              gh<_i137.BleSharingService>(),
              gh<_i85.NfcSharingService>(),
              gh<_i124.WifiDirectService>(),
            ));
    gh.lazySingleton<_i192.StartSharingUseCase>(() => _i192.StartSharingUseCase(
          gh<_i137.BleSharingService>(),
          gh<_i85.NfcSharingService>(),
          gh<_i124.WifiDirectService>(),
        ));
    gh.factory<_i193.SyncCubit>(() => _i193.SyncCubit(
          gh<_i65.SyncService>(),
          gh<_i115.VectorStoreService>(),
        ));
    gh.lazySingleton<_i194.SyncService>(() => _i195.SyncServiceImpl(
          gh<_i109.SyncRepository>(),
          gh<_i65.SyncService>(),
        ));
    gh.factory<_i196.UserProfileCubit>(
        () => _i196.UserProfileCubit(gh<_i112.UserProfileRepository>()));
    gh.factory<_i197.VitalSignBloc>(
        () => _i197.VitalSignBloc(gh<_i117.VitalSignRepository>()));
    gh.factory<_i198.VoiceChatCubit>(() => _i198.VoiceChatCubit(
          gh<_i189.SendMessageUseCase>(),
          gh<_i155.GetChatHistoryUseCase>(),
          gh<_i120.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i199.VouchCubit>(
        () => _i199.VouchCubit(gh<_i122.VouchRepository>()));
    gh.factory<_i200.AllergiesCubit>(
        () => _i200.AllergiesCubit(gh<_i128.AllergyRepository>()));
    gh.factory<_i201.AllergyBloc>(
        () => _i201.AllergyBloc(gh<_i128.AllergyRepository>()));
    gh.factory<_i202.AppointmentBloc>(
        () => _i202.AppointmentBloc(gh<_i130.AppointmentRepository>()));
    gh.factory<_i203.AuthCubit>(() => _i203.AuthCubit(gh<_i136.AuthService>()));
    gh.factory<_i204.AuthCubit>(() => _i204.AuthCubit(
          gh<_i134.AuthRepository>(),
          gh<_i32.EncryptionService>(),
          gh<_i11.BiometricService>(),
        ));
    gh.lazySingleton<_i205.BadgeCalculator>(() => _i205.BadgeCalculator(
          gh<_i149.DoctorProfileRepository>(),
          gh<_i93.RatingRepository>(),
          gh<_i122.VouchRepository>(),
        ));
    gh.factory<_i206.BadgeCubit>(
        () => _i206.BadgeCubit(gh<_i205.BadgeCalculator>()));
    gh.factory<_i207.CalendarImportCubit>(() => _i207.CalendarImportCubit(
          gh<_i16.CalendarImportRepository>(),
          gh<_i172.ImportCalendarUseCase>(),
        ));
    gh.factory<_i208.DashboardCubit>(() => _i208.DashboardCubit(
          gh<_i157.GetDashboardStatsUseCase>(),
          gh<_i159.GetRecentActivityUseCase>(),
        ));
    gh.lazySingleton<_i209.DistributedCacheUsecase>(() =>
        _i209.DistributedCacheUsecase(gh<_i147.DistributedStorageService>()));
    gh.factory<_i210.EpsConnectionBloc>(() => _i210.EpsConnectionBloc(
          gh<_i156.GetConnectionsUseCase>(),
          gh<_i141.ConnectProviderUseCase>(),
          gh<_i146.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i211.EpsConnectionCubit>(() => _i211.EpsConnectionCubit(
          gh<_i156.GetConnectionsUseCase>(),
          gh<_i141.ConnectProviderUseCase>(),
          gh<_i146.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i212.FhirSyncCubit>(() => _i212.FhirSyncCubit(
          gh<_i194.SyncService>(),
          gh<_i86.NodeDiscoveryService>(),
        ));
    gh.factory<_i213.GetHealthSummaryUseCase>(
        () => _i213.GetHealthSummaryUseCase(gh<_i170.HomeRepository>()));
    gh.factory<_i214.HealthRecordCubit>(() => _i214.HealthRecordCubit(
          gh<_i168.HealthRecordRepository>(),
          gh<_i34.FilePickerService>(),
          gh<_i52.ImagePickerService>(),
          gh<_i91.OcrService>(),
          gh<_i115.VectorStoreService>(),
        ));
    gh.factory<_i215.HomeCubit>(() => _i215.HomeCubit(
          gh<_i213.GetHealthSummaryUseCase>(),
          gh<_i170.HomeRepository>(),
        ));
    gh.lazySingleton<_i176.LlmService>(
      () => _i216.RagLlmService(
        gh<_i115.VectorStoreService>(),
        gh<_i179.MedicalResearchService>(),
        gh<_i112.UserProfileRepository>(),
        gh<_i60.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i217.MedicalIndexingService>(
        () => _i217.MedicalIndexingService(
              gh<_i66.MedicalKnowledgeRepository>(),
              gh<_i115.VectorStoreService>(),
              gh<_i184.PatientContextIndexer>(),
            ));
    gh.lazySingleton<_i218.MedicalResearchRepository>(
        () => _i219.MedicalResearchRepositoryImpl(
              gh<_i179.MedicalResearchService>(),
              gh<_i57.Isar>(),
            ));
    gh.factory<_i220.OnboardingCubit>(
        () => _i220.OnboardingCubit(gh<_i182.OnboardingRepository>()));
    gh.factory<_i221.ReportBloc>(() => _i221.ReportBloc(
          gh<_i96.ReportRepository>(),
          gh<_i185.ReportGenerationService>(),
        ));
    gh.factory<_i222.SearchMedicalResearch>(() =>
        _i222.SearchMedicalResearch(gh<_i218.MedicalResearchRepository>()));
    gh.factory<_i223.SharingCubit>(() => _i223.SharingCubit(
          bleService: gh<_i137.BleSharingService>(),
          nfcService: gh<_i85.NfcSharingService>(),
          wifiService: gh<_i124.WifiDirectService>(),
          startSharingUseCase: gh<_i192.StartSharingUseCase>(),
          startListeningUseCase: gh<_i191.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i138.CancelSharingUseCase>(),
          walletService: gh<_i31.WalletService>(),
          walletEncryption: gh<_i31.EncryptionService>(),
        ));
    gh.factory<_i224.GetResearchHistory>(
        () => _i224.GetResearchHistory(gh<_i218.MedicalResearchRepository>()));
    gh.factory<_i225.MedicalResearchCubit>(() => _i225.MedicalResearchCubit(
          gh<_i222.SearchMedicalResearch>(),
          gh<_i224.GetResearchHistory>(),
          gh<_i71.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i226.ServiceModule {}

class _$NetworkModule extends _i227.NetworkModule {}

class _$MemoryModule extends _i228.MemoryModule {}

class _$DatabaseModule extends _i229.DatabaseModule {}

class _$FhirModule extends _i230.FhirModule {}
