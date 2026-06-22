// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i15;
import 'package:dio/dio.dart' as _i23;
import 'package:flutter/services.dart' as _i74;
import 'package:flutter_appauth/flutter_appauth.dart' as _i81;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i78;
import 'package:get_it/get_it.dart' as _i1;
import 'package:health_wallet/health_wallet.dart' as _i27;
import 'package:http/http.dart' as _i19;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i44;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i26;
import 'package:medical_standards/medical_standards.dart' as _i55;

import '../../features/about/application/about_cubit.dart' as _i111;
import '../../features/about/data/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/data/datasources/about_remote_datasource.dart'
    as _i5;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i36;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i37;
import '../../features/allergies/application/allergies_cubit.dart' as _i178;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i112;
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i113;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i116;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i114;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i7;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i126;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i133;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i166;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i115;
import '../../features/auth/application/auth_cubit.dart' as _i180;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i179;
import '../../features/auth/domain/auth_service.dart' as _i119;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i117;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i118;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i10;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i28;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i183;
import '../../features/calendar_import/domain/repositories/calendar_repository.dart'
    as _i16;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
    as _i151;
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i14;
import '../../features/calendar_import/infrastructure/repositories/calendar_repository_impl.dart'
    as _i17;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i184;
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart'
    as _i20;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i125;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i124;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i136;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i138;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i182;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i131;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i167;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i177;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i129;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i85;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i90;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
    as _i108;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i181;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i46;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i45;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i130;
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i86;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i91;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
    as _i109;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i132;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i24;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i25;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i185;
import '../../features/eps_connection/data/datasources/oauth_local_datasource.dart'
    as _i77;
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i79;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i123;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i127;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i135;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i80;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i145;
import '../../features/health_data_import/data/datasources/health_data_file_datasource.dart'
    as _i143;
import '../../features/health_data_import/data/datasources/health_data_sensor_datasource.dart'
    as _i33;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i32;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i92;
import '../../features/health_data_import/infrastructure/health_data_repository_impl.dart'
    as _i144;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i188;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i146;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i147;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i30;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i38;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i82;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i194;
import '../../features/health_sharing/data/datasources/health_sharing_local_datasource.dart'
    as _i148;
import '../../features/health_sharing/data/datasources/health_sharing_remote_datasource.dart'
    as _i34;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
    as _i120;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i170;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i171;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i11;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i12;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i73;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i75;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i110;
import '../../features/home/application/home_cubit.dart' as _i189;
import '../../features/home/domain/repositories/home_repository.dart' as _i149;
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i187;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i35;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i150;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i169;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i121;
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i54;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i56;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i47;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i101;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i49;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i50;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i152;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i153;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i154;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i48;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i157;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i156;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i190;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i58;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i57;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i102;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i155;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i53;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i191;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i72;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i163;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i192;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i59;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i61;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i63;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i13;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i159;
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
import '../../features/meditation/application/meditation_cubit.dart' as _i160;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i69;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i122;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i137;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i139;
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i87;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i94;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i68;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i70;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i141;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i140;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i142;
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i40;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i39;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i41;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i83;
import '../../features/onboarding/application/sync_cubit.dart' as _i172;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i161;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i162;
import '../../features/reports/application/bloc/report_bloc.dart' as _i193;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i88;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i164;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i89;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i165;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i71;
import '../../features/settings/application/llm_settings_cubit.dart' as _i158;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i93;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i51;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i21;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i52;
import '../../features/sync/application/sync_cubit.dart' as _i186;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i95;
import '../../features/sync/domain/services/sync_service.dart' as _i173;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i128;
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i31;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i42;
import '../../features/sync/infrastructure/repositories/sync_repository.dart'
    as _i96;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i29;
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i43;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i76;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i174;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i175;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i97;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i98;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i100;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i99;
import '../../features/vitals/application/vitals_cubit.dart' as _i105;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i103;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i104;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i176;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i106;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i134;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i168;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i18;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i107;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i8;
import '../services/audio/audio_player_service.dart' as _i9;
import '../services/device_capability_service.dart' as _i22;
import '../services/privacy_anonymizer.dart' as _i84;
import 'calendar_module.dart' as _i196;
import 'database_module.dart' as _i199;
import 'fhir_module.dart' as _i195;
import 'memory_module.dart' as _i198;
import 'network_module.dart' as _i197;

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
    gh.lazySingleton<_i27.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i28.EncryptionService>(() => _i28.EncryptionService());
    gh.lazySingleton<_i29.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i30.FilePickerService>(
        () => _i30.FilePickerServiceImpl());
    gh.lazySingleton<_i31.FilecoinDatasource>(() => _i31.FilecoinDatasource());
    gh.lazySingleton<_i32.HealthDataImportService>(
        () => _i32.HealthDataImportService());
    gh.lazySingleton<_i33.HealthDataSensorDataSource>(
        () => _i33.HealthDataSensorDataSource());
    gh.lazySingleton<_i34.HealthSharingRemoteDataSource>(
        () => _i34.HealthSharingRemoteDataSource());
    gh.factory<_i35.HealthSummaryDatasource>(
        () => _i35.HealthSummaryDatasource());
    gh.lazySingleton<_i36.IAboutRepository>(() => _i37.AboutRepositoryImpl());
    gh.lazySingleton<_i38.ImagePickerService>(
        () => _i38.ImagePickerServiceImpl());
    gh.lazySingleton<_i39.IncentiveDatasource>(
        () => _i39.IncentiveDatasource());
    gh.lazySingleton<_i40.IncentiveRepository>(
        () => _i41.IncentiveRepositoryImpl(gh<_i39.IncentiveDatasource>()));
    gh.lazySingleton<_i42.IpfsDatasource>(
        () => _i42.IpfsDatasource(gh<_i23.Dio>()));
    gh.lazySingleton<_i43.IpfsService>(() => _i43.IpfsService(
          gh<_i42.IpfsDatasource>(),
          gh<_i31.FilecoinDatasource>(),
        ));
    await gh.factoryAsync<_i44.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i45.LicenseRegistryLocalDataSource>(() {
      final i = _i45.LicenseRegistryLocalDataSource(gh<_i44.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i46.LicenseVerifier>(() async =>
        _i46.LicenseVerifier(
            await getAsync<_i45.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i47.LlmAdapter>(
      () => _i48.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i47.LlmAdapter>(
      () => _i49.FlutterGemmaAdapter(wrapper: gh<_i50.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i51.LlmSettingsRepository>(
        () => _i52.LlmSettingsRepositoryImpl(gh<_i44.Isar>()));
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
              gh<_i23.Dio>(),
              gh<_i13.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i61.MedicalStandardsService>(() =>
        _i62.MedicalStandardsServiceImpl(gh<_i55.MedicalContextProvider>()));
    gh.lazySingleton<_i63.MedicalWebSearchService>(
        () => _i64.MedicalWebSearchServiceImpl(gh<_i23.Dio>()));
    gh.lazySingleton<_i65.MedicationRepository>(
        () => _i66.IsarMedicationRepository(gh<_i44.Isar>()));
    gh.factory<_i67.MedicationsCubit>(
        () => _i67.MedicationsCubit(gh<_i65.MedicationRepository>()));
    gh.lazySingleton<_i68.MeditationLocalDataSource>(
        () => _i68.MeditationLocalDataSource());
    gh.lazySingleton<_i69.MeditationRepository>(() =>
        _i70.MeditationRepositoryImpl(gh<_i68.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i26.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i44.Isar>(),
        gh<_i26.EmbeddingsAdapter>(),
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
        () => _i75.NfcSharingService(nfcHandler: gh<_i73.NfcHandler>()));
    gh.lazySingleton<_i76.NodeDiscoveryService>(
        () => _i76.NodeDiscoveryService());
    gh.lazySingleton<_i77.OAuthLocalDataSource>(() =>
        _i77.OAuthLocalDataSource(storage: gh<_i78.FlutterSecureStorage>()));
    gh.lazySingleton<_i79.OAuthRepository>(() => _i80.OAuthRepositoryImpl(
          gh<_i77.OAuthLocalDataSource>(),
          appAuth: gh<_i81.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i82.OcrService>(() => _i82.MlKitOcrService());
    gh.factory<_i83.OnboardingCubit>(() => _i83.OnboardingCubit());
    gh.lazySingleton<_i84.PromptScrubber>(
        () => _i84.PromptScrubber(gh<_i44.Isar>()));
    gh.lazySingleton<_i85.RatingRepository>(
        () => _i86.IsarRatingRepository(gh<_i44.Isar>()));
    gh.lazySingleton<_i87.RecommendScriptUseCase>(
        () => _i87.RecommendScriptUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i88.ReportRepository>(
        () => _i89.IsarReportRepository(gh<_i44.Isar>()));
    gh.lazySingleton<_i90.SecondOpinionRepository>(
        () => _i91.IsarSecondOpinionRepository(gh<_i44.Isar>()));
    gh.lazySingleton<_i92.SensorHealthDataSource>(
        () => _i92.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i93.SettingsLocalDataSource>(
        () => _i93.SettingsLocalDataSource(gh<_i44.Isar>()));
    gh.lazySingleton<_i94.StartSessionUseCase>(
        () => _i94.StartSessionUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i95.SyncRepository>(() => _i96.SyncRepositoryImpl(
          gh<_i29.FhirClient>(),
          gh<_i44.Isar>(),
          gh<_i78.FlutterSecureStorage>(),
          gh<_i76.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i55.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i97.UserProfileLocalDataSource>(
        () => _i97.UserProfileLocalDataSource(gh<_i44.Isar>()));
    gh.lazySingleton<_i98.UserProfileRepository>(
        () => _i99.UserProfileRepositoryImpl(gh<_i44.Isar>()));
    gh.lazySingleton<_i100.UserProfileService>(
        () => _i100.UserProfileService(gh<_i98.UserProfileRepository>()));
    gh.lazySingleton<_i101.VectorStoreService>(
        () => _i102.IsarVectorStoreService(
              gh<_i26.MemoryGraph>(),
              gh<_i56.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i103.VitalSignRepository>(
        () => _i104.VitalSignRepositoryImpl(gh<_i44.Isar>()));
    gh.factory<_i105.VitalsCubit>(
        () => _i105.VitalsCubit(gh<_i103.VitalSignRepository>()));
    gh.lazySingleton<_i106.VoiceChatRepository>(
        () => _i107.VoiceChatRepositoryImpl(gh<_i18.ChatAiDatasource>()));
    gh.lazySingleton<_i108.VouchRepository>(
        () => _i109.IsarVouchRepository(gh<_i44.Isar>()));
    gh.lazySingleton<_i27.WalletService>(() => databaseModule.walletService(
          gh<_i44.Isar>(),
          gh<_i27.EncryptionService>(),
        ));
    gh.lazySingleton<_i110.WifiDirectService>(() => _i110.WifiDirectService());
    gh.factory<_i111.AboutCubit>(
        () => _i111.AboutCubit(gh<_i36.IAboutRepository>()));
    gh.lazySingleton<_i112.AllergyRepository>(
        () => _i113.IsarAllergyRepository(gh<_i44.Isar>()));
    gh.lazySingleton<_i114.AppointmentRepository>(
        () => _i115.IsarAppointmentRepository(gh<_i44.Isar>()));
    gh.factory<_i116.AppointmentsCubit>(
        () => _i116.AppointmentsCubit(gh<_i114.AppointmentRepository>()));
    gh.lazySingleton<_i117.AuthRepository>(
        () => _i118.AuthRepositoryImpl(gh<_i44.Isar>()));
    gh.lazySingleton<_i119.AuthService>(
        () => _i119.AuthServiceImpl(gh<_i28.EncryptionService>()));
    gh.lazySingleton<_i120.CancelSharingUseCase>(
        () => _i120.CancelSharingUseCase(
              gh<_i11.BleSharingService>(),
              gh<_i75.NfcSharingService>(),
              gh<_i110.WifiDirectService>(),
            ));
    gh.lazySingleton<_i121.ChatMessageLocalDataSource>(
        () => _i121.ChatMessageLocalDataSource(gh<_i44.Isar>()));
    gh.lazySingleton<_i122.CompleteSessionUseCase>(
        () => _i122.CompleteSessionUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i123.ConnectProviderUseCase>(() => _i123.ConnectProviderUseCase(
          gh<_i79.OAuthRepository>(),
          gh<_i98.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i124.DashboardRepository>(
        () => _i125.DashboardRepositoryImpl(
              gh<_i103.VitalSignRepository>(),
              gh<_i65.MedicationRepository>(),
              gh<_i88.ReportRepository>(),
            ));
    gh.factory<_i126.DeleteAppointmentUseCase>(() =>
        _i126.DeleteAppointmentUseCase(gh<_i114.AppointmentRepository>()));
    gh.factory<_i127.DisconnectProviderUseCase>(
        () => _i127.DisconnectProviderUseCase(
              gh<_i79.OAuthRepository>(),
              gh<_i98.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i128.DistributedCacheUsecase>(
        () => _i128.DistributedCacheUsecase(gh<_i43.IpfsService>()));
    gh.lazySingleton<_i129.DoctorProfileRepository>(
        () => _i130.IsarDoctorProfileRepository(gh<_i44.Isar>()));
    gh.factoryAsync<_i131.DoctorVerificationCubit>(
        () async => _i131.DoctorVerificationCubit(
              gh<_i129.DoctorProfileRepository>(),
              gh<_i85.RatingRepository>(),
              await getAsync<_i46.LicenseVerifier>(),
            ));
    gh.factory<_i132.EmailCitasCubit>(() => _i132.EmailCitasCubit(
          gh<_i24.EmailRepository>(),
          gh<_i114.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i92.FileHealthDataSource>(
        () => _i92.FileHealthDataSourceImpl(
              gh<_i30.FilePickerService>(),
              gh<_i82.OcrService>(),
            ));
    gh.factory<_i133.GetAllAppointmentsUseCase>(() =>
        _i133.GetAllAppointmentsUseCase(gh<_i114.AppointmentRepository>()));
    gh.factory<_i134.GetChatHistoryUseCase>(
        () => _i134.GetChatHistoryUseCase(gh<_i106.VoiceChatRepository>()));
    gh.factory<_i135.GetConnectionsUseCase>(
        () => _i135.GetConnectionsUseCase(gh<_i79.OAuthRepository>()));
    gh.factory<_i136.GetDashboardStatsUseCase>(
        () => _i136.GetDashboardStatsUseCase(gh<_i124.DashboardRepository>()));
    gh.lazySingleton<_i137.GetProgressUseCase>(
        () => _i137.GetProgressUseCase(gh<_i69.MeditationRepository>()));
    gh.factory<_i138.GetRecentActivityUseCase>(
        () => _i138.GetRecentActivityUseCase(gh<_i124.DashboardRepository>()));
    gh.lazySingleton<_i139.GetScriptsUseCase>(
        () => _i139.GetScriptsUseCase(gh<_i69.MeditationRepository>()));
    gh.lazySingleton<_i140.GovernanceIpfsDatasource>(
        () => _i140.GovernanceIpfsDatasource(gh<_i42.IpfsDatasource>()));
    gh.lazySingleton<_i141.GovernanceRepository>(() =>
        _i142.GovernanceRepositoryImpl(gh<_i140.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i143.HealthDataFileDataSource>(
        () => _i143.HealthDataFileDataSource(
              gh<_i30.FilePickerService>(),
              gh<_i82.OcrService>(),
            ));
    gh.lazySingleton<_i144.HealthDataRepository>(
        () => _i144.HealthDataRepositoryImpl(
              gh<_i92.SensorHealthDataSource>(),
              gh<_i92.FileHealthDataSource>(),
            ));
    gh.factory<_i145.HealthImportCubit>(() => _i145.HealthImportCubit(
          gh<_i32.HealthDataImportService>(),
          gh<_i103.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i146.HealthRecordRepository>(
        () => _i147.HealthRecordRepositoryImpl(gh<_i44.Isar>()));
    gh.lazySingleton<_i148.HealthSharingLocalDataSource>(
        () => _i148.HealthSharingLocalDataSource(gh<_i44.Isar>()));
    gh.lazySingleton<_i149.HomeRepository>(() => _i150.HomeRepositoryImpl(
          gh<_i103.VitalSignRepository>(),
          gh<_i114.AppointmentRepository>(),
          gh<_i65.MedicationRepository>(),
        ));
    gh.factory<_i151.ImportCalendarUseCase>(() => _i151.ImportCalendarUseCase(
          gh<_i16.CalendarRepository>(),
          gh<_i114.AppointmentRepository>(),
          gh<_i98.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i47.LlmAdapter>(
      () => _i152.GeminiLlmAdapter(
        scrubber: gh<_i84.PromptScrubber>(),
        userProfileRepository: gh<_i98.UserProfileRepository>(),
        modelWrapper: gh<_i153.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i47.LlmAdapter>(
      () => _i154.MockLlmAdapter(gh<_i84.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i155.LlmAdapterFactory>(
        () => _i155.LlmAdapterFactory(gh<_i51.LlmSettingsRepository>()));
    gh.lazySingleton<_i156.LlmService>(() => _i157.GemmaLlmService(
          gh<_i101.VectorStoreService>(),
          gh<_i98.UserProfileRepository>(),
          gh<_i47.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i158.LlmSettingsCubit>(() => _i158.LlmSettingsCubit(
          gh<_i51.LlmSettingsRepository>(),
          gh<_i21.DeviceCapabilityService>(),
          gh<_i47.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.lazySingleton<_i159.MedicalResearchService>(
        () => _i159.MedicalResearchService(
              gh<_i63.MedicalWebSearchService>(),
              gh<_i59.MedicalScraperService>(),
            ));
    gh.factory<_i160.MeditationCubit>(() => _i160.MeditationCubit(
          gh<_i87.RecommendScriptUseCase>(),
          gh<_i94.StartSessionUseCase>(),
          gh<_i122.CompleteSessionUseCase>(),
          gh<_i137.GetProgressUseCase>(),
          gh<_i9.AudioService>(),
        ));
    gh.lazySingleton<_i161.OnboardingRepository>(
        () => _i162.OnboardingRepositoryImpl(gh<_i98.UserProfileRepository>()));
    gh.lazySingleton<_i163.PatientContextIndexer>(
      () => _i163.PatientContextIndexer(
        gh<_i44.Isar>(),
        gh<_i101.VectorStoreService>(),
        gh<_i146.HealthRecordRepository>(),
        gh<_i65.MedicationRepository>(),
        gh<_i112.AllergyRepository>(),
        gh<_i103.VitalSignRepository>(),
        gh<_i114.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i164.ReportGenerationService>(
        () => _i165.GemmaReportGenerationService(
              gh<_i47.LlmAdapter>(instanceName: 'gemma'),
              gh<_i101.VectorStoreService>(),
              gh<_i98.UserProfileRepository>(),
              gh<_i84.PromptScrubber>(),
            ));
    gh.factory<_i166.SaveAppointmentUseCase>(
        () => _i166.SaveAppointmentUseCase(gh<_i114.AppointmentRepository>()));
    gh.factory<_i167.SecondOpinionCubit>(
        () => _i167.SecondOpinionCubit(gh<_i90.SecondOpinionRepository>()));
    gh.factory<_i168.SendMessageUseCase>(
        () => _i168.SendMessageUseCase(gh<_i106.VoiceChatRepository>()));
    gh.lazySingleton<_i169.SmartSearchUseCase>(
        () => _i169.SmartSearchUseCase(gh<_i101.VectorStoreService>()));
    gh.lazySingleton<_i170.StartListeningUseCase>(
        () => _i170.StartListeningUseCase(
              gh<_i11.BleSharingService>(),
              gh<_i75.NfcSharingService>(),
              gh<_i110.WifiDirectService>(),
            ));
    gh.lazySingleton<_i171.StartSharingUseCase>(() => _i171.StartSharingUseCase(
          gh<_i11.BleSharingService>(),
          gh<_i75.NfcSharingService>(),
          gh<_i110.WifiDirectService>(),
        ));
    gh.factory<_i172.SyncCubit>(() => _i172.SyncCubit(
          gh<_i55.SyncService>(),
          gh<_i101.VectorStoreService>(),
        ));
    gh.lazySingleton<_i173.SyncService>(() => _i174.SyncServiceImpl(
          gh<_i95.SyncRepository>(),
          gh<_i55.SyncService>(),
        ));
    gh.factory<_i175.UserProfileCubit>(
        () => _i175.UserProfileCubit(gh<_i98.UserProfileRepository>()));
    gh.factory<_i176.VoiceChatCubit>(() => _i176.VoiceChatCubit(
          gh<_i168.SendMessageUseCase>(),
          gh<_i134.GetChatHistoryUseCase>(),
          gh<_i106.VoiceChatRepository>(),
          gh<_i9.AudioService>(),
        ));
    gh.factory<_i177.VouchCubit>(
        () => _i177.VouchCubit(gh<_i108.VouchRepository>()));
    gh.factory<_i178.AllergiesCubit>(
        () => _i178.AllergiesCubit(gh<_i112.AllergyRepository>()));
    gh.factory<_i179.AuthCubit>(() => _i179.AuthCubit(
          gh<_i117.AuthRepository>(),
          gh<_i28.EncryptionService>(),
          gh<_i10.BiometricService>(),
        ));
    gh.factory<_i180.AuthCubit>(() => _i180.AuthCubit(gh<_i119.AuthService>()));
    gh.lazySingleton<_i181.BadgeCalculator>(() => _i181.BadgeCalculator(
          gh<_i129.DoctorProfileRepository>(),
          gh<_i85.RatingRepository>(),
          gh<_i108.VouchRepository>(),
        ));
    gh.factory<_i182.BadgeCubit>(
        () => _i182.BadgeCubit(gh<_i181.BadgeCalculator>()));
    gh.factory<_i183.CalendarImportCubit>(() => _i183.CalendarImportCubit(
          gh<_i16.CalendarRepository>(),
          gh<_i151.ImportCalendarUseCase>(),
        ));
    gh.factory<_i184.DashboardCubit>(() => _i184.DashboardCubit(
          gh<_i136.GetDashboardStatsUseCase>(),
          gh<_i138.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i185.EpsConnectionCubit>(() => _i185.EpsConnectionCubit(
          gh<_i135.GetConnectionsUseCase>(),
          gh<_i123.ConnectProviderUseCase>(),
          gh<_i127.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i186.FhirSyncCubit>(() => _i186.FhirSyncCubit(
          gh<_i173.SyncService>(),
          gh<_i76.NodeDiscoveryService>(),
        ));
    gh.factory<_i187.GetHealthSummaryUseCase>(
        () => _i187.GetHealthSummaryUseCase(gh<_i149.HomeRepository>()));
    gh.factory<_i188.HealthRecordCubit>(() => _i188.HealthRecordCubit(
          gh<_i146.HealthRecordRepository>(),
          gh<_i30.FilePickerService>(),
          gh<_i38.ImagePickerService>(),
          gh<_i82.OcrService>(),
          gh<_i101.VectorStoreService>(),
        ));
    gh.factory<_i189.HomeCubit>(() => _i189.HomeCubit(
          gh<_i187.GetHealthSummaryUseCase>(),
          gh<_i149.HomeRepository>(),
        ));
    gh.lazySingleton<_i156.LlmService>(
      () => _i190.RagLlmService(
        gh<_i101.VectorStoreService>(),
        gh<_i159.MedicalResearchService>(),
        gh<_i98.UserProfileRepository>(),
        gh<_i47.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i191.MedicalIndexingService>(
        () => _i191.MedicalIndexingService(
              gh<_i56.MedicalKnowledgeRepository>(),
              gh<_i101.VectorStoreService>(),
              gh<_i163.PatientContextIndexer>(),
            ));
    gh.factory<_i192.MedicalResearchCubit>(() => _i192.MedicalResearchCubit(
          gh<_i159.MedicalResearchService>(),
          gh<_i61.MedicalStandardsService>(),
        ));
    gh.factory<_i193.ReportBloc>(() => _i193.ReportBloc(
          gh<_i88.ReportRepository>(),
          gh<_i164.ReportGenerationService>(),
        ));
    gh.factory<_i194.SharingCubit>(() => _i194.SharingCubit(
          bleService: gh<_i11.BleSharingService>(),
          nfcService: gh<_i75.NfcSharingService>(),
          wifiService: gh<_i110.WifiDirectService>(),
          startSharingUseCase: gh<_i171.StartSharingUseCase>(),
          startListeningUseCase: gh<_i170.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i120.CancelSharingUseCase>(),
          walletService: gh<_i27.WalletService>(),
          walletEncryption: gh<_i27.EncryptionService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i195.FhirModule {}

class _$CalendarModule extends _i196.CalendarModule {}

class _$NetworkModule extends _i197.NetworkModule {}

class _$MemoryModule extends _i198.MemoryModule {}

class _$DatabaseModule extends _i199.DatabaseModule {}
