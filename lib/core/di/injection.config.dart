// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:device_calendar/device_calendar.dart' as _i20;
import 'package:dio/dio.dart' as _i31;
import 'package:flutter/services.dart' as _i101;
import 'package:flutter_appauth/flutter_appauth.dart' as _i44;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i46;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i48;
import 'package:health_wallet/health_wallet.dart' as _i40;
import 'package:http/http.dart' as _i26;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i65;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i36;
import 'package:just_audio/just_audio.dart' as _i13;
import 'package:medical_standards/medical_standards.dart' as _i73;
import 'package:shared_preferences/shared_preferences.dart' as _i56;

import '../../features/about/application/about_cubit.dart' as _i148;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i58;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i174;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i149;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i59;
import '../../features/allergies/application/allergies_cubit.dart' as _i277;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i278;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i150;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i241;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i240;
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/domain/usecases/get_allergies_usecase.dart'
    as _i258;
import '../../features/allergies/domain/usecases/save_allergy_usecase.dart'
    as _i274;
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
    as _i49;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i115;
import '../../features/auth/application/auth_cubit.dart' as _i279;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i242;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i152;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i154;
import '../../features/auth/domain/auth_service.dart' as _i243;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i153;
import '../../features/auth/domain/usecases/check_session_timeout.dart'
    as _i158;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i179;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i204;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i205;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i220;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i227;
import '../../features/auth/domain/usecases/validate_session_usecase.dart'
    as _i235;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i16;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i172;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i246;
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i21;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i23;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i197;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i19;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i22;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i24;
import '../../features/clinical_assessments/application/clinical_assessments_cubit.dart'
    as _i247;
import '../../features/clinical_assessments/domain/repositories/i_assessment_repository.dart'
    as _i195;
import '../../features/clinical_assessments/infrastructure/datasources/assessment_local_datasource.dart'
    as _i151;
import '../../features/clinical_assessments/infrastructure/repositories/assessment_repository_impl.dart'
    as _i196;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i280;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i249;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i259;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i261;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
    as _i161;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i27;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i250;
import '../../features/data_sources/application/data_source_cubit.dart'
    as _i281;
import '../../features/data_sources/domain/repositories/data_source_repository.dart'
    as _i251;
import '../../features/data_sources/infrastructure/datasources/file_import_datasource.dart'
    as _i173;
import '../../features/data_sources/infrastructure/datasources/health_connect_datasource.dart'
    as _i190;
import '../../features/data_sources/infrastructure/datasources/sensor_api_datasource.dart'
    as _i121;
import '../../features/data_sources/infrastructure/repositories/data_source_repository_impl.dart'
    as _i252;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i245;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i168;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i225;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i238;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i166;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i109;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i117;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i143;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i244;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i67;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
    as _i175;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i180;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i66;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i167;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i110;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i118;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i144;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i170;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i171;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i34;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i129;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i35;
import '../../features/emergency/domain/repositories/medical_id_repository.dart'
    as _i74;
import '../../features/emergency/domain/usecases/get_medical_id_usecase.dart'
    as _i38;
import '../../features/emergency/domain/usecases/update_medical_id_usecase.dart'
    as _i39;
import '../../features/emergency/infrastructure/repositories/isar_medical_id_repository.dart'
    as _i75;
import '../../features/emergency/presentation/cubit/emergency_cubit.dart'
    as _i37;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i262;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i263;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i191;
import '../../features/health_data_import/domain/services/ecosystem_dietary_export_service.dart'
    as _i253;
import '../../features/health_data_import/domain/services/ecosystem_import_service.dart'
    as _i32;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i50;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i114;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i122;
import '../../features/health_data_import/infrastructure/ecosystem_record_store.dart'
    as _i169;
import '../../features/health_data_import/infrastructure/ecosystem_subject_store.dart'
    as _i33;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i192;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i264;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i193;
import '../../features/health_record/domain/usecases/get_all_records_usecase.dart'
    as _i257;
import '../../features/health_record/domain/usecases/save_record_usecase.dart'
    as _i222;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i194;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i42;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i60;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i105;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i276;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i126;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i156;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i229;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i230;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i155;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i17;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i51;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart'
    as _i52;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i100;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i102;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i127;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i145;
import '../../features/home/application/home_cubit.dart' as _i284;
import '../../features/home/domain/repositories/home_repository.dart' as _i265;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i282;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i53;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i55;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i57;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i266;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i228;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i157;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i72;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i76;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i68;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i136;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i177;
import '../../features/local_agent/domain/usecases/send_chat_message_usecase.dart'
    as _i120;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i70;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i45;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i199;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i47;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i198;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i69;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i202;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i201;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i267;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i77;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i78;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i137;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i200;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i71;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i285;
import '../../features/local_agent/infrastructure/services/medical_text_normalizer.dart'
    as _i84;
import '../../features/local_agent/infrastructure/services/medical_text_normalizer_config.dart'
    as _i83;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i93;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i272;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i286;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i268;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i79;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i81;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i85;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i283;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i275;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i18;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i206;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i80;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i82;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i86;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i269;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i270;
import '../../features/medications/application/medications_cubit.dart' as _i209;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i87;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i207;
import '../../features/medications/domain/usecases/get_all_medications_usecase.dart'
    as _i256;
import '../../features/medications/domain/usecases/save_medication_usecase.dart'
    as _i221;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i208;
import '../../features/medications/infrastructure/repositories/sqlite_medication_adherence_repository.dart'
    as _i88;
import '../../features/medications/infrastructure/services/pharmacy_api_service.dart'
    as _i106;
import '../../features/medications/infrastructure/services/rxnorm_api_service.dart'
    as _i107;
import '../../features/meditation/application/meditation_cubit.dart' as _i210;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i90;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i159;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i183;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i185;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i111;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i128;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i89;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i91;
import '../../features/network/application/network_cubit.dart' as _i211;
import '../../features/network/domain/repositories/network_peer_repository.dart'
    as _i96;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i188;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i187;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i189;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i62;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i61;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i63;
import '../../features/network/infrastructure/datasources/network_p2p_api.dart'
    as _i95;
import '../../features/network/infrastructure/repositories/network_peer_repository_impl.dart'
    as _i97;
import '../../features/network/network_health/application/network_health_cubit.dart'
    as _i212;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i98;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i160;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i181;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i182;
import '../../features/network/network_health/infrastructure/datasources/network_datasource.dart'
    as _i94;
import '../../features/network/network_health/infrastructure/repositories/network_repository_impl.dart'
    as _i99;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i271;
import '../../features/onboarding/application/sync_cubit.dart' as _i231;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i213;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i248;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i260;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i214;
import '../../features/reports/application/bloc/report_bloc.dart' as _i273;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i112;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i216;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i184;
import '../../features/reports/domain/usecases/save_report_usecase.dart'
    as _i116;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i113;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i217;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i92;
import '../../features/settings/application/llm_settings_cubit.dart' as _i203;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i124;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i29;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i123;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i125;
import '../../features/sync/application/sync_cubit.dart' as _i255;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i130;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i164;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i103;
import '../../features/sync/domain/services/sync_service.dart' as _i232;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i254;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i43;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i64;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i131;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i41;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i165;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i104;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i233;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i234;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i132;
import '../../features/user_profile/domain/repositories/data_export_repository.dart'
    as _i162;
import '../../features/user_profile/domain/repositories/right_to_erasure_repository.dart'
    as _i218;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i133;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i135;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i186;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
    as _i223;
import '../../features/user_profile/infrastructure/repositories/isar_data_export_repository.dart'
    as _i163;
import '../../features/user_profile/infrastructure/repositories/isar_right_to_erasure_repository.dart'
    as _i219;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i134;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i236;
import '../../features/vitals/application/vitals_cubit.dart' as _i140;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i138;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i176;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
    as _i224;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i139;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i237;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i141;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i178;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i226;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i25;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i142;
import '../../features/workouts/application/workout_fhir_export_service.dart'
    as _i239;
import '../../features/workouts/domain/repositories/workout_repository.dart'
    as _i146;
import '../../features/workouts/infrastructure/repositories/workout_repository_impl.dart'
    as _i147;
import '../audit/phi_audit_service.dart' as _i215;
import '../logging/audit_logger.dart' as _i15;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i11;
import '../services/audio/audio_player_service.dart' as _i12;
import '../services/audio/audio_recorder_service.dart' as _i14;
import '../services/device_capability_service.dart' as _i30;
import '../services/privacy_anonymizer.dart' as _i108;
import '../services/secure_storage_service.dart' as _i119;
import '../utils/health_wrapper.dart' as _i54;
import 'database_module.dart' as _i290;
import 'fhir_module.dart' as _i291;
import 'memory_module.dart' as _i289;
import 'network_module.dart' as _i288;
import 'service_module.dart' as _i287;

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
    gh.lazySingleton<_i32.EcosystemSubjectStore>(
        () => _i33.LocalEcosystemSubjectStore());
    gh.lazySingleton<_i34.EmailRepository>(() => _i35.EmailRepositoryImpl(
          gh<_i26.Client>(),
          gh<_i20.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i36.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.factory<_i37.EmergencyCubit>(() => _i37.EmergencyCubit(
          gh<_i38.GetMedicalIdUseCase>(),
          gh<_i39.UpdateMedicalIdUseCase>(),
        ));
    gh.lazySingleton<_i40.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i41.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i42.FilePickerService>(
        () => _i42.FilePickerServiceImpl());
    gh.lazySingleton<_i43.FilecoinDatasource>(() => _i43.FilecoinDatasource());
    gh.lazySingleton<_i44.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i45.FlutterGemmaWrapper>(
        () => _i45.FlutterGemmaWrapper());
    await gh.lazySingletonAsync<_i46.FlutterSecureStorage>(
      () => serviceModule.storage(gh<_i30.DeviceCapabilityService>()),
      preResolve: true,
    );
    gh.lazySingleton<_i47.GeminiModelWrapper>(
        () => _i47.GeminiModelWrapper(gh<_i48.GenerativeModel>()));
    gh.factory<_i49.GetAllAppointmentsUseCase>(
        () => _i49.GetAllAppointmentsUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i50.HealthDataImportService>(
        () => _i50.HealthDataImportService());
    gh.lazySingleton<_i51.HealthSharingLocalDataSource>(
        () => _i51.HealthSharingLocalDataSource());
    gh.lazySingleton<_i52.HealthSharingRemoteDataSource>(
        () => _i52.HealthSharingRemoteDataSource(gh<_i31.Dio>()));
    gh.factory<_i53.HealthSummaryDatasource>(
        () => _i53.HealthSummaryDatasource());
    gh.lazySingleton<_i54.HealthWrapper>(() => serviceModule.healthWrapper);
    gh.factory<_i55.HomeLocalDataSource>(
        () => _i55.HomeLocalDataSource(gh<_i56.SharedPreferences>()));
    gh.factory<_i57.HomeRemoteDataSource>(
        () => _i57.HomeRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i58.IAboutRepository>(
        () => _i59.AboutRepositoryImpl(gh<_i4.AboutLocalDataSource>()));
    gh.lazySingleton<_i60.ImagePickerService>(
        () => _i60.ImagePickerServiceImpl());
    gh.lazySingleton<_i61.IncentiveDatasource>(
        () => _i61.IncentiveDatasource());
    gh.lazySingleton<_i62.IncentiveRepository>(
        () => _i63.IncentiveRepositoryImpl(gh<_i61.IncentiveDatasource>()));
    gh.lazySingleton<_i64.IpfsDatasource>(
        () => _i64.IpfsDatasource(gh<_i31.Dio>()));
    await gh.factoryAsync<_i65.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i66.LicenseRegistryLocalDataSource>(() {
      final i = _i66.LicenseRegistryLocalDataSource(gh<_i65.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i67.LicenseVerifier>(() async =>
        _i67.LicenseVerifier(
            await getAsync<_i66.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i68.LlmAdapter>(
      () => _i69.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i68.LlmAdapter>(
      () => _i70.FlutterGemmaAdapter(wrapper: gh<_i45.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i71.LocalLlmService>(() => _i71.LocalLlmService());
    gh.lazySingleton<_i72.LocalModelLocalDataSource>(
        () => _i72.LocalModelLocalDataSource());
    gh.lazySingleton<_i73.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.lazySingleton<_i74.MedicalIdRepository>(
        () => _i75.IsarMedicalIdRepository(gh<_i65.Isar>()));
    gh.factory<_i76.MedicalKnowledgeRepository>(
      () => _i77.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i76.MedicalKnowledgeRepository>(
      () => _i78.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i79.MedicalScraperService>(
        () => _i80.MedicalScraperServiceImpl(
              gh<_i31.Dio>(),
              gh<_i18.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i81.MedicalStandardsService>(() =>
        _i82.MedicalStandardsServiceImpl(gh<_i73.MedicalContextProvider>()));
    gh.factory<_i83.MedicalTextNormalizationConfig>(
        () => _i83.MedicalTextNormalizationConfig(
              abbreviations: gh<Map<String, String>>(),
              stopWords: gh<List<String>>(),
            ));
    gh.factory<_i84.MedicalTextNormalizer>(() => _i84.MedicalTextNormalizer(
        config: gh<_i83.MedicalTextNormalizationConfig>()));
    gh.lazySingleton<_i85.MedicalWebSearchService>(
        () => _i86.MedicalWebSearchServiceImpl(gh<_i31.Dio>()));
    gh.lazySingleton<_i87.MedicationAdherenceRepository>(() =>
        _i88.SqliteMedicationAdherenceRepository(
            gh<_i5.AdherenceSqliteDatasource>()));
    gh.lazySingleton<_i89.MeditationLocalDataSource>(
        () => _i89.MeditationLocalDataSource());
    gh.lazySingleton<_i90.MeditationRepository>(() =>
        _i91.MeditationRepositoryImpl(gh<_i89.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i36.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i65.Isar>(),
        gh<_i36.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i92.MockReportGenerationService>(
      () => _i92.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i93.ModelDownloadService>(
        () => _i93.ModelDownloadService());
    gh.lazySingleton<_i94.NetworkDatasource>(
        () => _i94.NetworkDatasourceImpl(gh<_i31.Dio>()));
    gh.lazySingleton<_i95.NetworkP2PApi>(() => _i95.NetworkP2PApiImpl());
    gh.lazySingleton<_i96.NetworkPeerRepository>(
        () => _i97.NetworkPeerRepositoryImpl(gh<_i65.Isar>()));
    gh.lazySingleton<_i98.NetworkRepository>(
        () => _i99.NetworkRepositoryImpl(gh<_i94.NetworkDatasource>()));
    gh.lazySingleton<_i100.NfcHandler>(
        () => _i100.NfcHandler(channel: gh<_i101.MethodChannel>()));
    gh.lazySingleton<_i102.NfcSharingService>(
        () => _i102.NfcSharingService(gh<_i100.NfcHandler>()));
    gh.lazySingleton<_i103.NodeDiscoveryService>(
        () => _i104.NodeDiscoveryService());
    gh.lazySingleton<_i105.OcrService>(() => _i105.MlKitOcrService());
    gh.lazySingleton<_i106.PharmacyApiService>(
        () => _i107.RxNormApiService(gh<_i31.Dio>()));
    gh.lazySingleton<_i108.PromptScrubber>(
        () => _i108.PromptScrubber(gh<_i65.Isar>()));
    gh.lazySingleton<_i109.RatingRepository>(
        () => _i110.IsarRatingRepository(gh<_i65.Isar>()));
    gh.lazySingleton<_i111.RecommendScriptUseCase>(
        () => _i111.RecommendScriptUseCase(gh<_i90.MeditationRepository>()));
    gh.lazySingleton<_i112.ReportRepository>(
        () => _i113.IsarReportRepository(gh<_i65.Isar>()));
    gh.factory<_i114.RequestHealthAuthUseCase>(() =>
        _i114.RequestHealthAuthUseCase(gh<_i50.HealthDataImportService>()));
    gh.factory<_i115.SaveAppointmentUseCase>(
        () => _i115.SaveAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.factory<_i116.SaveReportUseCase>(
        () => _i116.SaveReportUseCase(gh<_i112.ReportRepository>()));
    gh.lazySingleton<_i117.SecondOpinionRepository>(
        () => _i118.IsarSecondOpinionRepository(gh<_i65.Isar>()));
    gh.lazySingleton<_i119.SecureStorageService>(
        () => _i119.SecureStorageServiceImpl(
              storage: gh<_i46.FlutterSecureStorage>(),
              capabilityService: gh<_i30.DeviceCapabilityService>(),
            ));
    gh.factory<_i120.SendChatMessageUseCase>(() => _i120.SendChatMessageUseCase(
          gh<_i68.LlmAdapter>(),
          gh<_i76.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i121.SensorApiDataSource>(
        () => _i121.SensorApiDataSourceImpl(gh<_i54.HealthWrapper>()));
    gh.lazySingleton<_i122.SensorHealthDataSource>(
        () => _i122.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i123.SettingsLocalDataSource>(
        () => _i123.SettingsLocalDataSource(gh<_i65.Isar>()));
    gh.lazySingleton<_i124.SettingsRepository>(() =>
        _i125.SettingsRepositoryImpl(gh<_i123.SettingsLocalDataSource>()));
    gh.lazySingleton<_i126.SharingRepository>(() =>
        _i127.HealthSharingRepositoryImpl(
            gh<_i51.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i128.StartSessionUseCase>(
        () => _i128.StartSessionUseCase(gh<_i90.MeditationRepository>()));
    gh.factory<_i129.SyncEmailAppointmentsUseCase>(
        () => _i129.SyncEmailAppointmentsUseCase(gh<_i34.EmailRepository>()));
    gh.lazySingleton<_i130.SyncRepository>(() => _i131.SyncRepositoryImpl(
          gh<_i41.FhirClient>(),
          gh<_i65.Isar>(),
          gh<_i46.FlutterSecureStorage>(),
          gh<_i103.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i73.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i132.UserProfileLocalDataSource>(
        () => _i132.UserProfileLocalDataSource(gh<_i65.Isar>()));
    gh.lazySingleton<_i133.UserProfileRepository>(
        () => _i134.UserProfileRepositoryImpl(gh<_i65.Isar>()));
    gh.lazySingleton<_i135.UserProfileService>(
        () => _i135.UserProfileService(gh<_i133.UserProfileRepository>()));
    gh.lazySingleton<_i136.VectorStoreService>(
        () => _i137.IsarVectorStoreService(
              gh<_i36.MemoryGraph>(),
              gh<_i76.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i138.VitalSignRepository>(
        () => _i139.VitalSignRepositoryImpl(gh<_i65.Isar>()));
    gh.factory<_i140.VitalsCubit>(
        () => _i140.VitalsCubit(gh<_i138.VitalSignRepository>()));
    gh.lazySingleton<_i141.VoiceChatRepository>(
        () => _i142.VoiceChatRepositoryImpl(gh<_i25.ChatAiDatasource>()));
    gh.lazySingleton<_i143.VouchRepository>(
        () => _i144.IsarVouchRepository(gh<_i65.Isar>()));
    gh.lazySingleton<_i40.WalletService>(() => databaseModule.walletService(
          gh<_i65.Isar>(),
          gh<_i40.EncryptionService>(),
        ));
    gh.lazySingleton<_i145.WifiDirectService>(() => _i145.WifiDirectService());
    gh.lazySingleton<_i146.WorkoutRepository>(
        () => _i147.WorkoutRepositoryImpl(gh<_i65.Isar>()));
    gh.factory<_i148.AboutCubit>(
        () => _i148.AboutCubit(gh<_i58.IAboutRepository>()));
    gh.lazySingleton<_i149.AboutRemoteDataSource>(
        () => _i149.AboutRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i150.AllergyLocalDataSource>(
        () => _i150.AllergyLocalDataSource(gh<_i65.Isar>()));
    gh.lazySingleton<_i151.AssessmentLocalDataSource>(
        () => _i151.AssessmentLocalDataSource(gh<_i65.Isar>()));
    gh.lazySingleton<_i152.AuthLocalDataSource>(
        () => _i152.AuthLocalDataSource(gh<_i65.Isar>()));
    gh.lazySingleton<_i153.AuthRepository>(() => _i154.AuthRepositoryImpl(
          gh<_i152.AuthLocalDataSource>(),
          gh<_i119.SecureStorageService>(),
        ));
    gh.lazySingleton<_i155.BleSharingService>(
        () => _i155.BleSharingService(gh<_i17.BleWrapper>()));
    gh.lazySingleton<_i156.CancelSharingUseCase>(
        () => _i156.CancelSharingUseCase(
              gh<_i155.BleSharingService>(),
              gh<_i102.NfcSharingService>(),
              gh<_i145.WifiDirectService>(),
            ));
    gh.lazySingleton<_i157.ChatMessageLocalDataSource>(
        () => _i157.ChatMessageLocalDataSource(gh<_i65.Isar>()));
    gh.factory<_i158.CheckSessionTimeoutUseCase>(
        () => _i158.CheckSessionTimeoutUseCase(gh<_i153.AuthRepository>()));
    gh.lazySingleton<_i159.CompleteSessionUseCase>(
        () => _i159.CompleteSessionUseCase(gh<_i90.MeditationRepository>()));
    gh.factory<_i129.ConnectEmailProviderUseCase>(
        () => _i129.ConnectEmailProviderUseCase(gh<_i34.EmailRepository>()));
    gh.lazySingleton<_i160.ConnectNode>(
        () => _i160.ConnectNode(gh<_i98.NetworkRepository>()));
    gh.lazySingleton<_i161.DashboardLocalDataSource>(
        () => _i161.DashboardLocalDataSource(gh<_i65.Isar>()));
    gh.lazySingleton<_i162.DataExportRepository>(
        () => _i163.IsarDataExportRepository(gh<_i65.Isar>()));
    gh.lazySingleton<_i164.DistributedStorageService>(() => _i165.IpfsService(
          gh<_i64.IpfsDatasource>(),
          gh<_i43.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i166.DoctorProfileRepository>(
        () => _i167.IsarDoctorProfileRepository(gh<_i65.Isar>()));
    gh.factoryAsync<_i168.DoctorVerificationCubit>(
        () async => _i168.DoctorVerificationCubit(
              gh<_i166.DoctorProfileRepository>(),
              gh<_i109.RatingRepository>(),
              await getAsync<_i67.LicenseVerifier>(),
            ));
    gh.lazySingleton<_i32.EcosystemRecordStore>(
        () => _i169.IsarEcosystemRecordStore(gh<_i65.Isar>()));
    gh.factory<_i170.EmailCitasBloc>(() => _i170.EmailCitasBloc(
          gh<_i129.ConnectEmailProviderUseCase>(),
          gh<_i129.SyncEmailAppointmentsUseCase>(),
          gh<_i34.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.factory<_i171.EmailCitasCubit>(() => _i171.EmailCitasCubit(
          gh<_i34.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i172.EncryptionService>(
        () => _i172.EncryptionService(gh<_i119.SecureStorageService>()));
    gh.lazySingleton<_i122.FileHealthDataSource>(
        () => _i122.FileHealthDataSourceImpl(
              gh<_i42.FilePickerService>(),
              gh<_i105.OcrService>(),
            ));
    gh.lazySingleton<_i173.FileImportDataSource>(
        () => _i173.FileImportDataSourceImpl(
              gh<_i42.FilePickerService>(),
              gh<_i105.OcrService>(),
            ));
    gh.factory<_i174.GetAboutInfoUseCase>(
        () => _i174.GetAboutInfoUseCase(gh<_i58.IAboutRepository>()));
    gh.factory<_i175.GetAllDoctorsUseCase>(
        () => _i175.GetAllDoctorsUseCase(gh<_i166.DoctorProfileRepository>()));
    gh.factory<_i176.GetAllVitalSignsUseCase>(
        () => _i176.GetAllVitalSignsUseCase(gh<_i138.VitalSignRepository>()));
    gh.factory<_i114.GetAvailableSourcesUseCase>(() =>
        _i114.GetAvailableSourcesUseCase(gh<_i50.HealthDataImportService>()));
    gh.factory<_i177.GetChatHistoryUseCase>(
        () => _i177.GetChatHistoryUseCase(gh<_i136.VectorStoreService>()));
    gh.factory<_i178.GetChatHistoryUseCase>(
        () => _i178.GetChatHistoryUseCase(gh<_i141.VoiceChatRepository>()));
    gh.factory<_i179.GetCredentialsUseCase>(
        () => _i179.GetCredentialsUseCase(gh<_i153.AuthRepository>()));
    gh.factory<_i180.GetDoctorProfileUseCase>(() =>
        _i180.GetDoctorProfileUseCase(gh<_i166.DoctorProfileRepository>()));
    gh.lazySingleton<_i181.GetNetworkHealth>(
        () => _i181.GetNetworkHealth(gh<_i98.NetworkRepository>()));
    gh.lazySingleton<_i182.GetNodeStats>(
        () => _i182.GetNodeStats(gh<_i98.NetworkRepository>()));
    gh.lazySingleton<_i183.GetProgressUseCase>(
        () => _i183.GetProgressUseCase(gh<_i90.MeditationRepository>()));
    gh.factory<_i184.GetReportsUseCase>(
        () => _i184.GetReportsUseCase(gh<_i112.ReportRepository>()));
    gh.lazySingleton<_i185.GetScriptsUseCase>(
        () => _i185.GetScriptsUseCase(gh<_i90.MeditationRepository>()));
    gh.factory<_i186.GetUserProfileUseCase>(
        () => _i186.GetUserProfileUseCase(gh<_i133.UserProfileRepository>()));
    gh.lazySingleton<_i187.GovernanceIpfsDatasource>(
        () => _i187.GovernanceIpfsDatasource(gh<_i64.IpfsDatasource>()));
    gh.lazySingleton<_i188.GovernanceRepository>(() =>
        _i189.GovernanceRepositoryImpl(gh<_i187.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i190.HealthConnectDataSource>(
        () => _i190.HealthConnectDataSourceImpl(gh<_i54.HealthWrapper>()));
    gh.lazySingleton<_i191.HealthDataImportRepository>(
        () => _i192.HealthDataImportRepositoryImpl(
              gh<_i122.SensorHealthDataSource>(),
              gh<_i122.FileHealthDataSource>(),
            ));
    gh.lazySingleton<_i193.HealthRecordRepository>(
        () => _i194.HealthRecordRepositoryImpl(gh<_i65.Isar>()));
    gh.lazySingleton<_i195.IAssessmentRepository>(
        () => _i196.AssessmentRepositoryImpl(gh<_i65.Isar>()));
    gh.factory<_i197.ImportCalendarUseCase>(() => _i197.ImportCalendarUseCase(
          gh<_i21.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i133.UserProfileRepository>(),
        ));
    gh.factory<_i114.ImportHealthDataUseCase>(
        () => _i114.ImportHealthDataUseCase(
              gh<_i50.HealthDataImportService>(),
              gh<_i138.VitalSignRepository>(),
            ));
    gh.factory<_i68.LlmAdapter>(
      () => _i198.MockLlmAdapter(gh<_i108.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i68.LlmAdapter>(
      () => _i199.GeminiLlmAdapter(
        scrubber: gh<_i108.PromptScrubber>(),
        userProfileRepository: gh<_i133.UserProfileRepository>(),
        modelWrapper: gh<_i47.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i200.LlmAdapterFactory>(
        () => _i200.LlmAdapterFactory(gh<_i124.SettingsRepository>()));
    gh.lazySingleton<_i201.LlmService>(() => _i202.GemmaLlmService(
          gh<_i136.VectorStoreService>(),
          gh<_i133.UserProfileRepository>(),
          gh<_i68.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i203.LlmSettingsCubit>(() => _i203.LlmSettingsCubit(
          gh<_i124.SettingsRepository>(),
          gh<_i29.DeviceCapabilityService>(),
          gh<_i68.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i204.LoginUseCase>(() => _i204.LoginUseCase(
          gh<_i153.AuthRepository>(),
          gh<_i172.EncryptionService>(),
          gh<_i16.BiometricService>(),
        ));
    gh.factory<_i205.LogoutUseCase>(
        () => _i205.LogoutUseCase(gh<_i153.AuthRepository>()));
    gh.lazySingleton<_i206.MedicalResearchService>(
        () => _i206.MedicalResearchService(
              gh<_i85.MedicalWebSearchService>(),
              gh<_i79.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i207.MedicationRepository>(
        () => _i208.IsarMedicationRepository(
              gh<_i65.Isar>(),
              gh<_i106.PharmacyApiService>(),
            ));
    gh.factory<_i209.MedicationsCubit>(
        () => _i209.MedicationsCubit(gh<_i207.MedicationRepository>()));
    gh.factory<_i210.MeditationCubit>(() => _i210.MeditationCubit(
          gh<_i111.RecommendScriptUseCase>(),
          gh<_i128.StartSessionUseCase>(),
          gh<_i159.CompleteSessionUseCase>(),
          gh<_i183.GetProgressUseCase>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i211.NetworkCubit>(() => _i211.NetworkCubit(
          gh<_i96.NetworkPeerRepository>(),
          gh<_i95.NetworkP2PApi>(),
        ));
    gh.factory<_i212.NetworkHealthCubit>(() => _i212.NetworkHealthCubit(
          gh<_i181.GetNetworkHealth>(),
          gh<_i160.ConnectNode>(),
          gh<_i98.NetworkRepository>(),
        ));
    gh.lazySingleton<_i213.OnboardingRepository>(() =>
        _i214.OnboardingRepositoryImpl(gh<_i133.UserProfileRepository>()));
    gh.lazySingleton<_i215.PhiAuditService>(
        () => _i215.PhiAuditService(gh<_i119.SecureStorageService>()));
    gh.lazySingleton<_i216.ReportGenerationService>(
        () => _i217.GemmaReportGenerationService(
              gh<_i68.LlmAdapter>(instanceName: 'gemma'),
              gh<_i136.VectorStoreService>(),
              gh<_i133.UserProfileRepository>(),
              gh<_i108.PromptScrubber>(),
            ));
    gh.lazySingleton<_i218.RightToErasureRepository>(
        () => _i219.IsarRightToErasureRepository(
              gh<_i65.Isar>(),
              gh<_i119.SecureStorageService>(),
            ));
    gh.factory<_i220.SaveCredentialsUseCase>(
        () => _i220.SaveCredentialsUseCase(gh<_i153.AuthRepository>()));
    gh.factory<_i221.SaveMedicationUseCase>(
        () => _i221.SaveMedicationUseCase(gh<_i207.MedicationRepository>()));
    gh.factory<_i222.SaveRecordUseCase>(
        () => _i222.SaveRecordUseCase(gh<_i193.HealthRecordRepository>()));
    gh.factory<_i223.SaveUserProfileUseCase>(
        () => _i223.SaveUserProfileUseCase(gh<_i133.UserProfileRepository>()));
    gh.factory<_i224.SaveVitalSignsUseCase>(
        () => _i224.SaveVitalSignsUseCase(gh<_i138.VitalSignRepository>()));
    gh.factory<_i225.SecondOpinionCubit>(
        () => _i225.SecondOpinionCubit(gh<_i117.SecondOpinionRepository>()));
    gh.factory<_i226.SendMessageUseCase>(
        () => _i226.SendMessageUseCase(gh<_i141.VoiceChatRepository>()));
    gh.factory<_i227.SetPinUseCase>(() => _i227.SetPinUseCase(
          gh<_i153.AuthRepository>(),
          gh<_i172.EncryptionService>(),
        ));
    gh.lazySingleton<_i228.SmartSearchUseCase>(
        () => _i228.SmartSearchUseCase(gh<_i136.VectorStoreService>()));
    gh.lazySingleton<_i229.StartListeningUseCase>(
        () => _i229.StartListeningUseCase(
              gh<_i155.BleSharingService>(),
              gh<_i102.NfcSharingService>(),
              gh<_i145.WifiDirectService>(),
            ));
    gh.lazySingleton<_i230.StartSharingUseCase>(() => _i230.StartSharingUseCase(
          gh<_i155.BleSharingService>(),
          gh<_i102.NfcSharingService>(),
          gh<_i145.WifiDirectService>(),
        ));
    gh.factory<_i231.SyncCubit>(() => _i231.SyncCubit(
          gh<_i73.SyncService>(),
          gh<_i136.VectorStoreService>(),
        ));
    gh.lazySingleton<_i232.SyncService>(() => _i233.SyncServiceImpl(
          gh<_i130.SyncRepository>(),
          gh<_i73.SyncService>(),
        ));
    gh.factory<_i234.UserProfileCubit>(
        () => _i234.UserProfileCubit(gh<_i133.UserProfileRepository>()));
    gh.factory<_i235.ValidateSessionUseCase>(
        () => _i235.ValidateSessionUseCase(gh<_i153.AuthRepository>()));
    gh.factory<_i236.VitalSignBloc>(
        () => _i236.VitalSignBloc(gh<_i138.VitalSignRepository>()));
    gh.factory<_i237.VoiceChatCubit>(() => _i237.VoiceChatCubit(
          gh<_i226.SendMessageUseCase>(),
          gh<_i178.GetChatHistoryUseCase>(),
          gh<_i141.VoiceChatRepository>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i238.VouchCubit>(
        () => _i238.VouchCubit(gh<_i143.VouchRepository>()));
    gh.lazySingleton<_i239.WorkoutFhirExportService>(
        () => _i239.WorkoutFhirExportService(gh<_i146.WorkoutRepository>()));
    gh.lazySingleton<_i240.AllergyRepository>(() => _i241.AllergyRepositoryImpl(
          gh<_i150.AllergyLocalDataSource>(),
          encryptionService: gh<_i172.EncryptionService>(),
        ));
    gh.factory<_i242.AuthCubit>(() => _i242.AuthCubit(
          gh<_i153.AuthRepository>(),
          gh<_i16.BiometricService>(),
          gh<_i204.LoginUseCase>(),
          gh<_i205.LogoutUseCase>(),
          gh<_i235.ValidateSessionUseCase>(),
          gh<_i227.SetPinUseCase>(),
          gh<_i158.CheckSessionTimeoutUseCase>(),
        ));
    gh.lazySingleton<_i243.AuthService>(
        () => _i243.AuthServiceImpl(gh<_i172.EncryptionService>()));
    gh.lazySingleton<_i244.BadgeCalculator>(() => _i244.BadgeCalculator(
          gh<_i166.DoctorProfileRepository>(),
          gh<_i109.RatingRepository>(),
          gh<_i143.VouchRepository>(),
        ));
    gh.factory<_i245.BadgeCubit>(
        () => _i245.BadgeCubit(gh<_i244.BadgeCalculator>()));
    gh.factory<_i246.CalendarImportCubit>(() => _i246.CalendarImportCubit(
          gh<_i21.CalendarImportRepository>(),
          gh<_i197.ImportCalendarUseCase>(),
        ));
    gh.factory<_i247.ClinicalAssessmentsCubit>(() =>
        _i247.ClinicalAssessmentsCubit(gh<_i195.IAssessmentRepository>()));
    gh.factory<_i248.CompleteOnboardingUseCase>(() =>
        _i248.CompleteOnboardingUseCase(gh<_i213.OnboardingRepository>()));
    gh.lazySingleton<_i249.DashboardRepository>(
        () => _i250.DashboardRepositoryImpl(
              gh<_i27.DashboardRemoteDataSource>(),
              gh<_i138.VitalSignRepository>(),
              gh<_i207.MedicationRepository>(),
              gh<_i112.ReportRepository>(),
            ));
    gh.lazySingleton<_i251.DataSourceRepository>(
        () => _i252.DataSourceRepositoryImpl(
              gh<_i121.SensorApiDataSource>(),
              gh<_i173.FileImportDataSource>(),
              gh<_i190.HealthConnectDataSource>(),
            ));
    gh.lazySingleton<_i253.DietaryProfileExportService>(
        () => _i253.DietaryProfileExportService(
              gh<_i240.AllergyRepository>(),
              gh<_i133.UserProfileRepository>(),
              gh<_i32.EcosystemSubjectStore>(),
            ));
    gh.lazySingleton<_i254.DistributedCacheUsecase>(() =>
        _i254.DistributedCacheUsecase(gh<_i164.DistributedStorageService>()));
    gh.lazySingleton<_i32.EcosystemImportService>(
        () => _i32.EcosystemImportService(
              gh<_i32.EcosystemSubjectStore>(),
              gh<_i32.EcosystemRecordStore>(),
            ));
    gh.factory<_i255.FhirSyncCubit>(() => _i255.FhirSyncCubit(
          gh<_i232.SyncService>(),
          gh<_i103.NodeDiscoveryService>(),
        ));
    gh.factory<_i256.GetAllMedicationsUseCase>(
        () => _i256.GetAllMedicationsUseCase(gh<_i207.MedicationRepository>()));
    gh.factory<_i257.GetAllRecordsUseCase>(
        () => _i257.GetAllRecordsUseCase(gh<_i193.HealthRecordRepository>()));
    gh.factory<_i258.GetAllergiesUseCase>(
        () => _i258.GetAllergiesUseCase(gh<_i240.AllergyRepository>()));
    gh.factory<_i259.GetDashboardStatsUseCase>(
        () => _i259.GetDashboardStatsUseCase(gh<_i249.DashboardRepository>()));
    gh.factory<_i260.GetOnboardingProfileUseCase>(() =>
        _i260.GetOnboardingProfileUseCase(gh<_i213.OnboardingRepository>()));
    gh.factory<_i261.GetRecentActivityUseCase>(
        () => _i261.GetRecentActivityUseCase(gh<_i249.DashboardRepository>()));
    gh.factory<_i262.HealthImportBloc>(() => _i262.HealthImportBloc(
          gh<_i114.GetAvailableSourcesUseCase>(),
          gh<_i114.RequestHealthAuthUseCase>(),
          gh<_i114.ImportHealthDataUseCase>(),
        ));
    gh.factory<_i263.HealthImportCubit>(() => _i263.HealthImportCubit(
          gh<_i114.GetAvailableSourcesUseCase>(),
          gh<_i114.RequestHealthAuthUseCase>(),
          gh<_i114.ImportHealthDataUseCase>(),
        ));
    gh.factory<_i264.HealthRecordCubit>(() => _i264.HealthRecordCubit(
          gh<_i193.HealthRecordRepository>(),
          gh<_i42.FilePickerService>(),
          gh<_i60.ImagePickerService>(),
          gh<_i105.OcrService>(),
          gh<_i136.VectorStoreService>(),
        ));
    gh.lazySingleton<_i265.HomeRepository>(() => _i266.HomeRepositoryImpl(
          gh<_i138.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i207.MedicationRepository>(),
          gh<_i55.HomeLocalDataSource>(),
          gh<_i57.HomeRemoteDataSource>(),
          gh<_i53.HealthSummaryDatasource>(),
        ));
    gh.lazySingleton<_i201.LlmService>(
      () => _i267.RagLlmService(
        gh<_i136.VectorStoreService>(),
        gh<_i206.MedicalResearchService>(),
        gh<_i133.UserProfileRepository>(),
        gh<_i68.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i268.MedicalResearchRepository>(
        () => _i269.MedicalResearchRepositoryImpl(
              gh<_i206.MedicalResearchService>(),
              gh<_i65.Isar>(),
            ));
    gh.factory<_i270.MedicationBloc>(
        () => _i270.MedicationBloc(gh<_i207.MedicationRepository>()));
    gh.factory<_i271.OnboardingCubit>(
        () => _i271.OnboardingCubit(gh<_i213.OnboardingRepository>()));
    gh.lazySingleton<_i272.PatientContextIndexer>(
      () => _i272.PatientContextIndexer(
        gh<_i65.Isar>(),
        gh<_i136.VectorStoreService>(),
        gh<_i193.HealthRecordRepository>(),
        gh<_i207.MedicationRepository>(),
        gh<_i240.AllergyRepository>(),
        gh<_i138.VitalSignRepository>(),
        gh<_i8.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i273.ReportBloc>(() => _i273.ReportBloc(
          gh<_i112.ReportRepository>(),
          gh<_i216.ReportGenerationService>(),
        ));
    gh.factory<_i274.SaveAllergyUseCase>(
        () => _i274.SaveAllergyUseCase(gh<_i240.AllergyRepository>()));
    gh.factory<_i275.SearchMedicalResearch>(() =>
        _i275.SearchMedicalResearch(gh<_i268.MedicalResearchRepository>()));
    gh.factory<_i276.SharingCubit>(() => _i276.SharingCubit(
          bleService: gh<_i155.BleSharingService>(),
          nfcService: gh<_i102.NfcSharingService>(),
          wifiService: gh<_i145.WifiDirectService>(),
          startSharingUseCase: gh<_i230.StartSharingUseCase>(),
          startListeningUseCase: gh<_i229.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i156.CancelSharingUseCase>(),
          walletService: gh<_i40.WalletService>(),
          walletEncryption: gh<_i40.EncryptionService>(),
        ));
    gh.factory<_i277.AllergiesCubit>(
        () => _i277.AllergiesCubit(gh<_i240.AllergyRepository>()));
    gh.factory<_i278.AllergyBloc>(
        () => _i278.AllergyBloc(gh<_i240.AllergyRepository>()));
    gh.factory<_i279.AuthCubit>(() => _i279.AuthCubit(gh<_i243.AuthService>()));
    gh.factory<_i280.DashboardCubit>(() => _i280.DashboardCubit(
          gh<_i259.GetDashboardStatsUseCase>(),
          gh<_i261.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i281.DataSourceCubit>(
        () => _i281.DataSourceCubit(gh<_i251.DataSourceRepository>()));
    gh.factory<_i282.GetHealthSummaryUseCase>(
        () => _i282.GetHealthSummaryUseCase(gh<_i265.HomeRepository>()));
    gh.factory<_i283.GetResearchHistory>(
        () => _i283.GetResearchHistory(gh<_i268.MedicalResearchRepository>()));
    gh.factory<_i284.HomeCubit>(() => _i284.HomeCubit(
          gh<_i282.GetHealthSummaryUseCase>(),
          gh<_i265.HomeRepository>(),
        ));
    gh.lazySingleton<_i285.MedicalIndexingService>(
        () => _i285.MedicalIndexingService(
              gh<_i76.MedicalKnowledgeRepository>(),
              gh<_i136.VectorStoreService>(),
              gh<_i272.PatientContextIndexer>(),
            ));
    gh.factory<_i286.MedicalResearchCubit>(() => _i286.MedicalResearchCubit(
          gh<_i275.SearchMedicalResearch>(),
          gh<_i283.GetResearchHistory>(),
          gh<_i81.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i287.ServiceModule {}

class _$NetworkModule extends _i288.NetworkModule {}

class _$MemoryModule extends _i289.MemoryModule {}

class _$DatabaseModule extends _i290.DatabaseModule {}

class _$FhirModule extends _i291.FhirModule {}
