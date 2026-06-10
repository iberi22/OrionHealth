// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i13;
import 'package:flutter_appauth/flutter_appauth.dart' as _i54;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i55;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i10;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i22;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i16;
import 'package:medical_standards/medical_standards.dart' as _i35;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i83;
import '../../features/allergies/domain/services/allergy_service.dart' as _i3;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i84;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i87;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i4;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i88;
import '../../features/auth/application/auth_cubit.dart' as _i122;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i123;
import '../../features/auth/domain/auth_service.dart' as _i91;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i89;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i90;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i5;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i92;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i17;
import '../../features/calendar_import/data/calendar_repository.dart' as _i9;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i93;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i98;
import '../../features/doctor_verification/data/datasources/license_registry_local.dart'
    as _i25;
import '../../features/doctor_verification/data/repositories/isar_doctor_profile_repository.dart'
    as _i97;
import '../../features/doctor_verification/data/repositories/isar_rating_repository.dart'
    as _i60;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i96;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i59;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i26;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i99;
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i14;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i15;
import '../../features/eps_connection/domain/eps_connection_cubit.dart'
    as _i100;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i53;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i104;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i20;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i124;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i105;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i106;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i19;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i21;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i56;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i65;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i6;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i7;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i51;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i66;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i119;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i37;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i27;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i77;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i29;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i30;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i107;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i108;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i109;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i28;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i112;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i111;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i125;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i39;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i38;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i78;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i110;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i33;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i126;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i50;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i116;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i114;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i23;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i72;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i79;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i94;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i102;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i34;
import '../../features/medical_assistant/domain/services/medical_guidelines_service.dart'
    as _i36;
import '../../features/medical_assistant/domain/services/risk_calculator_service.dart'
    as _i64;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i24;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i63;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i80;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i40;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i95;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i103;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i41;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i43;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i45;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i8;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i115;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i42;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i44;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i46;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i47;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i48;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i57;
import '../../features/onboarding/application/sync_cubit.dart' as _i120;
import '../../features/reports/application/bloc/report_bloc.dart' as _i127;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i61;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i117;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i62;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i118;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i49;
import '../../features/settings/application/llm_settings_cubit.dart' as _i113;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i31;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i12;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i32;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i68;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i85;
import '../../features/ssi/domain/services/ssi_service.dart' as _i70;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i69;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i86;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i67;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i71;
import '../../features/sync/data/fhir_client.dart' as _i18;
import '../../features/sync/data/node_discovery_service.dart' as _i52;
import '../../features/sync/data/sync_repository.dart' as _i73;
import '../../features/sync/domain/sync_cubit.dart' as _i101;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i121;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i74;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i76;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i75;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i81;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i82;
import '../services/device_capability_service.dart' as _i11;
import '../services/privacy_anonymizer.dart' as _i58;
import 'database_module.dart' as _i131;
import 'fhir_module.dart' as _i128;
import 'memory_module.dart' as _i130;
import 'network_module.dart' as _i129;

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
      () => _i28.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i27.LlmAdapter>(
      () => _i29.FlutterGemmaAdapter(wrapper: gh<_i30.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
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
      () => _i38.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i37.MedicalKnowledgeRepository>(
      () => _i39.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
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
    await gh.lazySingletonAsync<_i16.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i22.Isar>(),
        gh<_i16.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i49.MockReportGenerationService>(
      () => _i49.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i50.ModelDownloadService>(
        () => _i50.ModelDownloadService());
    gh.lazySingleton<_i51.NfcSharingService>(() => _i51.NfcSharingService());
    gh.lazySingleton<_i52.NodeDiscoveryService>(
        () => _i52.NodeDiscoveryService());
    gh.lazySingleton<_i53.OAuthRepository>(() => _i53.OAuthRepositoryImpl(
          appAuth: gh<_i54.FlutterAppAuth>(),
          secureStorage: gh<_i55.FlutterSecureStorage>(),
          clientId: gh<String>(),
          redirectUrl: gh<String>(),
          discoveryUrl: gh<String>(),
          scopes: gh<List<String>>(),
          accessTokenKey: gh<String>(),
          idTokenKey: gh<String>(),
          refreshTokenKey: gh<String>(),
        ));
    gh.lazySingleton<_i56.OcrService>(() => _i56.MlKitOcrService());
    gh.factory<_i57.OnboardingCubit>(() => _i57.OnboardingCubit());
    gh.lazySingleton<_i58.PromptScrubber>(
        () => _i58.PromptScrubber(gh<_i22.Isar>()));
    gh.lazySingleton<_i59.RatingRepository>(
        () => _i60.IsarRatingRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i61.ReportRepository>(
        () => _i62.IsarReportRepository(gh<_i22.Isar>()));
    gh.factory<_i63.RiskCalculator>(() => _i63.RiskCalculator());
    gh.factory<_i64.RiskCalculatorService>(() =>
        _i64.RiskCalculatorService(calculator: gh<_i63.RiskCalculator>()));
    gh.factory<_i65.SharingCubit>(() => _i65.SharingCubit(
          bleService: gh<_i6.BleSharingService>(),
          nfcService: gh<_i51.NfcSharingService>(),
          wifiService: gh<_i66.WifiDirectService>(),
        ));
    gh.lazySingleton<_i67.SidetreeAnchorClient>(
        () => _i67.SidetreeAnchorClient.create());
    gh.lazySingleton<_i68.SsiRepository>(
        () => _i69.IsarSsiRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i70.SsiService>(() => _i71.SsiServiceImpl(
          gh<_i68.SsiRepository>(),
          gh<_i67.SidetreeAnchorClient>(),
        ));
    gh.factory<_i72.SymptomAnalysisStrategy>(
        () => _i72.SymptomAnalysisStrategy());
    gh.lazySingleton<_i73.SyncRepository>(() => _i73.SyncRepository(
          gh<_i18.FhirClient>(),
          gh<_i22.Isar>(),
          gh<_i55.FlutterSecureStorage>(),
          gh<_i52.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i35.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i74.UserProfileRepository>(
        () => _i75.UserProfileRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i76.UserProfileService>(
        () => _i76.UserProfileService(gh<_i74.UserProfileRepository>()));
    gh.lazySingleton<_i77.VectorStoreService>(() => _i78.IsarVectorStoreService(
          gh<_i16.MemoryGraph>(),
          gh<_i37.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i79.VitalAnalysisStrategy>(() => _i79.VitalAnalysisStrategy());
    gh.factory<_i80.VitalSignAnalyzer>(() => _i80.VitalSignAnalyzer());
    gh.lazySingleton<_i81.VitalSignRepository>(
        () => _i82.VitalSignRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i66.WifiDirectService>(() => _i66.WifiDirectService());
    gh.lazySingleton<_i83.AllergyRepository>(
        () => _i84.IsarAllergyRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i85.AnonCredsService>(
        () => _i86.AnonCredsServiceImpl(gh<_i68.SsiRepository>()));
    gh.lazySingleton<_i87.AppointmentRepository>(
        () => _i88.IsarAppointmentRepository(gh<_i22.Isar>()));
    gh.lazySingleton<_i89.AuthRepository>(
        () => _i90.AuthRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i91.AuthService>(
        () => _i91.AuthServiceImpl(gh<_i17.EncryptionService>()));
    gh.lazySingleton<_i92.BleMedicalSharingService>(
        () => _i92.BleMedicalSharingService(
              gh<_i6.BleSharingService>(),
              gh<_i17.EncryptionService>(),
              gh<_i70.SsiService>(),
            ));
    gh.factory<_i93.CalendarImportCubit>(() => _i93.CalendarImportCubit(
          gh<_i9.CalendarRepository>(),
          gh<_i87.AppointmentRepository>(),
          gh<_i74.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i94.ClinicalReasonerService>(
        () => _i95.SymphonyClinicalReasonerService(
              gh<_i37.MedicalKnowledgeRepository>(),
              gh<_i58.PromptScrubber>(),
            ));
    gh.lazySingleton<_i96.DoctorProfileRepository>(
        () => _i97.IsarDoctorProfileRepository(gh<_i22.Isar>()));
    gh.factoryAsync<_i98.DoctorVerificationCubit>(
        () async => _i98.DoctorVerificationCubit(
              gh<_i96.DoctorProfileRepository>(),
              gh<_i59.RatingRepository>(),
              await getAsync<_i26.LicenseVerifier>(),
            ));
    gh.factory<_i99.EmailCitasCubit>(() => _i99.EmailCitasCubit(
          gh<_i14.EmailRepository>(),
          gh<_i87.AppointmentRepository>(),
        ));
    gh.factory<_i100.EpsConnectionCubit>(() => _i100.EpsConnectionCubit(
          gh<_i53.OAuthRepository>(),
          gh<_i74.UserProfileRepository>(),
        ));
    gh.factory<_i101.FhirSyncCubit>(
        () => _i101.FhirSyncCubit(gh<_i73.SyncRepository>()));
    gh.lazySingleton<_i102.HealthContextService>(
        () => _i103.IsarHealthContextService(
              gh<_i81.VitalSignRepository>(),
              gh<_i47.MedicationRepository>(),
              gh<_i74.UserProfileRepository>(),
              gh<_i16.MemoryGraph>(),
            ));
    gh.factory<_i104.HealthImportCubit>(() => _i104.HealthImportCubit(
          gh<_i20.HealthDataImportService>(),
          gh<_i81.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i105.HealthRecordRepository>(
        () => _i106.HealthRecordRepositoryImpl(gh<_i22.Isar>()));
    gh.lazySingleton<_i27.LlmAdapter>(
      () => _i107.GeminiLlmAdapter(
        scrubber: gh<_i58.PromptScrubber>(),
        userProfileRepository: gh<_i74.UserProfileRepository>(),
        modelWrapper: gh<_i108.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.factory<_i27.LlmAdapter>(
      () => _i109.MockLlmAdapter(gh<_i58.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i110.LlmAdapterFactory>(
        () => _i110.LlmAdapterFactory(gh<_i31.LlmSettingsRepository>()));
    gh.lazySingleton<_i111.LlmService>(() => _i112.GemmaLlmService(
          gh<_i77.VectorStoreService>(),
          gh<_i74.UserProfileRepository>(),
          gh<_i27.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i113.LlmSettingsCubit>(() => _i113.LlmSettingsCubit(
          gh<_i31.LlmSettingsRepository>(),
          gh<_i12.DeviceCapabilityService>(),
          gh<_i27.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i114.MedicalAssistantCubit>(() => _i114.MedicalAssistantCubit(
          llmAdapter: gh<_i40.MedicalLlmAdapter>(),
          analysisService: gh<_i34.MedicalAnalysisService>(),
          healthContextService: gh<_i102.HealthContextService>(),
        ));
    gh.lazySingleton<_i115.MedicalResearchService>(
        () => _i115.MedicalResearchService(
              gh<_i45.MedicalWebSearchService>(),
              gh<_i41.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i116.PatientContextIndexer>(
      () => _i116.PatientContextIndexer(
        gh<_i22.Isar>(),
        gh<_i77.VectorStoreService>(),
        gh<_i105.HealthRecordRepository>(),
        gh<_i47.MedicationRepository>(),
        gh<_i83.AllergyRepository>(),
        gh<_i81.VitalSignRepository>(),
        gh<_i87.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i117.ReportGenerationService>(
        () => _i118.GemmaReportGenerationService(
              gh<_i27.LlmAdapter>(instanceName: 'gemma'),
              gh<_i77.VectorStoreService>(),
              gh<_i74.UserProfileRepository>(),
              gh<_i58.PromptScrubber>(),
            ));
    gh.lazySingleton<_i119.SmartSearchUseCase>(
        () => _i119.SmartSearchUseCase(gh<_i77.VectorStoreService>()));
    gh.factory<_i120.SyncCubit>(() => _i120.SyncCubit(
          gh<_i35.SyncService>(),
          gh<_i77.VectorStoreService>(),
        ));
    gh.factory<_i121.UserProfileCubit>(
        () => _i121.UserProfileCubit(gh<_i74.UserProfileRepository>()));
    gh.factory<_i122.AuthCubit>(() => _i122.AuthCubit(gh<_i91.AuthService>()));
    gh.factory<_i123.AuthCubit>(() => _i123.AuthCubit(
          gh<_i89.AuthRepository>(),
          gh<_i17.EncryptionService>(),
          gh<_i5.BiometricService>(),
        ));
    gh.factory<_i124.HealthRecordCubit>(() => _i124.HealthRecordCubit(
          gh<_i105.HealthRecordRepository>(),
          gh<_i19.FilePickerService>(),
          gh<_i21.ImagePickerService>(),
          gh<_i56.OcrService>(),
          gh<_i77.VectorStoreService>(),
        ));
    gh.lazySingleton<_i111.LlmService>(
      () => _i125.RagLlmService(
        gh<_i77.VectorStoreService>(),
        gh<_i115.MedicalResearchService>(),
        gh<_i74.UserProfileRepository>(),
        gh<_i27.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i126.MedicalIndexingService>(
        () => _i126.MedicalIndexingService(
              gh<_i37.MedicalKnowledgeRepository>(),
              gh<_i77.VectorStoreService>(),
              gh<_i116.PatientContextIndexer>(),
            ));
    gh.factory<_i127.ReportBloc>(() => _i127.ReportBloc(
          gh<_i61.ReportRepository>(),
          gh<_i117.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i128.FhirModule {}

class _$NetworkModule extends _i129.NetworkModule {}

class _$MemoryModule extends _i130.MemoryModule {}

class _$DatabaseModule extends _i131.DatabaseModule {}
