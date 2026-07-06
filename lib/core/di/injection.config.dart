// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i18;
import 'package:dio/dio.dart' as _i29;
import 'package:flutter/services.dart' as _i91;
import 'package:flutter_appauth/flutter_appauth.dart' as _i38;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i40;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i42;
import 'package:health_wallet/health_wallet.dart' as _i33;
import 'package:http/http.dart' as _i24;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i59;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i32;
import 'package:just_audio/just_audio.dart' as _i12;
import 'package:medical_standards/medical_standards.dart' as _i67;
import 'package:shared_preferences/shared_preferences.dart' as _i50;

import '../../features/about/application/about_cubit.dart' as _i136;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i52;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i162;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i137;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i52;
import '../../features/allergies/application/allergies_cubit.dart' as _i225;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i226;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i138;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i140;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i139;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/domain/usecases/get_allergies_usecase.dart'
    as _i166;
import '../../features/allergies/domain/usecases/save_allergy_usecase.dart'
    as _i208;
import '../../features/appointments/application/appointments_cubit.dart' as _i9;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i6;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i7;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i8;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i26;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i43;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i106;
import '../../features/auth/application/auth_cubit.dart' as _i227;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i228;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i141;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i143;
import '../../features/auth/domain/auth_service.dart' as _i144;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i142;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i170;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i209;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i15;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i34;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i231;
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i19;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i21;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i191;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i17;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i20;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i22;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i233;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i152;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i171;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i176;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
    as _i151;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i25;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i153;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i230;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i159;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i213;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i224;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i157;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i100;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i109;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i133;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i229;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i60;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
    as _i163;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i172;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i59;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i158;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i101;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i110;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i134;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i160;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i161;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i30;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i119;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i31;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i117;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i32;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i235;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i236;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i96;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i150;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i154;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i169;
import '../../features/eps_connection/infrastructure/datasources/oauth_local_datasource.dart'
    as _i95;
import '../../features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart'
    as _i97;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i185;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i186;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i183;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i44;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i105;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i112;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i184;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i241;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i187;
import '../../features/health_record/domain/usecases/get_all_records_usecase.dart'
    as _i238;
import '../../features/health_record/domain/usecases/save_record_usecase.dart'
    as _i210;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i188;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i36;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i53;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i98;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i250;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i116;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i146;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i216;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i217;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i145;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i15;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i46;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i90;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i92;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i117;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i135;
import '../../features/home/application/home_cubit.dart' as _i242;
import '../../features/home/domain/repositories/home_repository.dart' as _i189;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i239;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i47;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i88;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i90;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i116;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i136;
import '../../features/home/application/home_cubit.dart' as _i243;
import '../../features/home/domain/repositories/home_repository.dart' as _i192;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i240;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i48;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i49;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i51;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i190;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i215;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i147;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i66;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i68;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i62;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i126;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i168;
import '../../features/local_agent/domain/usecases/send_chat_message_usecase.dart'
    as _i111;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i63;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i39;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i193;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i41;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i192;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i62;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i196;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i195;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i243;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i69;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i68;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i127;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i194;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i64;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i244;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i83;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i205;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i252;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i245;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i70;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i72;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i74;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i251;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i249;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i16;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i198;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i72;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i74;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i75;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i246;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i199;
import '../../features/medications/application/medications_cubit.dart' as _i78;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i76;
import '../../features/medications/domain/usecases/get_all_medications_usecase.dart'
    as _i164;
import '../../features/medications/domain/usecases/save_medication_usecase.dart'
    as _i107;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i77;
import '../../features/meditation/application/meditation_cubit.dart' as _i200;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i80;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i148;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i175;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i178;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i102;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i118;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i79;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i81;
import '../../features/network/application/network_cubit.dart' as _i201;
import '../../features/network/domain/repositories/network_peer_repository.dart'
    as _i86;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i181;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i180;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i182;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i55;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i54;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i56;
import '../../features/network/infrastructure/datasources/network_p2p_api.dart'
    as _i85;
import '../../features/network/infrastructure/repositories/network_peer_repository_impl.dart'
    as _i87;
import '../../features/network/network_health/application/network_health_cubit.dart'
    as _i202;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i88;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i149;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i173;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i174;
import '../../features/network/network_health/infrastructure/datasources/network_datasource.dart'
    as _i84;
import '../../features/network/network_health/infrastructure/repositories/network_repository_impl.dart'
    as _i89;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i247;
import '../../features/onboarding/application/sync_cubit.dart' as _i218;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i203;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i232;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i240;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i204;
import '../../features/reports/application/bloc/report_bloc.dart' as _i248;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i103;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i206;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i177;
import '../../features/reports/domain/usecases/save_report_usecase.dart'
    as _i108;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i104;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i207;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i82;
import '../../features/settings/application/llm_settings_cubit.dart' as _i197;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i114;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i28;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i113;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i115;
import '../../features/sync/application/sync_cubit.dart' as _i237;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i120;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i155;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i93;
import '../../features/sync/domain/services/sync_service.dart' as _i219;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i234;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i37;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i57;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i121;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i35;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i156;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i94;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i220;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i221;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i122;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i123;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i125;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i179;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
    as _i211;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i124;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i222;
import '../../features/vitals/application/vitals_cubit.dart' as _i130;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i128;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i165;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
    as _i212;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i129;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i223;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i131;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i167;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i214;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i23;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i132;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i10;
import '../services/audio/audio_player_service.dart' as _i11;
import '../services/audio/audio_recorder_service.dart' as _i13;
import '../services/device_capability_service.dart' as _i27;
import '../services/privacy_anonymizer.dart' as _i99;
import 'database_module.dart' as _i256;
import 'fhir_module.dart' as _i257;
import 'memory_module.dart' as _i255;
import 'network_module.dart' as _i254;
import 'service_module.dart' as _i253;

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
    gh.lazySingleton<_i5.AdherenceSqliteDatasource>(
        () => _i5.AdherenceSqliteDatasource());
    gh.lazySingleton<_i3.AgentMemoryService>(() => _i3.AgentMemoryService());
    gh.lazySingleton<_i6.AllergyService>(() => _i6.AllergyService());
    gh.factory<_i7.AppointmentBloc>(
        () => _i7.AppointmentBloc(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i9.AppointmentService>(() => _i9.AppointmentService());
    gh.factory<_i10.AppointmentsCubit>(
        () => _i10.AppointmentsCubit(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i11.AsrService>(() => _i11.AsrService());
    gh.lazySingleton<_i12.AudioService>(() => _i12.AudioService(
          player: gh<_i13.AudioPlayer>(),
          recorder: gh<_i14.AudioRecorderService>(),
        ));
    gh.lazySingleton<_i15.BiometricService>(() => _i15.BiometricService());
    gh.lazySingleton<_i16.BleWrapper>(() => _i16.BleWrapper());
    gh.lazySingleton<_i17.BotBypassHandler>(() => _i17.BotBypassHandler());
    gh.factory<_i18.CalendarApiDatasource>(() => _i18.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i19.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i20.CalendarImportRepository>(() =>
        _i21.CalendarImportRepositoryImpl(gh<_i18.CalendarApiDatasource>()));
    gh.lazySingleton<_i22.CalendarParserService>(
        () => _i23.CalendarParserServiceImpl());
    gh.lazySingleton<_i24.ChatAiDatasource>(() => _i24.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i11.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i25.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i26.DashboardRemoteDataSource>(
        () => _i26.DashboardRemoteDataSourceImpl());
    gh.factory<_i27.DeleteAppointmentUseCase>(
        () => _i27.DeleteAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i28.DeviceCapabilityService>(
        () => _i28.DeviceCapabilityService());
    gh.lazySingleton<_i29.DeviceCapabilityService>(
        () => _i29.DeviceCapabilityService());
    gh.lazySingleton<_i30.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i31.EmailRepository>(() => _i32.EmailRepositoryImpl(
          gh<_i25.Client>(),
          gh<_i19.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i33.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i33.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i34.EncryptionService>(() => _i34.EncryptionService());
    gh.lazySingleton<_i35.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i36.FilePickerService>(
        () => _i36.FilePickerServiceImpl());
    gh.lazySingleton<_i37.FilecoinDatasource>(() => _i37.FilecoinDatasource());
    gh.lazySingleton<_i38.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i39.FlutterGemmaWrapper>(
        () => _i39.FlutterGemmaWrapper());
    gh.lazySingleton<_i40.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i41.GeminiModelWrapper>(
        () => _i41.GeminiModelWrapper(gh<_i42.GenerativeModel>()));
    gh.factory<_i43.GetAllAppointmentsUseCase>(
        () => _i43.GetAllAppointmentsUseCase(gh<_i7.AppointmentRepository>()));
    gh.lazySingleton<_i44.HealthConnectDataSource>(
        () => _i44.HealthConnectDataSourceImpl());
    gh.lazySingleton<_i45.HealthDataImportService>(
        () => _i45.HealthDataImportService());
    gh.lazySingleton<_i46.HealthSharingLocalDataSource>(
        () => _i46.HealthSharingLocalDataSource());
    gh.lazySingleton<_i47.HealthSharingRemoteDataSource>(
        () => _i47.HealthSharingRemoteDataSource());
    gh.factory<_i48.HealthSummaryDatasource>(
        () => _i48.HealthSummaryDatasource());
    gh.factory<_i49.HomeLocalDataSource>(
        () => _i49.HomeLocalDataSource(gh<_i50.SharedPreferences>()));
    gh.factory<_i51.HomeRemoteDataSource>(() => _i51.HomeRemoteDataSource());
    gh.lazySingleton<_i52.IAboutRepository>(
        () => _i53.AboutRepositoryImpl(gh<_i4.AboutLocalDataSource>()));
    gh.lazySingleton<_i54.ImagePickerService>(
        () => _i54.ImagePickerServiceImpl());
    gh.lazySingleton<_i55.IncentiveDatasource>(
        () => _i55.IncentiveDatasource());
    gh.lazySingleton<_i56.IncentiveRepository>(
        () => _i57.IncentiveRepositoryImpl(gh<_i55.IncentiveDatasource>()));
    gh.lazySingleton<_i58.IpfsDatasource>(
        () => _i58.IpfsDatasource(gh<_i29.Dio>()));
    await gh.factoryAsync<_i59.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i60.LicenseRegistryLocalDataSource>(() {
      final i = _i60.LicenseRegistryLocalDataSource(gh<_i59.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i60.LicenseVerifier>(() async =>
        _i60.LicenseVerifier(
            await getAsync<_i59.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i61.LlmAdapter>(
      () => _i62.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i61.LlmAdapter>(
      () => _i63.FlutterGemmaAdapter(wrapper: gh<_i39.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i62.LlmAdapter>(
      () => _i64.FlutterGemmaAdapter(wrapper: gh<_i39.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i65.LocalLlmService>(() => _i65.LocalLlmService());
    gh.lazySingleton<_i66.LocalModelLocalDataSource>(
        () => _i66.LocalModelLocalDataSource());
    gh.lazySingleton<_i67.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i68.MedicalKnowledgeRepository>(
      () => _i69.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i68.MedicalKnowledgeRepository>(
      () => _i70.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i71.MedicalScraperService>(
        () => _i72.MedicalScraperServiceImpl(
              gh<_i29.Dio>(),
              gh<_i16.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i73.MedicalStandardsService>(() =>
        _i74.MedicalStandardsServiceImpl(gh<_i67.MedicalContextProvider>()));
    gh.lazySingleton<_i75.MedicalWebSearchService>(
        () => _i76.MedicalWebSearchServiceImpl(gh<_i29.Dio>()));
    gh.lazySingleton<_i77.MedicationRepository>(
        () => _i78.IsarMedicationRepository(gh<_i59.Isar>()));
    gh.factory<_i79.MedicationsCubit>(
        () => _i79.MedicationsCubit(gh<_i77.MedicationRepository>()));
    gh.lazySingleton<_i80.MeditationLocalDataSource>(
        () => _i80.MeditationLocalDataSource());
    gh.lazySingleton<_i81.MeditationRepository>(() =>
        _i82.MeditationRepositoryImpl(gh<_i80.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i32.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i59.Isar>(),
        gh<_i32.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i83.MockReportGenerationService>(
      () => _i83.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i83.ModelDownloadService>(
        () => _i83.ModelDownloadService());
    gh.lazySingleton<_i84.NetworkDatasource>(
        () => _i84.NetworkDatasourceImpl());
    gh.lazySingleton<_i85.NetworkP2PApi>(() => _i85.NetworkP2PApiImpl());
    gh.lazySingleton<_i86.NetworkPeerRepository>(
        () => _i87.NetworkPeerRepositoryImpl(gh<_i58.Isar>()));
    gh.lazySingleton<_i88.NetworkRepository>(
        () => _i89.NetworkRepositoryImpl(gh<_i84.NetworkDatasource>()));
    gh.lazySingleton<_i90.NfcHandler>(
        () => _i90.NfcHandler(channel: gh<_i91.MethodChannel>()));
    gh.lazySingleton<_i92.NfcSharingService>(
        () => _i92.NfcSharingService(gh<_i90.NfcHandler>()));
    gh.lazySingleton<_i93.NodeDiscoveryService>(
        () => _i94.NodeDiscoveryService());
    gh.lazySingleton<_i95.OAuthLocalDataSource>(
        () => _i95.OAuthLocalDataSource(gh<_i40.FlutterSecureStorage>()));
    gh.lazySingleton<_i96.OAuthRepository>(() => _i97.OAuthRepositoryImpl(
          gh<_i95.OAuthLocalDataSource>(),
          gh<_i29.Dio>(),
          gh<_i38.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i98.OcrService>(() => _i98.MlKitOcrService());
    gh.lazySingleton<_i99.PromptScrubber>(
        () => _i99.PromptScrubber(gh<_i58.Isar>()));
    gh.lazySingleton<_i100.RatingRepository>(
        () => _i101.IsarRatingRepository(gh<_i58.Isar>()));
    gh.lazySingleton<_i102.RecommendScriptUseCase>(
        () => _i102.RecommendScriptUseCase(gh<_i80.MeditationRepository>()));
    gh.lazySingleton<_i103.ReportRepository>(
        () => _i104.IsarReportRepository(gh<_i58.Isar>()));
    gh.factory<_i105.RequestHealthAuthUseCase>(() =>
        _i105.RequestHealthAuthUseCase(gh<_i44.HealthDataImportService>()));
    gh.factory<_i106.SaveAppointmentUseCase>(
        () => _i106.SaveAppointmentUseCase(gh<_i7.AppointmentRepository>()));
    gh.factory<_i107.SaveMedicationUseCase>(
        () => _i107.SaveMedicationUseCase(gh<_i76.MedicationRepository>()));
    gh.factory<_i108.SaveReportUseCase>(
        () => _i108.SaveReportUseCase(gh<_i103.ReportRepository>()));
    gh.lazySingleton<_i109.SecondOpinionRepository>(
        () => _i110.IsarSecondOpinionRepository(gh<_i58.Isar>()));
    gh.factory<_i111.SendChatMessageUseCase>(() => _i111.SendChatMessageUseCase(
          gh<_i61.LlmAdapter>(),
          gh<_i67.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i112.SensorHealthDataSource>(
        () => _i112.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i113.SettingsLocalDataSource>(
        () => _i113.SettingsLocalDataSource(gh<_i58.Isar>()));
    gh.lazySingleton<_i114.SettingsRepository>(() =>
        _i115.SettingsRepositoryImpl(gh<_i113.SettingsLocalDataSource>()));
    gh.lazySingleton<_i116.SharingRepository>(() =>
        _i117.HealthSharingRepositoryImpl(
            gh<_i45.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i118.StartSessionUseCase>(
        () => _i118.StartSessionUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i119.SyncEmailAppointmentsUseCase>(
        () => _i119.SyncEmailAppointmentsUseCase(gh<_i30.EmailRepository>()));
    gh.lazySingleton<_i120.SyncRepository>(() => _i121.SyncRepositoryImpl(
          gh<_i35.FhirClient>(),
          gh<_i59.Isar>(),
          gh<_i40.FlutterSecureStorage>(),
          gh<_i93.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i66.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i122.UserProfileLocalDataSource>(
        () => _i122.UserProfileLocalDataSource(gh<_i58.Isar>()));
    gh.lazySingleton<_i123.UserProfileRepository>(
        () => _i124.UserProfileRepositoryImpl(gh<_i58.Isar>()));
    gh.lazySingleton<_i125.UserProfileService>(
        () => _i125.UserProfileService(gh<_i123.UserProfileRepository>()));
    gh.lazySingleton<_i126.VectorStoreService>(
        () => _i127.IsarVectorStoreService(
              gh<_i32.MemoryGraph>(),
              gh<_i68.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i128.VitalSignRepository>(
        () => _i129.VitalSignRepositoryImpl(gh<_i58.Isar>()));
    gh.factory<_i130.VitalsCubit>(
        () => _i130.VitalsCubit(gh<_i128.VitalSignRepository>()));
    gh.lazySingleton<_i131.VoiceChatRepository>(
        () => _i132.VoiceChatRepositoryImpl(gh<_i23.ChatAiDatasource>()));
    gh.lazySingleton<_i133.VouchRepository>(
        () => _i134.IsarVouchRepository(gh<_i58.Isar>()));
    gh.lazySingleton<_i34.WalletService>(() => databaseModule.walletService(
          gh<_i59.Isar>(),
          gh<_i34.EncryptionService>(),
        ));
    gh.lazySingleton<_i135.WifiDirectService>(() => _i135.WifiDirectService());
    gh.factory<_i136.AboutCubit>(
        () => _i136.AboutCubit(gh<_i51.IAboutRepository>()));
    gh.lazySingleton<_i137.AboutRemoteDataSource>(
        () => _i137.AboutRemoteDataSource(gh<_i29.Dio>()));
    gh.lazySingleton<_i138.AllergyLocalDataSource>(
        () => _i138.AllergyLocalDataSource(gh<_i58.Isar>()));
    gh.lazySingleton<_i139.AllergyRepository>(
        () => _i140.AllergyRepositoryImpl(gh<_i138.AllergyLocalDataSource>()));
    gh.lazySingleton<_i141.AuthLocalDataSource>(
        () => _i141.AuthLocalDataSource(gh<_i58.Isar>()));
    gh.lazySingleton<_i142.AuthRepository>(
        () => _i143.AuthRepositoryImpl(gh<_i141.AuthLocalDataSource>()));
    gh.lazySingleton<_i144.AuthService>(
        () => _i144.AuthServiceImpl(gh<_i33.EncryptionService>()));
    gh.lazySingleton<_i145.BleSharingService>(
        () => _i145.BleSharingService(gh<_i15.BleWrapper>()));
    gh.lazySingleton<_i146.CancelSharingUseCase>(
        () => _i146.CancelSharingUseCase(
              gh<_i145.BleSharingService>(),
              gh<_i92.NfcSharingService>(),
              gh<_i135.WifiDirectService>(),
            ));
    gh.lazySingleton<_i147.ChatMessageLocalDataSource>(
        () => _i147.ChatMessageLocalDataSource(gh<_i58.Isar>()));
    gh.lazySingleton<_i148.CompleteSessionUseCase>(
        () => _i148.CompleteSessionUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i119.ConnectEmailProviderUseCase>(
        () => _i119.ConnectEmailProviderUseCase(gh<_i30.EmailRepository>()));
    gh.lazySingleton<_i149.ConnectNode>(
        () => _i149.ConnectNode(gh<_i88.NetworkRepository>()));
    gh.factory<_i150.ConnectProviderUseCase>(() => _i150.ConnectProviderUseCase(
          gh<_i96.OAuthRepository>(),
          gh<_i123.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i151.DashboardLocalDataSource>(
        () => _i151.DashboardLocalDataSource(gh<_i58.Isar>()));
    gh.lazySingleton<_i152.DashboardRepository>(
        () => _i153.DashboardRepositoryImpl(
              gh<_i25.DashboardRemoteDataSource>(),
              gh<_i128.VitalSignRepository>(),
              gh<_i76.MedicationRepository>(),
              gh<_i103.ReportRepository>(),
            ));
    gh.factory<_i154.DisconnectProviderUseCase>(
        () => _i154.DisconnectProviderUseCase(
              gh<_i96.OAuthRepository>(),
              gh<_i123.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i155.DistributedStorageService>(() => _i156.IpfsService(
          gh<_i57.IpfsDatasource>(),
          gh<_i37.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i157.DoctorProfileRepository>(
        () => _i158.IsarDoctorProfileRepository(gh<_i58.Isar>()));
    gh.factoryAsync<_i159.DoctorVerificationCubit>(
        () async => _i159.DoctorVerificationCubit(
              gh<_i157.DoctorProfileRepository>(),
              gh<_i100.RatingRepository>(),
              await getAsync<_i60.LicenseVerifier>(),
            ));
    gh.factory<_i160.EmailCitasBloc>(() => _i160.EmailCitasBloc(
          gh<_i119.ConnectEmailProviderUseCase>(),
          gh<_i119.SyncEmailAppointmentsUseCase>(),
          gh<_i30.EmailRepository>(),
          gh<_i7.AppointmentRepository>(),
        ));
    gh.factory<_i161.EmailCitasCubit>(() => _i161.EmailCitasCubit(
          gh<_i30.EmailRepository>(),
          gh<_i7.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i112.FileHealthDataSource>(
        () => _i112.FileHealthDataSourceImpl(
              gh<_i36.FilePickerService>(),
              gh<_i98.OcrService>(),
            ));
    gh.factory<_i162.GetAboutInfoUseCase>(
        () => _i162.GetAboutInfoUseCase(gh<_i51.IAboutRepository>()));
    gh.factory<_i163.GetAllDoctorsUseCase>(
        () => _i163.GetAllDoctorsUseCase(gh<_i157.DoctorProfileRepository>()));
    gh.factory<_i164.GetAllMedicationsUseCase>(
        () => _i164.GetAllMedicationsUseCase(gh<_i76.MedicationRepository>()));
    gh.factory<_i165.GetAllVitalSignsUseCase>(
        () => _i165.GetAllVitalSignsUseCase(gh<_i128.VitalSignRepository>()));
    gh.factory<_i166.GetAllergiesUseCase>(
        () => _i166.GetAllergiesUseCase(gh<_i139.AllergyRepository>()));
    gh.factory<_i105.GetAvailableSourcesUseCase>(() =>
        _i105.GetAvailableSourcesUseCase(gh<_i44.HealthDataImportService>()));
    gh.factory<_i167.GetChatHistoryUseCase>(
        () => _i167.GetChatHistoryUseCase(gh<_i131.VoiceChatRepository>()));
    gh.factory<_i168.GetChatHistoryUseCase>(
        () => _i168.GetChatHistoryUseCase(gh<_i126.VectorStoreService>()));
    gh.factory<_i169.GetConnectionsUseCase>(
        () => _i169.GetConnectionsUseCase(gh<_i96.OAuthRepository>()));
    gh.factory<_i170.GetCredentialsUseCase>(
        () => _i170.GetCredentialsUseCase(gh<_i142.AuthRepository>()));
    gh.factory<_i171.GetDashboardStatsUseCase>(
        () => _i171.GetDashboardStatsUseCase(gh<_i152.DashboardRepository>()));
    gh.factory<_i172.GetDoctorProfileUseCase>(() =>
        _i172.GetDoctorProfileUseCase(gh<_i157.DoctorProfileRepository>()));
    gh.lazySingleton<_i173.GetNetworkHealth>(
        () => _i173.GetNetworkHealth(gh<_i88.NetworkRepository>()));
    gh.lazySingleton<_i174.GetNodeStats>(
        () => _i174.GetNodeStats(gh<_i88.NetworkRepository>()));
    gh.lazySingleton<_i175.GetProgressUseCase>(
        () => _i175.GetProgressUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i176.GetRecentActivityUseCase>(
        () => _i176.GetRecentActivityUseCase(gh<_i152.DashboardRepository>()));
    gh.factory<_i177.GetReportsUseCase>(
        () => _i177.GetReportsUseCase(gh<_i103.ReportRepository>()));
    gh.lazySingleton<_i178.GetScriptsUseCase>(
        () => _i178.GetScriptsUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i179.GetUserProfileUseCase>(
        () => _i179.GetUserProfileUseCase(gh<_i123.UserProfileRepository>()));
    gh.lazySingleton<_i180.GovernanceIpfsDatasource>(
        () => _i180.GovernanceIpfsDatasource(gh<_i57.IpfsDatasource>()));
    gh.lazySingleton<_i181.GovernanceRepository>(() =>
        _i182.GovernanceRepositoryImpl(gh<_i180.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i183.HealthDataImportRepository>(
        () => _i184.HealthDataImportRepositoryImpl(
              gh<_i112.SensorHealthDataSource>(),
              gh<_i112.FileHealthDataSource>(),
            ));
    gh.factory<_i185.HealthImportBloc>(() => _i185.HealthImportBloc(
          gh<_i105.GetAvailableSourcesUseCase>(),
          gh<_i105.RequestHealthAuthUseCase>(),
          gh<_i44.HealthDataImportService>(),
          gh<_i128.VitalSignRepository>(),
        ));
    gh.factory<_i186.HealthImportCubit>(() => _i186.HealthImportCubit(
          gh<_i44.HealthDataImportService>(),
          gh<_i128.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i187.HealthRecordRepository>(
        () => _i188.HealthRecordRepositoryImpl(gh<_i58.Isar>()));
    gh.lazySingleton<_i189.HomeRepository>(() => _i190.HomeRepositoryImpl(
          gh<_i128.VitalSignRepository>(),
          gh<_i7.AppointmentRepository>(),
          gh<_i77.MedicationRepository>(),
          gh<_i49.HomeLocalDataSource>(),
          gh<_i51.HomeRemoteDataSource>(),
        ));
    gh.factory<_i191.ImportCalendarUseCase>(() => _i191.ImportCalendarUseCase(
          gh<_i19.CalendarImportRepository>(),
          gh<_i7.AppointmentRepository>(),
          gh<_i123.UserProfileRepository>(),
        ));
    gh.factory<_i61.LlmAdapter>(
      () => _i192.MockLlmAdapter(gh<_i99.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i61.LlmAdapter>(
      () => _i193.GeminiLlmAdapter(
        scrubber: gh<_i99.PromptScrubber>(),
        userProfileRepository: gh<_i123.UserProfileRepository>(),
        modelWrapper: gh<_i41.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i194.LlmAdapterFactory>(
        () => _i194.LlmAdapterFactory(gh<_i114.SettingsRepository>()));
    gh.lazySingleton<_i195.LlmService>(() => _i196.GemmaLlmService(
          gh<_i126.VectorStoreService>(),
          gh<_i123.UserProfileRepository>(),
          gh<_i61.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i197.LlmSettingsCubit>(() => _i197.LlmSettingsCubit(
          gh<_i114.SettingsRepository>(),
          gh<_i28.DeviceCapabilityService>(),
          gh<_i61.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i198.MedicalResearchService>(
        () => _i198.MedicalResearchService(
              gh<_i74.MedicalWebSearchService>(),
              gh<_i70.MedicalScraperService>(),
            ));
    gh.factory<_i199.MedicationBloc>(
        () => _i199.MedicationBloc(gh<_i76.MedicationRepository>()));
    gh.factory<_i200.MeditationCubit>(() => _i200.MeditationCubit(
          gh<_i102.RecommendScriptUseCase>(),
          gh<_i118.StartSessionUseCase>(),
          gh<_i148.CompleteSessionUseCase>(),
          gh<_i175.GetProgressUseCase>(),
          gh<_i11.AudioService>(),
        ));
    gh.factory<_i201.NetworkCubit>(() => _i201.NetworkCubit(
          gh<_i86.NetworkPeerRepository>(),
          gh<_i85.NetworkP2PApi>(),
        ));
    gh.factory<_i202.NetworkHealthCubit>(() => _i202.NetworkHealthCubit(
          gh<_i173.GetNetworkHealth>(),
          gh<_i149.ConnectNode>(),
          gh<_i88.NetworkRepository>(),
        ));
    gh.lazySingleton<_i203.OnboardingRepository>(() =>
        _i204.OnboardingRepositoryImpl(gh<_i123.UserProfileRepository>()));
    gh.lazySingleton<_i205.PatientContextIndexer>(
      () => _i205.PatientContextIndexer(
        gh<_i58.Isar>(),
        gh<_i126.VectorStoreService>(),
        gh<_i187.HealthRecordRepository>(),
        gh<_i76.MedicationRepository>(),
        gh<_i139.AllergyRepository>(),
        gh<_i128.VitalSignRepository>(),
        gh<_i7.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i206.ReportGenerationService>(
        () => _i207.GemmaReportGenerationService(
              gh<_i61.LlmAdapter>(instanceName: 'gemma'),
              gh<_i126.VectorStoreService>(),
              gh<_i123.UserProfileRepository>(),
              gh<_i99.PromptScrubber>(),
            ));
    gh.factory<_i208.SaveAllergyUseCase>(
        () => _i208.SaveAllergyUseCase(gh<_i139.AllergyRepository>()));
    gh.factory<_i209.SaveCredentialsUseCase>(
        () => _i209.SaveCredentialsUseCase(gh<_i142.AuthRepository>()));
    gh.factory<_i210.SaveRecordUseCase>(
        () => _i210.SaveRecordUseCase(gh<_i187.HealthRecordRepository>()));
    gh.factory<_i211.SaveUserProfileUseCase>(
        () => _i211.SaveUserProfileUseCase(gh<_i123.UserProfileRepository>()));
    gh.factory<_i212.SaveVitalSignsUseCase>(
        () => _i212.SaveVitalSignsUseCase(gh<_i128.VitalSignRepository>()));
    gh.factory<_i213.SecondOpinionCubit>(
        () => _i213.SecondOpinionCubit(gh<_i109.SecondOpinionRepository>()));
    gh.factory<_i214.SendMessageUseCase>(
        () => _i214.SendMessageUseCase(gh<_i131.VoiceChatRepository>()));
    gh.lazySingleton<_i215.SmartSearchUseCase>(
        () => _i215.SmartSearchUseCase(gh<_i126.VectorStoreService>()));
    gh.lazySingleton<_i216.StartListeningUseCase>(
        () => _i216.StartListeningUseCase(
              gh<_i145.BleSharingService>(),
              gh<_i92.NfcSharingService>(),
              gh<_i135.WifiDirectService>(),
            ));
    gh.lazySingleton<_i217.StartSharingUseCase>(() => _i217.StartSharingUseCase(
          gh<_i145.BleSharingService>(),
          gh<_i92.NfcSharingService>(),
          gh<_i135.WifiDirectService>(),
        ));
    gh.factory<_i218.SyncCubit>(() => _i218.SyncCubit(
          gh<_i66.SyncService>(),
          gh<_i126.VectorStoreService>(),
        ));
    gh.lazySingleton<_i219.SyncService>(() => _i220.SyncServiceImpl(
          gh<_i120.SyncRepository>(),
          gh<_i66.SyncService>(),
        ));
    gh.factory<_i221.UserProfileCubit>(
        () => _i221.UserProfileCubit(gh<_i123.UserProfileRepository>()));
    gh.factory<_i222.VitalSignBloc>(
        () => _i222.VitalSignBloc(gh<_i128.VitalSignRepository>()));
    gh.factory<_i223.VoiceChatCubit>(() => _i223.VoiceChatCubit(
          gh<_i214.SendMessageUseCase>(),
          gh<_i167.GetChatHistoryUseCase>(),
          gh<_i131.VoiceChatRepository>(),
          gh<_i11.AudioService>(),
        ));
    gh.factory<_i224.VouchCubit>(
        () => _i224.VouchCubit(gh<_i133.VouchRepository>()));
    gh.factory<_i225.AllergiesCubit>(
        () => _i225.AllergiesCubit(gh<_i139.AllergyRepository>()));
    gh.factory<_i226.AllergyBloc>(
        () => _i226.AllergyBloc(gh<_i139.AllergyRepository>()));
    gh.factory<_i227.AuthCubit>(() => _i227.AuthCubit(gh<_i144.AuthService>()));
    gh.factory<_i228.AuthCubit>(() => _i228.AuthCubit(
          gh<_i142.AuthRepository>(),
          gh<_i33.EncryptionService>(),
          gh<_i14.BiometricService>(),
          gh<_i198.LoginUseCase>(),
          gh<_i199.LogoutUseCase>(),
          gh<_i222.ValidateSessionUseCase>(),
          gh<_i216.SetPinUseCase>(),
        ));
    gh.lazySingleton<_i229.BadgeCalculator>(() => _i229.BadgeCalculator(
          gh<_i157.DoctorProfileRepository>(),
          gh<_i100.RatingRepository>(),
          gh<_i133.VouchRepository>(),
        ));
    gh.factory<_i230.BadgeCubit>(
        () => _i230.BadgeCubit(gh<_i229.BadgeCalculator>()));
    gh.factory<_i231.CalendarImportCubit>(() => _i231.CalendarImportCubit(
          gh<_i19.CalendarImportRepository>(),
          gh<_i191.ImportCalendarUseCase>(),
        ));
    gh.factory<_i232.CompleteOnboardingUseCase>(() =>
        _i232.CompleteOnboardingUseCase(gh<_i203.OnboardingRepository>()));
    gh.factory<_i233.DashboardCubit>(() => _i233.DashboardCubit(
          gh<_i171.GetDashboardStatsUseCase>(),
          gh<_i176.GetRecentActivityUseCase>(),
        ));
    gh.lazySingleton<_i234.DistributedCacheUsecase>(() =>
        _i234.DistributedCacheUsecase(gh<_i155.DistributedStorageService>()));
    gh.factory<_i235.EpsConnectionBloc>(() => _i235.EpsConnectionBloc(
          gh<_i169.GetConnectionsUseCase>(),
          gh<_i150.ConnectProviderUseCase>(),
          gh<_i154.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i236.EpsConnectionCubit>(() => _i236.EpsConnectionCubit(
          gh<_i169.GetConnectionsUseCase>(),
          gh<_i150.ConnectProviderUseCase>(),
          gh<_i154.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i237.FhirSyncCubit>(() => _i237.FhirSyncCubit(
          gh<_i219.SyncService>(),
          gh<_i93.NodeDiscoveryService>(),
        ));
    gh.factory<_i238.GetAllRecordsUseCase>(
        () => _i238.GetAllRecordsUseCase(gh<_i187.HealthRecordRepository>()));
    gh.factory<_i239.GetHealthSummaryUseCase>(
        () => _i239.GetHealthSummaryUseCase(gh<_i189.HomeRepository>()));
    gh.factory<_i240.GetOnboardingProfileUseCase>(() =>
        _i240.GetOnboardingProfileUseCase(gh<_i203.OnboardingRepository>()));
    gh.factory<_i241.HealthRecordCubit>(() => _i241.HealthRecordCubit(
          gh<_i187.HealthRecordRepository>(),
          gh<_i36.FilePickerService>(),
          gh<_i53.ImagePickerService>(),
          gh<_i98.OcrService>(),
          gh<_i126.VectorStoreService>(),
        ));
    gh.factory<_i242.HomeCubit>(() => _i242.HomeCubit(
          gh<_i239.GetHealthSummaryUseCase>(),
          gh<_i189.HomeRepository>(),
        ));
    gh.lazySingleton<_i195.LlmService>(
      () => _i243.RagLlmService(
        gh<_i126.VectorStoreService>(),
        gh<_i198.MedicalResearchService>(),
        gh<_i123.UserProfileRepository>(),
        gh<_i61.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i244.MedicalIndexingService>(
        () => _i244.MedicalIndexingService(
              gh<_i67.MedicalKnowledgeRepository>(),
              gh<_i126.VectorStoreService>(),
              gh<_i205.PatientContextIndexer>(),
            ));
    gh.lazySingleton<_i245.MedicalResearchRepository>(
        () => _i246.MedicalResearchRepositoryImpl(
              gh<_i198.MedicalResearchService>(),
              gh<_i58.Isar>(),
            ));
    gh.factory<_i247.OnboardingCubit>(
        () => _i247.OnboardingCubit(gh<_i203.OnboardingRepository>()));
    gh.factory<_i248.ReportBloc>(() => _i248.ReportBloc(
          gh<_i103.ReportRepository>(),
          gh<_i206.ReportGenerationService>(),
        ));
    gh.factory<_i249.SearchMedicalResearch>(() =>
        _i249.SearchMedicalResearch(gh<_i245.MedicalResearchRepository>()));
    gh.factory<_i250.SharingCubit>(() => _i250.SharingCubit(
          bleService: gh<_i145.BleSharingService>(),
          nfcService: gh<_i92.NfcSharingService>(),
          wifiService: gh<_i135.WifiDirectService>(),
          startSharingUseCase: gh<_i217.StartSharingUseCase>(),
          startListeningUseCase: gh<_i216.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i146.CancelSharingUseCase>(),
          walletService: gh<_i34.WalletService>(),
          walletEncryption: gh<_i34.EncryptionService>(),
        ));
    gh.factory<_i251.GetResearchHistory>(
        () => _i251.GetResearchHistory(gh<_i245.MedicalResearchRepository>()));
    gh.factory<_i252.MedicalResearchCubit>(() => _i252.MedicalResearchCubit(
          gh<_i249.SearchMedicalResearch>(),
          gh<_i251.GetResearchHistory>(),
          gh<_i72.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i253.ServiceModule {}

class _$NetworkModule extends _i254.NetworkModule {}

class _$MemoryModule extends _i255.MemoryModule {}

class _$DatabaseModule extends _i256.DatabaseModule {}

class _$FhirModule extends _i257.FhirModule {}
