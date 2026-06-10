// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i13;
import 'package:flutter_appauth/flutter_appauth.dart' as _i57;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i58;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i10;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i24;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i16;
import 'package:medical_standards/medical_standards.dart' as _i37;

import '../../features/about/application/about_cubit.dart' as _i88;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i21;
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i22;
import '../../features/allergies/application/allergies_cubit.dart' as _i137;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i89;
import '../../features/allergies/domain/services/allergy_service.dart' as _i3;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i90;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i95;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i93;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i4;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i94;
import '../../features/auth/application/auth_cubit.dart' as _i139;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i138;
import '../../features/auth/domain/auth_service.dart' as _i98;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i96;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i97;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i5;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i99;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i17;
import '../../features/calendar_import/data/calendar_repository.dart' as _i9;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i100;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i140;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i103;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i104;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i107;
import '../../features/doctor_verification/data/datasources/license_registry_local.dart'
    as _i27;
import '../../features/doctor_verification/data/repositories/isar_doctor_profile_repository.dart'
    as _i106;
import '../../features/doctor_verification/data/repositories/isar_rating_repository.dart'
    as _i63;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i105;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i62;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i28;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i108;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i14;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i15;
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i109;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i56;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i112;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i20;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i143;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i113;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i114;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i19;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i23;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i59;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i68;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i6;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i7;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i54;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i69;
import '../../features/home/domain/repositories/home_repository.dart' as _i148;
import '../../features/home/infrastructure/home_repository_impl.dart' as _i149;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i129;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i39;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i29;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i81;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i31;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i32;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i116;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i117;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i115;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i30;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i120;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i119;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i144;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i41;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i40;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i82;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i118;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i35;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i145;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i53;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i126;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i122;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i25;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i75;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i83;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i101;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i110;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i36;
import '../../features/medical_assistant/domain/services/medical_guidelines_service.dart'
    as _i38;
import '../../features/medical_assistant/domain/services/risk_calculator_service.dart'
    as _i67;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i26;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i66;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i84;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i42;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i102;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i111;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i146;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i43;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i45;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i47;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i8;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i123;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i44;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i46;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i48;
import '../../features/medications/application/medications_cubit.dart' as _i51;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i49;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i50;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i60;
import '../../features/onboarding/application/sync_cubit.dart' as _i131;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i124;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i125;
import '../../features/reports/application/bloc/report_bloc.dart' as _i147;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i64;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i127;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i65;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i128;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i52;
import '../../features/settings/application/llm_settings_cubit.dart' as _i121;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i33;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i12;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i34;
import '../../features/ssi/application/ssi_cubit.dart' as _i130;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i71;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i91;
import '../../features/ssi/domain/services/ssi_service.dart' as _i73;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i72;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i92;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i70;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i74;
import '../../features/sync/application/sync_cubit.dart' as _i142;
import '../../features/sync/data/fhir_client.dart' as _i18;
import '../../features/sync/data/node_discovery_service.dart' as _i55;
import '../../features/sync/data/sync_repository.dart' as _i77;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i135;
import '../../features/sync/domain/services/sync_service.dart' as _i133;
import '../../features/sync/domain/sync_cubit.dart' as _i141;
import '../../features/sync/domain/sync_repository.dart' as _i76;
import '../../features/sync/domain/sync_service.dart' as _i132;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i134;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i136;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i78;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i80;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i79;
import '../../features/vitals/application/vitals_cubit.dart' as _i87;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i85;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i86;
import '../services/device_capability_service.dart' as _i11;
import '../services/privacy_anonymizer.dart' as _i61;
import 'database_module.dart' as _i153;
import 'fhir_module.dart' as _i150;
import 'memory_module.dart' as _i152;
import 'network_module.dart' as _i151;

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
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i3.AllergyService>(() => _i3.AllergyService());
    gh.lazySingleton<_i4.AppointmentService>(() => _i4.AppointmentService());
    gh.lazySingleton<_i5.BiometricService>(() => _i5.BiometricService());
    gh.lazySingleton<_i6.BleSharingService>(
        () => _i6.BleSharingService(bleWrapper: gh<_i7.BleWrapper>()));
    gh.lazySingleton<_i7.BleWrapper>(() => _i7.BleWrapper());
    gh.lazySingleton<_i8.BotBypassHandler>(() => _i8.BotBypassHandler());
    gh.lazySingleton<_i9.CalendarRepository>(() => _i9.CalendarRepository());
    gh.lazySingleton<_i10.Client>(() => fhirModule.httpClient);
    gh.lazySingleton<_i11.DeviceCapabilityService>(
        () => _i11.DeviceCapabilityService());
    gh.lazySingleton<_i12.DeviceCapabilityService>(
        () => _i12.DeviceCapabilityService());
    gh.lazySingleton<_i13.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i14.EmailRepository>(
        () => _i15.EmailRepositoryImpl(client: gh<_i10.Client>()));
    gh.lazySingleton<_i16.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i17.EncryptionService>(() => _i17.EncryptionService());
    gh.lazySingleton<_i18.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i19.FilePickerService>(
        () => _i19.FilePickerServiceImpl());
    gh.lazySingleton<_i20.HealthDataImportService>(
        () => _i20.HealthDataImportService());
    gh.lazySingleton<_i21.IAboutRepository>(() => _i22.AboutRepositoryImpl());
    gh.lazySingleton<_i23.ImagePickerService>(
        () => _i23.ImagePickerServiceImpl());
    await gh.factoryAsync<_i24.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i25.LabAnalysisStrategy>(() => _i25.LabAnalysisStrategy());
    gh.factory<_i26.LabInterpreter>(() => _i26.LabInterpreter());
    gh.lazySingletonAsync<_i27.LicenseRegistryLocal>(() {
      final i = _i27.LicenseRegistryLocal();
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i28.LicenseVerifier>(() async =>
        _i28.LicenseVerifier(await getAsync<_i27.LicenseRegistryLocal>()));
    gh.lazySingleton<_i29.LlmAdapter>(
      () => _i30.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i29.LlmAdapter>(
      () => _i31.FlutterGemmaAdapter(wrapper: gh<_i32.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i33.LlmSettingsRepository>(
        () => _i34.LlmSettingsRepositoryImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i35.LocalLlmService>(() => _i35.LocalLlmService());
    gh.factory<_i36.MedicalAnalysisService>(
        () => _i36.MedicalAnalysisService());
    gh.lazySingleton<_i37.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i38.MedicalGuidelinesService>(
        () => _i38.MedicalGuidelinesService());
    gh.factory<_i39.MedicalKnowledgeRepository>(
      () => _i40.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i39.MedicalKnowledgeRepository>(
      () => _i41.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i42.MedicalLlmAdapter>(() => _i42.MedicalLlmAdapter());
    gh.lazySingleton<_i43.MedicalScraperService>(
        () => _i44.MedicalScraperServiceImpl(
              gh<_i13.Dio>(),
              gh<_i8.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i45.MedicalStandardsService>(() =>
        _i46.MedicalStandardsServiceImpl(gh<_i37.MedicalContextProvider>()));
    gh.lazySingleton<_i47.MedicalWebSearchService>(
        () => _i48.MedicalWebSearchServiceImpl(gh<_i13.Dio>()));
    gh.lazySingleton<_i49.MedicationRepository>(
        () => _i50.IsarMedicationRepository(gh<_i24.Isar>()));
    gh.factory<_i51.MedicationsCubit>(
        () => _i51.MedicationsCubit(gh<_i49.MedicationRepository>()));
    await gh.lazySingletonAsync<_i16.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i24.Isar>(),
        gh<_i16.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i52.MockReportGenerationService>(
      () => _i52.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i53.ModelDownloadService>(
        () => _i53.ModelDownloadService());
    gh.lazySingleton<_i54.NfcSharingService>(() => _i54.NfcSharingService());
    gh.lazySingleton<_i55.NodeDiscoveryService>(
        () => _i55.NodeDiscoveryService());
    gh.lazySingleton<_i56.OAuthRepository>(() => _i56.OAuthRepositoryImpl(
          appAuth: gh<_i57.FlutterAppAuth>(),
          secureStorage: gh<_i58.FlutterSecureStorage>(),
          clientId: gh<String>(),
          redirectUrl: gh<String>(),
          discoveryUrl: gh<String>(),
          scopes: gh<List<String>>(),
          accessTokenKey: gh<String>(),
          idTokenKey: gh<String>(),
          refreshTokenKey: gh<String>(),
        ));
    gh.lazySingleton<_i59.OcrService>(() => _i59.MlKitOcrService());
    gh.factory<_i60.OnboardingCubit>(() => _i60.OnboardingCubit());
    gh.lazySingleton<_i61.PromptScrubber>(
        () => _i61.PromptScrubber(gh<_i24.Isar>()));
    gh.lazySingleton<_i62.RatingRepository>(
        () => _i63.IsarRatingRepository(gh<_i24.Isar>()));
    gh.lazySingleton<_i64.ReportRepository>(
        () => _i65.IsarReportRepository(gh<_i24.Isar>()));
    gh.factory<_i66.RiskCalculator>(() => _i66.RiskCalculator());
    gh.factory<_i67.RiskCalculatorService>(() =>
        _i67.RiskCalculatorService(calculator: gh<_i66.RiskCalculator>()));
    gh.factory<_i68.SharingCubit>(() => _i68.SharingCubit(
          bleService: gh<_i6.BleSharingService>(),
          nfcService: gh<_i54.NfcSharingService>(),
          wifiService: gh<_i69.WifiDirectService>(),
        ));
    gh.lazySingleton<_i70.SidetreeAnchorClient>(
        () => _i70.SidetreeAnchorClient.create());
    gh.lazySingleton<_i71.SsiRepository>(
        () => _i72.IsarSsiRepository(gh<_i24.Isar>()));
    gh.lazySingleton<_i73.SsiService>(() => _i74.SsiServiceImpl(
          gh<_i71.SsiRepository>(),
          gh<_i70.SidetreeAnchorClient>(),
        ));
    gh.factory<_i75.SymptomAnalysisStrategy>(
        () => _i75.SymptomAnalysisStrategy());
    gh.lazySingleton<_i76.SyncRepository>(() => _i77.SyncRepositoryImpl(
          gh<_i18.FhirClient>(),
          gh<_i24.Isar>(),
          gh<_i58.FlutterSecureStorage>(),
          gh<_i55.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i37.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i78.UserProfileRepository>(
        () => _i79.UserProfileRepositoryImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i80.UserProfileService>(
        () => _i80.UserProfileService(gh<_i78.UserProfileRepository>()));
    gh.lazySingleton<_i81.VectorStoreService>(() => _i82.IsarVectorStoreService(
          gh<_i16.MemoryGraph>(),
          gh<_i39.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i83.VitalAnalysisStrategy>(() => _i83.VitalAnalysisStrategy());
    gh.factory<_i84.VitalSignAnalyzer>(() => _i84.VitalSignAnalyzer());
    gh.lazySingleton<_i85.VitalSignRepository>(
        () => _i86.VitalSignRepositoryImpl(gh<_i24.Isar>()));
    gh.factory<_i87.VitalsCubit>(
        () => _i87.VitalsCubit(gh<_i85.VitalSignRepository>()));
    gh.lazySingleton<_i69.WifiDirectService>(() => _i69.WifiDirectService());
    gh.factory<_i88.AboutCubit>(
        () => _i88.AboutCubit(gh<_i21.IAboutRepository>()));
    gh.lazySingleton<_i89.AllergyRepository>(
        () => _i90.IsarAllergyRepository(gh<_i24.Isar>()));
    gh.lazySingleton<_i91.AnonCredsService>(
        () => _i92.AnonCredsServiceImpl(gh<_i71.SsiRepository>()));
    gh.lazySingleton<_i93.AppointmentRepository>(
        () => _i94.IsarAppointmentRepository(gh<_i24.Isar>()));
    gh.factory<_i95.AppointmentsCubit>(
        () => _i95.AppointmentsCubit(gh<_i93.AppointmentRepository>()));
    gh.lazySingleton<_i96.AuthRepository>(
        () => _i97.AuthRepositoryImpl(gh<_i24.Isar>()));
    gh.lazySingleton<_i98.AuthService>(
        () => _i98.AuthServiceImpl(gh<_i17.EncryptionService>()));
    gh.lazySingleton<_i99.BleMedicalSharingService>(
        () => _i99.BleMedicalSharingService(
              gh<_i6.BleSharingService>(),
              gh<_i17.EncryptionService>(),
              gh<_i73.SsiService>(),
            ));
    gh.factory<_i100.CalendarImportCubit>(() => _i100.CalendarImportCubit(
          gh<_i9.CalendarRepository>(),
          gh<_i93.AppointmentRepository>(),
          gh<_i78.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i101.ClinicalReasonerService>(
        () => _i102.SymphonyClinicalReasonerService(
              gh<_i39.MedicalKnowledgeRepository>(),
              gh<_i61.PromptScrubber>(),
            ));
    gh.lazySingleton<_i103.DashboardRepository>(
        () => _i104.DashboardRepositoryImpl(
              gh<_i85.VitalSignRepository>(),
              gh<_i49.MedicationRepository>(),
              gh<_i64.ReportRepository>(),
            ));
    gh.lazySingleton<_i105.DoctorProfileRepository>(
        () => _i106.IsarDoctorProfileRepository(gh<_i24.Isar>()));
    gh.factoryAsync<_i107.DoctorVerificationCubit>(
        () async => _i107.DoctorVerificationCubit(
              gh<_i105.DoctorProfileRepository>(),
              gh<_i62.RatingRepository>(),
              await getAsync<_i28.LicenseVerifier>(),
            ));
    gh.factory<_i108.EmailCitasCubit>(() => _i108.EmailCitasCubit(
          gh<_i14.EmailRepository>(),
          gh<_i93.AppointmentRepository>(),
        ));
    gh.factory<_i109.EpsConnectionCubit>(() => _i109.EpsConnectionCubit(
          gh<_i56.OAuthRepository>(),
          gh<_i78.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i110.HealthContextService>(
        () => _i111.IsarHealthContextService(
              gh<_i85.VitalSignRepository>(),
              gh<_i49.MedicationRepository>(),
              gh<_i78.UserProfileRepository>(),
              gh<_i16.MemoryGraph>(),
            ));
    gh.factory<_i112.HealthImportCubit>(() => _i112.HealthImportCubit(
          gh<_i20.HealthDataImportService>(),
          gh<_i85.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i113.HealthRecordRepository>(
        () => _i114.HealthRecordRepositoryImpl(gh<_i24.Isar>()));
    gh.factory<_i29.LlmAdapter>(
      () => _i115.MockLlmAdapter(gh<_i61.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i29.LlmAdapter>(
      () => _i116.GeminiLlmAdapter(
        scrubber: gh<_i61.PromptScrubber>(),
        userProfileRepository: gh<_i78.UserProfileRepository>(),
        modelWrapper: gh<_i117.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i118.LlmAdapterFactory>(
        () => _i118.LlmAdapterFactory(gh<_i33.LlmSettingsRepository>()));
    gh.lazySingleton<_i119.LlmService>(() => _i120.GemmaLlmService(
          gh<_i81.VectorStoreService>(),
          gh<_i78.UserProfileRepository>(),
          gh<_i29.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i121.LlmSettingsCubit>(() => _i121.LlmSettingsCubit(
          gh<_i33.LlmSettingsRepository>(),
          gh<_i12.DeviceCapabilityService>(),
          gh<_i29.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i122.MedicalAssistantCubit>(() => _i122.MedicalAssistantCubit(
          llmAdapter: gh<_i42.MedicalLlmAdapter>(),
          analysisService: gh<_i36.MedicalAnalysisService>(),
          healthContextService: gh<_i110.HealthContextService>(),
        ));
    gh.lazySingleton<_i123.MedicalResearchService>(
        () => _i123.MedicalResearchService(
              gh<_i47.MedicalWebSearchService>(),
              gh<_i43.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i124.OnboardingRepository>(
        () => _i125.OnboardingRepositoryImpl(gh<_i78.UserProfileRepository>()));
    gh.lazySingleton<_i126.PatientContextIndexer>(
      () => _i126.PatientContextIndexer(
        gh<_i24.Isar>(),
        gh<_i81.VectorStoreService>(),
        gh<_i113.HealthRecordRepository>(),
        gh<_i49.MedicationRepository>(),
        gh<_i89.AllergyRepository>(),
        gh<_i85.VitalSignRepository>(),
        gh<_i93.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i127.ReportGenerationService>(
        () => _i128.GemmaReportGenerationService(
              gh<_i29.LlmAdapter>(instanceName: 'gemma'),
              gh<_i81.VectorStoreService>(),
              gh<_i78.UserProfileRepository>(),
              gh<_i61.PromptScrubber>(),
            ));
    gh.lazySingleton<_i129.SmartSearchUseCase>(
        () => _i129.SmartSearchUseCase(gh<_i81.VectorStoreService>()));
    gh.factory<_i130.SsiCubit>(() => _i130.SsiCubit(gh<_i71.SsiRepository>()));
    gh.factory<_i131.SyncCubit>(() => _i131.SyncCubit(
          gh<_i37.SyncService>(),
          gh<_i81.VectorStoreService>(),
        ));
    gh.lazySingleton<_i132.SyncService>(() => _i132.SyncService(
          gh<_i76.SyncRepository>(),
          gh<_i78.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i133.SyncService>(() => _i134.SyncServiceImpl(
          gh<_i135.SyncRepository>(),
          gh<_i37.SyncService>(),
        ));
    gh.factory<_i136.UserProfileCubit>(
        () => _i136.UserProfileCubit(gh<_i78.UserProfileRepository>()));
    gh.factory<_i137.AllergiesCubit>(
        () => _i137.AllergiesCubit(gh<_i89.AllergyRepository>()));
    gh.factory<_i138.AuthCubit>(() => _i138.AuthCubit(
          gh<_i96.AuthRepository>(),
          gh<_i17.EncryptionService>(),
          gh<_i5.BiometricService>(),
        ));
    gh.factory<_i139.AuthCubit>(() => _i139.AuthCubit(gh<_i98.AuthService>()));
    gh.factory<_i140.DashboardCubit>(
        () => _i140.DashboardCubit(gh<_i103.DashboardRepository>()));
    gh.factory<_i141.FhirSyncCubit>(
        () => _i141.FhirSyncCubit(gh<_i132.SyncService>()));
    gh.factory<_i142.FhirSyncCubit>(
        () => _i142.FhirSyncCubit(gh<_i133.SyncService>()));
    gh.factory<_i143.HealthRecordCubit>(() => _i143.HealthRecordCubit(
          gh<_i113.HealthRecordRepository>(),
          gh<_i19.FilePickerService>(),
          gh<_i23.ImagePickerService>(),
          gh<_i59.OcrService>(),
          gh<_i81.VectorStoreService>(),
        ));
    gh.lazySingleton<_i119.LlmService>(
      () => _i144.RagLlmService(
        gh<_i81.VectorStoreService>(),
        gh<_i123.MedicalResearchService>(),
        gh<_i78.UserProfileRepository>(),
        gh<_i29.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i145.MedicalIndexingService>(
        () => _i145.MedicalIndexingService(
              gh<_i39.MedicalKnowledgeRepository>(),
              gh<_i81.VectorStoreService>(),
              gh<_i126.PatientContextIndexer>(),
            ));
    gh.factory<_i146.MedicalResearchCubit>(() => _i146.MedicalResearchCubit(
          gh<_i123.MedicalResearchService>(),
          gh<_i45.MedicalStandardsService>(),
        ));
    gh.factory<_i147.ReportBloc>(() => _i147.ReportBloc(
          gh<_i64.ReportRepository>(),
          gh<_i127.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i148.HomeRepository>(() => _i149.HomeRepositoryImpl(
          gh<_i85.VitalSignRepository>(),
          gh<_i145.MedicalIndexingService>(),
          gh<_i36.MedicalAnalysisService>(),
          gh<_i78.UserProfileRepository>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i150.FhirModule {}

class _$NetworkModule extends _i151.NetworkModule {}

class _$MemoryModule extends _i152.MemoryModule {}

class _$DatabaseModule extends _i153.DatabaseModule {}
