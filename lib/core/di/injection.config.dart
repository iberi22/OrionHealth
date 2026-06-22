// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i13;
import 'package:dio/dio.dart' as _i21;
import 'package:flutter/services.dart' as _i74;
import 'package:flutter_appauth/flutter_appauth.dart' as _i30;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i32;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i34;
import 'package:health_wallet/health_wallet.dart' as _i25;
import 'package:http/http.dart' as _i17;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i47;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i24;
import 'package:medical_standards/medical_standards.dart' as _i55;

import '../../features/about/application/about_cubit.dart' as _i113;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i114;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i39;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i40;
import '../../features/allergies/application/allergies_cubit.dart' as _i183;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i115;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i116;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i119;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i117;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i130;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i139;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i173;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i118;
import '../../features/auth/application/auth_cubit.dart' as _i184;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i185;
import '../../features/auth/domain/auth_service.dart' as _i122;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i120;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i121;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i9;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i26;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i188;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i14;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i159;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i12;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i15;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i189;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i18;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i129;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i128;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i142;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i144;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i187;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i135;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i174;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i182;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i133;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i83;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i89;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i110;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i186;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i49;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i48;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i134;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i84;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i90;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i111;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i136;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i137;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i22;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i94;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i23;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i190;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i191;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i77;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i78;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i127;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i131;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i141;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i79;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
    as _i152;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i153;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i149;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i36;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i150;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i35;
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i88;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i91;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
    as _i151;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i193;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i154;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i155;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i28;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i41;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i80;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i201;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i156;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i37;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i124;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i177;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i178;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i123;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i10;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i73;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i75;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i112;
import '../../features/home/application/home_cubit.dart' as _i194;
import '../../features/home/domain/repositories/home_repository.dart' as _i157;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i192;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i38;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i158;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i176;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i125;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i54;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i56;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i50;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i103;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i51;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i31;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i160;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i33;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i161;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i52;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i163;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i162;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i196;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i58;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i57;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i104;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i195;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i53;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i198;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i72;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i170;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i199;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i59;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i61;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i63;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i11;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i166;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i60;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i62;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i64;
import '../../features/medications/application/medications_cubit.dart' as _i67;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i65;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i66;
import '../../features/meditation/application/meditation_cubit.dart' as _i167;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i69;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i126;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i143;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i145;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i85;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i93;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i68;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i70;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i147;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i146;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i148;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i43;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i42;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i44;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i81;
import '../../features/onboarding/application/sync_cubit.dart' as _i179;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i168;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i169;
import '../../features/reports/application/bloc/report_bloc.dart' as _i200;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i86;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i171;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i87;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i172;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i71;
import '../../features/settings/application/llm_settings_cubit.dart' as _i197;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i92;
import '../../features/settings/data/repositories/llm_settings_repository_impl.dart'
    as _i165;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i164;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i19;
import '../../features/sync/application/sync_cubit.dart' as _i138;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i95;
import '../../features/sync/domain/services/sync_service.dart' as _i97;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i132;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i29;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i45;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i96;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i27;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i46;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i76;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i98;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i180;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i99;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i100;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i102;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i101;
import '../../features/vitals/application/vitals_cubit.dart' as _i107;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i105;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i106;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i181;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i108;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i140;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i175;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i16;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i109;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/device_capability_service.dart' as _i20;
import '../services/privacy_anonymizer.dart' as _i82;
import 'calendar_module.dart' as _i203;
import 'database_module.dart' as _i206;
import 'fhir_module.dart' as _i202;
import 'memory_module.dart' as _i205;
import 'network_module.dart' as _i204;
import 'service_module.dart' as _i207;

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
    final fhirModule = _$FhirModule();
    final calendarModule = _$CalendarModule();
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    final serviceModule = _$ServiceModule();
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
    gh.lazySingleton<_i14.CalendarRepository>(
        () => _i15.CalendarRepositoryImpl(gh<_i12.CalendarApiDatasource>()));
    gh.lazySingleton<_i16.ChatAiDatasource>(() => _i16.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i17.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i18.DashboardLocalDataSource>(
        () => _i18.DashboardLocalDataSource());
    gh.lazySingleton<_i13.DeviceCalendarPlugin>(
        () => calendarModule.deviceCalendarPlugin);
    gh.lazySingleton<_i19.DeviceCapabilityService>(
        () => _i19.DeviceCapabilityService());
    gh.lazySingleton<_i20.DeviceCapabilityService>(
        () => _i20.DeviceCapabilityService());
    gh.lazySingleton<_i21.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i22.EmailRepository>(() => _i23.EmailRepositoryImpl(
          gh<_i17.Client>(),
          gh<_i13.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i24.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i25.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i26.EncryptionService>(() => _i26.EncryptionService());
    gh.lazySingleton<_i27.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i28.FilePickerService>(
        () => _i28.FilePickerServiceImpl());
    gh.lazySingleton<_i29.FilecoinDatasource>(() => _i29.FilecoinDatasource());
    gh.lazySingleton<_i30.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i31.FlutterGemmaWrapper>(
        () => _i31.FlutterGemmaWrapper());
    gh.lazySingleton<_i32.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i33.GeminiModelWrapper>(
        () => _i33.GeminiModelWrapper(gh<_i34.GenerativeModel>()));
    gh.lazySingleton<_i35.HealthDataImportService>(
        () => _i35.HealthDataImportService());
    gh.lazySingleton<_i36.HealthDataSensorDataSource>(
        () => _i36.HealthDataSensorDataSource());
    gh.lazySingleton<_i37.HealthSharingRemoteDataSource>(
        () => _i37.HealthSharingRemoteDataSource());
    gh.factory<_i38.HealthSummaryDatasource>(
        () => _i38.HealthSummaryDatasource());
    gh.lazySingleton<_i39.IAboutRepository>(() => _i40.AboutRepositoryImpl());
    gh.lazySingleton<_i41.ImagePickerService>(
        () => _i41.ImagePickerServiceImpl());
    gh.lazySingleton<_i42.IncentiveDatasource>(
        () => _i42.IncentiveDatasource());
    gh.lazySingleton<_i43.IncentiveRepository>(
        () => _i44.IncentiveRepositoryImpl(gh<_i42.IncentiveDatasource>()));
    gh.lazySingleton<_i45.IpfsDatasource>(
        () => _i45.IpfsDatasource(gh<_i21.Dio>()));
    gh.lazySingleton<_i46.IpfsService>(() => _i46.IpfsService(
          gh<_i45.IpfsDatasource>(),
          gh<_i29.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i47.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i48.LicenseRegistryLocalDataSource>(() {
      final i = _i48.LicenseRegistryLocalDataSource(gh<_i47.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i49.LicenseVerifier>(() async =>
        _i49.LicenseVerifier(
            await getAsync<_i48.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i50.LlmAdapter>(
      () => _i51.FlutterGemmaAdapter(wrapper: gh<_i31.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i50.LlmAdapter>(
      () => _i52.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i53.LocalLlmService>(() => _i53.LocalLlmService());
    gh.lazySingleton<_i54.LocalModelLocalDataSource>(
        () => _i54.LocalModelLocalDataSource());
    gh.lazySingleton<_i55.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i56.MedicalKnowledgeRepository>(
      () => _i57.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i56.MedicalKnowledgeRepository>(
      () => _i58.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i59.MedicalScraperService>(
        () => _i60.MedicalScraperServiceImpl(
              gh<_i21.Dio>(),
              gh<_i11.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i61.MedicalStandardsService>(() =>
        _i62.MedicalStandardsServiceImpl(gh<_i55.MedicalContextProvider>()));
    gh.lazySingleton<_i63.MedicalWebSearchService>(
        () => _i64.MedicalWebSearchServiceImpl(gh<_i21.Dio>()));
    gh.lazySingleton<_i65.MedicationRepository>(
        () => _i66.IsarMedicationRepository(gh<_i47.Isar>()));
    gh.factory<_i67.MedicationsCubit>(
        () => _i67.MedicationsCubit(gh<_i65.MedicationRepository>()));
    gh.lazySingleton<_i68.MeditationLocalDataSource>(
        () => _i68.MeditationLocalDataSource());
    gh.lazySingleton<_i69.MeditationRepository>(() =>
        _i70.MeditationRepositoryImpl(gh<_i68.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i24.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i47.Isar>(),
        gh<_i24.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i71.MockReportGenerationService>(
      () => _i71.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i72.ModelDownloadService>(
        () => _i72.ModelDownloadService());
    gh.lazySingleton<_i73.NfcHandler>(
        () => _i73.NfcHandler(channel: gh<_i74.MethodChannel>()));
    gh.lazySingleton<_i75.NfcSharingService>(
        () => _i75.NfcSharingService(gh<_i73.NfcHandler>()));
    gh.lazySingleton<_i76.NodeDiscoveryService>(
        () => _i76.NodeDiscoveryService());
    gh.lazySingleton<_i77.OAuthLocalDataSource>(
        () => _i77.OAuthLocalDataSource(gh<_i32.FlutterSecureStorage>()));
    gh.lazySingleton<_i78.OAuthRepository>(() => _i79.OAuthRepositoryImpl(
          gh<_i77.OAuthLocalDataSource>(),
          gh<_i21.Dio>(),
          gh<_i30.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i80.OcrService>(() => _i80.MlKitOcrService());
    gh.factory<_i81.OnboardingCubit>(() => _i81.OnboardingCubit());
    gh.lazySingleton<_i82.PromptScrubber>(
        () => _i82.PromptScrubber(gh<_i47.Isar>()));
    gh.lazySingleton<_i83.RatingRepository>(
        () => _i84.IsarRatingRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i85.RecommendScriptUseCase>(
        () => _i85.RecommendScriptUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i86.ReportRepository>(
        () => _i87.IsarReportRepository(gh<_i47.Isar>()));
    gh.factory<_i88.RequestHealthAuthUseCase>(() =>
        _i88.RequestHealthAuthUseCase(gh<_i35.HealthDataImportService>()));
    gh.lazySingleton<_i89.SecondOpinionRepository>(
        () => _i90.IsarSecondOpinionRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i91.SensorHealthDataSource>(
        () => _i91.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i92.SettingsLocalDataSource>(
        () => _i92.SettingsLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i93.StartSessionUseCase>(
        () => _i93.StartSessionUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i94.SyncEmailAppointmentsUseCase>(
        () => _i94.SyncEmailAppointmentsUseCase(gh<_i22.EmailRepository>()));
    gh.lazySingleton<_i95.SyncRepository>(() => _i96.SyncRepositoryImpl(
          gh<_i27.FhirClient>(),
          gh<_i47.Isar>(),
          gh<_i32.FlutterSecureStorage>(),
          gh<_i76.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i55.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i97.SyncService>(() => _i98.SyncServiceImpl(
          gh<_i95.SyncRepository>(),
          gh<_i55.SyncService>(),
        ));
    gh.lazySingleton<_i99.UserProfileLocalDataSource>(
        () => _i99.UserProfileLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i100.UserProfileRepository>(
        () => _i101.UserProfileRepositoryImpl(gh<_i47.Isar>()));
    gh.lazySingleton<_i102.UserProfileService>(
        () => _i102.UserProfileService(gh<_i100.UserProfileRepository>()));
    gh.lazySingleton<_i103.VectorStoreService>(
        () => _i104.IsarVectorStoreService(
              gh<_i24.MemoryGraph>(),
              gh<_i56.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i105.VitalSignRepository>(
        () => _i106.VitalSignRepositoryImpl(gh<_i47.Isar>()));
    gh.factory<_i107.VitalsCubit>(
        () => _i107.VitalsCubit(gh<_i105.VitalSignRepository>()));
    gh.lazySingleton<_i108.VoiceChatRepository>(
        () => _i109.VoiceChatRepositoryImpl(gh<_i16.ChatAiDatasource>()));
    gh.lazySingleton<_i110.VouchRepository>(
        () => _i111.IsarVouchRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i25.WalletService>(() => databaseModule.walletService(
          gh<_i47.Isar>(),
          gh<_i25.EncryptionService>(),
        ));
    gh.lazySingleton<_i112.WifiDirectService>(() => _i112.WifiDirectService());
    gh.factory<_i113.AboutCubit>(
        () => _i113.AboutCubit(gh<_i39.IAboutRepository>()));
    gh.lazySingleton<_i114.AboutRemoteDataSource>(
        () => _i114.AboutRemoteDataSource(gh<_i21.Dio>()));
    gh.lazySingleton<_i115.AllergyRepository>(
        () => _i116.IsarAllergyRepository(gh<_i47.Isar>()));
    gh.lazySingleton<_i117.AppointmentRepository>(
        () => _i118.IsarAppointmentRepository(gh<_i47.Isar>()));
    gh.factory<_i119.AppointmentsCubit>(
        () => _i119.AppointmentsCubit(gh<_i117.AppointmentRepository>()));
    gh.lazySingleton<_i120.AuthRepository>(
        () => _i121.AuthRepositoryImpl(gh<_i47.Isar>()));
    gh.lazySingleton<_i122.AuthService>(
        () => _i122.AuthServiceImpl(gh<_i26.EncryptionService>()));
    gh.lazySingleton<_i123.BleSharingService>(
        () => _i123.BleSharingService(gh<_i10.BleWrapper>()));
    gh.lazySingleton<_i124.CancelSharingUseCase>(
        () => _i124.CancelSharingUseCase(
              gh<_i123.BleSharingService>(),
              gh<_i75.NfcSharingService>(),
              gh<_i112.WifiDirectService>(),
            ));
    gh.lazySingleton<_i125.ChatMessageLocalDataSource>(
        () => _i125.ChatMessageLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i126.CompleteSessionUseCase>(
        () => _i126.CompleteSessionUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i94.ConnectEmailProviderUseCase>(
        () => _i94.ConnectEmailProviderUseCase(gh<_i22.EmailRepository>()));
    gh.factory<_i127.ConnectProviderUseCase>(() => _i127.ConnectProviderUseCase(
          gh<_i78.OAuthRepository>(),
          gh<_i100.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i128.DashboardRepository>(
        () => _i129.DashboardRepositoryImpl(
              gh<_i105.VitalSignRepository>(),
              gh<_i65.MedicationRepository>(),
              gh<_i86.ReportRepository>(),
            ));
    gh.factory<_i130.DeleteAppointmentUseCase>(() =>
        _i130.DeleteAppointmentUseCase(gh<_i117.AppointmentRepository>()));
    gh.factory<_i131.DisconnectProviderUseCase>(
        () => _i131.DisconnectProviderUseCase(
              gh<_i78.OAuthRepository>(),
              gh<_i100.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i132.DistributedCacheUsecase>(
        () => _i132.DistributedCacheUsecase(gh<_i46.IpfsService>()));
    gh.lazySingleton<_i133.DoctorProfileRepository>(
        () => _i134.IsarDoctorProfileRepository(gh<_i47.Isar>()));
    gh.factoryAsync<_i135.DoctorVerificationCubit>(
        () async => _i135.DoctorVerificationCubit(
              gh<_i133.DoctorProfileRepository>(),
              gh<_i83.RatingRepository>(),
              await getAsync<_i49.LicenseVerifier>(),
            ));
    gh.factory<_i136.EmailCitasBloc>(() => _i136.EmailCitasBloc(
          gh<_i94.ConnectEmailProviderUseCase>(),
          gh<_i94.SyncEmailAppointmentsUseCase>(),
          gh<_i22.EmailRepository>(),
          gh<_i117.AppointmentRepository>(),
        ));
    gh.factory<_i137.EmailCitasCubit>(() => _i137.EmailCitasCubit(
          gh<_i22.EmailRepository>(),
          gh<_i117.AppointmentRepository>(),
        ));
    gh.factory<_i138.FhirSyncCubit>(() => _i138.FhirSyncCubit(
          gh<_i97.SyncService>(),
          gh<_i76.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i91.FileHealthDataSource>(
        () => _i91.FileHealthDataSourceImpl(
              gh<_i28.FilePickerService>(),
              gh<_i80.OcrService>(),
            ));
    gh.factory<_i139.GetAllAppointmentsUseCase>(() =>
        _i139.GetAllAppointmentsUseCase(gh<_i117.AppointmentRepository>()));
    gh.factory<_i88.GetAvailableSourcesUseCase>(() =>
        _i88.GetAvailableSourcesUseCase(gh<_i35.HealthDataImportService>()));
    gh.factory<_i140.GetChatHistoryUseCase>(
        () => _i140.GetChatHistoryUseCase(gh<_i108.VoiceChatRepository>()));
    gh.factory<_i141.GetConnectionsUseCase>(
        () => _i141.GetConnectionsUseCase(gh<_i78.OAuthRepository>()));
    gh.factory<_i142.GetDashboardStatsUseCase>(
        () => _i142.GetDashboardStatsUseCase(gh<_i128.DashboardRepository>()));
    gh.lazySingleton<_i143.GetProgressUseCase>(
        () => _i143.GetProgressUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i144.GetRecentActivityUseCase>(
        () => _i144.GetRecentActivityUseCase(gh<_i128.DashboardRepository>()));
    gh.lazySingleton<_i145.GetScriptsUseCase>(
        () => _i145.GetScriptsUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i146.GovernanceIpfsDatasource>(
        () => _i146.GovernanceIpfsDatasource(gh<_i45.IpfsDatasource>()));
    gh.lazySingleton<_i147.GovernanceRepository>(() =>
        _i148.GovernanceRepositoryImpl(gh<_i146.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i149.HealthDataFileDataSource>(
        () => _i149.HealthDataFileDataSource(
              gh<_i28.FilePickerService>(),
              gh<_i80.OcrService>(),
            ));
    gh.lazySingleton<_i150.HealthDataImportRepository>(
        () => _i151.HealthDataImportRepositoryImpl(
              gh<_i91.SensorHealthDataSource>(),
              gh<_i91.FileHealthDataSource>(),
            ));
    gh.factory<_i152.HealthImportBloc>(() => _i152.HealthImportBloc(
          gh<_i88.GetAvailableSourcesUseCase>(),
          gh<_i88.RequestHealthAuthUseCase>(),
          gh<_i35.HealthDataImportService>(),
          gh<_i105.VitalSignRepository>(),
        ));
    gh.factory<_i153.HealthImportCubit>(() => _i153.HealthImportCubit(
          gh<_i35.HealthDataImportService>(),
          gh<_i105.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i154.HealthRecordRepository>(
        () => _i155.HealthRecordRepositoryImpl(gh<_i47.Isar>()));
    gh.lazySingleton<_i156.HealthSharingLocalDataSource>(
        () => _i156.HealthSharingLocalDataSource(gh<_i47.Isar>()));
    gh.lazySingleton<_i157.HomeRepository>(() => _i158.HomeRepositoryImpl(
          gh<_i105.VitalSignRepository>(),
          gh<_i117.AppointmentRepository>(),
          gh<_i65.MedicationRepository>(),
        ));
    gh.factory<_i159.ImportCalendarUseCase>(() => _i159.ImportCalendarUseCase(
          gh<_i14.CalendarRepository>(),
          gh<_i117.AppointmentRepository>(),
          gh<_i100.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i50.LlmAdapter>(
      () => _i160.GeminiLlmAdapter(
        scrubber: gh<_i82.PromptScrubber>(),
        userProfileRepository: gh<_i100.UserProfileRepository>(),
        modelWrapper: gh<_i33.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i50.LlmAdapter>(
      () => _i161.MockLlmAdapter(gh<_i82.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i162.LlmService>(() => _i163.GemmaLlmService(
          gh<_i103.VectorStoreService>(),
          gh<_i100.UserProfileRepository>(),
          gh<_i50.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i164.LlmSettingsRepository>(() =>
        _i165.LlmSettingsRepositoryImpl(gh<_i92.SettingsLocalDataSource>()));
    gh.lazySingleton<_i166.MedicalResearchService>(
        () => _i166.MedicalResearchService(
              gh<_i63.MedicalWebSearchService>(),
              gh<_i59.MedicalScraperService>(),
            ));
    gh.factory<_i167.MeditationCubit>(() => _i167.MeditationCubit(
          gh<_i85.RecommendScriptUseCase>(),
          gh<_i93.StartSessionUseCase>(),
          gh<_i126.CompleteSessionUseCase>(),
          gh<_i143.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i168.OnboardingRepository>(() =>
        _i169.OnboardingRepositoryImpl(gh<_i100.UserProfileRepository>()));
    gh.lazySingleton<_i170.PatientContextIndexer>(
      () => _i170.PatientContextIndexer(
        gh<_i47.Isar>(),
        gh<_i103.VectorStoreService>(),
        gh<_i154.HealthRecordRepository>(),
        gh<_i65.MedicationRepository>(),
        gh<_i115.AllergyRepository>(),
        gh<_i105.VitalSignRepository>(),
        gh<_i117.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i171.ReportGenerationService>(
        () => _i172.GemmaReportGenerationService(
              gh<_i50.LlmAdapter>(instanceName: 'gemma'),
              gh<_i103.VectorStoreService>(),
              gh<_i100.UserProfileRepository>(),
              gh<_i82.PromptScrubber>(),
            ));
    gh.factory<_i173.SaveAppointmentUseCase>(
        () => _i173.SaveAppointmentUseCase(gh<_i117.AppointmentRepository>()));
    gh.factory<_i174.SecondOpinionCubit>(
        () => _i174.SecondOpinionCubit(gh<_i89.SecondOpinionRepository>()));
    gh.factory<_i175.SendMessageUseCase>(
        () => _i175.SendMessageUseCase(gh<_i108.VoiceChatRepository>()));
    gh.lazySingleton<_i176.SmartSearchUseCase>(
        () => _i176.SmartSearchUseCase(gh<_i103.VectorStoreService>()));
    gh.lazySingleton<_i177.StartListeningUseCase>(
        () => _i177.StartListeningUseCase(
              gh<_i123.BleSharingService>(),
              gh<_i75.NfcSharingService>(),
              gh<_i112.WifiDirectService>(),
            ));
    gh.lazySingleton<_i178.StartSharingUseCase>(() => _i178.StartSharingUseCase(
          gh<_i123.BleSharingService>(),
          gh<_i75.NfcSharingService>(),
          gh<_i112.WifiDirectService>(),
        ));
    gh.factory<_i179.SyncCubit>(() => _i179.SyncCubit(
          gh<_i55.SyncService>(),
          gh<_i103.VectorStoreService>(),
        ));
    gh.factory<_i180.UserProfileCubit>(
        () => _i180.UserProfileCubit(gh<_i100.UserProfileRepository>()));
    gh.factory<_i181.VoiceChatCubit>(() => _i181.VoiceChatCubit(
          gh<_i175.SendMessageUseCase>(),
          gh<_i140.GetChatHistoryUseCase>(),
          gh<_i108.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i182.VouchCubit>(
        () => _i182.VouchCubit(gh<_i110.VouchRepository>()));
    gh.factory<_i183.AllergiesCubit>(
        () => _i183.AllergiesCubit(gh<_i115.AllergyRepository>()));
    gh.factory<_i184.AuthCubit>(() => _i184.AuthCubit(gh<_i122.AuthService>()));
    gh.factory<_i185.AuthCubit>(() => _i185.AuthCubit(
          gh<_i120.AuthRepository>(),
          gh<_i26.EncryptionService>(),
          gh<_i9.BiometricService>(),
        ));
    gh.lazySingleton<_i186.BadgeCalculator>(() => _i186.BadgeCalculator(
          gh<_i133.DoctorProfileRepository>(),
          gh<_i83.RatingRepository>(),
          gh<_i110.VouchRepository>(),
        ));
    gh.factory<_i187.BadgeCubit>(
        () => _i187.BadgeCubit(gh<_i186.BadgeCalculator>()));
    gh.factory<_i188.CalendarImportCubit>(() => _i188.CalendarImportCubit(
          gh<_i14.CalendarRepository>(),
          gh<_i159.ImportCalendarUseCase>(),
        ));
    gh.factory<_i189.DashboardCubit>(() => _i189.DashboardCubit(
          gh<_i142.GetDashboardStatsUseCase>(),
          gh<_i144.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i190.EpsConnectionBloc>(() => _i190.EpsConnectionBloc(
          gh<_i141.GetConnectionsUseCase>(),
          gh<_i127.ConnectProviderUseCase>(),
          gh<_i131.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i191.EpsConnectionCubit>(() => _i191.EpsConnectionCubit(
          gh<_i141.GetConnectionsUseCase>(),
          gh<_i127.ConnectProviderUseCase>(),
          gh<_i131.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i192.GetHealthSummaryUseCase>(
        () => _i192.GetHealthSummaryUseCase(gh<_i157.HomeRepository>()));
    gh.factory<_i193.HealthRecordCubit>(() => _i193.HealthRecordCubit(
          gh<_i154.HealthRecordRepository>(),
          gh<_i28.FilePickerService>(),
          gh<_i41.ImagePickerService>(),
          gh<_i80.OcrService>(),
          gh<_i103.VectorStoreService>(),
        ));
    gh.factory<_i194.HomeCubit>(() => _i194.HomeCubit(
          gh<_i192.GetHealthSummaryUseCase>(),
          gh<_i157.HomeRepository>(),
        ));
    gh.lazySingleton<_i195.LlmAdapterFactory>(
        () => _i195.LlmAdapterFactory(gh<_i164.LlmSettingsRepository>()));
    gh.lazySingleton<_i162.LlmService>(
      () => _i196.RagLlmService(
        gh<_i103.VectorStoreService>(),
        gh<_i166.MedicalResearchService>(),
        gh<_i100.UserProfileRepository>(),
        gh<_i50.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.factory<_i197.LlmSettingsCubit>(() => _i197.LlmSettingsCubit(
          gh<_i164.LlmSettingsRepository>(),
          gh<_i19.DeviceCapabilityService>(),
          gh<_i50.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i198.MedicalIndexingService>(
        () => _i198.MedicalIndexingService(
              gh<_i56.MedicalKnowledgeRepository>(),
              gh<_i103.VectorStoreService>(),
              gh<_i170.PatientContextIndexer>(),
            ));
    gh.factory<_i199.MedicalResearchCubit>(() => _i199.MedicalResearchCubit(
          gh<_i166.MedicalResearchService>(),
          gh<_i61.MedicalStandardsService>(),
        ));
    gh.factory<_i200.ReportBloc>(() => _i200.ReportBloc(
          gh<_i86.ReportRepository>(),
          gh<_i171.ReportGenerationService>(),
        ));
    gh.factory<_i201.SharingCubit>(() => _i201.SharingCubit(
          bleService: gh<_i123.BleSharingService>(),
          nfcService: gh<_i75.NfcSharingService>(),
          wifiService: gh<_i112.WifiDirectService>(),
          startSharingUseCase: gh<_i178.StartSharingUseCase>(),
          startListeningUseCase: gh<_i177.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i124.CancelSharingUseCase>(),
          walletService: gh<_i25.WalletService>(),
          walletEncryption: gh<_i25.EncryptionService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i202.FhirModule {}

class _$CalendarModule extends _i203.CalendarModule {}

class _$NetworkModule extends _i204.NetworkModule {}

class _$MemoryModule extends _i205.MemoryModule {}

class _$DatabaseModule extends _i206.DatabaseModule {}

class _$ServiceModule extends _i207.ServiceModule {}
