// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i19;
import 'package:dio/dio.dart' as _i30;
import 'package:flutter/services.dart' as _i92;
import 'package:flutter_appauth/flutter_appauth.dart' as _i39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i41;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i43;
import 'package:health_wallet/health_wallet.dart' as _i35;
import 'package:http/http.dart' as _i25;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i60;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i33;
import 'package:just_audio/just_audio.dart' as _i13;
import 'package:medical_standards/medical_standards.dart' as _i68;
import 'package:shared_preferences/shared_preferences.dart' as _i51;

import '../../features/about/application/about_cubit.dart' as _i139;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i53;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i164;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i140;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i54;
import '../../features/allergies/application/allergies_cubit.dart' as _i227;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i228;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i141;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i143;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i142;
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/domain/usecases/get_allergies_usecase.dart'
    as _i167;
import '../../features/allergies/domain/usecases/save_allergy_usecase.dart'
    as _i207;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i10;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i7;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i8;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i9;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i27;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i44;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i109;
import '../../features/auth/application/auth_cubit.dart' as _i229;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i230;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i144;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i146;
import '../../features/auth/domain/auth_service.dart' as _i147;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i145;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i171;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i193;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i194;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i208;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i215;
import '../../features/auth/domain/usecases/validate_session_usecase.dart'
    as _i223;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i15;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i34;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i233;
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i20;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i22;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i186;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i18;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i21;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i23;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i262;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i235;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i245;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i247;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
    as _i154;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i26;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i236;
import '../../features/data_sources/application/data_source_cubit.dart'
    as _i263;
import '../../features/data_sources/domain/repositories/data_source_repository.dart'
    as _i237;
import '../../features/data_sources/infrastructure/datasources/file_import_datasource.dart'
    as _i163;
import '../../features/data_sources/infrastructure/datasources/health_connect_datasource.dart'
    as _i45;
import '../../features/data_sources/infrastructure/datasources/sensor_api_datasource.dart'
    as _i114;
import '../../features/data_sources/infrastructure/repositories/data_source_repository_impl.dart'
    as _i238;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i232;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i160;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i213;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i226;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i158;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i103;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i111;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i136;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i231;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i62;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
    as _i165;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i172;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i61;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i159;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i104;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i112;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i137;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i161;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i162;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i31;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i122;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i32;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i240;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i241;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i97;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i153;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i155;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i170;
import '../../features/eps_connection/infrastructure/datasources/oauth_local_datasource.dart'
    as _i96;
import '../../features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart'
    as _i98;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i248;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i249;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i182;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i46;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i108;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i115;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i183;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i250;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i184;
import '../../features/health_record/domain/usecases/get_all_records_usecase.dart'
    as _i244;
import '../../features/health_record/domain/usecases/save_record_usecase.dart'
    as _i210;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i185;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i37;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i55;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i99;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i261;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i119;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i149;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i217;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i218;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i148;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i16;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i47;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart'
    as _i48;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i91;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i93;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i120;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i138;
import '../../features/home/application/home_cubit.dart' as _i266;
import '../../features/home/domain/repositories/home_repository.dart' as _i251;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i264;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i49;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i50;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i52;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i252;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i216;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i150;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i67;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i69;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i63;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i129;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i168;
import '../../features/local_agent/domain/usecases/send_chat_message_usecase.dart'
    as _i113;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i64;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i40;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i187;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i42;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i188;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i65;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i191;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i190;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i253;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i70;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i71;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i130;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i189;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i66;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i254;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i84;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i204;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i267;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i255;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i72;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i74;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i76;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i265;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i260;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i17;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i195;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i73;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i75;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i77;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i256;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i257;
import '../../features/medications/application/medications_cubit.dart' as _i198;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i78;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i196;
import '../../features/medications/domain/usecases/get_all_medications_usecase.dart'
    as _i243;
import '../../features/medications/domain/usecases/save_medication_usecase.dart'
    as _i209;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i197;
import '../../features/medications/infrastructure/repositories/sqlite_medication_adherence_repository.dart'
    as _i79;
import '../../features/medications/infrastructure/services/pharmacy_api_service.dart'
    as _i100;
import '../../features/medications/infrastructure/services/rxnorm_api_service.dart'
    as _i101;
import '../../features/meditation/application/meditation_cubit.dart' as _i199;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i81;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i151;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i175;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i177;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i105;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i121;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i80;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i82;
import '../../features/network/application/network_cubit.dart' as _i200;
import '../../features/network/domain/repositories/network_peer_repository.dart'
    as _i87;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i180;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i179;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i181;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i57;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i56;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i58;
import '../../features/network/infrastructure/datasources/network_p2p_api.dart'
    as _i86;
import '../../features/network/infrastructure/repositories/network_peer_repository_impl.dart'
    as _i88;
import '../../features/network/network_health/application/network_health_cubit.dart'
    as _i201;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i89;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i152;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i173;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i174;
import '../../features/network/network_health/infrastructure/datasources/network_datasource.dart'
    as _i85;
import '../../features/network/network_health/infrastructure/repositories/network_repository_impl.dart'
    as _i90;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i258;
import '../../features/onboarding/application/sync_cubit.dart' as _i219;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i202;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i234;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i246;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i203;
import '../../features/reports/application/bloc/report_bloc.dart' as _i259;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i106;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i205;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i176;
import '../../features/reports/domain/usecases/save_report_usecase.dart'
    as _i110;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i107;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i206;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i83;
import '../../features/settings/application/llm_settings_cubit.dart' as _i192;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i117;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i28;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i116;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i118;
import '../../features/sync/application/sync_cubit.dart' as _i242;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i123;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i156;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i94;
import '../../features/sync/domain/services/sync_service.dart' as _i220;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i239;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i38;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i59;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i124;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i36;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i157;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i95;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i221;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i222;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i125;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i126;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i128;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i178;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
    as _i211;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i127;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i224;
import '../../features/vitals/application/vitals_cubit.dart' as _i133;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i131;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i166;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
    as _i212;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i132;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i225;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i134;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i169;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i214;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i24;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i135;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i11;
import '../services/audio/audio_player_service.dart' as _i12;
import '../services/audio/audio_recorder_service.dart' as _i14;
import '../services/device_capability_service.dart' as _i29;
import '../services/privacy_anonymizer.dart' as _i102;
import 'database_module.dart' as _i271;
import 'fhir_module.dart' as _i272;
import 'memory_module.dart' as _i270;
import 'network_module.dart' as _i269;
import 'service_module.dart' as _i268;

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
    gh.lazySingleton<_i34.EncryptionService>(() => _i34.EncryptionService());
    gh.lazySingleton<_i35.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i36.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i37.FilePickerService>(
        () => _i37.FilePickerServiceImpl());
    gh.lazySingleton<_i38.FilecoinDatasource>(() => _i38.FilecoinDatasource());
    gh.lazySingleton<_i39.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i40.FlutterGemmaWrapper>(
        () => _i40.FlutterGemmaWrapper());
    gh.lazySingleton<_i41.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i42.GeminiModelWrapper>(
        () => _i42.GeminiModelWrapper(gh<_i43.GenerativeModel>()));
    gh.factory<_i44.GetAllAppointmentsUseCase>(
        () => _i44.GetAllAppointmentsUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i45.HealthConnectDataSource>(
        () => _i45.HealthConnectDataSourceImpl());
    gh.lazySingleton<_i46.HealthDataImportService>(
        () => _i46.HealthDataImportService());
    gh.lazySingleton<_i47.HealthSharingLocalDataSource>(
        () => _i47.HealthSharingLocalDataSource());
    gh.lazySingleton<_i48.HealthSharingRemoteDataSource>(
        () => _i48.HealthSharingRemoteDataSource());
    gh.factory<_i49.HealthSummaryDatasource>(
        () => _i49.HealthSummaryDatasource());
    gh.factory<_i50.HomeLocalDataSource>(
        () => _i50.HomeLocalDataSource(gh<_i51.SharedPreferences>()));
    gh.factory<_i52.HomeRemoteDataSource>(() => _i52.HomeRemoteDataSource());
    gh.lazySingleton<_i53.IAboutRepository>(
        () => _i54.AboutRepositoryImpl(gh<_i4.AboutLocalDataSource>()));
    gh.lazySingleton<_i55.ImagePickerService>(
        () => _i55.ImagePickerServiceImpl());
    gh.lazySingleton<_i56.IncentiveDatasource>(
        () => _i56.IncentiveDatasource());
    gh.lazySingleton<_i57.IncentiveRepository>(
        () => _i58.IncentiveRepositoryImpl(gh<_i56.IncentiveDatasource>()));
    gh.lazySingleton<_i59.IpfsDatasource>(
        () => _i59.IpfsDatasource(gh<_i30.Dio>()));
    await gh.factoryAsync<_i60.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i61.LicenseRegistryLocalDataSource>(() {
      final i = _i61.LicenseRegistryLocalDataSource(gh<_i60.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i62.LicenseVerifier>(() async =>
        _i62.LicenseVerifier(
            await getAsync<_i61.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i63.LlmAdapter>(
      () => _i64.FlutterGemmaAdapter(wrapper: gh<_i40.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i63.LlmAdapter>(
      () => _i65.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i66.LocalLlmService>(() => _i66.LocalLlmService());
    gh.lazySingleton<_i67.LocalModelLocalDataSource>(
        () => _i67.LocalModelLocalDataSource());
    gh.lazySingleton<_i68.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i69.MedicalKnowledgeRepository>(
      () => _i70.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i69.MedicalKnowledgeRepository>(
      () => _i71.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i72.MedicalScraperService>(
        () => _i73.MedicalScraperServiceImpl(
              gh<_i30.Dio>(),
              gh<_i17.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i74.MedicalStandardsService>(() =>
        _i75.MedicalStandardsServiceImpl(gh<_i68.MedicalContextProvider>()));
    gh.lazySingleton<_i76.MedicalWebSearchService>(
        () => _i77.MedicalWebSearchServiceImpl(gh<_i30.Dio>()));
    gh.lazySingleton<_i78.MedicationAdherenceRepository>(() =>
        _i79.SqliteMedicationAdherenceRepository(
            gh<_i5.AdherenceSqliteDatasource>()));
    gh.lazySingleton<_i80.MeditationLocalDataSource>(
        () => _i80.MeditationLocalDataSource());
    gh.lazySingleton<_i81.MeditationRepository>(() =>
        _i82.MeditationRepositoryImpl(gh<_i80.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i33.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i60.Isar>(),
        gh<_i33.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i83.MockReportGenerationService>(
      () => _i83.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i84.ModelDownloadService>(
        () => _i84.ModelDownloadService());
    gh.lazySingleton<_i85.NetworkDatasource>(
        () => _i85.NetworkDatasourceImpl());
    gh.lazySingleton<_i86.NetworkP2PApi>(() => _i86.NetworkP2PApiImpl());
    gh.lazySingleton<_i87.NetworkPeerRepository>(
        () => _i88.NetworkPeerRepositoryImpl(gh<_i60.Isar>()));
    gh.lazySingleton<_i89.NetworkRepository>(
        () => _i90.NetworkRepositoryImpl(gh<_i85.NetworkDatasource>()));
    gh.lazySingleton<_i91.NfcHandler>(
        () => _i91.NfcHandler(channel: gh<_i92.MethodChannel>()));
    gh.lazySingleton<_i93.NfcSharingService>(
        () => _i93.NfcSharingService(gh<_i91.NfcHandler>()));
    gh.lazySingleton<_i94.NodeDiscoveryService>(
        () => _i95.NodeDiscoveryService());
    gh.lazySingleton<_i96.OAuthLocalDataSource>(
        () => _i96.OAuthLocalDataSource(gh<_i41.FlutterSecureStorage>()));
    gh.lazySingleton<_i97.OAuthRepository>(() => _i98.OAuthRepositoryImpl(
          gh<_i96.OAuthLocalDataSource>(),
          gh<_i30.Dio>(),
          gh<_i39.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i99.OcrService>(() => _i99.MlKitOcrService());
    gh.lazySingleton<_i100.PharmacyApiService>(
        () => _i101.RxNormApiService(gh<_i30.Dio>()));
    gh.lazySingleton<_i102.PromptScrubber>(
        () => _i102.PromptScrubber(gh<_i60.Isar>()));
    gh.lazySingleton<_i103.RatingRepository>(
        () => _i104.IsarRatingRepository(gh<_i60.Isar>()));
    gh.lazySingleton<_i105.RecommendScriptUseCase>(
        () => _i105.RecommendScriptUseCase(gh<_i81.MeditationRepository>()));
    gh.lazySingleton<_i106.ReportRepository>(
        () => _i107.IsarReportRepository(gh<_i60.Isar>()));
    gh.factory<_i108.RequestHealthAuthUseCase>(() =>
        _i108.RequestHealthAuthUseCase(gh<_i46.HealthDataImportService>()));
    gh.factory<_i109.SaveAppointmentUseCase>(
        () => _i109.SaveAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.factory<_i110.SaveReportUseCase>(
        () => _i110.SaveReportUseCase(gh<_i106.ReportRepository>()));
    gh.lazySingleton<_i111.SecondOpinionRepository>(
        () => _i112.IsarSecondOpinionRepository(gh<_i60.Isar>()));
    gh.factory<_i113.SendChatMessageUseCase>(() => _i113.SendChatMessageUseCase(
          gh<_i63.LlmAdapter>(),
          gh<_i69.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i114.SensorApiDataSource>(
        () => _i114.SensorApiDataSourceImpl());
    gh.lazySingleton<_i115.SensorHealthDataSource>(
        () => _i115.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i116.SettingsLocalDataSource>(
        () => _i116.SettingsLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i117.SettingsRepository>(() =>
        _i118.SettingsRepositoryImpl(gh<_i116.SettingsLocalDataSource>()));
    gh.lazySingleton<_i119.SharingRepository>(() =>
        _i120.HealthSharingRepositoryImpl(
            gh<_i47.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i121.StartSessionUseCase>(
        () => _i121.StartSessionUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i122.SyncEmailAppointmentsUseCase>(
        () => _i122.SyncEmailAppointmentsUseCase(gh<_i31.EmailRepository>()));
    gh.lazySingleton<_i123.SyncRepository>(() => _i124.SyncRepositoryImpl(
          gh<_i36.FhirClient>(),
          gh<_i60.Isar>(),
          gh<_i41.FlutterSecureStorage>(),
          gh<_i94.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i68.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i125.UserProfileLocalDataSource>(
        () => _i125.UserProfileLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i126.UserProfileRepository>(
        () => _i127.UserProfileRepositoryImpl(gh<_i60.Isar>()));
    gh.lazySingleton<_i128.UserProfileService>(
        () => _i128.UserProfileService(gh<_i126.UserProfileRepository>()));
    gh.lazySingleton<_i129.VectorStoreService>(
        () => _i130.IsarVectorStoreService(
              gh<_i33.MemoryGraph>(),
              gh<_i69.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i131.VitalSignRepository>(
        () => _i132.VitalSignRepositoryImpl(gh<_i60.Isar>()));
    gh.factory<_i133.VitalsCubit>(
        () => _i133.VitalsCubit(gh<_i131.VitalSignRepository>()));
    gh.lazySingleton<_i134.VoiceChatRepository>(
        () => _i135.VoiceChatRepositoryImpl(gh<_i24.ChatAiDatasource>()));
    gh.lazySingleton<_i136.VouchRepository>(
        () => _i137.IsarVouchRepository(gh<_i60.Isar>()));
    gh.lazySingleton<_i35.WalletService>(() => databaseModule.walletService(
          gh<_i60.Isar>(),
          gh<_i35.EncryptionService>(),
        ));
    gh.lazySingleton<_i138.WifiDirectService>(() => _i138.WifiDirectService());
    gh.factory<_i139.AboutCubit>(
        () => _i139.AboutCubit(gh<_i53.IAboutRepository>()));
    gh.lazySingleton<_i140.AboutRemoteDataSource>(
        () => _i140.AboutRemoteDataSource(gh<_i30.Dio>()));
    gh.lazySingleton<_i141.AllergyLocalDataSource>(
        () => _i141.AllergyLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i142.AllergyRepository>(
        () => _i143.AllergyRepositoryImpl(gh<_i141.AllergyLocalDataSource>()));
    gh.lazySingleton<_i144.AuthLocalDataSource>(
        () => _i144.AuthLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i145.AuthRepository>(
        () => _i146.AuthRepositoryImpl(gh<_i144.AuthLocalDataSource>()));
    gh.lazySingleton<_i147.AuthService>(
        () => _i147.AuthServiceImpl(gh<_i34.EncryptionService>()));
    gh.lazySingleton<_i148.BleSharingService>(
        () => _i148.BleSharingService(gh<_i16.BleWrapper>()));
    gh.lazySingleton<_i149.CancelSharingUseCase>(
        () => _i149.CancelSharingUseCase(
              gh<_i148.BleSharingService>(),
              gh<_i93.NfcSharingService>(),
              gh<_i138.WifiDirectService>(),
            ));
    gh.lazySingleton<_i150.ChatMessageLocalDataSource>(
        () => _i150.ChatMessageLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i151.CompleteSessionUseCase>(
        () => _i151.CompleteSessionUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i122.ConnectEmailProviderUseCase>(
        () => _i122.ConnectEmailProviderUseCase(gh<_i31.EmailRepository>()));
    gh.lazySingleton<_i152.ConnectNode>(
        () => _i152.ConnectNode(gh<_i89.NetworkRepository>()));
    gh.factory<_i153.ConnectProviderUseCase>(() => _i153.ConnectProviderUseCase(
          gh<_i97.OAuthRepository>(),
          gh<_i126.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i154.DashboardLocalDataSource>(
        () => _i154.DashboardLocalDataSource(gh<_i60.Isar>()));
    gh.factory<_i155.DisconnectProviderUseCase>(
        () => _i155.DisconnectProviderUseCase(
              gh<_i97.OAuthRepository>(),
              gh<_i126.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i156.DistributedStorageService>(() => _i157.IpfsService(
          gh<_i59.IpfsDatasource>(),
          gh<_i38.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i158.DoctorProfileRepository>(
        () => _i159.IsarDoctorProfileRepository(gh<_i60.Isar>()));
    gh.factoryAsync<_i160.DoctorVerificationCubit>(
        () async => _i160.DoctorVerificationCubit(
              gh<_i158.DoctorProfileRepository>(),
              gh<_i103.RatingRepository>(),
              await getAsync<_i62.LicenseVerifier>(),
            ));
    gh.factory<_i161.EmailCitasBloc>(() => _i161.EmailCitasBloc(
          gh<_i122.ConnectEmailProviderUseCase>(),
          gh<_i122.SyncEmailAppointmentsUseCase>(),
          gh<_i31.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.factory<_i162.EmailCitasCubit>(() => _i162.EmailCitasCubit(
          gh<_i31.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i115.FileHealthDataSource>(
        () => _i115.FileHealthDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i99.OcrService>(),
            ));
    gh.lazySingleton<_i163.FileImportDataSource>(
        () => _i163.FileImportDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i99.OcrService>(),
            ));
    gh.factory<_i164.GetAboutInfoUseCase>(
        () => _i164.GetAboutInfoUseCase(gh<_i53.IAboutRepository>()));
    gh.factory<_i165.GetAllDoctorsUseCase>(
        () => _i165.GetAllDoctorsUseCase(gh<_i158.DoctorProfileRepository>()));
    gh.factory<_i166.GetAllVitalSignsUseCase>(
        () => _i166.GetAllVitalSignsUseCase(gh<_i131.VitalSignRepository>()));
    gh.factory<_i167.GetAllergiesUseCase>(
        () => _i167.GetAllergiesUseCase(gh<_i142.AllergyRepository>()));
    gh.factory<_i108.GetAvailableSourcesUseCase>(() =>
        _i108.GetAvailableSourcesUseCase(gh<_i46.HealthDataImportService>()));
    gh.factory<_i168.GetChatHistoryUseCase>(
        () => _i168.GetChatHistoryUseCase(gh<_i129.VectorStoreService>()));
    gh.factory<_i169.GetChatHistoryUseCase>(
        () => _i169.GetChatHistoryUseCase(gh<_i134.VoiceChatRepository>()));
    gh.factory<_i170.GetConnectionsUseCase>(
        () => _i170.GetConnectionsUseCase(gh<_i97.OAuthRepository>()));
    gh.factory<_i171.GetCredentialsUseCase>(
        () => _i171.GetCredentialsUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i172.GetDoctorProfileUseCase>(() =>
        _i172.GetDoctorProfileUseCase(gh<_i158.DoctorProfileRepository>()));
    gh.lazySingleton<_i173.GetNetworkHealth>(
        () => _i173.GetNetworkHealth(gh<_i89.NetworkRepository>()));
    gh.lazySingleton<_i174.GetNodeStats>(
        () => _i174.GetNodeStats(gh<_i89.NetworkRepository>()));
    gh.lazySingleton<_i175.GetProgressUseCase>(
        () => _i175.GetProgressUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i176.GetReportsUseCase>(
        () => _i176.GetReportsUseCase(gh<_i106.ReportRepository>()));
    gh.lazySingleton<_i177.GetScriptsUseCase>(
        () => _i177.GetScriptsUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i178.GetUserProfileUseCase>(
        () => _i178.GetUserProfileUseCase(gh<_i126.UserProfileRepository>()));
    gh.lazySingleton<_i179.GovernanceIpfsDatasource>(
        () => _i179.GovernanceIpfsDatasource(gh<_i59.IpfsDatasource>()));
    gh.lazySingleton<_i180.GovernanceRepository>(() =>
        _i181.GovernanceRepositoryImpl(gh<_i179.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i182.HealthDataImportRepository>(
        () => _i183.HealthDataImportRepositoryImpl(
              gh<_i115.SensorHealthDataSource>(),
              gh<_i115.FileHealthDataSource>(),
            ));
    gh.lazySingleton<_i184.HealthRecordRepository>(
        () => _i185.HealthRecordRepositoryImpl(gh<_i60.Isar>()));
    gh.factory<_i186.ImportCalendarUseCase>(() => _i186.ImportCalendarUseCase(
          gh<_i20.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i126.UserProfileRepository>(),
        ));
    gh.factory<_i108.ImportHealthDataUseCase>(
        () => _i108.ImportHealthDataUseCase(
              gh<_i46.HealthDataImportService>(),
              gh<_i131.VitalSignRepository>(),
            ));
    gh.lazySingleton<_i63.LlmAdapter>(
      () => _i187.GeminiLlmAdapter(
        scrubber: gh<_i102.PromptScrubber>(),
        userProfileRepository: gh<_i126.UserProfileRepository>(),
        modelWrapper: gh<_i42.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i63.LlmAdapter>(
      () => _i188.MockLlmAdapter(gh<_i102.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i189.LlmAdapterFactory>(
        () => _i189.LlmAdapterFactory(gh<_i117.SettingsRepository>()));
    gh.lazySingleton<_i190.LlmService>(() => _i191.GemmaLlmService(
          gh<_i129.VectorStoreService>(),
          gh<_i126.UserProfileRepository>(),
          gh<_i63.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i192.LlmSettingsCubit>(() => _i192.LlmSettingsCubit(
          gh<_i117.SettingsRepository>(),
          gh<_i28.DeviceCapabilityService>(),
          gh<_i63.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i193.LoginUseCase>(() => _i193.LoginUseCase(
          gh<_i145.AuthRepository>(),
          gh<_i34.EncryptionService>(),
          gh<_i15.BiometricService>(),
        ));
    gh.factory<_i194.LogoutUseCase>(
        () => _i194.LogoutUseCase(gh<_i145.AuthRepository>()));
    gh.lazySingleton<_i195.MedicalResearchService>(
        () => _i195.MedicalResearchService(
              gh<_i76.MedicalWebSearchService>(),
              gh<_i72.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i196.MedicationRepository>(
        () => _i197.IsarMedicationRepository(
              gh<_i60.Isar>(),
              gh<_i100.PharmacyApiService>(),
            ));
    gh.factory<_i198.MedicationsCubit>(
        () => _i198.MedicationsCubit(gh<_i196.MedicationRepository>()));
    gh.factory<_i199.MeditationCubit>(() => _i199.MeditationCubit(
          gh<_i105.RecommendScriptUseCase>(),
          gh<_i121.StartSessionUseCase>(),
          gh<_i151.CompleteSessionUseCase>(),
          gh<_i175.GetProgressUseCase>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i200.NetworkCubit>(() => _i200.NetworkCubit(
          gh<_i87.NetworkPeerRepository>(),
          gh<_i86.NetworkP2PApi>(),
        ));
    gh.factory<_i201.NetworkHealthCubit>(() => _i201.NetworkHealthCubit(
          gh<_i173.GetNetworkHealth>(),
          gh<_i152.ConnectNode>(),
          gh<_i89.NetworkRepository>(),
        ));
    gh.lazySingleton<_i202.OnboardingRepository>(() =>
        _i203.OnboardingRepositoryImpl(gh<_i126.UserProfileRepository>()));
    gh.lazySingleton<_i204.PatientContextIndexer>(
      () => _i204.PatientContextIndexer(
        gh<_i60.Isar>(),
        gh<_i129.VectorStoreService>(),
        gh<_i184.HealthRecordRepository>(),
        gh<_i196.MedicationRepository>(),
        gh<_i142.AllergyRepository>(),
        gh<_i131.VitalSignRepository>(),
        gh<_i8.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i205.ReportGenerationService>(
        () => _i206.GemmaReportGenerationService(
              gh<_i63.LlmAdapter>(instanceName: 'gemma'),
              gh<_i129.VectorStoreService>(),
              gh<_i126.UserProfileRepository>(),
              gh<_i102.PromptScrubber>(),
            ));
    gh.factory<_i207.SaveAllergyUseCase>(
        () => _i207.SaveAllergyUseCase(gh<_i142.AllergyRepository>()));
    gh.factory<_i208.SaveCredentialsUseCase>(
        () => _i208.SaveCredentialsUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i209.SaveMedicationUseCase>(
        () => _i209.SaveMedicationUseCase(gh<_i196.MedicationRepository>()));
    gh.factory<_i210.SaveRecordUseCase>(
        () => _i210.SaveRecordUseCase(gh<_i184.HealthRecordRepository>()));
    gh.factory<_i211.SaveUserProfileUseCase>(
        () => _i211.SaveUserProfileUseCase(gh<_i126.UserProfileRepository>()));
    gh.factory<_i212.SaveVitalSignsUseCase>(
        () => _i212.SaveVitalSignsUseCase(gh<_i131.VitalSignRepository>()));
    gh.factory<_i213.SecondOpinionCubit>(
        () => _i213.SecondOpinionCubit(gh<_i111.SecondOpinionRepository>()));
    gh.factory<_i214.SendMessageUseCase>(
        () => _i214.SendMessageUseCase(gh<_i134.VoiceChatRepository>()));
    gh.factory<_i215.SetPinUseCase>(() => _i215.SetPinUseCase(
          gh<_i145.AuthRepository>(),
          gh<_i34.EncryptionService>(),
        ));
    gh.lazySingleton<_i216.SmartSearchUseCase>(
        () => _i216.SmartSearchUseCase(gh<_i129.VectorStoreService>()));
    gh.lazySingleton<_i217.StartListeningUseCase>(
        () => _i217.StartListeningUseCase(
              gh<_i148.BleSharingService>(),
              gh<_i93.NfcSharingService>(),
              gh<_i138.WifiDirectService>(),
            ));
    gh.lazySingleton<_i218.StartSharingUseCase>(() => _i218.StartSharingUseCase(
          gh<_i148.BleSharingService>(),
          gh<_i93.NfcSharingService>(),
          gh<_i138.WifiDirectService>(),
        ));
    gh.factory<_i219.SyncCubit>(() => _i219.SyncCubit(
          gh<_i68.SyncService>(),
          gh<_i129.VectorStoreService>(),
        ));
    gh.lazySingleton<_i220.SyncService>(() => _i221.SyncServiceImpl(
          gh<_i123.SyncRepository>(),
          gh<_i68.SyncService>(),
        ));
    gh.factory<_i222.UserProfileCubit>(
        () => _i222.UserProfileCubit(gh<_i126.UserProfileRepository>()));
    gh.factory<_i223.ValidateSessionUseCase>(
        () => _i223.ValidateSessionUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i224.VitalSignBloc>(
        () => _i224.VitalSignBloc(gh<_i131.VitalSignRepository>()));
    gh.factory<_i225.VoiceChatCubit>(() => _i225.VoiceChatCubit(
          gh<_i214.SendMessageUseCase>(),
          gh<_i169.GetChatHistoryUseCase>(),
          gh<_i134.VoiceChatRepository>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i226.VouchCubit>(
        () => _i226.VouchCubit(gh<_i136.VouchRepository>()));
    gh.factory<_i227.AllergiesCubit>(
        () => _i227.AllergiesCubit(gh<_i142.AllergyRepository>()));
    gh.factory<_i228.AllergyBloc>(
        () => _i228.AllergyBloc(gh<_i142.AllergyRepository>()));
    gh.factory<_i229.AuthCubit>(() => _i229.AuthCubit(gh<_i147.AuthService>()));
    gh.factory<_i230.AuthCubit>(() => _i230.AuthCubit(
          gh<_i145.AuthRepository>(),
          gh<_i15.BiometricService>(),
          gh<_i193.LoginUseCase>(),
          gh<_i194.LogoutUseCase>(),
          gh<_i223.ValidateSessionUseCase>(),
          gh<_i215.SetPinUseCase>(),
        ));
    gh.lazySingleton<_i231.BadgeCalculator>(() => _i231.BadgeCalculator(
          gh<_i158.DoctorProfileRepository>(),
          gh<_i103.RatingRepository>(),
          gh<_i136.VouchRepository>(),
        ));
    gh.factory<_i232.BadgeCubit>(
        () => _i232.BadgeCubit(gh<_i231.BadgeCalculator>()));
    gh.factory<_i233.CalendarImportCubit>(() => _i233.CalendarImportCubit(
          gh<_i20.CalendarImportRepository>(),
          gh<_i186.ImportCalendarUseCase>(),
        ));
    gh.factory<_i234.CompleteOnboardingUseCase>(() =>
        _i234.CompleteOnboardingUseCase(gh<_i202.OnboardingRepository>()));
    gh.lazySingleton<_i235.DashboardRepository>(
        () => _i236.DashboardRepositoryImpl(
              gh<_i26.DashboardRemoteDataSource>(),
              gh<_i131.VitalSignRepository>(),
              gh<_i196.MedicationRepository>(),
              gh<_i106.ReportRepository>(),
            ));
    gh.lazySingleton<_i237.DataSourceRepository>(
        () => _i238.DataSourceRepositoryImpl(
              gh<_i114.SensorApiDataSource>(),
              gh<_i163.FileImportDataSource>(),
              gh<_i45.HealthConnectDataSource>(),
            ));
    gh.lazySingleton<_i239.DistributedCacheUsecase>(() =>
        _i239.DistributedCacheUsecase(gh<_i156.DistributedStorageService>()));
    gh.factory<_i240.EpsConnectionBloc>(() => _i240.EpsConnectionBloc(
          gh<_i170.GetConnectionsUseCase>(),
          gh<_i153.ConnectProviderUseCase>(),
          gh<_i155.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i241.EpsConnectionCubit>(() => _i241.EpsConnectionCubit(
          gh<_i170.GetConnectionsUseCase>(),
          gh<_i153.ConnectProviderUseCase>(),
          gh<_i155.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i242.FhirSyncCubit>(() => _i242.FhirSyncCubit(
          gh<_i220.SyncService>(),
          gh<_i94.NodeDiscoveryService>(),
        ));
    gh.factory<_i243.GetAllMedicationsUseCase>(
        () => _i243.GetAllMedicationsUseCase(gh<_i196.MedicationRepository>()));
    gh.factory<_i244.GetAllRecordsUseCase>(
        () => _i244.GetAllRecordsUseCase(gh<_i184.HealthRecordRepository>()));
    gh.factory<_i245.GetDashboardStatsUseCase>(
        () => _i245.GetDashboardStatsUseCase(gh<_i235.DashboardRepository>()));
    gh.factory<_i246.GetOnboardingProfileUseCase>(() =>
        _i246.GetOnboardingProfileUseCase(gh<_i202.OnboardingRepository>()));
    gh.factory<_i247.GetRecentActivityUseCase>(
        () => _i247.GetRecentActivityUseCase(gh<_i235.DashboardRepository>()));
    gh.factory<_i248.HealthImportBloc>(() => _i248.HealthImportBloc(
          gh<_i108.GetAvailableSourcesUseCase>(),
          gh<_i108.RequestHealthAuthUseCase>(),
          gh<_i108.ImportHealthDataUseCase>(),
        ));
    gh.factory<_i249.HealthImportCubit>(() => _i249.HealthImportCubit(
          gh<_i108.GetAvailableSourcesUseCase>(),
          gh<_i108.RequestHealthAuthUseCase>(),
          gh<_i108.ImportHealthDataUseCase>(),
        ));
    gh.factory<_i250.HealthRecordCubit>(() => _i250.HealthRecordCubit(
          gh<_i184.HealthRecordRepository>(),
          gh<_i37.FilePickerService>(),
          gh<_i55.ImagePickerService>(),
          gh<_i99.OcrService>(),
          gh<_i129.VectorStoreService>(),
        ));
    gh.lazySingleton<_i251.HomeRepository>(() => _i252.HomeRepositoryImpl(
          gh<_i131.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i196.MedicationRepository>(),
          gh<_i50.HomeLocalDataSource>(),
          gh<_i52.HomeRemoteDataSource>(),
          gh<_i49.HealthSummaryDatasource>(),
        ));
    gh.lazySingleton<_i190.LlmService>(
      () => _i253.RagLlmService(
        gh<_i129.VectorStoreService>(),
        gh<_i195.MedicalResearchService>(),
        gh<_i126.UserProfileRepository>(),
        gh<_i63.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i254.MedicalIndexingService>(
        () => _i254.MedicalIndexingService(
              gh<_i69.MedicalKnowledgeRepository>(),
              gh<_i129.VectorStoreService>(),
              gh<_i204.PatientContextIndexer>(),
            ));
    gh.lazySingleton<_i255.MedicalResearchRepository>(
        () => _i256.MedicalResearchRepositoryImpl(
              gh<_i195.MedicalResearchService>(),
              gh<_i60.Isar>(),
            ));
    gh.factory<_i257.MedicationBloc>(
        () => _i257.MedicationBloc(gh<_i196.MedicationRepository>()));
    gh.factory<_i258.OnboardingCubit>(
        () => _i258.OnboardingCubit(gh<_i202.OnboardingRepository>()));
    gh.factory<_i259.ReportBloc>(() => _i259.ReportBloc(
          gh<_i106.ReportRepository>(),
          gh<_i205.ReportGenerationService>(),
        ));
    gh.factory<_i260.SearchMedicalResearch>(() =>
        _i260.SearchMedicalResearch(gh<_i255.MedicalResearchRepository>()));
    gh.factory<_i261.SharingCubit>(() => _i261.SharingCubit(
          bleService: gh<_i148.BleSharingService>(),
          nfcService: gh<_i93.NfcSharingService>(),
          wifiService: gh<_i138.WifiDirectService>(),
          startSharingUseCase: gh<_i218.StartSharingUseCase>(),
          startListeningUseCase: gh<_i217.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i149.CancelSharingUseCase>(),
          walletService: gh<_i35.WalletService>(),
          walletEncryption: gh<_i35.EncryptionService>(),
        ));
    gh.factory<_i262.DashboardCubit>(() => _i262.DashboardCubit(
          gh<_i245.GetDashboardStatsUseCase>(),
          gh<_i247.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i263.DataSourceCubit>(
        () => _i263.DataSourceCubit(gh<_i237.DataSourceRepository>()));
    gh.factory<_i264.GetHealthSummaryUseCase>(
        () => _i264.GetHealthSummaryUseCase(gh<_i251.HomeRepository>()));
    gh.factory<_i265.GetResearchHistory>(
        () => _i265.GetResearchHistory(gh<_i255.MedicalResearchRepository>()));
    gh.factory<_i266.HomeCubit>(() => _i266.HomeCubit(
          gh<_i264.GetHealthSummaryUseCase>(),
          gh<_i251.HomeRepository>(),
        ));
    gh.factory<_i267.MedicalResearchCubit>(() => _i267.MedicalResearchCubit(
          gh<_i260.SearchMedicalResearch>(),
          gh<_i265.GetResearchHistory>(),
          gh<_i74.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i268.ServiceModule {}

class _$NetworkModule extends _i269.NetworkModule {}

class _$MemoryModule extends _i270.MemoryModule {}

class _$DatabaseModule extends _i271.DatabaseModule {}

class _$FhirModule extends _i272.FhirModule {}
