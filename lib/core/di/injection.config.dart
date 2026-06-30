// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i15;
import 'package:dio/dio.dart' as _i25;
import 'package:flutter/services.dart' as _i81;
import 'package:flutter_appauth/flutter_appauth.dart' as _i34;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i36;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i38;
import 'package:health_wallet/health_wallet.dart' as _i30;
import 'package:http/http.dart' as _i21;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i54;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i28;
import 'package:just_audio/just_audio.dart' as _i9;
import 'package:medical_standards/medical_standards.dart' as _i62;
import 'package:shared_preferences/shared_preferences.dart' as _i45;

import '../../features/about/application/about_cubit.dart' as _i120;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i121;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i47;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i48;
import '../../features/allergies/application/allergies_cubit.dart' as _i194;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i195;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i122;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i123;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i126;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i196;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i124;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i138;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i147;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i181;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i125;
import '../../features/auth/application/auth_cubit.dart' as _i197;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i198;
import '../../features/auth/domain/auth_service.dart' as _i129;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i127;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i128;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i11;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i29;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i201;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i18;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i16;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i166;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i14;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i19;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i17;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i202;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i135;
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i22;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i137;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i136;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i150;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i152;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i200;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i144;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i182;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i193;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i142;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i90;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i96;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i117;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i199;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i56;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i55;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i143;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i91;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i97;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i118;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i145;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i146;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i26;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i103;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i27;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i204;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i205;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i85;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i86;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i134;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i139;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i149;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i87;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i160;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i161;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i157;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i40;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i158;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i39;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i95;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i98;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i159;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i208;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i162;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i163;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i32;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i49;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i88;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i215;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i41;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i42;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i131;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i185;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i186;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i130;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i12;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i80;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i82;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i119;
import '../../features/home/application/home_cubit.dart' as _i209;
import '../../features/home/domain/repositories/home_repository.dart' as _i164;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i207;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i43;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i44;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i46;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i165;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i184;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i132;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i61;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i63;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i57;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i110;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i58;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i35;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i168;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i37;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i167;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i59;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i171;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i170;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i210;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i65;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i64;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i111;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i169;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i60;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i211;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i79;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i178;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i212;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i66;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i68;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i70;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i13;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i173;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i67;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i69;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i71;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i174;
import '../../features/medications/application/medications_cubit.dart' as _i74;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i72;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i73;
import '../../features/meditation/application/meditation_cubit.dart' as _i175;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i76;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i133;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i151;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i153;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i92;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i102;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i75;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i77;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i155;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i154;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i156;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i51;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i50;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i52;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i213;
import '../../features/onboarding/application/sync_cubit.dart' as _i187;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i176;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i177;
import '../../features/reports/application/bloc/report_bloc.dart' as _i214;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i93;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i179;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i94;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i180;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i78;
import '../../features/settings/application/llm_settings_cubit.dart' as _i172;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i100;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i24;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i99;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i101;
import '../../features/sync/application/sync_cubit.dart' as _i206;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i104;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i140;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i83;
import '../../features/sync/domain/services/sync_service.dart' as _i188;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i203;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i33;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i53;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i105;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i31;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i141;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i84;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i189;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i190;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i106;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i107;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i109;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i108;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i191;
import '../../features/vitals/application/vitals_cubit.dart' as _i114;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i112;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i113;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i192;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i115;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i148;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i183;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i20;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i116;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/audio/audio_recorder_service.dart' as _i10;
import '../services/device_capability_service.dart' as _i23;
import '../services/privacy_anonymizer.dart' as _i89;
import 'database_module.dart' as _i219;
import 'fhir_module.dart' as _i220;
import 'memory_module.dart' as _i218;
import 'network_module.dart' as _i217;
import 'service_module.dart' as _i216;

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
    gh.lazySingleton<_i41.HealthSharingLocalDataSource>(
        () => _i41.HealthSharingLocalDataSource());
    gh.lazySingleton<_i42.HealthSharingRemoteDataSource>(
        () => _i42.HealthSharingRemoteDataSource());
    gh.factory<_i43.HealthSummaryDatasource>(
        () => _i43.HealthSummaryDatasource());
    gh.factory<_i44.HomeLocalDataSource>(
        () => _i44.HomeLocalDataSource(gh<_i45.SharedPreferences>()));
    gh.factory<_i46.HomeRemoteDataSource>(() => _i46.HomeRemoteDataSource());
    gh.lazySingleton<_i47.IAboutRepository>(() => _i48.AboutRepositoryImpl());
    gh.lazySingleton<_i49.ImagePickerService>(
        () => _i49.ImagePickerServiceImpl());
    gh.lazySingleton<_i50.IncentiveDatasource>(
        () => _i50.IncentiveDatasource());
    gh.lazySingleton<_i51.IncentiveRepository>(
        () => _i52.IncentiveRepositoryImpl(gh<_i50.IncentiveDatasource>()));
    gh.lazySingleton<_i53.IpfsDatasource>(
        () => _i53.IpfsDatasource(gh<_i25.Dio>()));
    await gh.factoryAsync<_i54.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i55.LicenseRegistryLocalDataSource>(() {
      final i = _i55.LicenseRegistryLocalDataSource(gh<_i54.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i56.LicenseVerifier>(() async =>
        _i56.LicenseVerifier(
            await getAsync<_i55.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i57.LlmAdapter>(
      () => _i58.FlutterGemmaAdapter(wrapper: gh<_i35.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i57.LlmAdapter>(
      () => _i59.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i60.LocalLlmService>(() => _i60.LocalLlmService());
    gh.lazySingleton<_i61.LocalModelLocalDataSource>(
        () => _i61.LocalModelLocalDataSource());
    gh.lazySingleton<_i62.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i63.MedicalKnowledgeRepository>(
      () => _i64.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i63.MedicalKnowledgeRepository>(
      () => _i65.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i66.MedicalScraperService>(
        () => _i67.MedicalScraperServiceImpl(
              gh<_i25.Dio>(),
              gh<_i13.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i68.MedicalStandardsService>(() =>
        _i69.MedicalStandardsServiceImpl(gh<_i62.MedicalContextProvider>()));
    gh.lazySingleton<_i70.MedicalWebSearchService>(
        () => _i71.MedicalWebSearchServiceImpl(gh<_i25.Dio>()));
    gh.lazySingleton<_i72.MedicationRepository>(
        () => _i73.IsarMedicationRepository(gh<_i54.Isar>()));
    gh.factory<_i74.MedicationsCubit>(
        () => _i74.MedicationsCubit(gh<_i72.MedicationRepository>()));
    gh.lazySingleton<_i75.MeditationLocalDataSource>(
        () => _i75.MeditationLocalDataSource());
    gh.lazySingleton<_i76.MeditationRepository>(() =>
        _i77.MeditationRepositoryImpl(gh<_i75.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i28.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i54.Isar>(),
        gh<_i28.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i78.MockReportGenerationService>(
      () => _i78.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i79.ModelDownloadService>(
        () => _i79.ModelDownloadService());
    gh.lazySingleton<_i80.NfcHandler>(
        () => _i80.NfcHandler(channel: gh<_i81.MethodChannel>()));
    gh.lazySingleton<_i82.NfcSharingService>(
        () => _i82.NfcSharingService(gh<_i80.NfcHandler>()));
    gh.lazySingleton<_i83.NodeDiscoveryService>(
        () => _i84.NodeDiscoveryService());
    gh.lazySingleton<_i85.OAuthLocalDataSource>(
        () => _i85.OAuthLocalDataSource(gh<_i36.FlutterSecureStorage>()));
    gh.lazySingleton<_i86.OAuthRepository>(() => _i87.OAuthRepositoryImpl(
          gh<_i85.OAuthLocalDataSource>(),
          gh<_i25.Dio>(),
          gh<_i34.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i88.OcrService>(() => _i88.MlKitOcrService());
    gh.lazySingleton<_i89.PromptScrubber>(
        () => _i89.PromptScrubber(gh<_i54.Isar>()));
    gh.lazySingleton<_i90.RatingRepository>(
        () => _i91.IsarRatingRepository(gh<_i54.Isar>()));
    gh.lazySingleton<_i92.RecommendScriptUseCase>(
        () => _i92.RecommendScriptUseCase(gh<_i76.MeditationRepository>()));
    gh.lazySingleton<_i93.ReportRepository>(
        () => _i94.IsarReportRepository(gh<_i54.Isar>()));
    gh.factory<_i95.RequestHealthAuthUseCase>(() =>
        _i95.RequestHealthAuthUseCase(gh<_i39.HealthDataImportService>()));
    gh.lazySingleton<_i96.SecondOpinionRepository>(
        () => _i97.IsarSecondOpinionRepository(gh<_i54.Isar>()));
    gh.lazySingleton<_i98.SensorHealthDataSource>(
        () => _i98.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i99.SettingsLocalDataSource>(
        () => _i99.SettingsLocalDataSource(gh<_i54.Isar>()));
    gh.lazySingleton<_i100.SettingsRepository>(
        () => _i101.SettingsRepositoryImpl(gh<_i99.SettingsLocalDataSource>()));
    gh.lazySingleton<_i102.StartSessionUseCase>(
        () => _i102.StartSessionUseCase(gh<_i76.MeditationRepository>()));
    gh.factory<_i103.SyncEmailAppointmentsUseCase>(
        () => _i103.SyncEmailAppointmentsUseCase(gh<_i26.EmailRepository>()));
    gh.lazySingleton<_i104.SyncRepository>(() => _i105.SyncRepositoryImpl(
          gh<_i31.FhirClient>(),
          gh<_i54.Isar>(),
          gh<_i36.FlutterSecureStorage>(),
          gh<_i83.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i62.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i106.UserProfileLocalDataSource>(
        () => _i106.UserProfileLocalDataSource(gh<_i54.Isar>()));
    gh.lazySingleton<_i107.UserProfileRepository>(
        () => _i108.UserProfileRepositoryImpl(gh<_i54.Isar>()));
    gh.lazySingleton<_i109.UserProfileService>(
        () => _i109.UserProfileService(gh<_i107.UserProfileRepository>()));
    gh.lazySingleton<_i110.VectorStoreService>(
        () => _i111.IsarVectorStoreService(
              gh<_i28.MemoryGraph>(),
              gh<_i63.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i112.VitalSignRepository>(
        () => _i113.VitalSignRepositoryImpl(gh<_i54.Isar>()));
    gh.factory<_i114.VitalsCubit>(
        () => _i114.VitalsCubit(gh<_i112.VitalSignRepository>()));
    gh.lazySingleton<_i115.VoiceChatRepository>(
        () => _i116.VoiceChatRepositoryImpl(gh<_i20.ChatAiDatasource>()));
    gh.lazySingleton<_i117.VouchRepository>(
        () => _i118.IsarVouchRepository(gh<_i54.Isar>()));
    gh.lazySingleton<_i30.WalletService>(() => databaseModule.walletService(
          gh<_i54.Isar>(),
          gh<_i30.EncryptionService>(),
        ));
    gh.lazySingleton<_i119.WifiDirectService>(() => _i119.WifiDirectService());
    gh.factory<_i120.AboutCubit>(
        () => _i120.AboutCubit(gh<_i47.IAboutRepository>()));
    gh.lazySingleton<_i121.AboutRemoteDataSource>(
        () => _i121.AboutRemoteDataSource(gh<_i25.Dio>()));
    gh.lazySingleton<_i122.AllergyRepository>(
        () => _i123.IsarAllergyRepository(gh<_i54.Isar>()));
    gh.lazySingleton<_i124.AppointmentRepository>(
        () => _i125.IsarAppointmentRepository(gh<_i54.Isar>()));
    gh.factory<_i126.AppointmentsCubit>(
        () => _i126.AppointmentsCubit(gh<_i124.AppointmentRepository>()));
    gh.lazySingleton<_i127.AuthRepository>(
        () => _i128.AuthRepositoryImpl(gh<_i54.Isar>()));
    gh.lazySingleton<_i129.AuthService>(
        () => _i129.AuthServiceImpl(gh<_i29.EncryptionService>()));
    gh.lazySingleton<_i130.BleSharingService>(
        () => _i130.BleSharingService(gh<_i12.BleWrapper>()));
    gh.lazySingleton<_i131.CancelSharingUseCase>(
        () => _i131.CancelSharingUseCase(
              gh<_i130.BleSharingService>(),
              gh<_i82.NfcSharingService>(),
              gh<_i119.WifiDirectService>(),
            ));
    gh.lazySingleton<_i132.ChatMessageLocalDataSource>(
        () => _i132.ChatMessageLocalDataSource(gh<_i54.Isar>()));
    gh.lazySingleton<_i133.CompleteSessionUseCase>(
        () => _i133.CompleteSessionUseCase(gh<_i76.MeditationRepository>()));
    gh.factory<_i103.ConnectEmailProviderUseCase>(
        () => _i103.ConnectEmailProviderUseCase(gh<_i26.EmailRepository>()));
    gh.factory<_i134.ConnectProviderUseCase>(() => _i134.ConnectProviderUseCase(
          gh<_i86.OAuthRepository>(),
          gh<_i107.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i135.DashboardLocalDataSource>(
        () => _i135.DashboardLocalDataSource(gh<_i54.Isar>()));
    gh.lazySingleton<_i136.DashboardRepository>(
        () => _i137.DashboardRepositoryImpl(
              gh<_i22.DashboardRemoteDataSource>(),
              gh<_i112.VitalSignRepository>(),
              gh<_i72.MedicationRepository>(),
              gh<_i93.ReportRepository>(),
            ));
    gh.factory<_i138.DeleteAppointmentUseCase>(() =>
        _i138.DeleteAppointmentUseCase(gh<_i124.AppointmentRepository>()));
    gh.factory<_i139.DisconnectProviderUseCase>(
        () => _i139.DisconnectProviderUseCase(
              gh<_i86.OAuthRepository>(),
              gh<_i107.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i140.DistributedStorageService>(() => _i141.IpfsService(
          gh<_i53.IpfsDatasource>(),
          gh<_i33.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i142.DoctorProfileRepository>(
        () => _i143.IsarDoctorProfileRepository(gh<_i54.Isar>()));
    gh.factoryAsync<_i144.DoctorVerificationCubit>(
        () async => _i144.DoctorVerificationCubit(
              gh<_i142.DoctorProfileRepository>(),
              gh<_i90.RatingRepository>(),
              await getAsync<_i56.LicenseVerifier>(),
            ));
    gh.factory<_i145.EmailCitasBloc>(() => _i145.EmailCitasBloc(
          gh<_i103.ConnectEmailProviderUseCase>(),
          gh<_i103.SyncEmailAppointmentsUseCase>(),
          gh<_i26.EmailRepository>(),
          gh<_i124.AppointmentRepository>(),
        ));
    gh.factory<_i146.EmailCitasCubit>(() => _i146.EmailCitasCubit(
          gh<_i26.EmailRepository>(),
          gh<_i124.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i98.FileHealthDataSource>(
        () => _i98.FileHealthDataSourceImpl(
              gh<_i32.FilePickerService>(),
              gh<_i88.OcrService>(),
            ));
    gh.factory<_i147.GetAllAppointmentsUseCase>(() =>
        _i147.GetAllAppointmentsUseCase(gh<_i124.AppointmentRepository>()));
    gh.factory<_i95.GetAvailableSourcesUseCase>(() =>
        _i95.GetAvailableSourcesUseCase(gh<_i39.HealthDataImportService>()));
    gh.factory<_i148.GetChatHistoryUseCase>(
        () => _i148.GetChatHistoryUseCase(gh<_i115.VoiceChatRepository>()));
    gh.factory<_i149.GetConnectionsUseCase>(
        () => _i149.GetConnectionsUseCase(gh<_i86.OAuthRepository>()));
    gh.factory<_i150.GetDashboardStatsUseCase>(
        () => _i150.GetDashboardStatsUseCase(gh<_i136.DashboardRepository>()));
    gh.lazySingleton<_i151.GetProgressUseCase>(
        () => _i151.GetProgressUseCase(gh<_i76.MeditationRepository>()));
    gh.factory<_i152.GetRecentActivityUseCase>(
        () => _i152.GetRecentActivityUseCase(gh<_i136.DashboardRepository>()));
    gh.lazySingleton<_i153.GetScriptsUseCase>(
        () => _i153.GetScriptsUseCase(gh<_i76.MeditationRepository>()));
    gh.lazySingleton<_i154.GovernanceIpfsDatasource>(
        () => _i154.GovernanceIpfsDatasource(gh<_i53.IpfsDatasource>()));
    gh.lazySingleton<_i155.GovernanceRepository>(() =>
        _i156.GovernanceRepositoryImpl(gh<_i154.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i157.HealthDataFileDataSource>(
        () => _i157.HealthDataFileDataSource(
              gh<_i32.FilePickerService>(),
              gh<_i88.OcrService>(),
            ));
    gh.lazySingleton<_i158.HealthDataImportRepository>(
        () => _i159.HealthDataImportRepositoryImpl(
              gh<_i98.SensorHealthDataSource>(),
              gh<_i98.FileHealthDataSource>(),
            ));
    gh.factory<_i160.HealthImportBloc>(() => _i160.HealthImportBloc(
          gh<_i95.GetAvailableSourcesUseCase>(),
          gh<_i95.RequestHealthAuthUseCase>(),
          gh<_i39.HealthDataImportService>(),
          gh<_i112.VitalSignRepository>(),
        ));
    gh.factory<_i161.HealthImportCubit>(() => _i161.HealthImportCubit(
          gh<_i39.HealthDataImportService>(),
          gh<_i112.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i162.HealthRecordRepository>(
        () => _i163.HealthRecordRepositoryImpl(gh<_i54.Isar>()));
    gh.lazySingleton<_i164.HomeRepository>(() => _i165.HomeRepositoryImpl(
          gh<_i112.VitalSignRepository>(),
          gh<_i124.AppointmentRepository>(),
          gh<_i72.MedicationRepository>(),
          gh<_i44.HomeLocalDataSource>(),
          gh<_i46.HomeRemoteDataSource>(),
        ));
    gh.factory<_i166.ImportCalendarUseCase>(() => _i166.ImportCalendarUseCase(
          gh<_i18.CalendarRepository>(),
          gh<_i124.AppointmentRepository>(),
          gh<_i107.UserProfileRepository>(),
        ));
    gh.factory<_i57.LlmAdapter>(
      () => _i167.MockLlmAdapter(gh<_i89.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i57.LlmAdapter>(
      () => _i168.GeminiLlmAdapter(
        scrubber: gh<_i89.PromptScrubber>(),
        userProfileRepository: gh<_i107.UserProfileRepository>(),
        modelWrapper: gh<_i37.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i169.LlmAdapterFactory>(
        () => _i169.LlmAdapterFactory(gh<_i100.SettingsRepository>()));
    gh.lazySingleton<_i170.LlmService>(() => _i171.GemmaLlmService(
          gh<_i110.VectorStoreService>(),
          gh<_i107.UserProfileRepository>(),
          gh<_i57.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i172.LlmSettingsCubit>(() => _i172.LlmSettingsCubit(
          gh<_i100.SettingsRepository>(),
          gh<_i24.DeviceCapabilityService>(),
          gh<_i57.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i173.MedicalResearchService>(
        () => _i173.MedicalResearchService(
              gh<_i70.MedicalWebSearchService>(),
              gh<_i66.MedicalScraperService>(),
            ));
    gh.factory<_i174.MedicationBloc>(
        () => _i174.MedicationBloc(gh<_i72.MedicationRepository>()));
    gh.factory<_i175.MeditationCubit>(() => _i175.MeditationCubit(
          gh<_i92.RecommendScriptUseCase>(),
          gh<_i102.StartSessionUseCase>(),
          gh<_i133.CompleteSessionUseCase>(),
          gh<_i151.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i176.OnboardingRepository>(() =>
        _i177.OnboardingRepositoryImpl(gh<_i107.UserProfileRepository>()));
    gh.lazySingleton<_i178.PatientContextIndexer>(
      () => _i178.PatientContextIndexer(
        gh<_i54.Isar>(),
        gh<_i110.VectorStoreService>(),
        gh<_i162.HealthRecordRepository>(),
        gh<_i72.MedicationRepository>(),
        gh<_i122.AllergyRepository>(),
        gh<_i112.VitalSignRepository>(),
        gh<_i124.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i179.ReportGenerationService>(
        () => _i180.GemmaReportGenerationService(
              gh<_i57.LlmAdapter>(instanceName: 'gemma'),
              gh<_i110.VectorStoreService>(),
              gh<_i107.UserProfileRepository>(),
              gh<_i89.PromptScrubber>(),
            ));
    gh.factory<_i181.SaveAppointmentUseCase>(
        () => _i181.SaveAppointmentUseCase(gh<_i124.AppointmentRepository>()));
    gh.factory<_i182.SecondOpinionCubit>(
        () => _i182.SecondOpinionCubit(gh<_i96.SecondOpinionRepository>()));
    gh.factory<_i183.SendMessageUseCase>(
        () => _i183.SendMessageUseCase(gh<_i115.VoiceChatRepository>()));
    gh.lazySingleton<_i184.SmartSearchUseCase>(
        () => _i184.SmartSearchUseCase(gh<_i110.VectorStoreService>()));
    gh.lazySingleton<_i185.StartListeningUseCase>(
        () => _i185.StartListeningUseCase(
              gh<_i130.BleSharingService>(),
              gh<_i82.NfcSharingService>(),
              gh<_i119.WifiDirectService>(),
            ));
    gh.lazySingleton<_i186.StartSharingUseCase>(() => _i186.StartSharingUseCase(
          gh<_i130.BleSharingService>(),
          gh<_i82.NfcSharingService>(),
          gh<_i119.WifiDirectService>(),
        ));
    gh.factory<_i187.SyncCubit>(() => _i187.SyncCubit(
          gh<_i62.SyncService>(),
          gh<_i110.VectorStoreService>(),
        ));
    gh.lazySingleton<_i188.SyncService>(() => _i189.SyncServiceImpl(
          gh<_i104.SyncRepository>(),
          gh<_i62.SyncService>(),
        ));
    gh.factory<_i190.UserProfileCubit>(
        () => _i190.UserProfileCubit(gh<_i107.UserProfileRepository>()));
    gh.factory<_i191.VitalSignBloc>(
        () => _i191.VitalSignBloc(gh<_i112.VitalSignRepository>()));
    gh.factory<_i192.VoiceChatCubit>(() => _i192.VoiceChatCubit(
          gh<_i183.SendMessageUseCase>(),
          gh<_i148.GetChatHistoryUseCase>(),
          gh<_i115.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i193.VouchCubit>(
        () => _i193.VouchCubit(gh<_i117.VouchRepository>()));
    gh.factory<_i194.AllergiesCubit>(
        () => _i194.AllergiesCubit(gh<_i122.AllergyRepository>()));
    gh.factory<_i195.AllergyBloc>(
        () => _i195.AllergyBloc(gh<_i122.AllergyRepository>()));
    gh.factory<_i196.AppointmentBloc>(
        () => _i196.AppointmentBloc(gh<_i124.AppointmentRepository>()));
    gh.factory<_i197.AuthCubit>(() => _i197.AuthCubit(gh<_i129.AuthService>()));
    gh.factory<_i198.AuthCubit>(() => _i198.AuthCubit(
          gh<_i127.AuthRepository>(),
          gh<_i29.EncryptionService>(),
          gh<_i11.BiometricService>(),
        ));
    gh.lazySingleton<_i199.BadgeCalculator>(() => _i199.BadgeCalculator(
          gh<_i142.DoctorProfileRepository>(),
          gh<_i90.RatingRepository>(),
          gh<_i117.VouchRepository>(),
        ));
    gh.factory<_i200.BadgeCubit>(
        () => _i200.BadgeCubit(gh<_i199.BadgeCalculator>()));
    gh.factory<_i201.CalendarImportCubit>(() => _i201.CalendarImportCubit(
          gh<_i18.CalendarRepository>(),
          gh<_i166.ImportCalendarUseCase>(),
        ));
    gh.factory<_i202.DashboardCubit>(() => _i202.DashboardCubit(
          gh<_i150.GetDashboardStatsUseCase>(),
          gh<_i152.GetRecentActivityUseCase>(),
        ));
    gh.lazySingleton<_i203.DistributedCacheUsecase>(() =>
        _i203.DistributedCacheUsecase(gh<_i140.DistributedStorageService>()));
    gh.factory<_i204.EpsConnectionBloc>(() => _i204.EpsConnectionBloc(
          gh<_i149.GetConnectionsUseCase>(),
          gh<_i134.ConnectProviderUseCase>(),
          gh<_i139.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i205.EpsConnectionCubit>(() => _i205.EpsConnectionCubit(
          gh<_i149.GetConnectionsUseCase>(),
          gh<_i134.ConnectProviderUseCase>(),
          gh<_i139.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i206.FhirSyncCubit>(() => _i206.FhirSyncCubit(
          gh<_i188.SyncService>(),
          gh<_i83.NodeDiscoveryService>(),
        ));
    gh.factory<_i207.GetHealthSummaryUseCase>(
        () => _i207.GetHealthSummaryUseCase(gh<_i164.HomeRepository>()));
    gh.factory<_i208.HealthRecordCubit>(() => _i208.HealthRecordCubit(
          gh<_i162.HealthRecordRepository>(),
          gh<_i32.FilePickerService>(),
          gh<_i49.ImagePickerService>(),
          gh<_i88.OcrService>(),
          gh<_i110.VectorStoreService>(),
        ));
    gh.factory<_i209.HomeCubit>(() => _i209.HomeCubit(
          gh<_i207.GetHealthSummaryUseCase>(),
          gh<_i164.HomeRepository>(),
        ));
    gh.lazySingleton<_i170.LlmService>(
      () => _i210.RagLlmService(
        gh<_i110.VectorStoreService>(),
        gh<_i173.MedicalResearchService>(),
        gh<_i107.UserProfileRepository>(),
        gh<_i57.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i211.MedicalIndexingService>(
        () => _i211.MedicalIndexingService(
              gh<_i63.MedicalKnowledgeRepository>(),
              gh<_i110.VectorStoreService>(),
              gh<_i178.PatientContextIndexer>(),
            ));
    gh.factory<_i212.MedicalResearchCubit>(() => _i212.MedicalResearchCubit(
          gh<_i173.MedicalResearchService>(),
          gh<_i68.MedicalStandardsService>(),
        ));
    gh.factory<_i213.OnboardingCubit>(
        () => _i213.OnboardingCubit(gh<_i176.OnboardingRepository>()));
    gh.factory<_i214.ReportBloc>(() => _i214.ReportBloc(
          gh<_i93.ReportRepository>(),
          gh<_i179.ReportGenerationService>(),
        ));
    gh.factory<_i215.SharingCubit>(() => _i215.SharingCubit(
          bleService: gh<_i130.BleSharingService>(),
          nfcService: gh<_i82.NfcSharingService>(),
          wifiService: gh<_i119.WifiDirectService>(),
          startSharingUseCase: gh<_i186.StartSharingUseCase>(),
          startListeningUseCase: gh<_i185.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i131.CancelSharingUseCase>(),
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
