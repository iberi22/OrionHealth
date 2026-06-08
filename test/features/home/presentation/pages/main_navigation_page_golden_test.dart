import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/presentation/pages/main_navigation_page.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/medical_analysis_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockHomeCubit extends Mock implements HomeCubit {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockMedicalIndexingService extends Mock implements MedicalIndexingService {}
class MockMedicalAnalysisService extends Mock implements MedicalAnalysisService {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHomeCubit mockHomeCubit;

  HttpOverrides.runZoned(() {
    // This will cause all network requests to return 400.
  }, createHttpClient: (_) => _MockHttpClient());

  GoogleFonts.config.allowRuntimeFetching = false;
  late MockVitalSignRepository mockVitalSignRepository;
  late MockMedicalIndexingService mockMedicalIndexingService;
  late MockMedicalAnalysisService mockMedicalAnalysisService;
  late MockUserProfileRepository mockUserProfileRepository;

  setUpAll(() {
    final getIt = GetIt.instance;
    mockHomeCubit = MockHomeCubit();
    mockVitalSignRepository = MockVitalSignRepository();
    mockMedicalIndexingService = MockMedicalIndexingService();
    mockMedicalAnalysisService = MockMedicalAnalysisService();
    mockUserProfileRepository = MockUserProfileRepository();

    getIt.registerFactory<HomeCubit>(() => mockHomeCubit);
    getIt.registerLazySingleton<VitalSignRepository>(() => mockVitalSignRepository);
    getIt.registerLazySingleton<MedicalIndexingService>(() => mockMedicalIndexingService);
    getIt.registerLazySingleton<MedicalAnalysisService>(() => mockMedicalAnalysisService);
    getIt.registerLazySingleton<UserProfileRepository>(() => mockUserProfileRepository);

    // Register other dependencies if needed by sub-widgets
    // This is a minimal setup for MainNavigationPage
  });

  setUp(() {
    when(() => mockHomeCubit.state).thenReturn(HomeState(
      isLoadingVitals: false,
      latestVitals: {
        VitalSignType.heartRate: VitalSign(
          type: VitalSignType.heartRate,
          value: 75,
          dateTime: DateTime.now(),
        ),
        VitalSignType.bloodPressureSystolic: VitalSign(
          type: VitalSignType.bloodPressureSystolic,
          value: 120,
          dateTime: DateTime.now(),
        ),
        VitalSignType.bloodPressureDiastolic: VitalSign(
          type: VitalSignType.bloodPressureDiastolic,
          value: 80,
          dateTime: DateTime.now(),
        ),
        VitalSignType.temperature: VitalSign(
          type: VitalSignType.temperature,
          value: 36.6,
          dateTime: DateTime.now(),
        ),
        VitalSignType.oxygenSaturation: VitalSign(
          type: VitalSignType.oxygenSaturation,
          value: 98,
          dateTime: DateTime.now(),
        ),
      },
    ));
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockMedicalIndexingService.hasIndexed).thenReturn(true);
    when(() => mockMedicalIndexingService.statusStream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Main Navigation Page Golden Screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const MainNavigationPage(),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MainNavigationPage),
      matchesGoldenFile('../../../../goldens/main_navigation.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
