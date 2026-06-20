// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i15;
import 'package:dio/dio.dart' as _i23;
import 'package:flutter/services.dart' as _i73;
import 'package:flutter_appauth/flutter_appauth.dart' as _i80;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i77;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i19;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i43;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i26;
import 'package:medical_standards/medical_standards.dart' as _i54;

import '../../features/about/application/about_cubit.dart' as _i109;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i5;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i35;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i36;
import '../../features/allergies/application/allergies_cubit.dart' as _i177;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i110;
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i111;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i114;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i112;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i7;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i124;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i131;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i164;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i113;
import '../../features/auth/application/auth_cubit.dart' as _i179;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i178;
import '../../features/auth/domain/auth_service.dart' as _i117;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i115;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i116;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i10;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i27;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i182;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i16;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i149;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i14;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i17;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i183;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i20;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i123;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i122;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i134;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i136;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i181;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i129;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i165;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i176;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i127;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i84;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i89;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i106;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i180;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i45;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i44;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i128;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i85;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i90;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i107;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i130;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i24;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i25;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i184;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i76;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i78;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i121;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i125;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i133;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i79;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i143;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i141;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i32;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i31;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i91;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i142;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i187;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i144;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i145;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i29;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i37;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i81;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i193;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i146;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i33;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i118;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i168;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i169;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i11;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i12;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i72;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i74;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i108;
import '../../features/home/application/home_cubit.dart' as _i188;
import '../../features/home/domain/repositories/home_repository.dart' as _i147;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i186;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i34;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i148;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i167;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i119;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i53;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i55;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i46;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i99;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i47;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i48;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i150;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i151;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i152;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i49;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i155;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i154;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i189;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i57;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i56;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i100;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i153;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i52;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i190;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i71;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i161;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i191;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i58;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i60;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i62;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i13;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i157;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i59;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i61;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i63;
import '../../features/medications/application/medications_cubit.dart' as _i66;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i64;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i65;
import '../../features/meditation/application/meditation_cubit.dart' as _i158;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i68;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i120;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i135;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i137;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i86;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i93;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i67;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i69;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i139;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i138;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i140;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i39;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i38;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i40;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i82;
import '../../features/onboarding/application/sync_cubit.dart' as _i170;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i159;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i160;
import '../../features/reports/application/bloc/report_bloc.dart' as _i192;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i87;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i162;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i88;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i163;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i70;
import '../../features/settings/application/llm_settings_cubit.dart' as _i156;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i92;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i50;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i21;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i51;
import '../../features/sync/application/sync_cubit.dart' as _i185;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i173;
import '../../features/sync/domain/services/sync_service.dart' as _i171;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i126;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i30;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i41;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i94;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i28;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i42;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i75;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i172;
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
    as _i132;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i166;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i18;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i105;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i8;
import '../services/audio/audio_player_service.dart' as _i9;
import '../services/device_capability_service.dart' as _i22;
import '../services/privacy_anonymizer.dart' as _i83;
import 'calendar_module.dart' as _i195;
import 'database_module.dart' as _i198;
import 'fhir_module.dart' as _i194;
import 'memory_module.dart' as _i197;
import 'network_module.dart' as _i196;

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
    final fhirModule = _$FhirModule();
    final calendarModule = _$CalendarModule();
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.AIService>(() => _i3.AIService());
    gh.lazySingleton<_i4.AboutLocalDataSource>(
        () => _i4.AboutLocalDataSource());
    gh.lazySingleton<_i5.AboutRemoteDataSource>(
        () => _i5.AboutRemoteDataSource());
    gh.lazySingleton<_i3.AgentMemoryService>(() => _i3.AgentMemoryService());
    gh.lazySingleton<_i6.AllergyService>(() => _i6.AllergyService());
    gh.lazySingleton<_i7.AppointmentService>(() => _i7.AppointmentService());
    gh.lazySingleton<_i8.AsrService>(() => _i8.AsrService());
    gh.lazySingleton<_i9.AudioService>(() => _i9.AudioService());
    gh.lazySingleton<_i10.BiometricService>(() => _i10.BiometricService());
    gh.lazySingleton<_i11.BleSharingService>(
        () => _i11.BleSharingService(bleWrapper: gh<_i12.BleWrapper>()));
    gh.lazySingleton<_i12.BleWrapper>(() => _i12.BleWrapper());
    gh.lazySingleton<_i13.BotBypassHandler>(() => _i13.BotBypassHandler());
    gh.factory<_i14.CalendarApiDatasource>(() => _i14.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i15.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i16.CalendarRepository>(
        () => _i17.CalendarRepositoryImpl(gh<_i14.CalendarApiDatasource>()));
    gh.lazySingleton<_i18.ChatAiDatasource>(() => _i18.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i8.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i19.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i20.DashboardLocalDataSource>(
        () => _i20.DashboardLocalDataSource());
    gh.lazySingleton<_i15.DeviceCalendarPlugin>(
        () => calendarModule.deviceCalendarPlugin);
    gh.lazySingleton<_i21.DeviceCapabilityService>(
        () => _i21.DeviceCapabilityService());
    gh.lazySingleton<_i22.DeviceCapabilityService>(
        () => _i22.DeviceCapabilityService());
    gh.lazySingleton<_i23.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i24.EmailRepository>(() => _i25.EmailRepositoryImpl(
          client: gh<_i19.Client>(),
          deviceCalendarPlugin: gh<_i15.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i26.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i27.EncryptionService>(() => _i27.EncryptionService());
    gh.lazySingleton<_i28.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i29.FilePickerService>(
        () => _i29.FilePickerServiceImpl());
    gh.lazySingleton<_i30.FilecoinDatasource>(() => _i30.FilecoinDatasource());
    gh.lazySingleton<_i31.HealthDataImportService>(
        () => _i31.HealthDataImportService());
    gh.lazySingleton<_i32.HealthDataSensorDataSource>(
        () => _i32.HealthDataSensorDataSource());
    gh.lazySingleton<_i33.HealthSharingRemoteDataSource>(
        () => _i33.HealthSharingRemoteDataSource());
    gh.factory<_i34.HealthSummaryDatasource>(
        () => _i34.HealthSummaryDatasource());
    gh.lazySingleton<_i35.IAboutRepository>(() => _i36.AboutRepositoryImpl());
    gh.lazySingleton<_i37.ImagePickerService>(
        () => _i37.ImagePickerServiceImpl());
    gh.lazySingleton<_i38.IncentiveDatasource>(
        () => _i38.IncentiveDatasource());
    gh.lazySingleton<_i39.IncentiveRepository>(
        () => _i40.IncentiveRepositoryImpl(gh<_i38.IncentiveDatasource>()));
    gh.lazySingleton<_i41.IpfsDatasource>(
        () => _i41.IpfsDatasource(gh<_i23.Dio>()));
    gh.lazySingleton<_i42.IpfsService>(() => _i42.IpfsService(
          gh<_i41.IpfsDatasource>(),
          gh<_i30.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i43.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i44.LicenseRegistryLocalDataSource>(() {
      final i = _i44.LicenseRegistryLocalDataSource(gh<_i43.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i45.LicenseVerifier>(() async =>
        _i45.LicenseVerifier(
            await getAsync<_i44.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i46.LlmAdapter>(
      () => _i47.FlutterGemmaAdapter(wrapper: gh<_i48.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i46.LlmAdapter>(
      () => _i49.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i50.LlmSettingsRepository>(
        () => _i51.LlmSettingsRepositoryImpl(gh<_i43.Isar>()));
    gh.lazySingleton<_i52.LocalLlmService>(() => _i52.LocalLlmService());
    gh.lazySingleton<_i53.LocalModelLocalDataSource>(
        () => _i53.LocalModelLocalDataSource());
    gh.lazySingleton<_i54.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i55.MedicalKnowledgeRepository>(
      () => _i56.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i55.MedicalKnowledgeRepository>(
      () => _i57.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.lazySingleton<_i58.MedicalScraperService>(
        () => _i59.MedicalScraperServiceImpl(
              gh<_i23.Dio>(),
              gh<_i13.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i60.MedicalStandardsService>(() =>
        _i61.MedicalStandardsServiceImpl(gh<_i54.MedicalContextProvider>()));
    gh.lazySingleton<_i62.MedicalWebSearchService>(
        () => _i63.MedicalWebSearchServiceImpl(gh<_i23.Dio>()));
    gh.lazySingleton<_i64.MedicationRepository>(
        () => _i65.IsarMedicationRepository(gh<_i43.Isar>()));
    gh.factory<_i66.MedicationsCubit>(
        () => _i66.MedicationsCubit(gh<_i64.MedicationRepository>()));
    gh.lazySingleton<_i67.MeditationLocalDataSource>(
        () => _i67.MeditationLocalDataSource());
    gh.lazySingleton<_i68.MeditationRepository>(() =>
        _i69.MeditationRepositoryImpl(gh<_i67.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i26.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i43.Isar>(),
        gh<_i26.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i70.MockReportGenerationService>(
      () => _i70.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i71.ModelDownloadService>(
        () => _i71.ModelDownloadService());
    gh.lazySingleton<_i72.NfcHandler>(
        () => _i72.NfcHandler(channel: gh<_i73.MethodChannel>()));
    gh.lazySingleton<_i74.NfcSharingService>(
        () => _i74.NfcSharingService(nfcHandler: gh<_i72.NfcHandler>()));
    gh.lazySingleton<_i75.NodeDiscoveryService>(
        () => _i75.NodeDiscoveryService());
    gh.lazySingleton<_i76.OAuthLocalDataSource>(() =>
        _i76.OAuthLocalDataSource(storage: gh<_i77.FlutterSecureStorage>()));
    gh.lazySingleton<_i78.OAuthRepository>(() => _i79.OAuthRepositoryImpl(
          gh<_i76.OAuthLocalDataSource>(),
          appAuth: gh<_i80.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i81.OcrService>(() => _i81.MlKitOcrService());
    gh.factory<_i82.OnboardingCubit>(() => _i82.OnboardingCubit());
    gh.lazySingleton<_i83.PromptScrubber>(
        () => _i83.PromptScrubber(gh<_i43.Isar>()));
    gh.lazySingleton<_i84.RatingRepository>(
        () => _i85.IsarRatingRepository(gh<_i43.Isar>()));
    gh.lazySingleton<_i86.RecommendScriptUseCase>(
        () => _i86.RecommendScriptUseCase(gh<_i68.MeditationRepository>()));
    gh.lazySingleton<_i87.ReportRepository>(
        () => _i88.IsarReportRepository(gh<_i43.Isar>()));
    gh.lazySingleton<_i89.SecondOpinionRepository>(
        () => _i90.IsarSecondOpinionRepository(gh<_i43.Isar>()));
    gh.lazySingleton<_i91.SensorHealthDataSource>(
        () => _i91.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i92.SettingsLocalDataSource>(
        () => _i92.SettingsLocalDataSource(gh<_i43.Isar>()));
    gh.lazySingleton<_i93.StartSessionUseCase>(
        () => _i93.StartSessionUseCase(gh<_i68.MeditationRepository>()));
    gh.lazySingleton<_i94.SyncRepositoryImpl>(() => _i94.SyncRepositoryImpl(
          gh<_i28.FhirClient>(),
          gh<_i43.Isar>(),
          gh<_i77.FlutterSecureStorage>(),
          gh<_i75.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i54.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i95.UserProfileLocalDataSource>(
        () => _i95.UserProfileLocalDataSource(gh<_i43.Isar>()));
    gh.lazySingleton<_i96.UserProfileRepository>(
        () => _i97.UserProfileRepositoryImpl(gh<_i43.Isar>()));
    gh.lazySingleton<_i98.UserProfileService>(
        () => _i98.UserProfileService(gh<_i96.UserProfileRepository>()));
    gh.lazySingleton<_i99.VectorStoreService>(
        () => _i100.IsarVectorStoreService(
              gh<_i26.MemoryGraph>(),
              gh<_i55.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i101.VitalSignRepository>(
        () => _i102.VitalSignRepositoryImpl(gh<_i43.Isar>()));
    gh.factory<_i103.VitalsCubit>(
        () => _i103.VitalsCubit(gh<_i101.VitalSignRepository>()));
    gh.lazySingleton<_i104.VoiceChatRepository>(
        () => _i105.VoiceChatRepositoryImpl(gh<_i18.ChatAiDatasource>()));
    gh.lazySingleton<_i106.VouchRepository>(
        () => _i107.IsarVouchRepository(gh<_i43.Isar>()));
    gh.lazySingleton<_i108.WifiDirectService>(() => _i108.WifiDirectService());
    gh.factory<_i109.AboutCubit>(
        () => _i109.AboutCubit(gh<_i35.IAboutRepository>()));
    gh.lazySingleton<_i110.AllergyRepository>(
        () => _i111.IsarAllergyRepository(gh<_i43.Isar>()));
    gh.lazySingleton<_i112.AppointmentRepository>(
        () => _i113.IsarAppointmentRepository(gh<_i43.Isar>()));
    gh.factory<_i114.AppointmentsCubit>(
        () => _i114.AppointmentsCubit(gh<_i112.AppointmentRepository>()));
    gh.lazySingleton<_i115.AuthRepository>(
        () => _i116.AuthRepositoryImpl(gh<_i43.Isar>()));
    gh.lazySingleton<_i117.AuthService>(
        () => _i117.AuthServiceImpl(gh<_i27.EncryptionService>()));
    gh.lazySingleton<_i118.CancelSharingUseCase>(
        () => _i118.CancelSharingUseCase(
              gh<_i11.BleSharingService>(),
              gh<_i74.NfcSharingService>(),
              gh<_i108.WifiDirectService>(),
            ));
    gh.lazySingleton<_i119.ChatMessageLocalDataSource>(
        () => _i119.ChatMessageLocalDataSource(gh<_i43.Isar>()));
    gh.lazySingleton<_i120.CompleteSessionUseCase>(
        () => _i120.CompleteSessionUseCase(gh<_i68.MeditationRepository>()));
    gh.factory<_i121.ConnectProviderUseCase>(() => _i121.ConnectProviderUseCase(
          gh<_i78.OAuthRepository>(),
          gh<_i96.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i122.DashboardRepository>(
        () => _i123.DashboardRepositoryImpl(
              gh<_i101.VitalSignRepository>(),
              gh<_i64.MedicationRepository>(),
              gh<_i87.ReportRepository>(),
            ));
    gh.factory<_i124.DeleteAppointmentUseCase>(() =>
        _i124.DeleteAppointmentUseCase(gh<_i112.AppointmentRepository>()));
    gh.factory<_i125.DisconnectProviderUseCase>(
        () => _i125.DisconnectProviderUseCase(
              gh<_i78.OAuthRepository>(),
              gh<_i96.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i126.DistributedCacheUsecase>(
        () => _i126.DistributedCacheUsecase(gh<_i42.IpfsService>()));
    gh.lazySingleton<_i127.DoctorProfileRepository>(
        () => _i128.IsarDoctorProfileRepository(gh<_i43.Isar>()));
    gh.factoryAsync<_i129.DoctorVerificationCubit>(
        () async => _i129.DoctorVerificationCubit(
              gh<_i127.DoctorProfileRepository>(),
              gh<_i84.RatingRepository>(),
              await getAsync<_i45.LicenseVerifier>(),
            ));
    gh.factory<_i130.EmailCitasCubit>(() => _i130.EmailCitasCubit(
          gh<_i24.EmailRepository>(),
          gh<_i112.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i91.FileHealthDataSource>(
        () => _i91.FileHealthDataSourceImpl(
              gh<_i29.FilePickerService>(),
              gh<_i81.OcrService>(),
            ));
    gh.factory<_i131.GetAllAppointmentsUseCase>(() =>
        _i131.GetAllAppointmentsUseCase(gh<_i112.AppointmentRepository>()));
    gh.factory<_i132.GetChatHistoryUseCase>(
        () => _i132.GetChatHistoryUseCase(gh<_i104.VoiceChatRepository>()));
    gh.factory<_i133.GetConnectionsUseCase>(
        () => _i133.GetConnectionsUseCase(gh<_i78.OAuthRepository>()));
    gh.factory<_i134.GetDashboardStatsUseCase>(
        () => _i134.GetDashboardStatsUseCase(gh<_i122.DashboardRepository>()));
    gh.lazySingleton<_i135.GetProgressUseCase>(
        () => _i135.GetProgressUseCase(gh<_i68.MeditationRepository>()));
    gh.factory<_i136.GetRecentActivityUseCase>(
        () => _i136.GetRecentActivityUseCase(gh<_i122.DashboardRepository>()));
    gh.lazySingleton<_i137.GetScriptsUseCase>(
        () => _i137.GetScriptsUseCase(gh<_i68.MeditationRepository>()));
    gh.lazySingleton<_i138.GovernanceIpfsDatasource>(
        () => _i138.GovernanceIpfsDatasource(gh<_i41.IpfsDatasource>()));
    gh.lazySingleton<_i139.GovernanceRepository>(() =>
        _i140.GovernanceRepositoryImpl(gh<_i138.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i141.HealthDataFileDataSource>(
        () => _i141.HealthDataFileDataSource(
              gh<_i29.FilePickerService>(),
              gh<_i81.OcrService>(),
            ));
    gh.lazySingleton<_i142.HealthDataRepository>(
        () => _i142.HealthDataRepositoryImpl(
              gh<_i91.SensorHealthDataSource>(),
              gh<_i91.FileHealthDataSource>(),
            ));
    gh.factory<_i143.HealthImportCubit>(() => _i143.HealthImportCubit(
          gh<_i31.HealthDataImportService>(),
          gh<_i101.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i144.HealthRecordRepository>(
        () => _i145.HealthRecordRepositoryImpl(gh<_i43.Isar>()));
    gh.lazySingleton<_i146.HealthSharingLocalDataSource>(
        () => _i146.HealthSharingLocalDataSource(gh<_i43.Isar>()));
    gh.lazySingleton<_i147.HomeRepository>(() => _i148.HomeRepositoryImpl(
          gh<_i101.VitalSignRepository>(),
          gh<_i112.AppointmentRepository>(),
          gh<_i64.MedicationRepository>(),
        ));
    gh.factory<_i149.ImportCalendarUseCase>(() => _i149.ImportCalendarUseCase(
          gh<_i16.CalendarRepository>(),
          gh<_i112.AppointmentRepository>(),
          gh<_i96.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i46.LlmAdapter>(
      () => _i150.GeminiLlmAdapter(
        scrubber: gh<_i83.PromptScrubber>(),
        userProfileRepository: gh<_i96.UserProfileRepository>(),
        modelWrapper: gh<_i151.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i46.LlmAdapter>(
      () => _i152.MockLlmAdapter(gh<_i83.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i153.LlmAdapterFactory>(
        () => _i153.LlmAdapterFactory(gh<_i50.LlmSettingsRepository>()));
    gh.lazySingleton<_i154.LlmService>(() => _i155.GemmaLlmService(
          gh<_i99.VectorStoreService>(),
          gh<_i96.UserProfileRepository>(),
          gh<_i46.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i156.LlmSettingsCubit>(() => _i156.LlmSettingsCubit(
          gh<_i50.LlmSettingsRepository>(),
          gh<_i21.DeviceCapabilityService>(),
          gh<_i46.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i157.MedicalResearchService>(
        () => _i157.MedicalResearchService(
              gh<_i62.MedicalWebSearchService>(),
              gh<_i58.MedicalScraperService>(),
            ));
    gh.factory<_i158.MeditationCubit>(() => _i158.MeditationCubit(
          gh<_i86.RecommendScriptUseCase>(),
          gh<_i93.StartSessionUseCase>(),
          gh<_i120.CompleteSessionUseCase>(),
          gh<_i135.GetProgressUseCase>(),
          gh<_i9.AudioService>(),
        ));
    gh.lazySingleton<_i159.OnboardingRepository>(
        () => _i160.OnboardingRepositoryImpl(gh<_i96.UserProfileRepository>()));
    gh.lazySingleton<_i161.PatientContextIndexer>(
      () => _i161.PatientContextIndexer(
        gh<_i43.Isar>(),
        gh<_i99.VectorStoreService>(),
        gh<_i144.HealthRecordRepository>(),
        gh<_i64.MedicationRepository>(),
        gh<_i110.AllergyRepository>(),
        gh<_i101.VitalSignRepository>(),
        gh<_i112.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i162.ReportGenerationService>(
        () => _i163.GemmaReportGenerationService(
              gh<_i46.LlmAdapter>(instanceName: 'gemma'),
              gh<_i99.VectorStoreService>(),
              gh<_i96.UserProfileRepository>(),
              gh<_i83.PromptScrubber>(),
            ));
    gh.factory<_i164.SaveAppointmentUseCase>(
        () => _i164.SaveAppointmentUseCase(gh<_i112.AppointmentRepository>()));
    gh.factory<_i165.SecondOpinionCubit>(
        () => _i165.SecondOpinionCubit(gh<_i89.SecondOpinionRepository>()));
    gh.factory<_i166.SendMessageUseCase>(
        () => _i166.SendMessageUseCase(gh<_i104.VoiceChatRepository>()));
    gh.lazySingleton<_i167.SmartSearchUseCase>(
        () => _i167.SmartSearchUseCase(gh<_i99.VectorStoreService>()));
    gh.lazySingleton<_i168.StartListeningUseCase>(
        () => _i168.StartListeningUseCase(
              gh<_i11.BleSharingService>(),
              gh<_i74.NfcSharingService>(),
              gh<_i108.WifiDirectService>(),
            ));
    gh.lazySingleton<_i169.StartSharingUseCase>(() => _i169.StartSharingUseCase(
          gh<_i11.BleSharingService>(),
          gh<_i74.NfcSharingService>(),
          gh<_i108.WifiDirectService>(),
        ));
    gh.factory<_i170.SyncCubit>(() => _i170.SyncCubit(
          gh<_i54.SyncService>(),
          gh<_i99.VectorStoreService>(),
        ));
    gh.lazySingleton<_i171.SyncService>(() => _i172.SyncServiceImpl(
          gh<_i173.SyncRepository>(),
          gh<_i54.SyncService>(),
        ));
    gh.factory<_i174.UserProfileCubit>(
        () => _i174.UserProfileCubit(gh<_i96.UserProfileRepository>()));
    gh.factory<_i175.VoiceChatCubit>(() => _i175.VoiceChatCubit(
          gh<_i166.SendMessageUseCase>(),
          gh<_i132.GetChatHistoryUseCase>(),
          gh<_i104.VoiceChatRepository>(),
          gh<_i9.AudioService>(),
        ));
    gh.factory<_i176.VouchCubit>(
        () => _i176.VouchCubit(gh<_i106.VouchRepository>()));
    gh.factory<_i177.AllergiesCubit>(
        () => _i177.AllergiesCubit(gh<_i110.AllergyRepository>()));
    gh.factory<_i178.AuthCubit>(() => _i178.AuthCubit(
          gh<_i115.AuthRepository>(),
          gh<_i27.EncryptionService>(),
          gh<_i10.BiometricService>(),
        ));
    gh.factory<_i179.AuthCubit>(() => _i179.AuthCubit(gh<_i117.AuthService>()));
    gh.lazySingleton<_i180.BadgeCalculator>(() => _i180.BadgeCalculator(
          gh<_i127.DoctorProfileRepository>(),
          gh<_i84.RatingRepository>(),
          gh<_i106.VouchRepository>(),
        ));
    gh.factory<_i181.BadgeCubit>(
        () => _i181.BadgeCubit(gh<_i180.BadgeCalculator>()));
    gh.factory<_i182.CalendarImportCubit>(() => _i182.CalendarImportCubit(
          gh<_i16.CalendarRepository>(),
          gh<_i149.ImportCalendarUseCase>(),
        ));
    gh.factory<_i183.DashboardCubit>(() => _i183.DashboardCubit(
          gh<_i134.GetDashboardStatsUseCase>(),
          gh<_i136.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i184.EpsConnectionCubit>(() => _i184.EpsConnectionCubit(
          gh<_i133.GetConnectionsUseCase>(),
          gh<_i121.ConnectProviderUseCase>(),
          gh<_i125.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i185.FhirSyncCubit>(() => _i185.FhirSyncCubit(
          gh<_i171.SyncService>(),
          gh<_i75.NodeDiscoveryService>(),
        ));
    gh.factory<_i186.GetHealthSummaryUseCase>(
        () => _i186.GetHealthSummaryUseCase(gh<_i147.HomeRepository>()));
    gh.factory<_i187.HealthRecordCubit>(() => _i187.HealthRecordCubit(
          gh<_i144.HealthRecordRepository>(),
          gh<_i29.FilePickerService>(),
          gh<_i37.ImagePickerService>(),
          gh<_i81.OcrService>(),
          gh<_i99.VectorStoreService>(),
        ));
    gh.factory<_i188.HomeCubit>(() => _i188.HomeCubit(
          gh<_i186.GetHealthSummaryUseCase>(),
          gh<_i147.HomeRepository>(),
        ));
    gh.lazySingleton<_i154.LlmService>(
      () => _i189.RagLlmService(
        gh<_i99.VectorStoreService>(),
        gh<_i157.MedicalResearchService>(),
        gh<_i96.UserProfileRepository>(),
        gh<_i46.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i190.MedicalIndexingService>(
        () => _i190.MedicalIndexingService(
              gh<_i55.MedicalKnowledgeRepository>(),
              gh<_i99.VectorStoreService>(),
              gh<_i161.PatientContextIndexer>(),
            ));
    gh.factory<_i191.MedicalResearchCubit>(() => _i191.MedicalResearchCubit(
          gh<_i157.MedicalResearchService>(),
          gh<_i60.MedicalStandardsService>(),
        ));
    gh.factory<_i192.ReportBloc>(() => _i192.ReportBloc(
          gh<_i87.ReportRepository>(),
          gh<_i162.ReportGenerationService>(),
        ));
    gh.factory<_i193.SharingCubit>(() => _i193.SharingCubit(
          bleService: gh<_i11.BleSharingService>(),
          nfcService: gh<_i74.NfcSharingService>(),
          wifiService: gh<_i108.WifiDirectService>(),
          startSharingUseCase: gh<_i169.StartSharingUseCase>(),
          startListeningUseCase: gh<_i168.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i118.CancelSharingUseCase>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i194.FhirModule {}

class _$CalendarModule extends _i195.CalendarModule {}

class _$NetworkModule extends _i196.NetworkModule {}

class _$MemoryModule extends _i197.MemoryModule {}

class _$DatabaseModule extends _i198.DatabaseModule {}
