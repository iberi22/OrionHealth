// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i19;
import 'package:dio/dio.dart' as _i30;
import 'package:flutter/services.dart' as _i88;
import 'package:flutter_appauth/flutter_appauth.dart' as _i39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i41;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i43;
import 'package:health_wallet/health_wallet.dart' as _i34;
import 'package:http/http.dart' as _i25;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i59;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i33;
import 'package:just_audio/just_audio.dart' as _i13;
import 'package:medical_standards/medical_standards.dart' as _i67;
import 'package:shared_preferences/shared_preferences.dart' as _i50;

import '../../features/about/application/about_cubit.dart' as _i134;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i52;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i158;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i135;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i53;
import '../../features/allergies/application/allergies_cubit.dart' as _i218;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i219;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
    as _i136;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i138;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i137;
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/domain/usecases/get_allergies_usecase.dart'
    as _i161;
import '../../features/allergies/domain/usecases/save_allergy_usecase.dart'
    as _i200;
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
    as _i105;
import '../../features/auth/application/auth_cubit.dart' as _i221;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i220;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i139;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i141;
import '../../features/auth/domain/auth_service.dart' as _i142;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i140;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i165;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i201;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i15;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i35;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i224;
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i20;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i22;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i182;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i18;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i21;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i23;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i249;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i226;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i234;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i236;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
    as _i149;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i26;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i227;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i223;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i155;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i206;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i217;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i153;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i99;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i107;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i131;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i222;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i61;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
    as _i159;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i166;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i60;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i154;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i100;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i108;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i132;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i156;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i157;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i31;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i117;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i32;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i229;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i230;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i93;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i148;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i150;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i164;
import '../../features/eps_connection/infrastructure/datasources/oauth_local_datasource.dart'
    as _i92;
import '../../features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart'
    as _i94;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i178;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i179;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i176;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i45;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i104;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i110;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i177;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i237;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i180;
import '../../features/health_record/domain/usecases/get_all_records_usecase.dart'
    as _i233;
import '../../features/health_record/domain/usecases/save_record_usecase.dart'
    as _i203;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i181;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i37;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i54;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i95;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i248;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i114;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i144;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i209;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i210;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i143;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i16;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i46;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart'
    as _i47;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i87;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i89;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i115;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i133;
import '../../features/home/application/home_cubit.dart' as _i252;
import '../../features/home/domain/repositories/home_repository.dart' as _i238;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i250;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i48;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i49;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i51;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i239;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i208;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i145;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i66;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i68;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i62;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i124;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i162;
import '../../features/local_agent/domain/usecases/send_chat_message_usecase.dart'
    as _i109;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i63;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i40;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i184;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i42;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i183;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i64;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i187;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i186;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i240;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i69;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i70;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i125;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i185;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i65;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i241;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i83;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i197;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i253;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i242;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i71;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i73;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i75;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i251;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i247;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i17;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i189;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i72;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i74;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i76;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
    as _i243;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i244;
import '../../features/medications/application/medications_cubit.dart' as _i192;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i77;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i190;
import '../../features/medications/domain/usecases/get_all_medications_usecase.dart'
    as _i232;
import '../../features/medications/domain/usecases/save_medication_usecase.dart'
    as _i202;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i191;
import '../../features/medications/infrastructure/repositories/sqlite_medication_adherence_repository.dart'
    as _i78;
import '../../features/medications/infrastructure/services/pharmacy_api_service.dart'
    as _i96;
import '../../features/medications/infrastructure/services/rxnorm_api_service.dart'
    as _i97;
import '../../features/meditation/application/meditation_cubit.dart' as _i193;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i80;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i146;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i169;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i171;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i101;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i116;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i79;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i81;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i174;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i173;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i175;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i56;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i55;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i57;
import '../../features/network/network_health/application/network_health_cubit.dart'
    as _i194;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i85;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i147;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i167;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i168;
import '../../features/network/network_health/infrastructure/datasources/network_datasource.dart'
    as _i84;
import '../../features/network/network_health/infrastructure/repositories/network_repository_impl.dart'
    as _i86;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i245;
import '../../features/onboarding/application/sync_cubit.dart' as _i211;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i195;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i225;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i235;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i196;
import '../../features/reports/application/bloc/report_bloc.dart' as _i246;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i102;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i198;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i170;
import '../../features/reports/domain/usecases/save_report_usecase.dart'
    as _i106;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i103;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i199;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i82;
import '../../features/settings/application/llm_settings_cubit.dart' as _i188;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i112;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i28;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i111;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i113;
import '../../features/sync/application/sync_cubit.dart' as _i231;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i118;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i151;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i90;
import '../../features/sync/domain/services/sync_service.dart' as _i212;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i228;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i38;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i58;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i119;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i36;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i152;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i91;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i213;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i214;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i120;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i121;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i123;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i172;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
    as _i204;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i122;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i215;
import '../../features/vitals/application/vitals_cubit.dart' as _i128;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i126;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i160;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
    as _i205;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i127;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i216;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i129;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i163;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i207;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i24;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i130;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i11;
import '../services/audio/audio_player_service.dart' as _i12;
import '../services/audio/audio_recorder_service.dart' as _i14;
import '../services/device_capability_service.dart' as _i29;
import '../services/privacy_anonymizer.dart' as _i98;
import 'database_module.dart' as _i257;
import 'fhir_module.dart' as _i258;
import 'memory_module.dart' as _i256;
import 'network_module.dart' as _i255;
import 'service_module.dart' as _i254;

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
    gh.lazySingleton<_i34.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i35.EncryptionService>(() => _i35.EncryptionService());
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
        () => _i58.IpfsDatasource(gh<_i30.Dio>()));
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
      () => _i63.FlutterGemmaAdapter(wrapper: gh<_i40.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i62.LlmAdapter>(
      () => _i64.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
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
              gh<_i30.Dio>(),
              gh<_i17.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i73.MedicalStandardsService>(() =>
        _i74.MedicalStandardsServiceImpl(gh<_i67.MedicalContextProvider>()));
    gh.lazySingleton<_i75.MedicalWebSearchService>(
        () => _i76.MedicalWebSearchServiceImpl(gh<_i30.Dio>()));
    gh.lazySingleton<_i77.MedicationAdherenceRepository>(() =>
        _i78.SqliteMedicationAdherenceRepository(
            gh<_i5.AdherenceSqliteDatasource>()));
    gh.lazySingleton<_i79.MeditationLocalDataSource>(
        () => _i79.MeditationLocalDataSource());
    gh.lazySingleton<_i80.MeditationRepository>(() =>
        _i81.MeditationRepositoryImpl(gh<_i79.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i33.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i59.Isar>(),
        gh<_i33.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i82.MockReportGenerationService>(
      () => _i82.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i83.ModelDownloadService>(
        () => _i83.ModelDownloadService());
    gh.lazySingleton<_i84.NetworkDatasource>(
        () => _i84.NetworkDatasourceImpl());
    gh.lazySingleton<_i85.NetworkRepository>(
        () => _i86.NetworkRepositoryImpl(gh<_i84.NetworkDatasource>()));
    gh.lazySingleton<_i87.NfcHandler>(
        () => _i87.NfcHandler(channel: gh<_i88.MethodChannel>()));
    gh.lazySingleton<_i89.NfcSharingService>(
        () => _i89.NfcSharingService(gh<_i87.NfcHandler>()));
    gh.lazySingleton<_i90.NodeDiscoveryService>(
        () => _i91.NodeDiscoveryService());
    gh.lazySingleton<_i92.OAuthLocalDataSource>(
        () => _i92.OAuthLocalDataSource(gh<_i41.FlutterSecureStorage>()));
    gh.lazySingleton<_i93.OAuthRepository>(() => _i94.OAuthRepositoryImpl(
          gh<_i92.OAuthLocalDataSource>(),
          gh<_i30.Dio>(),
          gh<_i39.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i95.OcrService>(() => _i95.MlKitOcrService());
    gh.lazySingleton<_i96.PharmacyApiService>(
        () => _i97.RxNormApiService(gh<_i30.Dio>()));
    gh.lazySingleton<_i98.PromptScrubber>(
        () => _i98.PromptScrubber(gh<_i59.Isar>()));
    gh.lazySingleton<_i99.RatingRepository>(
        () => _i100.IsarRatingRepository(gh<_i59.Isar>()));
    gh.lazySingleton<_i101.RecommendScriptUseCase>(
        () => _i101.RecommendScriptUseCase(gh<_i80.MeditationRepository>()));
    gh.lazySingleton<_i102.ReportRepository>(
        () => _i103.IsarReportRepository(gh<_i59.Isar>()));
    gh.factory<_i104.RequestHealthAuthUseCase>(() =>
        _i104.RequestHealthAuthUseCase(gh<_i45.HealthDataImportService>()));
    gh.factory<_i105.SaveAppointmentUseCase>(
        () => _i105.SaveAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.factory<_i106.SaveReportUseCase>(
        () => _i106.SaveReportUseCase(gh<_i102.ReportRepository>()));
    gh.lazySingleton<_i107.SecondOpinionRepository>(
        () => _i108.IsarSecondOpinionRepository(gh<_i59.Isar>()));
    gh.factory<_i109.SendChatMessageUseCase>(() => _i109.SendChatMessageUseCase(
          gh<_i62.LlmAdapter>(),
          gh<_i68.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i110.SensorHealthDataSource>(
        () => _i110.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i111.SettingsLocalDataSource>(
        () => _i111.SettingsLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i112.SettingsRepository>(() =>
        _i113.SettingsRepositoryImpl(gh<_i111.SettingsLocalDataSource>()));
    gh.lazySingleton<_i114.SharingRepository>(() =>
        _i115.HealthSharingRepositoryImpl(
            gh<_i46.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i116.StartSessionUseCase>(
        () => _i116.StartSessionUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i117.SyncEmailAppointmentsUseCase>(
        () => _i117.SyncEmailAppointmentsUseCase(gh<_i31.EmailRepository>()));
    gh.lazySingleton<_i118.SyncRepository>(() => _i119.SyncRepositoryImpl(
          gh<_i36.FhirClient>(),
          gh<_i59.Isar>(),
          gh<_i41.FlutterSecureStorage>(),
          gh<_i90.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i67.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i120.UserProfileLocalDataSource>(
        () => _i120.UserProfileLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i121.UserProfileRepository>(
        () => _i122.UserProfileRepositoryImpl(gh<_i59.Isar>()));
    gh.lazySingleton<_i123.UserProfileService>(
        () => _i123.UserProfileService(gh<_i121.UserProfileRepository>()));
    gh.lazySingleton<_i124.VectorStoreService>(
        () => _i125.IsarVectorStoreService(
              gh<_i33.MemoryGraph>(),
              gh<_i68.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i126.VitalSignRepository>(
        () => _i127.VitalSignRepositoryImpl(gh<_i59.Isar>()));
    gh.factory<_i128.VitalsCubit>(
        () => _i128.VitalsCubit(gh<_i126.VitalSignRepository>()));
    gh.lazySingleton<_i129.VoiceChatRepository>(
        () => _i130.VoiceChatRepositoryImpl(gh<_i24.ChatAiDatasource>()));
    gh.lazySingleton<_i131.VouchRepository>(
        () => _i132.IsarVouchRepository(gh<_i59.Isar>()));
    gh.lazySingleton<_i34.WalletService>(() => databaseModule.walletService(
          gh<_i59.Isar>(),
          gh<_i34.EncryptionService>(),
        ));
    gh.lazySingleton<_i133.WifiDirectService>(() => _i133.WifiDirectService());
    gh.factory<_i134.AboutCubit>(
        () => _i134.AboutCubit(gh<_i52.IAboutRepository>()));
    gh.lazySingleton<_i135.AboutRemoteDataSource>(
        () => _i135.AboutRemoteDataSource(gh<_i30.Dio>()));
    gh.lazySingleton<_i136.AllergyLocalDataSource>(
        () => _i136.AllergyLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i137.AllergyRepository>(
        () => _i138.AllergyRepositoryImpl(gh<_i136.AllergyLocalDataSource>()));
    gh.lazySingleton<_i139.AuthLocalDataSource>(
        () => _i139.AuthLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i140.AuthRepository>(
        () => _i141.AuthRepositoryImpl(gh<_i139.AuthLocalDataSource>()));
    gh.lazySingleton<_i142.AuthService>(
        () => _i142.AuthServiceImpl(gh<_i35.EncryptionService>()));
    gh.lazySingleton<_i143.BleSharingService>(
        () => _i143.BleSharingService(gh<_i16.BleWrapper>()));
    gh.lazySingleton<_i144.CancelSharingUseCase>(
        () => _i144.CancelSharingUseCase(
              gh<_i143.BleSharingService>(),
              gh<_i89.NfcSharingService>(),
              gh<_i133.WifiDirectService>(),
            ));
    gh.lazySingleton<_i145.ChatMessageLocalDataSource>(
        () => _i145.ChatMessageLocalDataSource(gh<_i59.Isar>()));
    gh.lazySingleton<_i146.CompleteSessionUseCase>(
        () => _i146.CompleteSessionUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i117.ConnectEmailProviderUseCase>(
        () => _i117.ConnectEmailProviderUseCase(gh<_i31.EmailRepository>()));
    gh.lazySingleton<_i147.ConnectNode>(
        () => _i147.ConnectNode(gh<_i85.NetworkRepository>()));
    gh.factory<_i148.ConnectProviderUseCase>(() => _i148.ConnectProviderUseCase(
          gh<_i93.OAuthRepository>(),
          gh<_i121.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i149.DashboardLocalDataSource>(
        () => _i149.DashboardLocalDataSource(gh<_i59.Isar>()));
    gh.factory<_i150.DisconnectProviderUseCase>(
        () => _i150.DisconnectProviderUseCase(
              gh<_i93.OAuthRepository>(),
              gh<_i121.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i151.DistributedStorageService>(() => _i152.IpfsService(
          gh<_i58.IpfsDatasource>(),
          gh<_i38.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i153.DoctorProfileRepository>(
        () => _i154.IsarDoctorProfileRepository(gh<_i59.Isar>()));
    gh.factoryAsync<_i155.DoctorVerificationCubit>(
        () async => _i155.DoctorVerificationCubit(
              gh<_i153.DoctorProfileRepository>(),
              gh<_i99.RatingRepository>(),
              await getAsync<_i61.LicenseVerifier>(),
            ));
    gh.factory<_i156.EmailCitasBloc>(() => _i156.EmailCitasBloc(
          gh<_i117.ConnectEmailProviderUseCase>(),
          gh<_i117.SyncEmailAppointmentsUseCase>(),
          gh<_i31.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.factory<_i157.EmailCitasCubit>(() => _i157.EmailCitasCubit(
          gh<_i31.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i110.FileHealthDataSource>(
        () => _i110.FileHealthDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i95.OcrService>(),
            ));
    gh.factory<_i158.GetAboutInfoUseCase>(
        () => _i158.GetAboutInfoUseCase(gh<_i52.IAboutRepository>()));
    gh.factory<_i159.GetAllDoctorsUseCase>(
        () => _i159.GetAllDoctorsUseCase(gh<_i153.DoctorProfileRepository>()));
    gh.factory<_i160.GetAllVitalSignsUseCase>(
        () => _i160.GetAllVitalSignsUseCase(gh<_i126.VitalSignRepository>()));
    gh.factory<_i161.GetAllergiesUseCase>(
        () => _i161.GetAllergiesUseCase(gh<_i137.AllergyRepository>()));
    gh.factory<_i104.GetAvailableSourcesUseCase>(() =>
        _i104.GetAvailableSourcesUseCase(gh<_i45.HealthDataImportService>()));
    gh.factory<_i162.GetChatHistoryUseCase>(
        () => _i162.GetChatHistoryUseCase(gh<_i124.VectorStoreService>()));
    gh.factory<_i163.GetChatHistoryUseCase>(
        () => _i163.GetChatHistoryUseCase(gh<_i129.VoiceChatRepository>()));
    gh.factory<_i164.GetConnectionsUseCase>(
        () => _i164.GetConnectionsUseCase(gh<_i93.OAuthRepository>()));
    gh.factory<_i165.GetCredentialsUseCase>(
        () => _i165.GetCredentialsUseCase(gh<_i140.AuthRepository>()));
    gh.factory<_i166.GetDoctorProfileUseCase>(() =>
        _i166.GetDoctorProfileUseCase(gh<_i153.DoctorProfileRepository>()));
    gh.lazySingleton<_i167.GetNetworkHealth>(
        () => _i167.GetNetworkHealth(gh<_i85.NetworkRepository>()));
    gh.lazySingleton<_i168.GetNodeStats>(
        () => _i168.GetNodeStats(gh<_i85.NetworkRepository>()));
    gh.lazySingleton<_i169.GetProgressUseCase>(
        () => _i169.GetProgressUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i170.GetReportsUseCase>(
        () => _i170.GetReportsUseCase(gh<_i102.ReportRepository>()));
    gh.lazySingleton<_i171.GetScriptsUseCase>(
        () => _i171.GetScriptsUseCase(gh<_i80.MeditationRepository>()));
    gh.factory<_i172.GetUserProfileUseCase>(
        () => _i172.GetUserProfileUseCase(gh<_i121.UserProfileRepository>()));
    gh.lazySingleton<_i173.GovernanceIpfsDatasource>(
        () => _i173.GovernanceIpfsDatasource(gh<_i58.IpfsDatasource>()));
    gh.lazySingleton<_i174.GovernanceRepository>(() =>
        _i175.GovernanceRepositoryImpl(gh<_i173.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i176.HealthDataImportRepository>(
        () => _i177.HealthDataImportRepositoryImpl(
              gh<_i110.SensorHealthDataSource>(),
              gh<_i110.FileHealthDataSource>(),
            ));
    gh.factory<_i178.HealthImportBloc>(() => _i178.HealthImportBloc(
          gh<_i104.GetAvailableSourcesUseCase>(),
          gh<_i104.RequestHealthAuthUseCase>(),
          gh<_i45.HealthDataImportService>(),
          gh<_i126.VitalSignRepository>(),
        ));
    gh.factory<_i179.HealthImportCubit>(() => _i179.HealthImportCubit(
          gh<_i45.HealthDataImportService>(),
          gh<_i126.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i180.HealthRecordRepository>(
        () => _i181.HealthRecordRepositoryImpl(gh<_i59.Isar>()));
    gh.factory<_i182.ImportCalendarUseCase>(() => _i182.ImportCalendarUseCase(
          gh<_i20.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i121.UserProfileRepository>(),
        ));
    gh.factory<_i62.LlmAdapter>(
      () => _i183.MockLlmAdapter(gh<_i98.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i62.LlmAdapter>(
      () => _i184.GeminiLlmAdapter(
        scrubber: gh<_i98.PromptScrubber>(),
        userProfileRepository: gh<_i121.UserProfileRepository>(),
        modelWrapper: gh<_i42.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i185.LlmAdapterFactory>(
        () => _i185.LlmAdapterFactory(gh<_i112.SettingsRepository>()));
    gh.lazySingleton<_i186.LlmService>(() => _i187.GemmaLlmService(
          gh<_i124.VectorStoreService>(),
          gh<_i121.UserProfileRepository>(),
          gh<_i62.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i188.LlmSettingsCubit>(() => _i188.LlmSettingsCubit(
          gh<_i112.SettingsRepository>(),
          gh<_i28.DeviceCapabilityService>(),
          gh<_i62.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i189.MedicalResearchService>(
        () => _i189.MedicalResearchService(
              gh<_i75.MedicalWebSearchService>(),
              gh<_i71.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i190.MedicationRepository>(
        () => _i191.IsarMedicationRepository(
              gh<_i59.Isar>(),
              gh<_i96.PharmacyApiService>(),
            ));
    gh.factory<_i192.MedicationsCubit>(
        () => _i192.MedicationsCubit(gh<_i190.MedicationRepository>()));
    gh.factory<_i193.MeditationCubit>(() => _i193.MeditationCubit(
          gh<_i101.RecommendScriptUseCase>(),
          gh<_i116.StartSessionUseCase>(),
          gh<_i146.CompleteSessionUseCase>(),
          gh<_i169.GetProgressUseCase>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i194.NetworkHealthCubit>(() => _i194.NetworkHealthCubit(
          gh<_i167.GetNetworkHealth>(),
          gh<_i147.ConnectNode>(),
          gh<_i85.NetworkRepository>(),
        ));
    gh.lazySingleton<_i195.OnboardingRepository>(() =>
        _i196.OnboardingRepositoryImpl(gh<_i121.UserProfileRepository>()));
    gh.lazySingleton<_i197.PatientContextIndexer>(
      () => _i197.PatientContextIndexer(
        gh<_i59.Isar>(),
        gh<_i124.VectorStoreService>(),
        gh<_i180.HealthRecordRepository>(),
        gh<_i190.MedicationRepository>(),
        gh<_i137.AllergyRepository>(),
        gh<_i126.VitalSignRepository>(),
        gh<_i8.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i198.ReportGenerationService>(
        () => _i199.GemmaReportGenerationService(
              gh<_i62.LlmAdapter>(instanceName: 'gemma'),
              gh<_i124.VectorStoreService>(),
              gh<_i121.UserProfileRepository>(),
              gh<_i98.PromptScrubber>(),
            ));
    gh.factory<_i200.SaveAllergyUseCase>(
        () => _i200.SaveAllergyUseCase(gh<_i137.AllergyRepository>()));
    gh.factory<_i201.SaveCredentialsUseCase>(
        () => _i201.SaveCredentialsUseCase(gh<_i140.AuthRepository>()));
    gh.factory<_i202.SaveMedicationUseCase>(
        () => _i202.SaveMedicationUseCase(gh<_i190.MedicationRepository>()));
    gh.factory<_i203.SaveRecordUseCase>(
        () => _i203.SaveRecordUseCase(gh<_i180.HealthRecordRepository>()));
    gh.factory<_i204.SaveUserProfileUseCase>(
        () => _i204.SaveUserProfileUseCase(gh<_i121.UserProfileRepository>()));
    gh.factory<_i205.SaveVitalSignsUseCase>(
        () => _i205.SaveVitalSignsUseCase(gh<_i126.VitalSignRepository>()));
    gh.factory<_i206.SecondOpinionCubit>(
        () => _i206.SecondOpinionCubit(gh<_i107.SecondOpinionRepository>()));
    gh.factory<_i207.SendMessageUseCase>(
        () => _i207.SendMessageUseCase(gh<_i129.VoiceChatRepository>()));
    gh.lazySingleton<_i208.SmartSearchUseCase>(
        () => _i208.SmartSearchUseCase(gh<_i124.VectorStoreService>()));
    gh.lazySingleton<_i209.StartListeningUseCase>(
        () => _i209.StartListeningUseCase(
              gh<_i143.BleSharingService>(),
              gh<_i89.NfcSharingService>(),
              gh<_i133.WifiDirectService>(),
            ));
    gh.lazySingleton<_i210.StartSharingUseCase>(() => _i210.StartSharingUseCase(
          gh<_i143.BleSharingService>(),
          gh<_i89.NfcSharingService>(),
          gh<_i133.WifiDirectService>(),
        ));
    gh.factory<_i211.SyncCubit>(() => _i211.SyncCubit(
          gh<_i67.SyncService>(),
          gh<_i124.VectorStoreService>(),
        ));
    gh.lazySingleton<_i212.SyncService>(() => _i213.SyncServiceImpl(
          gh<_i118.SyncRepository>(),
          gh<_i67.SyncService>(),
        ));
    gh.factory<_i214.UserProfileCubit>(
        () => _i214.UserProfileCubit(gh<_i121.UserProfileRepository>()));
    gh.factory<_i215.VitalSignBloc>(
        () => _i215.VitalSignBloc(gh<_i126.VitalSignRepository>()));
    gh.factory<_i216.VoiceChatCubit>(() => _i216.VoiceChatCubit(
          gh<_i207.SendMessageUseCase>(),
          gh<_i163.GetChatHistoryUseCase>(),
          gh<_i129.VoiceChatRepository>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i217.VouchCubit>(
        () => _i217.VouchCubit(gh<_i131.VouchRepository>()));
    gh.factory<_i218.AllergiesCubit>(
        () => _i218.AllergiesCubit(gh<_i137.AllergyRepository>()));
    gh.factory<_i219.AllergyBloc>(
        () => _i219.AllergyBloc(gh<_i137.AllergyRepository>()));
    gh.factory<_i220.AuthCubit>(() => _i220.AuthCubit(
          gh<_i140.AuthRepository>(),
          gh<_i35.EncryptionService>(),
          gh<_i15.BiometricService>(),
        ));
    gh.factory<_i221.AuthCubit>(() => _i221.AuthCubit(gh<_i142.AuthService>()));
    gh.lazySingleton<_i222.BadgeCalculator>(() => _i222.BadgeCalculator(
          gh<_i153.DoctorProfileRepository>(),
          gh<_i99.RatingRepository>(),
          gh<_i131.VouchRepository>(),
        ));
    gh.factory<_i223.BadgeCubit>(
        () => _i223.BadgeCubit(gh<_i222.BadgeCalculator>()));
    gh.factory<_i224.CalendarImportCubit>(() => _i224.CalendarImportCubit(
          gh<_i20.CalendarImportRepository>(),
          gh<_i182.ImportCalendarUseCase>(),
        ));
    gh.factory<_i225.CompleteOnboardingUseCase>(() =>
        _i225.CompleteOnboardingUseCase(gh<_i195.OnboardingRepository>()));
    gh.lazySingleton<_i226.DashboardRepository>(
        () => _i227.DashboardRepositoryImpl(
              gh<_i26.DashboardRemoteDataSource>(),
              gh<_i126.VitalSignRepository>(),
              gh<_i190.MedicationRepository>(),
              gh<_i102.ReportRepository>(),
            ));
    gh.lazySingleton<_i228.DistributedCacheUsecase>(() =>
        _i228.DistributedCacheUsecase(gh<_i151.DistributedStorageService>()));
    gh.factory<_i229.EpsConnectionBloc>(() => _i229.EpsConnectionBloc(
          gh<_i164.GetConnectionsUseCase>(),
          gh<_i148.ConnectProviderUseCase>(),
          gh<_i150.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i230.EpsConnectionCubit>(() => _i230.EpsConnectionCubit(
          gh<_i164.GetConnectionsUseCase>(),
          gh<_i148.ConnectProviderUseCase>(),
          gh<_i150.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i231.FhirSyncCubit>(() => _i231.FhirSyncCubit(
          gh<_i212.SyncService>(),
          gh<_i90.NodeDiscoveryService>(),
        ));
    gh.factory<_i232.GetAllMedicationsUseCase>(
        () => _i232.GetAllMedicationsUseCase(gh<_i190.MedicationRepository>()));
    gh.factory<_i233.GetAllRecordsUseCase>(
        () => _i233.GetAllRecordsUseCase(gh<_i180.HealthRecordRepository>()));
    gh.factory<_i234.GetDashboardStatsUseCase>(
        () => _i234.GetDashboardStatsUseCase(gh<_i226.DashboardRepository>()));
    gh.factory<_i235.GetOnboardingProfileUseCase>(() =>
        _i235.GetOnboardingProfileUseCase(gh<_i195.OnboardingRepository>()));
    gh.factory<_i236.GetRecentActivityUseCase>(
        () => _i236.GetRecentActivityUseCase(gh<_i226.DashboardRepository>()));
    gh.factory<_i237.HealthRecordCubit>(() => _i237.HealthRecordCubit(
          gh<_i180.HealthRecordRepository>(),
          gh<_i37.FilePickerService>(),
          gh<_i54.ImagePickerService>(),
          gh<_i95.OcrService>(),
          gh<_i124.VectorStoreService>(),
        ));
    gh.lazySingleton<_i238.HomeRepository>(() => _i239.HomeRepositoryImpl(
          gh<_i126.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i190.MedicationRepository>(),
          gh<_i49.HomeLocalDataSource>(),
          gh<_i51.HomeRemoteDataSource>(),
        ));
    gh.lazySingleton<_i186.LlmService>(
      () => _i240.RagLlmService(
        gh<_i124.VectorStoreService>(),
        gh<_i189.MedicalResearchService>(),
        gh<_i121.UserProfileRepository>(),
        gh<_i62.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i241.MedicalIndexingService>(
        () => _i241.MedicalIndexingService(
              gh<_i68.MedicalKnowledgeRepository>(),
              gh<_i124.VectorStoreService>(),
              gh<_i197.PatientContextIndexer>(),
            ));
    gh.lazySingleton<_i242.MedicalResearchRepository>(
        () => _i243.MedicalResearchRepositoryImpl(
              gh<_i189.MedicalResearchService>(),
              gh<_i59.Isar>(),
            ));
    gh.factory<_i244.MedicationBloc>(
        () => _i244.MedicationBloc(gh<_i190.MedicationRepository>()));
    gh.factory<_i245.OnboardingCubit>(
        () => _i245.OnboardingCubit(gh<_i195.OnboardingRepository>()));
    gh.factory<_i246.ReportBloc>(() => _i246.ReportBloc(
          gh<_i102.ReportRepository>(),
          gh<_i198.ReportGenerationService>(),
        ));
    gh.factory<_i247.SearchMedicalResearch>(() =>
        _i247.SearchMedicalResearch(gh<_i242.MedicalResearchRepository>()));
    gh.factory<_i248.SharingCubit>(() => _i248.SharingCubit(
          bleService: gh<_i143.BleSharingService>(),
          nfcService: gh<_i89.NfcSharingService>(),
          wifiService: gh<_i133.WifiDirectService>(),
          startSharingUseCase: gh<_i210.StartSharingUseCase>(),
          startListeningUseCase: gh<_i209.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i144.CancelSharingUseCase>(),
          walletService: gh<_i34.WalletService>(),
          walletEncryption: gh<_i34.EncryptionService>(),
        ));
    gh.factory<_i249.DashboardCubit>(() => _i249.DashboardCubit(
          gh<_i234.GetDashboardStatsUseCase>(),
          gh<_i236.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i250.GetHealthSummaryUseCase>(
        () => _i250.GetHealthSummaryUseCase(gh<_i238.HomeRepository>()));
    gh.factory<_i251.GetResearchHistory>(
        () => _i251.GetResearchHistory(gh<_i242.MedicalResearchRepository>()));
    gh.factory<_i252.HomeCubit>(() => _i252.HomeCubit(
          gh<_i250.GetHealthSummaryUseCase>(),
          gh<_i238.HomeRepository>(),
        ));
    gh.factory<_i253.MedicalResearchCubit>(() => _i253.MedicalResearchCubit(
          gh<_i247.SearchMedicalResearch>(),
          gh<_i251.GetResearchHistory>(),
          gh<_i73.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i254.ServiceModule {}

class _$NetworkModule extends _i255.NetworkModule {}

class _$MemoryModule extends _i256.MemoryModule {}

class _$DatabaseModule extends _i257.DatabaseModule {}

class _$FhirModule extends _i258.FhirModule {}
