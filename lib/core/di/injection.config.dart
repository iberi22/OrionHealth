// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i20;
import 'package:dio/dio.dart' as _i31;
import 'package:flutter/services.dart' as _i92;
import 'package:flutter_appauth/flutter_appauth.dart' as _i39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i41;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i43;
import 'package:health_wallet/health_wallet.dart' as _i35;
import 'package:http/http.dart' as _i26;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i60;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i34;
import 'package:just_audio/just_audio.dart' as _i13;
import 'package:medical_standards/medical_standards.dart' as _i68;
import 'package:shared_preferences/shared_preferences.dart' as _i51;

import '../../features/about/application/about_cubit.dart' as _i143;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i53;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i169;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i144;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i54;
import '../../features/allergies/application/allergies_cubit.dart' as _i267;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i268;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i145;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i231;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i230;
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/domain/usecases/get_allergies_usecase.dart'
    as _i248;
import '../../features/allergies/domain/usecases/save_allergy_usecase.dart'
    as _i264;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i10;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i7;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i8;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i9;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i28;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i44;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i110;
import '../../features/auth/application/auth_cubit.dart' as _i269;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i232;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i147;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i149;
import '../../features/auth/domain/auth_service.dart' as _i233;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i148;
import '../../features/auth/domain/usecases/check_session_timeout.dart'
    as _i153;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i175;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i200;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i201;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i213;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i220;
import '../../features/auth/domain/usecases/validate_session_usecase.dart'
    as _i226;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i16;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i166;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i236;
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i21;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i23;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i193;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i19;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i22;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i24;
import '../../features/clinical_assessments/application/clinical_assessments_cubit.dart'
    as _i237;
import '../../features/clinical_assessments/domain/repositories/i_assessment_repository.dart'
    as _i191;
import '../../features/clinical_assessments/infrastructure/datasources/assessment_local_datasource.dart'
    as _i146;
import '../../features/clinical_assessments/infrastructure/repositories/assessment_repository_impl.dart'
    as _i192;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i270;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i239;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i249;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i251;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
    as _i157;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i27;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i240;
import '../../features/data_sources/application/data_source_cubit.dart'
    as _i271;
import '../../features/data_sources/domain/repositories/data_source_repository.dart'
    as _i241;
import '../../features/data_sources/infrastructure/datasources/file_import_datasource.dart'
    as _i168;
import '../../features/data_sources/infrastructure/datasources/health_connect_datasource.dart'
    as _i186;
import '../../features/data_sources/infrastructure/datasources/sensor_api_datasource.dart'
    as _i116;
import '../../features/data_sources/infrastructure/repositories/data_source_repository_impl.dart'
    as _i242;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i235;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i163;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i218;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i229;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i161;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i104;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i112;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i140;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i234;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i62;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
    as _i170;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i176;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i61;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i162;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i105;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i113;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i141;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i164;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i165;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i32;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i124;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i33;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i244;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i245;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i97;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i156;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i158;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i174;
import '../../features/eps_connection/infrastructure/datasources/oauth_local_datasource.dart'
    as _i96;
import '../../features/eps_connection/infrastructure/repositories/local_fhir_oauth_repository.dart'
    as _i99;
import '../../features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart'
    as _i98;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i252;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i253;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i187;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i45;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i109;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i117;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i188;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i254;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i189;
import '../../features/health_record/domain/usecases/get_all_records_usecase.dart'
    as _i247;
import '../../features/health_record/domain/usecases/save_record_usecase.dart'
    as _i215;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i190;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i37;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i55;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i100;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i266;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i121;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i151;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i222;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i223;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i150;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i17;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i46;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart'
    as _i47;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i91;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i93;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i122;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i142;
import '../../features/home/application/home_cubit.dart' as _i274;
import '../../features/home/domain/repositories/home_repository.dart' as _i255;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i272;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i48;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i50;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i52;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i256;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i221;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i152;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i67;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i69;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i63;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i133;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i173;
import '../../features/local_agent/domain/usecases/send_chat_message_usecase.dart'
    as _i115;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i65;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i40;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i195;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i42;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i194;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i64;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i198;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i197;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i257;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i70;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i71;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i134;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i196;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i66;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i275;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i84;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i262;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i276;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i258;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i72;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i74;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i76;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i273;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i265;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i18;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i202;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i73;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i75;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i77;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i259;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i260;
import '../../features/medications/application/medications_cubit.dart' as _i205;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i78;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i203;
import '../../features/medications/domain/usecases/get_all_medications_usecase.dart'
    as _i246;
import '../../features/medications/domain/usecases/save_medication_usecase.dart'
    as _i214;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i204;
import '../../features/medications/infrastructure/repositories/sqlite_medication_adherence_repository.dart'
    as _i79;
import '../../features/medications/infrastructure/services/pharmacy_api_service.dart'
    as _i101;
import '../../features/medications/infrastructure/services/rxnorm_api_service.dart'
    as _i102;
import '../../features/meditation/application/meditation_cubit.dart' as _i206;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i81;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i154;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i179;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i181;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i106;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i123;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i80;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i82;
import '../../features/network/application/network_cubit.dart' as _i207;
import '../../features/network/domain/repositories/network_peer_repository.dart'
    as _i87;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i184;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i183;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i185;
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
    as _i208;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i89;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i155;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i177;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i178;
import '../../features/network/network_health/infrastructure/datasources/network_datasource.dart'
    as _i85;
import '../../features/network/network_health/infrastructure/repositories/network_repository_impl.dart'
    as _i90;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i261;
import '../../features/onboarding/application/sync_cubit.dart' as _i224;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i209;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i238;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i250;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i210;
import '../../features/reports/application/bloc/report_bloc.dart' as _i263;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i107;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i211;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i180;
import '../../features/reports/domain/usecases/save_report_usecase.dart'
    as _i111;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i108;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i212;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i83;
import '../../features/settings/application/llm_settings_cubit.dart' as _i199;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i119;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i29;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i118;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i120;
import '../../features/sync/application/sync_cubit.dart' as _i167;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i125;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i159;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i94;
import '../../features/sync/domain/services/sync_service.dart' as _i127;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i243;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i38;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i59;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i126;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i36;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i160;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i95;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i128;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i225;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i129;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i130;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i132;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i182;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
    as _i216;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i131;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i227;
import '../../features/vitals/application/vitals_cubit.dart' as _i137;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i135;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i171;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
    as _i217;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i136;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i228;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i138;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i172;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i219;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i25;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i139;
import '../logging/audit_logger.dart' as _i15;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i11;
import '../services/audio/audio_player_service.dart' as _i12;
import '../services/audio/audio_recorder_service.dart' as _i14;
import '../services/device_capability_service.dart' as _i30;
import '../services/privacy_anonymizer.dart' as _i103;
import '../services/secure_storage_service.dart' as _i114;
import '../utils/health_wrapper.dart' as _i49;
import 'database_module.dart' as _i280;
import 'fhir_module.dart' as _i281;
import 'memory_module.dart' as _i279;
import 'network_module.dart' as _i278;
import 'service_module.dart' as _i277;

const String _mobile = 'mobile';
const String _desktop = 'desktop';
const String _test = 'test';
const String _production = 'production';
const String _development = 'development';
const String _staging = 'staging';

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
    gh.lazySingleton<_i15.AuditLogger>(() => _i15.AuditLogger());
    gh.lazySingleton<_i16.BiometricService>(() => _i16.BiometricService());
    gh.lazySingleton<_i17.BleWrapper>(() => _i17.BleWrapper());
    gh.lazySingleton<_i18.BotBypassHandler>(() => _i18.BotBypassHandler());
    gh.factory<_i19.CalendarApiDatasource>(() => _i19.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i20.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i21.CalendarImportRepository>(() =>
        _i22.CalendarImportRepositoryImpl(gh<_i19.CalendarApiDatasource>()));
    gh.lazySingleton<_i23.CalendarParserService>(
        () => _i24.CalendarParserServiceImpl());
    gh.lazySingleton<_i25.ChatAiDatasource>(() => _i25.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i11.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i26.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i27.DashboardRemoteDataSource>(
        () => _i27.DashboardRemoteDataSourceImpl());
    gh.factory<_i28.DeleteAppointmentUseCase>(
        () => _i28.DeleteAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i29.DeviceCapabilityService>(
        () => _i29.DeviceCapabilityService());
    gh.lazySingleton<_i30.DeviceCapabilityService>(
        () => _i30.DeviceCapabilityService());
    gh.lazySingleton<_i31.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i32.EmailRepository>(() => _i33.EmailRepositoryImpl(
          gh<_i26.Client>(),
          gh<_i20.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i34.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i35.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i36.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i37.FilePickerService>(
        () => _i37.FilePickerServiceImpl());
    gh.lazySingleton<_i38.FilecoinDatasource>(() => _i38.FilecoinDatasource());
    gh.lazySingleton<_i39.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i40.FlutterGemmaWrapper>(
        () => _i40.FlutterGemmaWrapper());
    await gh.lazySingletonAsync<_i41.FlutterSecureStorage>(
      () => serviceModule.storage(gh<_i30.DeviceCapabilityService>()),
      preResolve: true,
    );
    gh.lazySingleton<_i42.GeminiModelWrapper>(
        () => _i42.GeminiModelWrapper(gh<_i43.GenerativeModel>()));
    gh.factory<_i44.GetAllAppointmentsUseCase>(
        () => _i44.GetAllAppointmentsUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i45.HealthDataImportService>(
        () => _i45.HealthDataImportService());
    gh.lazySingleton<_i46.HealthSharingLocalDataSource>(
        () => _i46.HealthSharingLocalDataSource());
    gh.lazySingleton<_i47.HealthSharingRemoteDataSource>(
        () => _i47.HealthSharingRemoteDataSource(gh<_i31.Dio>()));
    gh.factory<_i48.HealthSummaryDatasource>(
        () => _i48.HealthSummaryDatasource());
    gh.lazySingleton<_i49.HealthWrapper>(() => serviceModule.healthWrapper);
    gh.factory<_i50.HomeLocalDataSource>(
        () => _i50.HomeLocalDataSource(gh<_i51.SharedPreferences>()));
    gh.factory<_i52.HomeRemoteDataSource>(
        () => _i52.HomeRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i53.IAboutRepository>(
        () => _i54.AboutRepositoryImpl(gh<_i4.AboutLocalDataSource>()));
    gh.lazySingleton<_i55.ImagePickerService>(
        () => _i55.ImagePickerServiceImpl());
    gh.lazySingleton<_i56.IncentiveDatasource>(
        () => _i56.IncentiveDatasource());
    gh.lazySingleton<_i57.IncentiveRepository>(
        () => _i58.IncentiveRepositoryImpl(gh<_i56.IncentiveDatasource>()));
    gh.lazySingleton<_i59.IpfsDatasource>(
        () => _i59.IpfsDatasource(gh<_i31.Dio>()));
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
      () => _i64.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i63.LlmAdapter>(
      () => _i65.FlutterGemmaAdapter(wrapper: gh<_i40.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
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
              gh<_i31.Dio>(),
              gh<_i18.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i74.MedicalStandardsService>(() =>
        _i75.MedicalStandardsServiceImpl(gh<_i68.MedicalContextProvider>()));
    gh.lazySingleton<_i76.MedicalWebSearchService>(
        () => _i77.MedicalWebSearchServiceImpl(gh<_i31.Dio>()));
    gh.lazySingleton<_i78.MedicationAdherenceRepository>(() =>
        _i79.SqliteMedicationAdherenceRepository(
            gh<_i5.AdherenceSqliteDatasource>()));
    gh.lazySingleton<_i80.MeditationLocalDataSource>(
        () => _i80.MeditationLocalDataSource());
    gh.lazySingleton<_i81.MeditationRepository>(() =>
        _i82.MeditationRepositoryImpl(gh<_i80.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i34.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i60.Isar>(),
        gh<_i34.EmbeddingsAdapter>(),
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
        () => _i85.NetworkDatasourceImpl(gh<_i31.Dio>()));
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
    gh.lazySingleton<_i97.OAuthRepository>(
      () => _i98.OAuthRepositoryImpl(
        gh<_i96.OAuthLocalDataSource>(),
        gh<_i31.Dio>(),
        gh<_i39.FlutterAppAuth>(),
      ),
      registerFor: {_production},
    );
    gh.lazySingleton<_i97.OAuthRepository>(
      () => _i99.LocalFhirOAuthRepository(),
      registerFor: {
        _development,
        _staging,
        _test,
      },
    );
    gh.lazySingleton<_i100.OcrService>(() => _i100.MlKitOcrService());
    gh.lazySingleton<_i101.PharmacyApiService>(
        () => _i102.RxNormApiService(gh<_i31.Dio>()));
    gh.lazySingleton<_i103.PromptScrubber>(
        () => _i103.PromptScrubber(gh<_i60.Isar>()));
    gh.lazySingleton<_i104.RatingRepository>(
        () => _i105.IsarRatingRepository(gh<_i60.Isar>()));
    gh.lazySingleton<_i106.RecommendScriptUseCase>(
        () => _i106.RecommendScriptUseCase(gh<_i81.MeditationRepository>()));
    gh.lazySingleton<_i107.ReportRepository>(
        () => _i108.IsarReportRepository(gh<_i60.Isar>()));
    gh.factory<_i109.RequestHealthAuthUseCase>(() =>
        _i109.RequestHealthAuthUseCase(gh<_i45.HealthDataImportService>()));
    gh.factory<_i110.SaveAppointmentUseCase>(
        () => _i110.SaveAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.factory<_i111.SaveReportUseCase>(
        () => _i111.SaveReportUseCase(gh<_i107.ReportRepository>()));
    gh.lazySingleton<_i112.SecondOpinionRepository>(
        () => _i113.IsarSecondOpinionRepository(gh<_i60.Isar>()));
    gh.lazySingleton<_i114.SecureStorageService>(
        () => _i114.SecureStorageServiceImpl(
              storage: gh<_i41.FlutterSecureStorage>(),
              capabilityService: gh<_i30.DeviceCapabilityService>(),
            ));
    gh.factory<_i115.SendChatMessageUseCase>(() => _i115.SendChatMessageUseCase(
          gh<_i63.LlmAdapter>(),
          gh<_i69.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i116.SensorApiDataSource>(
        () => _i116.SensorApiDataSourceImpl(gh<_i49.HealthWrapper>()));
    gh.lazySingleton<_i117.SensorHealthDataSource>(
        () => _i117.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i118.SettingsLocalDataSource>(
        () => _i118.SettingsLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i119.SettingsRepository>(() =>
        _i120.SettingsRepositoryImpl(gh<_i118.SettingsLocalDataSource>()));
    gh.lazySingleton<_i121.SharingRepository>(() =>
        _i122.HealthSharingRepositoryImpl(
            gh<_i46.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i123.StartSessionUseCase>(
        () => _i123.StartSessionUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i124.SyncEmailAppointmentsUseCase>(
        () => _i124.SyncEmailAppointmentsUseCase(gh<_i32.EmailRepository>()));
    gh.lazySingleton<_i125.SyncRepository>(() => _i126.SyncRepositoryImpl(
          gh<_i36.FhirClient>(),
          gh<_i60.Isar>(),
          gh<_i41.FlutterSecureStorage>(),
          gh<_i94.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i68.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i127.SyncService>(() => _i128.SyncServiceImpl(
          gh<_i125.SyncRepository>(),
          gh<_i68.SyncService>(),
        ));
    gh.lazySingleton<_i129.UserProfileLocalDataSource>(
        () => _i129.UserProfileLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i130.UserProfileRepository>(
        () => _i131.UserProfileRepositoryImpl(gh<_i60.Isar>()));
    gh.lazySingleton<_i132.UserProfileService>(
        () => _i132.UserProfileService(gh<_i130.UserProfileRepository>()));
    gh.lazySingleton<_i133.VectorStoreService>(
        () => _i134.IsarVectorStoreService(
              gh<_i34.MemoryGraph>(),
              gh<_i69.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i135.VitalSignRepository>(
        () => _i136.VitalSignRepositoryImpl(gh<_i60.Isar>()));
    gh.factory<_i137.VitalsCubit>(
        () => _i137.VitalsCubit(gh<_i135.VitalSignRepository>()));
    gh.lazySingleton<_i138.VoiceChatRepository>(
        () => _i139.VoiceChatRepositoryImpl(gh<_i25.ChatAiDatasource>()));
    gh.lazySingleton<_i140.VouchRepository>(
        () => _i141.IsarVouchRepository(gh<_i60.Isar>()));
    gh.lazySingleton<_i35.WalletService>(() => databaseModule.walletService(
          gh<_i60.Isar>(),
          gh<_i35.EncryptionService>(),
        ));
    gh.lazySingleton<_i142.WifiDirectService>(() => _i142.WifiDirectService());
    gh.factory<_i143.AboutCubit>(
        () => _i143.AboutCubit(gh<_i53.IAboutRepository>()));
    gh.lazySingleton<_i144.AboutRemoteDataSource>(
        () => _i144.AboutRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i145.AllergyLocalDataSource>(
        () => _i145.AllergyLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i146.AssessmentLocalDataSource>(
        () => _i146.AssessmentLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i147.AuthLocalDataSource>(
        () => _i147.AuthLocalDataSource(gh<_i60.Isar>()));
    gh.lazySingleton<_i148.AuthRepository>(() => _i149.AuthRepositoryImpl(
          gh<_i147.AuthLocalDataSource>(),
          gh<_i114.SecureStorageService>(),
        ));
    gh.lazySingleton<_i150.BleSharingService>(
        () => _i150.BleSharingService(gh<_i17.BleWrapper>()));
    gh.lazySingleton<_i151.CancelSharingUseCase>(
        () => _i151.CancelSharingUseCase(
              gh<_i150.BleSharingService>(),
              gh<_i93.NfcSharingService>(),
              gh<_i142.WifiDirectService>(),
            ));
    gh.lazySingleton<_i152.ChatMessageLocalDataSource>(
        () => _i152.ChatMessageLocalDataSource(gh<_i60.Isar>()));
    gh.factory<_i153.CheckSessionTimeoutUseCase>(
        () => _i153.CheckSessionTimeoutUseCase(gh<_i148.AuthRepository>()));
    gh.lazySingleton<_i154.CompleteSessionUseCase>(
        () => _i154.CompleteSessionUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i124.ConnectEmailProviderUseCase>(
        () => _i124.ConnectEmailProviderUseCase(gh<_i32.EmailRepository>()));
    gh.lazySingleton<_i155.ConnectNode>(
        () => _i155.ConnectNode(gh<_i89.NetworkRepository>()));
    gh.factory<_i156.ConnectProviderUseCase>(() => _i156.ConnectProviderUseCase(
          gh<_i97.OAuthRepository>(),
          gh<_i130.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i157.DashboardLocalDataSource>(
        () => _i157.DashboardLocalDataSource(gh<_i60.Isar>()));
    gh.factory<_i158.DisconnectProviderUseCase>(
        () => _i158.DisconnectProviderUseCase(
              gh<_i97.OAuthRepository>(),
              gh<_i130.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i159.DistributedStorageService>(() => _i160.IpfsService(
          gh<_i59.IpfsDatasource>(),
          gh<_i38.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i161.DoctorProfileRepository>(
        () => _i162.IsarDoctorProfileRepository(gh<_i60.Isar>()));
    gh.factoryAsync<_i163.DoctorVerificationCubit>(
        () async => _i163.DoctorVerificationCubit(
              gh<_i161.DoctorProfileRepository>(),
              gh<_i104.RatingRepository>(),
              await getAsync<_i62.LicenseVerifier>(),
            ));
    gh.factory<_i164.EmailCitasBloc>(() => _i164.EmailCitasBloc(
          gh<_i124.ConnectEmailProviderUseCase>(),
          gh<_i124.SyncEmailAppointmentsUseCase>(),
          gh<_i32.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.factory<_i165.EmailCitasCubit>(() => _i165.EmailCitasCubit(
          gh<_i32.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i166.EncryptionService>(
        () => _i166.EncryptionService(gh<_i114.SecureStorageService>()));
    gh.factory<_i167.FhirSyncCubit>(() => _i167.FhirSyncCubit(
          gh<_i127.SyncService>(),
          gh<_i94.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i117.FileHealthDataSource>(
        () => _i117.FileHealthDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i100.OcrService>(),
            ));
    gh.lazySingleton<_i168.FileImportDataSource>(
        () => _i168.FileImportDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i100.OcrService>(),
            ));
    gh.factory<_i169.GetAboutInfoUseCase>(
        () => _i169.GetAboutInfoUseCase(gh<_i53.IAboutRepository>()));
    gh.factory<_i170.GetAllDoctorsUseCase>(
        () => _i170.GetAllDoctorsUseCase(gh<_i161.DoctorProfileRepository>()));
    gh.factory<_i171.GetAllVitalSignsUseCase>(
        () => _i171.GetAllVitalSignsUseCase(gh<_i135.VitalSignRepository>()));
    gh.factory<_i109.GetAvailableSourcesUseCase>(() =>
        _i109.GetAvailableSourcesUseCase(gh<_i45.HealthDataImportService>()));
    gh.factory<_i172.GetChatHistoryUseCase>(
        () => _i172.GetChatHistoryUseCase(gh<_i138.VoiceChatRepository>()));
    gh.factory<_i173.GetChatHistoryUseCase>(
        () => _i173.GetChatHistoryUseCase(gh<_i133.VectorStoreService>()));
    gh.factory<_i174.GetConnectionsUseCase>(
        () => _i174.GetConnectionsUseCase(gh<_i97.OAuthRepository>()));
    gh.factory<_i175.GetCredentialsUseCase>(
        () => _i175.GetCredentialsUseCase(gh<_i148.AuthRepository>()));
    gh.factory<_i176.GetDoctorProfileUseCase>(() =>
        _i176.GetDoctorProfileUseCase(gh<_i161.DoctorProfileRepository>()));
    gh.lazySingleton<_i177.GetNetworkHealth>(
        () => _i177.GetNetworkHealth(gh<_i89.NetworkRepository>()));
    gh.lazySingleton<_i178.GetNodeStats>(
        () => _i178.GetNodeStats(gh<_i89.NetworkRepository>()));
    gh.lazySingleton<_i179.GetProgressUseCase>(
        () => _i179.GetProgressUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i180.GetReportsUseCase>(
        () => _i180.GetReportsUseCase(gh<_i107.ReportRepository>()));
    gh.lazySingleton<_i181.GetScriptsUseCase>(
        () => _i181.GetScriptsUseCase(gh<_i81.MeditationRepository>()));
    gh.factory<_i182.GetUserProfileUseCase>(
        () => _i182.GetUserProfileUseCase(gh<_i130.UserProfileRepository>()));
    gh.lazySingleton<_i183.GovernanceIpfsDatasource>(
        () => _i183.GovernanceIpfsDatasource(gh<_i59.IpfsDatasource>()));
    gh.lazySingleton<_i184.GovernanceRepository>(() =>
        _i185.GovernanceRepositoryImpl(gh<_i183.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i186.HealthConnectDataSource>(
        () => _i186.HealthConnectDataSourceImpl(gh<_i49.HealthWrapper>()));
    gh.lazySingleton<_i187.HealthDataImportRepository>(
        () => _i188.HealthDataImportRepositoryImpl(
              gh<_i117.SensorHealthDataSource>(),
              gh<_i117.FileHealthDataSource>(),
            ));
    gh.lazySingleton<_i189.HealthRecordRepository>(
        () => _i190.HealthRecordRepositoryImpl(gh<_i60.Isar>()));
    gh.lazySingleton<_i191.IAssessmentRepository>(
        () => _i192.AssessmentRepositoryImpl(gh<_i60.Isar>()));
    gh.factory<_i193.ImportCalendarUseCase>(() => _i193.ImportCalendarUseCase(
          gh<_i21.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i130.UserProfileRepository>(),
        ));
    gh.factory<_i109.ImportHealthDataUseCase>(
        () => _i109.ImportHealthDataUseCase(
              gh<_i45.HealthDataImportService>(),
              gh<_i135.VitalSignRepository>(),
            ));
    gh.factory<_i63.LlmAdapter>(
      () => _i194.MockLlmAdapter(gh<_i103.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i63.LlmAdapter>(
      () => _i195.GeminiLlmAdapter(
        scrubber: gh<_i103.PromptScrubber>(),
        userProfileRepository: gh<_i130.UserProfileRepository>(),
        modelWrapper: gh<_i42.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i196.LlmAdapterFactory>(
        () => _i196.LlmAdapterFactory(gh<_i119.SettingsRepository>()));
    gh.lazySingleton<_i197.LlmService>(() => _i198.GemmaLlmService(
          gh<_i133.VectorStoreService>(),
          gh<_i130.UserProfileRepository>(),
          gh<_i63.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i199.LlmSettingsCubit>(() => _i199.LlmSettingsCubit(
          gh<_i119.SettingsRepository>(),
          gh<_i29.DeviceCapabilityService>(),
          gh<_i63.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i200.LoginUseCase>(() => _i200.LoginUseCase(
          gh<_i148.AuthRepository>(),
          gh<_i166.EncryptionService>(),
          gh<_i16.BiometricService>(),
        ));
    gh.factory<_i201.LogoutUseCase>(
        () => _i201.LogoutUseCase(gh<_i148.AuthRepository>()));
    gh.lazySingleton<_i202.MedicalResearchService>(
        () => _i202.MedicalResearchService(
              gh<_i76.MedicalWebSearchService>(),
              gh<_i72.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i203.MedicationRepository>(
        () => _i204.IsarMedicationRepository(
              gh<_i60.Isar>(),
              gh<_i101.PharmacyApiService>(),
            ));
    gh.factory<_i205.MedicationsCubit>(
        () => _i205.MedicationsCubit(gh<_i203.MedicationRepository>()));
    gh.factory<_i206.MeditationCubit>(() => _i206.MeditationCubit(
          gh<_i106.RecommendScriptUseCase>(),
          gh<_i123.StartSessionUseCase>(),
          gh<_i154.CompleteSessionUseCase>(),
          gh<_i179.GetProgressUseCase>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i207.NetworkCubit>(() => _i207.NetworkCubit(
          gh<_i87.NetworkPeerRepository>(),
          gh<_i86.NetworkP2PApi>(),
        ));
    gh.factory<_i208.NetworkHealthCubit>(() => _i208.NetworkHealthCubit(
          gh<_i177.GetNetworkHealth>(),
          gh<_i155.ConnectNode>(),
          gh<_i89.NetworkRepository>(),
        ));
    gh.lazySingleton<_i209.OnboardingRepository>(() =>
        _i210.OnboardingRepositoryImpl(gh<_i130.UserProfileRepository>()));
    gh.lazySingleton<_i211.ReportGenerationService>(
        () => _i212.GemmaReportGenerationService(
              gh<_i63.LlmAdapter>(instanceName: 'gemma'),
              gh<_i133.VectorStoreService>(),
              gh<_i130.UserProfileRepository>(),
              gh<_i103.PromptScrubber>(),
            ));
    gh.factory<_i213.SaveCredentialsUseCase>(
        () => _i213.SaveCredentialsUseCase(gh<_i148.AuthRepository>()));
    gh.factory<_i214.SaveMedicationUseCase>(
        () => _i214.SaveMedicationUseCase(gh<_i203.MedicationRepository>()));
    gh.factory<_i215.SaveRecordUseCase>(
        () => _i215.SaveRecordUseCase(gh<_i189.HealthRecordRepository>()));
    gh.factory<_i216.SaveUserProfileUseCase>(
        () => _i216.SaveUserProfileUseCase(gh<_i130.UserProfileRepository>()));
    gh.factory<_i217.SaveVitalSignsUseCase>(
        () => _i217.SaveVitalSignsUseCase(gh<_i135.VitalSignRepository>()));
    gh.factory<_i218.SecondOpinionCubit>(
        () => _i218.SecondOpinionCubit(gh<_i112.SecondOpinionRepository>()));
    gh.factory<_i219.SendMessageUseCase>(
        () => _i219.SendMessageUseCase(gh<_i138.VoiceChatRepository>()));
    gh.factory<_i220.SetPinUseCase>(() => _i220.SetPinUseCase(
          gh<_i148.AuthRepository>(),
          gh<_i166.EncryptionService>(),
        ));
    gh.lazySingleton<_i221.SmartSearchUseCase>(
        () => _i221.SmartSearchUseCase(gh<_i133.VectorStoreService>()));
    gh.lazySingleton<_i222.StartListeningUseCase>(
        () => _i222.StartListeningUseCase(
              gh<_i150.BleSharingService>(),
              gh<_i93.NfcSharingService>(),
              gh<_i142.WifiDirectService>(),
            ));
    gh.lazySingleton<_i223.StartSharingUseCase>(() => _i223.StartSharingUseCase(
          gh<_i150.BleSharingService>(),
          gh<_i93.NfcSharingService>(),
          gh<_i142.WifiDirectService>(),
        ));
    gh.factory<_i224.SyncCubit>(() => _i224.SyncCubit(
          gh<_i68.SyncService>(),
          gh<_i133.VectorStoreService>(),
        ));
    gh.factory<_i225.UserProfileCubit>(
        () => _i225.UserProfileCubit(gh<_i130.UserProfileRepository>()));
    gh.factory<_i226.ValidateSessionUseCase>(
        () => _i226.ValidateSessionUseCase(gh<_i148.AuthRepository>()));
    gh.factory<_i227.VitalSignBloc>(
        () => _i227.VitalSignBloc(gh<_i135.VitalSignRepository>()));
    gh.factory<_i228.VoiceChatCubit>(() => _i228.VoiceChatCubit(
          gh<_i219.SendMessageUseCase>(),
          gh<_i172.GetChatHistoryUseCase>(),
          gh<_i138.VoiceChatRepository>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i229.VouchCubit>(
        () => _i229.VouchCubit(gh<_i140.VouchRepository>()));
    gh.lazySingleton<_i230.AllergyRepository>(() => _i231.AllergyRepositoryImpl(
          gh<_i145.AllergyLocalDataSource>(),
          encryptionService: gh<_i166.EncryptionService>(),
        ));
    gh.factory<_i232.AuthCubit>(() => _i232.AuthCubit(
          gh<_i148.AuthRepository>(),
          gh<_i16.BiometricService>(),
          gh<_i200.LoginUseCase>(),
          gh<_i201.LogoutUseCase>(),
          gh<_i226.ValidateSessionUseCase>(),
          gh<_i220.SetPinUseCase>(),
          gh<_i153.CheckSessionTimeoutUseCase>(),
        ));
    gh.lazySingleton<_i233.AuthService>(
        () => _i233.AuthServiceImpl(gh<_i166.EncryptionService>()));
    gh.lazySingleton<_i234.BadgeCalculator>(() => _i234.BadgeCalculator(
          gh<_i161.DoctorProfileRepository>(),
          gh<_i104.RatingRepository>(),
          gh<_i140.VouchRepository>(),
        ));
    gh.factory<_i235.BadgeCubit>(
        () => _i235.BadgeCubit(gh<_i234.BadgeCalculator>()));
    gh.factory<_i236.CalendarImportCubit>(() => _i236.CalendarImportCubit(
          gh<_i21.CalendarImportRepository>(),
          gh<_i193.ImportCalendarUseCase>(),
        ));
    gh.factory<_i237.ClinicalAssessmentsCubit>(() =>
        _i237.ClinicalAssessmentsCubit(gh<_i191.IAssessmentRepository>()));
    gh.factory<_i238.CompleteOnboardingUseCase>(() =>
        _i238.CompleteOnboardingUseCase(gh<_i209.OnboardingRepository>()));
    gh.lazySingleton<_i239.DashboardRepository>(
        () => _i240.DashboardRepositoryImpl(
              gh<_i27.DashboardRemoteDataSource>(),
              gh<_i135.VitalSignRepository>(),
              gh<_i203.MedicationRepository>(),
              gh<_i107.ReportRepository>(),
            ));
    gh.lazySingleton<_i241.DataSourceRepository>(
        () => _i242.DataSourceRepositoryImpl(
              gh<_i116.SensorApiDataSource>(),
              gh<_i168.FileImportDataSource>(),
              gh<_i186.HealthConnectDataSource>(),
            ));
    gh.lazySingleton<_i243.DistributedCacheUsecase>(() =>
        _i243.DistributedCacheUsecase(gh<_i159.DistributedStorageService>()));
    gh.factory<_i244.EpsConnectionBloc>(() => _i244.EpsConnectionBloc(
          gh<_i174.GetConnectionsUseCase>(),
          gh<_i156.ConnectProviderUseCase>(),
          gh<_i158.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i245.EpsConnectionCubit>(() => _i245.EpsConnectionCubit(
          gh<_i174.GetConnectionsUseCase>(),
          gh<_i156.ConnectProviderUseCase>(),
          gh<_i158.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i246.GetAllMedicationsUseCase>(
        () => _i246.GetAllMedicationsUseCase(gh<_i203.MedicationRepository>()));
    gh.factory<_i247.GetAllRecordsUseCase>(
        () => _i247.GetAllRecordsUseCase(gh<_i189.HealthRecordRepository>()));
    gh.factory<_i248.GetAllergiesUseCase>(
        () => _i248.GetAllergiesUseCase(gh<_i230.AllergyRepository>()));
    gh.factory<_i249.GetDashboardStatsUseCase>(
        () => _i249.GetDashboardStatsUseCase(gh<_i239.DashboardRepository>()));
    gh.factory<_i250.GetOnboardingProfileUseCase>(() =>
        _i250.GetOnboardingProfileUseCase(gh<_i209.OnboardingRepository>()));
    gh.factory<_i251.GetRecentActivityUseCase>(
        () => _i251.GetRecentActivityUseCase(gh<_i239.DashboardRepository>()));
    gh.factory<_i252.HealthImportBloc>(() => _i252.HealthImportBloc(
          gh<_i109.GetAvailableSourcesUseCase>(),
          gh<_i109.RequestHealthAuthUseCase>(),
          gh<_i109.ImportHealthDataUseCase>(),
        ));
    gh.factory<_i253.HealthImportCubit>(() => _i253.HealthImportCubit(
          gh<_i109.GetAvailableSourcesUseCase>(),
          gh<_i109.RequestHealthAuthUseCase>(),
          gh<_i109.ImportHealthDataUseCase>(),
        ));
    gh.factory<_i254.HealthRecordCubit>(() => _i254.HealthRecordCubit(
          gh<_i189.HealthRecordRepository>(),
          gh<_i37.FilePickerService>(),
          gh<_i55.ImagePickerService>(),
          gh<_i100.OcrService>(),
          gh<_i133.VectorStoreService>(),
        ));
    gh.lazySingleton<_i255.HomeRepository>(() => _i256.HomeRepositoryImpl(
          gh<_i135.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i203.MedicationRepository>(),
          gh<_i50.HomeLocalDataSource>(),
          gh<_i52.HomeRemoteDataSource>(),
          gh<_i48.HealthSummaryDatasource>(),
        ));
    gh.lazySingleton<_i197.LlmService>(
      () => _i257.RagLlmService(
        gh<_i133.VectorStoreService>(),
        gh<_i202.MedicalResearchService>(),
        gh<_i130.UserProfileRepository>(),
        gh<_i63.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i258.MedicalResearchRepository>(
        () => _i259.MedicalResearchRepositoryImpl(
              gh<_i202.MedicalResearchService>(),
              gh<_i60.Isar>(),
            ));
    gh.factory<_i260.MedicationBloc>(
        () => _i260.MedicationBloc(gh<_i203.MedicationRepository>()));
    gh.factory<_i261.OnboardingCubit>(
        () => _i261.OnboardingCubit(gh<_i209.OnboardingRepository>()));
    gh.lazySingleton<_i262.PatientContextIndexer>(
      () => _i262.PatientContextIndexer(
        gh<_i60.Isar>(),
        gh<_i133.VectorStoreService>(),
        gh<_i189.HealthRecordRepository>(),
        gh<_i203.MedicationRepository>(),
        gh<_i230.AllergyRepository>(),
        gh<_i135.VitalSignRepository>(),
        gh<_i8.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i263.ReportBloc>(() => _i263.ReportBloc(
          gh<_i107.ReportRepository>(),
          gh<_i211.ReportGenerationService>(),
        ));
    gh.factory<_i264.SaveAllergyUseCase>(
        () => _i264.SaveAllergyUseCase(gh<_i230.AllergyRepository>()));
    gh.factory<_i265.SearchMedicalResearch>(() =>
        _i265.SearchMedicalResearch(gh<_i258.MedicalResearchRepository>()));
    gh.factory<_i266.SharingCubit>(() => _i266.SharingCubit(
          bleService: gh<_i150.BleSharingService>(),
          nfcService: gh<_i93.NfcSharingService>(),
          wifiService: gh<_i142.WifiDirectService>(),
          startSharingUseCase: gh<_i223.StartSharingUseCase>(),
          startListeningUseCase: gh<_i222.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i151.CancelSharingUseCase>(),
          walletService: gh<_i35.WalletService>(),
          walletEncryption: gh<_i35.EncryptionService>(),
        ));
    gh.factory<_i267.AllergiesCubit>(
        () => _i267.AllergiesCubit(gh<_i230.AllergyRepository>()));
    gh.factory<_i268.AllergyBloc>(
        () => _i268.AllergyBloc(gh<_i230.AllergyRepository>()));
    gh.factory<_i269.AuthCubit>(() => _i269.AuthCubit(gh<_i233.AuthService>()));
    gh.factory<_i270.DashboardCubit>(() => _i270.DashboardCubit(
          gh<_i249.GetDashboardStatsUseCase>(),
          gh<_i251.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i271.DataSourceCubit>(
        () => _i271.DataSourceCubit(gh<_i241.DataSourceRepository>()));
    gh.factory<_i272.GetHealthSummaryUseCase>(
        () => _i272.GetHealthSummaryUseCase(gh<_i255.HomeRepository>()));
    gh.factory<_i273.GetResearchHistory>(
        () => _i273.GetResearchHistory(gh<_i258.MedicalResearchRepository>()));
    gh.factory<_i274.HomeCubit>(() => _i274.HomeCubit(
          gh<_i272.GetHealthSummaryUseCase>(),
          gh<_i255.HomeRepository>(),
        ));
    gh.lazySingleton<_i275.MedicalIndexingService>(
        () => _i275.MedicalIndexingService(
              gh<_i69.MedicalKnowledgeRepository>(),
              gh<_i133.VectorStoreService>(),
              gh<_i262.PatientContextIndexer>(),
            ));
    gh.factory<_i276.MedicalResearchCubit>(() => _i276.MedicalResearchCubit(
          gh<_i265.SearchMedicalResearch>(),
          gh<_i273.GetResearchHistory>(),
          gh<_i74.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i277.ServiceModule {}

class _$NetworkModule extends _i278.NetworkModule {}

class _$MemoryModule extends _i279.MemoryModule {}

class _$DatabaseModule extends _i280.DatabaseModule {}

class _$FhirModule extends _i281.FhirModule {}
