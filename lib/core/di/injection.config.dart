// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i14;
import 'package:dio/dio.dart' as _i22;
import 'package:flutter/services.dart' as _i72;
import 'package:flutter_appauth/flutter_appauth.dart' as _i79;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i76;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i18;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i42;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i25;
import 'package:medical_standards/medical_standards.dart' as _i53;

import '../../features/about/application/about_cubit.dart' as _i109;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i110;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i34;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i35;
import '../../features/allergies/application/allergies_cubit.dart' as _i177;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i111;
import '../../features/allergies/domain/services/allergy_service.dart' as _i5;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i112;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i115;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i113;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i6;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i125;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i132;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i165;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i114;
import '../../features/auth/application/auth_cubit.dart' as _i178;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i179;
import '../../features/auth/domain/auth_service.dart' as _i118;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i116;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i117;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i9;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i26;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i182;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i15;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i150;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i13;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i16;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i183;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i19;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i124;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i123;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i135;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i137;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i181;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i130;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i166;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i176;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i128;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i83;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i88;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i106;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i180;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i44;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i43;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i129;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i84;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i89;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i107;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i131;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i23;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i24;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i184;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i75;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i77;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i122;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i126;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i134;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i78;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i144;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i142;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i31;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i30;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i90;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i143;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i187;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i145;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i146;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i28;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i36;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i80;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i193;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i147;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i32;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i119;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i169;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i170;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i10;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i11;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i71;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i73;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i108;
import '../../features/home/application/home_cubit.dart' as _i188;
import '../../features/home/domain/repositories/home_repository.dart' as _i148;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i186;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i33;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i149;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i168;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i120;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i52;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i54;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i45;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i99;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i46;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i47;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i151;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i152;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i153;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i48;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i156;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i155;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i189;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i55;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i56;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i100;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i154;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i51;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i190;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i70;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i162;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i191;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i57;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i59;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i61;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i12;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i158;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i58;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i60;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i62;
import '../../features/medications/application/medications_cubit.dart' as _i65;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i63;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i64;
import '../../features/meditation/application/meditation_cubit.dart' as _i159;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i67;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i121;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i136;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i138;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i85;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i92;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i66;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i68;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i140;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i139;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i141;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i38;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i37;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i39;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i81;
import '../../features/onboarding/application/sync_cubit.dart' as _i171;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i160;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i161;
import '../../features/reports/application/bloc/report_bloc.dart' as _i192;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i86;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i163;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i87;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i164;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i69;
import '../../features/settings/application/llm_settings_cubit.dart' as _i157;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i91;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i49;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i20;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i50;
import '../../features/sync/application/sync_cubit.dart' as _i185;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i93;
import '../../features/sync/domain/services/sync_service.dart' as _i172;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i127;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i29;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i40;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i94;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i27;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i41;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i74;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i173;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i174;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i95;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i96;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i98;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i97;
import '../../features/vitals/application/vitals_cubit.dart' as _i103;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i101;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i102;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i175;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i104;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i133;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i167;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i17;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i105;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i7;
import '../services/audio/audio_player_service.dart' as _i8;
import '../services/device_capability_service.dart' as _i21;
import '../services/privacy_anonymizer.dart' as _i82;
import 'calendar_module.dart' as _i195;
import 'database_module.dart' as _i198;
import 'fhir_module.dart' as _i194;
import 'memory_module.dart' as _i197;
import 'network_module.dart' as _i196;

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
    gh.lazySingleton<_i3.AIService>(() => _i3.AIService());
    gh.lazySingleton<_i4.AboutLocalDataSource>(
        () => _i4.AboutLocalDataSource());
    gh.lazySingleton<_i3.AgentMemoryService>(() => _i3.AgentMemoryService());
    gh.lazySingleton<_i5.AllergyService>(() => _i5.AllergyService());
    gh.lazySingleton<_i6.AppointmentService>(() => _i6.AppointmentService());
    gh.lazySingleton<_i7.AsrService>(() => _i7.AsrService());
    gh.lazySingleton<_i8.AudioService>(() => _i8.AudioService());
    gh.lazySingleton<_i9.BiometricService>(() => _i9.BiometricService());
    gh.lazySingleton<_i10.BleSharingService>(
        () => _i10.BleSharingService(bleWrapper: gh<_i11.BleWrapper>()));
    gh.lazySingleton<_i11.BleWrapper>(() => _i11.BleWrapper());
    gh.lazySingleton<_i12.BotBypassHandler>(() => _i12.BotBypassHandler());
    gh.factory<_i13.CalendarApiDatasource>(() => _i13.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i14.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i15.CalendarRepository>(
        () => _i16.CalendarRepositoryImpl(gh<_i13.CalendarApiDatasource>()));
    gh.lazySingleton<_i17.ChatAiDatasource>(() => _i17.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i7.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i18.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i19.DashboardLocalDataSource>(
        () => _i19.DashboardLocalDataSource());
    gh.lazySingleton<_i14.DeviceCalendarPlugin>(
        () => calendarModule.deviceCalendarPlugin);
    gh.lazySingleton<_i20.DeviceCapabilityService>(
        () => _i20.DeviceCapabilityService());
    gh.lazySingleton<_i21.DeviceCapabilityService>(
        () => _i21.DeviceCapabilityService());
    gh.lazySingleton<_i22.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i23.EmailRepository>(() => _i24.EmailRepositoryImpl(
          client: gh<_i18.Client>(),
          deviceCalendarPlugin: gh<_i14.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i25.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i26.EncryptionService>(() => _i26.EncryptionService());
    gh.lazySingleton<_i27.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i28.FilePickerService>(
        () => _i28.FilePickerServiceImpl());
    gh.lazySingleton<_i29.FilecoinDatasource>(() => _i29.FilecoinDatasource());
    gh.lazySingleton<_i30.HealthDataImportService>(
        () => _i30.HealthDataImportService());
    gh.lazySingleton<_i31.HealthDataSensorDataSource>(
        () => _i31.HealthDataSensorDataSource());
    gh.lazySingleton<_i32.HealthSharingRemoteDataSource>(
        () => _i32.HealthSharingRemoteDataSource());
    gh.factory<_i33.HealthSummaryDatasource>(
        () => _i33.HealthSummaryDatasource());
    gh.lazySingleton<_i34.IAboutRepository>(() => _i35.AboutRepositoryImpl());
    gh.lazySingleton<_i36.ImagePickerService>(
        () => _i36.ImagePickerServiceImpl());
    gh.lazySingleton<_i37.IncentiveDatasource>(
        () => _i37.IncentiveDatasource());
    gh.lazySingleton<_i38.IncentiveRepository>(
        () => _i39.IncentiveRepositoryImpl(gh<_i37.IncentiveDatasource>()));
    gh.lazySingleton<_i40.IpfsDatasource>(
        () => _i40.IpfsDatasource(gh<_i22.Dio>()));
    gh.lazySingleton<_i41.IpfsService>(() => _i41.IpfsService(
          gh<_i40.IpfsDatasource>(),
          gh<_i29.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i42.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i43.LicenseRegistryLocalDataSource>(() {
      final i = _i43.LicenseRegistryLocalDataSource(gh<_i42.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i44.LicenseVerifier>(() async =>
        _i44.LicenseVerifier(
            await getAsync<_i43.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i45.LlmAdapter>(
      () => _i46.FlutterGemmaAdapter(wrapper: gh<_i47.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i45.LlmAdapter>(
      () => _i48.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i49.LlmSettingsRepository>(
        () => _i50.LlmSettingsRepositoryImpl(gh<_i42.Isar>()));
    gh.lazySingleton<_i51.LocalLlmService>(() => _i51.LocalLlmService());
    gh.lazySingleton<_i52.LocalModelLocalDataSource>(
        () => _i52.LocalModelLocalDataSource());
    gh.lazySingleton<_i53.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i54.MedicalKnowledgeRepository>(
      () => _i55.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i54.MedicalKnowledgeRepository>(
      () => _i56.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.lazySingleton<_i57.MedicalScraperService>(
        () => _i58.MedicalScraperServiceImpl(
              gh<_i22.Dio>(),
              gh<_i12.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i59.MedicalStandardsService>(() =>
        _i60.MedicalStandardsServiceImpl(gh<_i53.MedicalContextProvider>()));
    gh.lazySingleton<_i61.MedicalWebSearchService>(
        () => _i62.MedicalWebSearchServiceImpl(gh<_i22.Dio>()));
    gh.lazySingleton<_i63.MedicationRepository>(
        () => _i64.IsarMedicationRepository(gh<_i42.Isar>()));
    gh.factory<_i65.MedicationsCubit>(
        () => _i65.MedicationsCubit(gh<_i63.MedicationRepository>()));
    gh.lazySingleton<_i66.MeditationLocalDataSource>(
        () => _i66.MeditationLocalDataSource());
    gh.lazySingleton<_i67.MeditationRepository>(() =>
        _i68.MeditationRepositoryImpl(gh<_i66.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i25.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i42.Isar>(),
        gh<_i25.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i69.MockReportGenerationService>(
      () => _i69.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i70.ModelDownloadService>(
        () => _i70.ModelDownloadService());
    gh.lazySingleton<_i71.NfcHandler>(
        () => _i71.NfcHandler(channel: gh<_i72.MethodChannel>()));
    gh.lazySingleton<_i73.NfcSharingService>(
        () => _i73.NfcSharingService(nfcHandler: gh<_i71.NfcHandler>()));
    gh.lazySingleton<_i74.NodeDiscoveryService>(
        () => _i74.NodeDiscoveryService());
    gh.lazySingleton<_i75.OAuthLocalDataSource>(() =>
        _i75.OAuthLocalDataSource(storage: gh<_i76.FlutterSecureStorage>()));
    gh.lazySingleton<_i77.OAuthRepository>(() => _i78.OAuthRepositoryImpl(
          gh<_i75.OAuthLocalDataSource>(),
          appAuth: gh<_i79.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i80.OcrService>(() => _i80.MlKitOcrService());
    gh.factory<_i81.OnboardingCubit>(() => _i81.OnboardingCubit());
    gh.lazySingleton<_i82.PromptScrubber>(
        () => _i82.PromptScrubber(gh<_i42.Isar>()));
    gh.lazySingleton<_i83.RatingRepository>(
        () => _i84.IsarRatingRepository(gh<_i42.Isar>()));
    gh.lazySingleton<_i85.RecommendScriptUseCase>(
        () => _i85.RecommendScriptUseCase(gh<_i67.MeditationRepository>()));
    gh.lazySingleton<_i86.ReportRepository>(
        () => _i87.IsarReportRepository(gh<_i42.Isar>()));
    gh.lazySingleton<_i88.SecondOpinionRepository>(
        () => _i89.IsarSecondOpinionRepository(gh<_i42.Isar>()));
    gh.lazySingleton<_i90.SensorHealthDataSource>(
        () => _i90.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i91.SettingsLocalDataSource>(
        () => _i91.SettingsLocalDataSource(gh<_i42.Isar>()));
    gh.lazySingleton<_i92.StartSessionUseCase>(
        () => _i92.StartSessionUseCase(gh<_i67.MeditationRepository>()));
    gh.lazySingleton<_i93.SyncRepository>(() => _i94.SyncRepositoryImpl(
          gh<_i27.FhirClient>(),
          gh<_i42.Isar>(),
          gh<_i76.FlutterSecureStorage>(),
          gh<_i74.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i53.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i95.UserProfileLocalDataSource>(
        () => _i95.UserProfileLocalDataSource(gh<_i42.Isar>()));
    gh.lazySingleton<_i96.UserProfileRepository>(
        () => _i97.UserProfileRepositoryImpl(gh<_i42.Isar>()));
    gh.lazySingleton<_i98.UserProfileService>(
        () => _i98.UserProfileService(gh<_i96.UserProfileRepository>()));
    gh.lazySingleton<_i99.VectorStoreService>(
        () => _i100.IsarVectorStoreService(
              gh<_i25.MemoryGraph>(),
              gh<_i54.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i101.VitalSignRepository>(
        () => _i102.VitalSignRepositoryImpl(gh<_i42.Isar>()));
    gh.factory<_i103.VitalsCubit>(
        () => _i103.VitalsCubit(gh<_i101.VitalSignRepository>()));
    gh.lazySingleton<_i104.VoiceChatRepository>(
        () => _i105.VoiceChatRepositoryImpl(gh<_i17.ChatAiDatasource>()));
    gh.lazySingleton<_i106.VouchRepository>(
        () => _i107.IsarVouchRepository(gh<_i42.Isar>()));
    gh.lazySingleton<_i108.WifiDirectService>(() => _i108.WifiDirectService());
    gh.factory<_i109.AboutCubit>(
        () => _i109.AboutCubit(gh<_i34.IAboutRepository>()));
    gh.lazySingleton<_i110.AboutRemoteDataSource>(
        () => _i110.AboutRemoteDataSource(gh<_i22.Dio>()));
    gh.lazySingleton<_i111.AllergyRepository>(
        () => _i112.IsarAllergyRepository(gh<_i42.Isar>()));
    gh.lazySingleton<_i113.AppointmentRepository>(
        () => _i114.IsarAppointmentRepository(gh<_i42.Isar>()));
    gh.factory<_i115.AppointmentsCubit>(
        () => _i115.AppointmentsCubit(gh<_i113.AppointmentRepository>()));
    gh.lazySingleton<_i116.AuthRepository>(
        () => _i117.AuthRepositoryImpl(gh<_i42.Isar>()));
    gh.lazySingleton<_i118.AuthService>(
        () => _i118.AuthServiceImpl(gh<_i26.EncryptionService>()));
    gh.lazySingleton<_i119.CancelSharingUseCase>(
        () => _i119.CancelSharingUseCase(
              gh<_i10.BleSharingService>(),
              gh<_i73.NfcSharingService>(),
              gh<_i108.WifiDirectService>(),
            ));
    gh.lazySingleton<_i120.ChatMessageLocalDataSource>(
        () => _i120.ChatMessageLocalDataSource(gh<_i42.Isar>()));
    gh.lazySingleton<_i121.CompleteSessionUseCase>(
        () => _i121.CompleteSessionUseCase(gh<_i67.MeditationRepository>()));
    gh.factory<_i122.ConnectProviderUseCase>(() => _i122.ConnectProviderUseCase(
          gh<_i77.OAuthRepository>(),
          gh<_i96.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i123.DashboardRepository>(
        () => _i124.DashboardRepositoryImpl(
              gh<_i101.VitalSignRepository>(),
              gh<_i63.MedicationRepository>(),
              gh<_i86.ReportRepository>(),
            ));
    gh.factory<_i125.DeleteAppointmentUseCase>(() =>
        _i125.DeleteAppointmentUseCase(gh<_i113.AppointmentRepository>()));
    gh.factory<_i126.DisconnectProviderUseCase>(
        () => _i126.DisconnectProviderUseCase(
              gh<_i77.OAuthRepository>(),
              gh<_i96.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i127.DistributedCacheUsecase>(
        () => _i127.DistributedCacheUsecase(gh<_i41.IpfsService>()));
    gh.lazySingleton<_i128.DoctorProfileRepository>(
        () => _i129.IsarDoctorProfileRepository(gh<_i42.Isar>()));
    gh.factoryAsync<_i130.DoctorVerificationCubit>(
        () async => _i130.DoctorVerificationCubit(
              gh<_i128.DoctorProfileRepository>(),
              gh<_i83.RatingRepository>(),
              await getAsync<_i44.LicenseVerifier>(),
            ));
    gh.factory<_i131.EmailCitasCubit>(() => _i131.EmailCitasCubit(
          gh<_i23.EmailRepository>(),
          gh<_i113.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i90.FileHealthDataSource>(
        () => _i90.FileHealthDataSourceImpl(
              gh<_i28.FilePickerService>(),
              gh<_i80.OcrService>(),
            ));
    gh.factory<_i132.GetAllAppointmentsUseCase>(() =>
        _i132.GetAllAppointmentsUseCase(gh<_i113.AppointmentRepository>()));
    gh.factory<_i133.GetChatHistoryUseCase>(
        () => _i133.GetChatHistoryUseCase(gh<_i104.VoiceChatRepository>()));
    gh.factory<_i134.GetConnectionsUseCase>(
        () => _i134.GetConnectionsUseCase(gh<_i77.OAuthRepository>()));
    gh.factory<_i135.GetDashboardStatsUseCase>(
        () => _i135.GetDashboardStatsUseCase(gh<_i123.DashboardRepository>()));
    gh.lazySingleton<_i136.GetProgressUseCase>(
        () => _i136.GetProgressUseCase(gh<_i67.MeditationRepository>()));
    gh.factory<_i137.GetRecentActivityUseCase>(
        () => _i137.GetRecentActivityUseCase(gh<_i123.DashboardRepository>()));
    gh.lazySingleton<_i138.GetScriptsUseCase>(
        () => _i138.GetScriptsUseCase(gh<_i67.MeditationRepository>()));
    gh.lazySingleton<_i139.GovernanceIpfsDatasource>(
        () => _i139.GovernanceIpfsDatasource(gh<_i40.IpfsDatasource>()));
    gh.lazySingleton<_i140.GovernanceRepository>(() =>
        _i141.GovernanceRepositoryImpl(gh<_i139.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i142.HealthDataFileDataSource>(
        () => _i142.HealthDataFileDataSource(
              gh<_i28.FilePickerService>(),
              gh<_i80.OcrService>(),
            ));
    gh.lazySingleton<_i143.HealthDataRepository>(
        () => _i143.HealthDataRepositoryImpl(
              gh<_i90.SensorHealthDataSource>(),
              gh<_i90.FileHealthDataSource>(),
            ));
    gh.factory<_i144.HealthImportCubit>(() => _i144.HealthImportCubit(
          gh<_i30.HealthDataImportService>(),
          gh<_i101.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i145.HealthRecordRepository>(
        () => _i146.HealthRecordRepositoryImpl(gh<_i42.Isar>()));
    gh.lazySingleton<_i147.HealthSharingLocalDataSource>(
        () => _i147.HealthSharingLocalDataSource(gh<_i42.Isar>()));
    gh.lazySingleton<_i148.HomeRepository>(() => _i149.HomeRepositoryImpl(
          gh<_i101.VitalSignRepository>(),
          gh<_i113.AppointmentRepository>(),
          gh<_i63.MedicationRepository>(),
        ));
    gh.factory<_i150.ImportCalendarUseCase>(() => _i150.ImportCalendarUseCase(
          gh<_i15.CalendarRepository>(),
          gh<_i113.AppointmentRepository>(),
          gh<_i96.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i45.LlmAdapter>(
      () => _i151.GeminiLlmAdapter(
        scrubber: gh<_i82.PromptScrubber>(),
        userProfileRepository: gh<_i96.UserProfileRepository>(),
        modelWrapper: gh<_i152.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i45.LlmAdapter>(
      () => _i153.MockLlmAdapter(gh<_i82.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i154.LlmAdapterFactory>(
        () => _i154.LlmAdapterFactory(gh<_i49.LlmSettingsRepository>()));
    gh.lazySingleton<_i155.LlmService>(() => _i156.GemmaLlmService(
          gh<_i99.VectorStoreService>(),
          gh<_i96.UserProfileRepository>(),
          gh<_i45.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i157.LlmSettingsCubit>(() => _i157.LlmSettingsCubit(
          gh<_i49.LlmSettingsRepository>(),
          gh<_i20.DeviceCapabilityService>(),
          gh<_i45.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i158.MedicalResearchService>(
        () => _i158.MedicalResearchService(
              gh<_i61.MedicalWebSearchService>(),
              gh<_i57.MedicalScraperService>(),
            ));
    gh.factory<_i159.MeditationCubit>(() => _i159.MeditationCubit(
          gh<_i85.RecommendScriptUseCase>(),
          gh<_i92.StartSessionUseCase>(),
          gh<_i121.CompleteSessionUseCase>(),
          gh<_i136.GetProgressUseCase>(),
          gh<_i8.AudioService>(),
        ));
    gh.lazySingleton<_i160.OnboardingRepository>(
        () => _i161.OnboardingRepositoryImpl(gh<_i96.UserProfileRepository>()));
    gh.lazySingleton<_i162.PatientContextIndexer>(
      () => _i162.PatientContextIndexer(
        gh<_i42.Isar>(),
        gh<_i99.VectorStoreService>(),
        gh<_i145.HealthRecordRepository>(),
        gh<_i63.MedicationRepository>(),
        gh<_i111.AllergyRepository>(),
        gh<_i101.VitalSignRepository>(),
        gh<_i113.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i163.ReportGenerationService>(
        () => _i164.GemmaReportGenerationService(
              gh<_i45.LlmAdapter>(instanceName: 'gemma'),
              gh<_i99.VectorStoreService>(),
              gh<_i96.UserProfileRepository>(),
              gh<_i82.PromptScrubber>(),
            ));
    gh.factory<_i165.SaveAppointmentUseCase>(
        () => _i165.SaveAppointmentUseCase(gh<_i113.AppointmentRepository>()));
    gh.factory<_i166.SecondOpinionCubit>(
        () => _i166.SecondOpinionCubit(gh<_i88.SecondOpinionRepository>()));
    gh.factory<_i167.SendMessageUseCase>(
        () => _i167.SendMessageUseCase(gh<_i104.VoiceChatRepository>()));
    gh.lazySingleton<_i168.SmartSearchUseCase>(
        () => _i168.SmartSearchUseCase(gh<_i99.VectorStoreService>()));
    gh.lazySingleton<_i169.StartListeningUseCase>(
        () => _i169.StartListeningUseCase(
              gh<_i10.BleSharingService>(),
              gh<_i73.NfcSharingService>(),
              gh<_i108.WifiDirectService>(),
            ));
    gh.lazySingleton<_i170.StartSharingUseCase>(() => _i170.StartSharingUseCase(
          gh<_i10.BleSharingService>(),
          gh<_i73.NfcSharingService>(),
          gh<_i108.WifiDirectService>(),
        ));
    gh.factory<_i171.SyncCubit>(() => _i171.SyncCubit(
          gh<_i53.SyncService>(),
          gh<_i99.VectorStoreService>(),
        ));
    gh.lazySingleton<_i172.SyncService>(() => _i173.SyncServiceImpl(
          gh<_i93.SyncRepository>(),
          gh<_i53.SyncService>(),
        ));
    gh.factory<_i174.UserProfileCubit>(
        () => _i174.UserProfileCubit(gh<_i96.UserProfileRepository>()));
    gh.factory<_i175.VoiceChatCubit>(() => _i175.VoiceChatCubit(
          gh<_i167.SendMessageUseCase>(),
          gh<_i133.GetChatHistoryUseCase>(),
          gh<_i104.VoiceChatRepository>(),
          gh<_i8.AudioService>(),
        ));
    gh.factory<_i176.VouchCubit>(
        () => _i176.VouchCubit(gh<_i106.VouchRepository>()));
    gh.factory<_i177.AllergiesCubit>(
        () => _i177.AllergiesCubit(gh<_i111.AllergyRepository>()));
    gh.factory<_i178.AuthCubit>(() => _i178.AuthCubit(gh<_i118.AuthService>()));
    gh.factory<_i179.AuthCubit>(() => _i179.AuthCubit(
          gh<_i116.AuthRepository>(),
          gh<_i26.EncryptionService>(),
          gh<_i9.BiometricService>(),
        ));
    gh.lazySingleton<_i180.BadgeCalculator>(() => _i180.BadgeCalculator(
          gh<_i128.DoctorProfileRepository>(),
          gh<_i83.RatingRepository>(),
          gh<_i106.VouchRepository>(),
        ));
    gh.factory<_i181.BadgeCubit>(
        () => _i181.BadgeCubit(gh<_i180.BadgeCalculator>()));
    gh.factory<_i182.CalendarImportCubit>(() => _i182.CalendarImportCubit(
          gh<_i15.CalendarRepository>(),
          gh<_i150.ImportCalendarUseCase>(),
        ));
    gh.factory<_i183.DashboardCubit>(() => _i183.DashboardCubit(
          gh<_i135.GetDashboardStatsUseCase>(),
          gh<_i137.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i184.EpsConnectionCubit>(() => _i184.EpsConnectionCubit(
          gh<_i134.GetConnectionsUseCase>(),
          gh<_i122.ConnectProviderUseCase>(),
          gh<_i126.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i185.FhirSyncCubit>(() => _i185.FhirSyncCubit(
          gh<_i172.SyncService>(),
          gh<_i74.NodeDiscoveryService>(),
        ));
    gh.factory<_i186.GetHealthSummaryUseCase>(
        () => _i186.GetHealthSummaryUseCase(gh<_i148.HomeRepository>()));
    gh.factory<_i187.HealthRecordCubit>(() => _i187.HealthRecordCubit(
          gh<_i145.HealthRecordRepository>(),
          gh<_i28.FilePickerService>(),
          gh<_i36.ImagePickerService>(),
          gh<_i80.OcrService>(),
          gh<_i99.VectorStoreService>(),
        ));
    gh.factory<_i188.HomeCubit>(() => _i188.HomeCubit(
          gh<_i186.GetHealthSummaryUseCase>(),
          gh<_i148.HomeRepository>(),
        ));
    gh.lazySingleton<_i155.LlmService>(
      () => _i189.RagLlmService(
        gh<_i99.VectorStoreService>(),
        gh<_i158.MedicalResearchService>(),
        gh<_i96.UserProfileRepository>(),
        gh<_i45.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i190.MedicalIndexingService>(
        () => _i190.MedicalIndexingService(
              gh<_i54.MedicalKnowledgeRepository>(),
              gh<_i99.VectorStoreService>(),
              gh<_i162.PatientContextIndexer>(),
            ));
    gh.factory<_i191.MedicalResearchCubit>(() => _i191.MedicalResearchCubit(
          gh<_i158.MedicalResearchService>(),
          gh<_i59.MedicalStandardsService>(),
        ));
    gh.factory<_i192.ReportBloc>(() => _i192.ReportBloc(
          gh<_i86.ReportRepository>(),
          gh<_i163.ReportGenerationService>(),
        ));
    gh.factory<_i193.SharingCubit>(() => _i193.SharingCubit(
          bleService: gh<_i10.BleSharingService>(),
          nfcService: gh<_i73.NfcSharingService>(),
          wifiService: gh<_i108.WifiDirectService>(),
          startSharingUseCase: gh<_i170.StartSharingUseCase>(),
          startListeningUseCase: gh<_i169.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i119.CancelSharingUseCase>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i194.FhirModule {}

class _$CalendarModule extends _i195.CalendarModule {}

class _$NetworkModule extends _i196.NetworkModule {}

class _$MemoryModule extends _i197.MemoryModule {}

class _$DatabaseModule extends _i198.DatabaseModule {}
