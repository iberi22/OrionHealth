// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i13;
import 'package:flutter_appauth/flutter_appauth.dart' as _i55;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i56;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i10;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i22;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i16;
import 'package:medical_standards/medical_standards.dart' as _i35;

import '../../features/allergies/application/allergies_cubit.dart' as _i134;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i86;
import '../../features/allergies/domain/services/allergy_service.dart' as _i3;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i87;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i92;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i90;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i4;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i91;
import '../../features/auth/application/auth_cubit.dart' as _i136;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i135;
import '../../features/auth/domain/auth_service.dart' as _i95;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i93;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i94;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i5;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i96;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i17;
import '../../features/calendar_import/data/calendar_repository.dart' as _i9;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i97;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i137;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i100;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i101;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i104;
import '../../features/doctor_verification/data/datasources/license_registry_local.dart'
    as _i25;
import '../../features/doctor_verification/data/repositories/isar_doctor_profile_repository.dart'
    as _i103;
import '../../features/doctor_verification/data/repositories/isar_rating_repository.dart'
    as _i61;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i102;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i60;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i26;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i105;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i14;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i15;
import '../../features/eps_connection/domain/eps_connection_cubit.dart'
    as _i106;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i54;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i109;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i20;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i140;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i110;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i111;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i19;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i21;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i57;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i66;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i6;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i7;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i52;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i67;
import '../../features/home/domain/repositories/home_repository.dart' as _i145;
import '../../features/home/infrastructure/home_repository_impl.dart' as _i146;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i126;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i37;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i27;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i79;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i28;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i29;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i113;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i114;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i112;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i30;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i117;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i116;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i141;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i38;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i39;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i80;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i115;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i33;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i142;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i51;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i123;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i119;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i23;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i73;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i81;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i98;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i107;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i34;
import '../../features/medical_assistant/domain/services/medical_guidelines_service.dart'
    as _i36;
import '../../features/medical_assistant/domain/services/risk_calculator_service.dart'
    as _i65;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i24;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i64;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i82;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i40;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i99;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i108;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i143;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i41;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i43;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i45;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i8;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i120;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i42;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i44;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i46;
import '../../features/medications/application/medications_cubit.dart' as _i49;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i47;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i48;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i58;
import '../../features/onboarding/application/sync_cubit.dart' as _i128;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i121;
import '../../features/onboarding/infrastructure/onboarding_repository_impl.dart'
    as _i122;
import '../../features/reports/application/bloc/report_bloc.dart' as _i144;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i62;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i124;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i63;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i125;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i50;
import '../../features/settings/application/llm_settings_cubit.dart' as _i118;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i31;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i12;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i32;
import '../../features/ssi/application/ssi_cubit.dart' as _i127;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i69;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i88;
import '../../features/ssi/domain/services/ssi_service.dart' as _i71;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i70;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i89;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i68;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i72;
import '../../features/sync/application/sync_cubit.dart' as _i138;
import '../../features/sync/data/fhir_client.dart' as _i18;
import '../../features/sync/data/node_discovery_service.dart' as _i53;
import '../../features/sync/data/sync_repository.dart' as _i75;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i131;
import '../../features/sync/domain/services/sync_service.dart' as _i129;
import '../../features/sync/domain/sync_cubit.dart' as _i139;
import '../../features/sync/domain/sync_repository.dart' as _i74;
import '../../features/sync/domain/sync_service.dart' as _i132;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i130;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i133;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i76;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i78;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i77;
import '../../features/vitals/application/vitals_cubit.dart' as _i85;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i83;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i84;
import '../services/device_capability_service.dart' as _i11;
import '../services/privacy_anonymizer.dart' as _i59;
import 'database_module.dart' as _i150;
import 'fhir_module.dart' as _i147;
import 'memory_module.dart' as _i149;
import 'network_module.dart' as _i148;

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
    gh.lazySingleton<_i21.ImagePickerService>(
        () => _i21.ImagePickerServiceImpl());
    await gh.factoryAsync<_i22.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i23.LabAnalysisStrategy>(() => _i23.LabAnalysisStrategy());
    gh.factory<_i24.LabInterpreter>(() => _i24.LabInterpreter());
    gh.lazySingletonAsync<_i25.LicenseRegistryLocal>(() {
      final i = _i25.LicenseRegistryLocal();
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i26.LicenseVerifier>(() async =>
        _i26.LicenseVerifier(await getAsync<_i25.LicenseRegistryLocal>()));
    gh.lazySingleton<_i27.LlmAdapter>(
      () => _i28.FlutterGemmaAdapter(wrapper: gh<_i29.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i27.LlmAdapter>(
      () => _i30.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i31.LlmSettingsRepository>(
        () => _i32.LlmSettingsRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i33.LocalLlmService>(() => _i33.LocalLlmService());
    gh.factory<_i34.MedicalAnalysisService>(
        () => _i34.MedicalAnalysisService());
    gh.lazySingleton<_i35.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i36.MedicalGuidelinesService>(
        () => _i36.MedicalGuidelinesService());
    gh.factory<_i37.MedicalKnowledgeRepository>(
      () => _i38.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i37.MedicalKnowledgeRepository>(
      () => _i39.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i40.MedicalLlmAdapter>(() => _i40.MedicalLlmAdapter());
    gh.lazySingleton<_i41.MedicalScraperService>(
        () => _i42.MedicalScraperServiceImpl(
              gh<_i13.Dio>(),
              gh<_i8.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i43.MedicalStandardsService>(() =>
        _i44.MedicalStandardsServiceImpl(gh<_i35.MedicalContextProvider>()));
    gh.lazySingleton<_i45.MedicalWebSearchService>(
        () => _i46.MedicalWebSearchServiceImpl(gh<_i13.Dio>()));
    gh.lazySingleton<_i47.MedicationRepository>(
        () => _i48.IsarMedicationRepository(gh<_i22.Isar>()));
    gh.factory<_i49.MedicationsCubit>(
        () => _i49.MedicationsCubit(gh<_i47.MedicationRepository>()));
    await gh.lazySingletonAsync<_i16.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i22.Isar>(),
        gh<_i16.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i50.MockReportGenerationService>(
      () => _i50.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i51.ModelDownloadService>(
        () => _i51.ModelDownloadService());
    gh.lazySingleton<_i52.NfcSharingService>(() => _i52.NfcSharingService());
    gh.lazySingleton<_i53.NodeDiscoveryService>(
        () => _i53.NodeDiscoveryService());
    gh.lazySingleton<_i54.OAuthRepository>(() => _i54.OAuthRepositoryImpl(
          appAuth: gh<_i55.FlutterAppAuth>(),
          secureStorage: gh<_i56.FlutterSecureStorage>(),
          clientId: gh<String>(),
          redirectUrl: gh<String>(),
          discoveryUrl: gh<String>(),
          scopes: gh<List<String>>(),
          accessTokenKey: gh<String>(),
          idTokenKey: gh<String>(),
          refreshTokenKey: gh<String>(),
        ));
    gh.lazySingleton<_i57.OcrService>(() => _i57.MlKitOcrService());
    gh.factory<_i58.OnboardingCubit>(() => _i58.OnboardingCubit());
    gh.lazySingleton<_i59.PromptScrubber>(
        () => _i59.PromptScrubber(gh<_i22.Isar>()));
    gh.lazySingleton<_i60.RatingRepository>(
        () => _i61.IsarRatingRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i62.ReportRepository>(
        () => _i63.IsarReportRepository(gh<_i22.Isar>()));
    gh.factory<_i64.RiskCalculator>(() => _i64.RiskCalculator());
    gh.factory<_i65.RiskCalculatorService>(() =>
        _i65.RiskCalculatorService(calculator: gh<_i64.RiskCalculator>()));
    gh.factory<_i66.SharingCubit>(() => _i66.SharingCubit(
          bleService: gh<_i6.BleSharingService>(),
          nfcService: gh<_i52.NfcSharingService>(),
          wifiService: gh<_i67.WifiDirectService>(),
        ));
    gh.lazySingleton<_i68.SidetreeAnchorClient>(
        () => _i68.SidetreeAnchorClient.create());
    gh.lazySingleton<_i69.SsiRepository>(
        () => _i70.IsarSsiRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i71.SsiService>(() => _i72.SsiServiceImpl(
          gh<_i69.SsiRepository>(),
          gh<_i68.SidetreeAnchorClient>(),
        ));
    gh.factory<_i73.SymptomAnalysisStrategy>(
        () => _i73.SymptomAnalysisStrategy());
    gh.lazySingleton<_i74.SyncRepository>(() => _i75.SyncRepositoryImpl(
          gh<_i18.FhirClient>(),
          gh<_i22.Isar>(),
          gh<_i56.FlutterSecureStorage>(),
          gh<_i53.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i35.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i76.UserProfileRepository>(
        () => _i77.UserProfileRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i78.UserProfileService>(
        () => _i78.UserProfileService(gh<_i76.UserProfileRepository>()));
    gh.lazySingleton<_i79.VectorStoreService>(() => _i80.IsarVectorStoreService(
          gh<_i16.MemoryGraph>(),
          gh<_i37.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i81.VitalAnalysisStrategy>(() => _i81.VitalAnalysisStrategy());
    gh.factory<_i82.VitalSignAnalyzer>(() => _i82.VitalSignAnalyzer());
    gh.lazySingleton<_i83.VitalSignRepository>(
        () => _i84.VitalSignRepositoryImpl(gh<_i22.Isar>()));
    gh.factory<_i85.VitalsCubit>(
        () => _i85.VitalsCubit(gh<_i83.VitalSignRepository>()));
    gh.lazySingleton<_i67.WifiDirectService>(() => _i67.WifiDirectService());
    gh.lazySingleton<_i86.AllergyRepository>(
        () => _i87.IsarAllergyRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i88.AnonCredsService>(
        () => _i89.AnonCredsServiceImpl(gh<_i69.SsiRepository>()));
    gh.lazySingleton<_i90.AppointmentRepository>(
        () => _i91.IsarAppointmentRepository(gh<_i22.Isar>()));
    gh.factory<_i92.AppointmentsCubit>(
        () => _i92.AppointmentsCubit(gh<_i90.AppointmentRepository>()));
    gh.lazySingleton<_i93.AuthRepository>(
        () => _i94.AuthRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i95.AuthService>(
        () => _i95.AuthServiceImpl(gh<_i17.EncryptionService>()));
    gh.lazySingleton<_i96.BleMedicalSharingService>(
        () => _i96.BleMedicalSharingService(
              gh<_i6.BleSharingService>(),
              gh<_i17.EncryptionService>(),
              gh<_i71.SsiService>(),
            ));
    gh.factory<_i97.CalendarImportCubit>(() => _i97.CalendarImportCubit(
          gh<_i9.CalendarRepository>(),
          gh<_i90.AppointmentRepository>(),
          gh<_i76.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i98.ClinicalReasonerService>(
        () => _i99.SymphonyClinicalReasonerService(
              gh<_i37.MedicalKnowledgeRepository>(),
              gh<_i59.PromptScrubber>(),
            ));
    gh.lazySingleton<_i100.DashboardRepository>(
        () => _i101.DashboardRepositoryImpl(
              gh<_i83.VitalSignRepository>(),
              gh<_i47.MedicationRepository>(),
              gh<_i62.ReportRepository>(),
            ));
    gh.lazySingleton<_i102.DoctorProfileRepository>(
        () => _i103.IsarDoctorProfileRepository(gh<_i22.Isar>()));
    gh.factoryAsync<_i104.DoctorVerificationCubit>(
        () async => _i104.DoctorVerificationCubit(
              gh<_i102.DoctorProfileRepository>(),
              gh<_i60.RatingRepository>(),
              await getAsync<_i26.LicenseVerifier>(),
            ));
    gh.factory<_i105.EmailCitasCubit>(() => _i105.EmailCitasCubit(
          gh<_i14.EmailRepository>(),
          gh<_i90.AppointmentRepository>(),
        ));
    gh.factory<_i106.EpsConnectionCubit>(() => _i106.EpsConnectionCubit(
          gh<_i54.OAuthRepository>(),
          gh<_i76.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i107.HealthContextService>(
        () => _i108.IsarHealthContextService(
              gh<_i83.VitalSignRepository>(),
              gh<_i47.MedicationRepository>(),
              gh<_i76.UserProfileRepository>(),
              gh<_i16.MemoryGraph>(),
            ));
    gh.factory<_i109.HealthImportCubit>(() => _i109.HealthImportCubit(
          gh<_i20.HealthDataImportService>(),
          gh<_i83.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i110.HealthRecordRepository>(
        () => _i111.HealthRecordRepositoryImpl(gh<_i22.Isar>()));
    gh.factory<_i27.LlmAdapter>(
      () => _i112.MockLlmAdapter(gh<_i59.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i27.LlmAdapter>(
      () => _i113.GeminiLlmAdapter(
        scrubber: gh<_i59.PromptScrubber>(),
        userProfileRepository: gh<_i76.UserProfileRepository>(),
        modelWrapper: gh<_i114.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i115.LlmAdapterFactory>(
        () => _i115.LlmAdapterFactory(gh<_i31.LlmSettingsRepository>()));
    gh.lazySingleton<_i116.LlmService>(() => _i117.GemmaLlmService(
          gh<_i79.VectorStoreService>(),
          gh<_i76.UserProfileRepository>(),
          gh<_i27.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i118.LlmSettingsCubit>(() => _i118.LlmSettingsCubit(
          gh<_i31.LlmSettingsRepository>(),
          gh<_i12.DeviceCapabilityService>(),
          gh<_i27.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i119.MedicalAssistantCubit>(() => _i119.MedicalAssistantCubit(
          llmAdapter: gh<_i40.MedicalLlmAdapter>(),
          analysisService: gh<_i34.MedicalAnalysisService>(),
          healthContextService: gh<_i107.HealthContextService>(),
        ));
    gh.lazySingleton<_i120.MedicalResearchService>(
        () => _i120.MedicalResearchService(
              gh<_i45.MedicalWebSearchService>(),
              gh<_i41.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i121.OnboardingRepository>(
        () => _i122.OnboardingRepositoryImpl(gh<_i76.UserProfileRepository>()));
    gh.lazySingleton<_i123.PatientContextIndexer>(
      () => _i123.PatientContextIndexer(
        gh<_i22.Isar>(),
        gh<_i79.VectorStoreService>(),
        gh<_i110.HealthRecordRepository>(),
        gh<_i47.MedicationRepository>(),
        gh<_i86.AllergyRepository>(),
        gh<_i83.VitalSignRepository>(),
        gh<_i90.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i124.ReportGenerationService>(
        () => _i125.GemmaReportGenerationService(
              gh<_i27.LlmAdapter>(instanceName: 'gemma'),
              gh<_i79.VectorStoreService>(),
              gh<_i76.UserProfileRepository>(),
              gh<_i59.PromptScrubber>(),
            ));
    gh.lazySingleton<_i126.SmartSearchUseCase>(
        () => _i126.SmartSearchUseCase(gh<_i79.VectorStoreService>()));
    gh.factory<_i127.SsiCubit>(() => _i127.SsiCubit(gh<_i69.SsiRepository>()));
    gh.factory<_i128.SyncCubit>(() => _i128.SyncCubit(
          gh<_i35.SyncService>(),
          gh<_i79.VectorStoreService>(),
        ));
    gh.lazySingleton<_i129.SyncService>(() => _i130.SyncServiceImpl(
          gh<_i131.SyncRepository>(),
          gh<_i35.SyncService>(),
        ));
    gh.lazySingleton<_i132.SyncService>(() => _i132.SyncService(
          gh<_i74.SyncRepository>(),
          gh<_i76.UserProfileRepository>(),
        ));
    gh.factory<_i133.UserProfileCubit>(
        () => _i133.UserProfileCubit(gh<_i76.UserProfileRepository>()));
    gh.factory<_i134.AllergiesCubit>(
        () => _i134.AllergiesCubit(gh<_i86.AllergyRepository>()));
    gh.factory<_i135.AuthCubit>(() => _i135.AuthCubit(
          gh<_i93.AuthRepository>(),
          gh<_i17.EncryptionService>(),
          gh<_i5.BiometricService>(),
        ));
    gh.factory<_i136.AuthCubit>(() => _i136.AuthCubit(gh<_i95.AuthService>()));
    gh.factory<_i137.DashboardCubit>(
        () => _i137.DashboardCubit(gh<_i100.DashboardRepository>()));
    gh.factory<_i138.FhirSyncCubit>(
        () => _i138.FhirSyncCubit(gh<_i129.SyncService>()));
    gh.factory<_i139.FhirSyncCubit>(
        () => _i139.FhirSyncCubit(gh<_i132.SyncService>()));
    gh.factory<_i140.HealthRecordCubit>(() => _i140.HealthRecordCubit(
          gh<_i110.HealthRecordRepository>(),
          gh<_i19.FilePickerService>(),
          gh<_i21.ImagePickerService>(),
          gh<_i57.OcrService>(),
          gh<_i79.VectorStoreService>(),
        ));
    gh.lazySingleton<_i116.LlmService>(
      () => _i141.RagLlmService(
        gh<_i79.VectorStoreService>(),
        gh<_i120.MedicalResearchService>(),
        gh<_i76.UserProfileRepository>(),
        gh<_i27.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i142.MedicalIndexingService>(
        () => _i142.MedicalIndexingService(
              gh<_i37.MedicalKnowledgeRepository>(),
              gh<_i79.VectorStoreService>(),
              gh<_i123.PatientContextIndexer>(),
            ));
    gh.factory<_i143.MedicalResearchCubit>(() => _i143.MedicalResearchCubit(
          gh<_i120.MedicalResearchService>(),
          gh<_i43.MedicalStandardsService>(),
        ));
    gh.factory<_i144.ReportBloc>(() => _i144.ReportBloc(
          gh<_i62.ReportRepository>(),
          gh<_i124.ReportGenerationService>(),
        ));
    gh.lazySingleton<_i145.HomeRepository>(() => _i146.HomeRepositoryImpl(
          gh<_i83.VitalSignRepository>(),
          gh<_i142.MedicalIndexingService>(),
          gh<_i34.MedicalAnalysisService>(),
          gh<_i76.UserProfileRepository>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i147.FhirModule {}

class _$NetworkModule extends _i148.NetworkModule {}

class _$MemoryModule extends _i149.MemoryModule {}

class _$DatabaseModule extends _i150.DatabaseModule {}
