// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i13;
import 'package:flutter_appauth/flutter_appauth.dart' as _i50;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i51;
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i10;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i20;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i14;
import 'package:medical_standards/medical_standards.dart' as _i33;

import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i77;
import '../../features/allergies/domain/services/allergy_service.dart' as _i3;
import '../../features/allergies/infrastructure/repositories/isar_allergy_repository.dart'
    as _i78;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i81;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i4;
import '../../features/appointments/infrastructure/repositories/isar_appointment_repository.dart'
    as _i82;
import '../../features/auth/application/auth_cubit.dart' as _i115;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i116;
import '../../features/auth/domain/auth_service.dart' as _i85;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i83;
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'
    as _i84;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i5;
import '../../features/auth/infrastructure/services/ble_medical_sharing_service.dart'
    as _i86;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i15;
import '../../features/ble_sharing/domain/ble_sharing_service.dart' as _i6;
import '../../features/ble_sharing/domain/ble_wrapper.dart' as _i7;
import '../../features/calendar_import/data/calendar_repository.dart' as _i9;
import '../../features/calendar_import/domain/calendar_import_cubit.dart'
    as _i87;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i92;
import '../../features/doctor_verification/data/datasources/license_registry_local.dart'
    as _i23;
import '../../features/doctor_verification/data/repositories/isar_doctor_profile_repository.dart'
    as _i91;
import '../../features/doctor_verification/data/repositories/isar_rating_repository.dart'
    as _i56;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i90;
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i55;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i24;
import '../../features/eps_connection/domain/eps_connection_cubit.dart' as _i93;
import '../../features/eps_connection/infrastructure/oauth_repository.dart'
    as _i49;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i97;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i18;
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i117;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
    as _i98;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i99;
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i17;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i19;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i52;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
    as _i112;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i35;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i25;
import '../../features/local_agent/domain/services/vector_store_service.dart'
    as _i71;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i26;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i27;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
    as _i101;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i102;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i100;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i28;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i105;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i104;
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i118;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
    as _i36;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i37;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i72;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i103;
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i31;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i119;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i48;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i109;
import '../../features/medical_assistant/application/medical_assistant_cubit.dart'
    as _i107;
import '../../features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart'
    as _i21;
import '../../features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart'
    as _i66;
import '../../features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart'
    as _i73;
import '../../features/medical_assistant/domain/services/clinical_reasoner_service.dart'
    as _i88;
import '../../features/medical_assistant/domain/services/health_context_service.dart'
    as _i95;
import '../../features/medical_assistant/domain/services/medical_analysis_service.dart'
    as _i32;
import '../../features/medical_assistant/domain/services/medical_guidelines_service.dart'
    as _i34;
import '../../features/medical_assistant/domain/services/risk_calculator_service.dart'
    as _i60;
import '../../features/medical_assistant/infrastructure/analysis/lab_interpreter.dart'
    as _i22;
import '../../features/medical_assistant/infrastructure/analysis/risk_calculator.dart'
    as _i59;
import '../../features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart'
    as _i74;
import '../../features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart'
    as _i38;
import '../../features/medical_assistant/infrastructure/services/clinical_reasoner_service.dart'
    as _i89;
import '../../features/medical_assistant/infrastructure/services/health_context_service_impl.dart'
    as _i96;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i39;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i41;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i43;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i8;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
    as _i108;
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i40;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i42;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i44;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i45;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i46;
import '../../features/onboarding/application/onboarding_cubit.dart' as _i53;
import '../../features/onboarding/application/sync_cubit.dart' as _i113;
import '../../features/reports/application/bloc/report_bloc.dart' as _i120;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i57;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i110;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i58;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
    as _i111;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i47;
import '../../features/settings/application/llm_settings_cubit.dart' as _i106;
import '../../features/settings/domain/repositories/llm_settings_repository.dart'
    as _i29;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i12;
import '../../features/settings/infrastructure/repositories/llm_settings_repository_impl.dart'
    as _i30;
import '../../features/ssi/domain/repositories/ssi_repository.dart' as _i62;
import '../../features/ssi/domain/services/anoncreds_service.dart' as _i79;
import '../../features/ssi/domain/services/ssi_service.dart' as _i64;
import '../../features/ssi/infrastructure/repositories/isar_ssi_repository.dart'
    as _i63;
import '../../features/ssi/infrastructure/services/anoncreds_service_impl.dart'
    as _i80;
import '../../features/ssi/infrastructure/services/sidetree_anchor_client.dart'
    as _i61;
import '../../features/ssi/infrastructure/services/ssi_service_impl.dart'
    as _i65;
import '../../features/sync/data/fhir_client.dart' as _i16;
import '../../features/sync/data/sync_repository.dart' as _i67;
import '../../features/sync/domain/sync_cubit.dart' as _i94;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i114;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i68;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i70;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i69;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i75;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i76;
import '../services/device_capability_service.dart' as _i11;
import '../services/privacy_anonymizer.dart' as _i54;
import 'database_module.dart' as _i124;
import 'fhir_module.dart' as _i121;
import 'memory_module.dart' as _i123;
import 'network_module.dart' as _i122;

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
    gh.lazySingleton<_i14.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i15.EncryptionService>(() => _i15.EncryptionService());
    gh.lazySingleton<_i16.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i17.FilePickerService>(
        () => _i17.FilePickerServiceImpl());
    gh.lazySingleton<_i18.HealthDataImportService>(
        () => _i18.HealthDataImportService());
    gh.lazySingleton<_i19.ImagePickerService>(
        () => _i19.ImagePickerServiceImpl());
    await gh.factoryAsync<_i20.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.factory<_i21.LabAnalysisStrategy>(() => _i21.LabAnalysisStrategy());
    gh.factory<_i22.LabInterpreter>(() => _i22.LabInterpreter());
    gh.lazySingletonAsync<_i23.LicenseRegistryLocal>(() {
      final i = _i23.LicenseRegistryLocal();
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i24.LicenseVerifier>(() async =>
        _i24.LicenseVerifier(await getAsync<_i23.LicenseRegistryLocal>()));
    gh.lazySingleton<_i25.LlmAdapter>(
      () => _i26.FlutterGemmaAdapter(wrapper: gh<_i27.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i25.LlmAdapter>(
      () => _i28.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i29.LlmSettingsRepository>(
        () => _i30.LlmSettingsRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i31.LocalLlmService>(() => _i31.LocalLlmService());
    gh.factory<_i32.MedicalAnalysisService>(
        () => _i32.MedicalAnalysisService());
    gh.lazySingleton<_i33.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
    gh.factory<_i34.MedicalGuidelinesService>(
        () => _i34.MedicalGuidelinesService());
    gh.factory<_i35.MedicalKnowledgeRepository>(
      () => _i36.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i35.MedicalKnowledgeRepository>(
      () => _i37.JsonMedicalKnowledgeRepository(),
      registerFor: {
        _desktop,
        _test,
      },
    );
    gh.factory<_i38.MedicalLlmAdapter>(() => _i38.MedicalLlmAdapter());
    gh.lazySingleton<_i39.MedicalScraperService>(
        () => _i40.MedicalScraperServiceImpl(
              gh<_i13.Dio>(),
              gh<_i8.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i41.MedicalStandardsService>(() =>
        _i42.MedicalStandardsServiceImpl(gh<_i33.MedicalContextProvider>()));
    gh.lazySingleton<_i43.MedicalWebSearchService>(
        () => _i44.MedicalWebSearchServiceImpl(gh<_i13.Dio>()));
    gh.lazySingleton<_i45.MedicationRepository>(
        () => _i46.IsarMedicationRepository(gh<_i20.Isar>()));
    await gh.lazySingletonAsync<_i14.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i20.Isar>(),
        gh<_i14.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i47.MockReportGenerationService>(
      () => _i47.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i48.ModelDownloadService>(
        () => _i48.ModelDownloadService());
    gh.lazySingleton<_i49.OAuthRepository>(() => _i49.OAuthRepositoryImpl(
          appAuth: gh<_i50.FlutterAppAuth>(),
          secureStorage: gh<_i51.FlutterSecureStorage>(),
          clientId: gh<String>(),
          redirectUrl: gh<String>(),
          discoveryUrl: gh<String>(),
          scopes: gh<List<String>>(),
          accessTokenKey: gh<String>(),
          idTokenKey: gh<String>(),
          refreshTokenKey: gh<String>(),
        ));
    gh.lazySingleton<_i52.OcrService>(() => _i52.MlKitOcrService());
    gh.factory<_i53.OnboardingCubit>(() => _i53.OnboardingCubit());
    gh.lazySingleton<_i54.PromptScrubber>(
        () => _i54.PromptScrubber(gh<_i20.Isar>()));
    gh.lazySingleton<_i55.RatingRepository>(
        () => _i56.IsarRatingRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i57.ReportRepository>(
        () => _i58.IsarReportRepository(gh<_i20.Isar>()));
    gh.factory<_i59.RiskCalculator>(() => _i59.RiskCalculator());
    gh.factory<_i60.RiskCalculatorService>(() =>
        _i60.RiskCalculatorService(calculator: gh<_i59.RiskCalculator>()));
    gh.lazySingleton<_i61.SidetreeAnchorClient>(
        () => _i61.SidetreeAnchorClient.create());
    gh.lazySingleton<_i62.SsiRepository>(
        () => _i63.IsarSsiRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i64.SsiService>(() => _i65.SsiServiceImpl(
          gh<_i62.SsiRepository>(),
          gh<_i61.SidetreeAnchorClient>(),
        ));
    gh.factory<_i66.SymptomAnalysisStrategy>(
        () => _i66.SymptomAnalysisStrategy());
    gh.lazySingleton<_i67.SyncRepository>(() => _i67.SyncRepository(
          gh<_i16.FhirClient>(),
          gh<_i20.Isar>(),
          gh<_i51.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i33.SyncService>(() => networkModule.syncService);
    gh.lazySingleton<_i68.UserProfileRepository>(
        () => _i69.UserProfileRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i70.UserProfileService>(
        () => _i70.UserProfileService(gh<_i68.UserProfileRepository>()));
    gh.lazySingleton<_i71.VectorStoreService>(() => _i72.IsarVectorStoreService(
          gh<_i14.MemoryGraph>(),
          gh<_i35.MedicalKnowledgeRepository>(),
        ));
    gh.factory<_i73.VitalAnalysisStrategy>(() => _i73.VitalAnalysisStrategy());
    gh.factory<_i74.VitalSignAnalyzer>(() => _i74.VitalSignAnalyzer());
    gh.lazySingleton<_i75.VitalSignRepository>(
        () => _i76.VitalSignRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i77.AllergyRepository>(
        () => _i78.IsarAllergyRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i79.AnonCredsService>(
        () => _i80.AnonCredsServiceImpl(gh<_i62.SsiRepository>()));
    gh.lazySingleton<_i81.AppointmentRepository>(
        () => _i82.IsarAppointmentRepository(gh<_i20.Isar>()));
    gh.lazySingleton<_i83.AuthRepository>(
        () => _i84.AuthRepositoryImpl(gh<_i20.Isar>()));
    gh.lazySingleton<_i85.AuthService>(
        () => _i85.AuthServiceImpl(gh<_i15.EncryptionService>()));
    gh.lazySingleton<_i86.BleMedicalSharingService>(
        () => _i86.BleMedicalSharingService(
              gh<_i6.BleSharingService>(),
              gh<_i15.EncryptionService>(),
              gh<_i64.SsiService>(),
            ));
    gh.factory<_i87.CalendarImportCubit>(() => _i87.CalendarImportCubit(
          gh<_i9.CalendarRepository>(),
          gh<_i81.AppointmentRepository>(),
          gh<_i68.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i88.ClinicalReasonerService>(
        () => _i89.SymphonyClinicalReasonerService(
              gh<_i35.MedicalKnowledgeRepository>(),
              gh<_i54.PromptScrubber>(),
            ));
    gh.lazySingleton<_i90.DoctorProfileRepository>(
        () => _i91.IsarDoctorProfileRepository(gh<_i20.Isar>()));
    gh.factoryAsync<_i92.DoctorVerificationCubit>(
        () async => _i92.DoctorVerificationCubit(
              gh<_i90.DoctorProfileRepository>(),
              gh<_i55.RatingRepository>(),
              await getAsync<_i24.LicenseVerifier>(),
            ));
    gh.factory<_i93.EpsConnectionCubit>(() => _i93.EpsConnectionCubit(
          gh<_i49.OAuthRepository>(),
          gh<_i68.UserProfileRepository>(),
        ));
    gh.factory<_i94.FhirSyncCubit>(
        () => _i94.FhirSyncCubit(gh<_i67.SyncRepository>()));
    gh.lazySingleton<_i95.HealthContextService>(
        () => _i96.IsarHealthContextService(
              gh<_i75.VitalSignRepository>(),
              gh<_i45.MedicationRepository>(),
              gh<_i68.UserProfileRepository>(),
              gh<_i14.MemoryGraph>(),
            ));
    gh.factory<_i97.HealthImportCubit>(() => _i97.HealthImportCubit(
          gh<_i18.HealthDataImportService>(),
          gh<_i75.VitalSignRepository>(),
        ));
    gh.lazySingleton<_i98.HealthRecordRepository>(
        () => _i99.HealthRecordRepositoryImpl(gh<_i20.Isar>()));
    gh.factory<_i25.LlmAdapter>(
      () => _i100.MockLlmAdapter(gh<_i54.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i25.LlmAdapter>(
      () => _i101.GeminiLlmAdapter(
        scrubber: gh<_i54.PromptScrubber>(),
        userProfileRepository: gh<_i68.UserProfileRepository>(),
        modelWrapper: gh<_i102.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
    gh.lazySingleton<_i103.LlmAdapterFactory>(
        () => _i103.LlmAdapterFactory(gh<_i29.LlmSettingsRepository>()));
    gh.lazySingleton<_i104.LlmService>(() => _i105.GemmaLlmService(
          gh<_i71.VectorStoreService>(),
          gh<_i68.UserProfileRepository>(),
          gh<_i25.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i106.LlmSettingsCubit>(() => _i106.LlmSettingsCubit(
          gh<_i29.LlmSettingsRepository>(),
          gh<_i12.DeviceCapabilityService>(),
          gh<_i25.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i107.MedicalAssistantCubit>(() => _i107.MedicalAssistantCubit(
          llmAdapter: gh<_i38.MedicalLlmAdapter>(),
          analysisService: gh<_i32.MedicalAnalysisService>(),
          healthContextService: gh<_i95.HealthContextService>(),
          labInterpreter: gh<dynamic>(),
          vitalAnalyzer: gh<dynamic>(),
          riskCalculator: gh<dynamic>(),
        ));
    gh.lazySingleton<_i108.MedicalResearchService>(
        () => _i108.MedicalResearchService(
              gh<_i43.MedicalWebSearchService>(),
              gh<_i39.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i109.PatientContextIndexer>(
      () => _i109.PatientContextIndexer(
        gh<_i20.Isar>(),
        gh<_i71.VectorStoreService>(),
        gh<_i98.HealthRecordRepository>(),
        gh<_i45.MedicationRepository>(),
        gh<_i77.AllergyRepository>(),
        gh<_i75.VitalSignRepository>(),
        gh<_i81.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i110.ReportGenerationService>(
        () => _i111.GemmaReportGenerationService(
              gh<_i25.LlmAdapter>(instanceName: 'gemma'),
              gh<_i71.VectorStoreService>(),
              gh<_i68.UserProfileRepository>(),
              gh<_i54.PromptScrubber>(),
            ));
    gh.lazySingleton<_i112.SmartSearchUseCase>(
        () => _i112.SmartSearchUseCase(gh<_i71.VectorStoreService>()));
    gh.factory<_i113.SyncCubit>(() => _i113.SyncCubit(
          gh<_i33.SyncService>(),
          gh<_i71.VectorStoreService>(),
        ));
    gh.factory<_i114.UserProfileCubit>(
        () => _i114.UserProfileCubit(gh<_i68.UserProfileRepository>()));
    gh.factory<_i115.AuthCubit>(() => _i115.AuthCubit(gh<_i85.AuthService>()));
    gh.factory<_i116.AuthCubit>(() => _i116.AuthCubit(
          gh<_i83.AuthRepository>(),
          gh<_i15.EncryptionService>(),
          gh<_i5.BiometricService>(),
        ));
    gh.factory<_i117.HealthRecordCubit>(() => _i117.HealthRecordCubit(
          gh<_i98.HealthRecordRepository>(),
          gh<_i17.FilePickerService>(),
          gh<_i19.ImagePickerService>(),
          gh<_i52.OcrService>(),
          gh<_i71.VectorStoreService>(),
        ));
    gh.lazySingleton<_i104.LlmService>(
      () => _i118.RagLlmService(
        gh<_i71.VectorStoreService>(),
        gh<_i108.MedicalResearchService>(),
        gh<_i68.UserProfileRepository>(),
        gh<_i25.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
    gh.lazySingleton<_i119.MedicalIndexingService>(
        () => _i119.MedicalIndexingService(
              gh<_i35.MedicalKnowledgeRepository>(),
              gh<_i71.VectorStoreService>(),
              gh<_i109.PatientContextIndexer>(),
            ));
    gh.factory<_i120.ReportBloc>(() => _i120.ReportBloc(
          gh<_i57.ReportRepository>(),
          gh<_i110.ReportGenerationService>(),
        ));
    return this;
  }
}

class _$FhirModule extends _i121.FhirModule {}

class _$NetworkModule extends _i122.NetworkModule {}

class _$MemoryModule extends _i123.MemoryModule {}

class _$DatabaseModule extends _i124.DatabaseModule {}
