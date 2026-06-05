import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/main.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/medical_analysis_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockMedicalIndexingService extends Mock implements MedicalIndexingService {}
class MockMedicalAnalysisService extends Mock implements MedicalAnalysisService {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  final getIt = GetIt.instance;
  late MockVitalSignRepository mockVitalSignRepository;
  late MockMedicalIndexingService mockMedicalIndexingService;
  late MockMedicalAnalysisService mockMedicalAnalysisService;
  late MockUserProfileRepository mockUserProfileRepository;

  setUpAll(() {
    mockVitalSignRepository = MockVitalSignRepository();
    mockMedicalIndexingService = MockMedicalIndexingService();
    mockMedicalAnalysisService = MockMedicalAnalysisService();
    mockUserProfileRepository = MockUserProfileRepository();

    getIt.registerLazySingleton<VitalSignRepository>(() => mockVitalSignRepository);
    getIt.registerLazySingleton<MedicalIndexingService>(() => mockMedicalIndexingService);
    getIt.registerLazySingleton<MedicalAnalysisService>(() => mockMedicalAnalysisService);
    getIt.registerLazySingleton<UserProfileRepository>(() => mockUserProfileRepository);

    // Default mock behavior
    when(() => mockMedicalIndexingService.hasIndexed).thenReturn(true);
    when(() => mockMedicalIndexingService.statusStream).thenAnswer((_) => const Stream.empty());
    when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => {});
    when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);
  });

  tearDownAll(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: HomePage(),
    );
  }

  testWidgets('HomePage renders basic elements', (WidgetTester tester) async {
    // Increase surface size to ensure everything is visible and can be found
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify PageHeader (translated in es)
    expect(find.text('Inicio'), findsOneWidget); // l10n.homeTitle is "Inicio"
    expect(find.text('Gestiona tu salud y consulta con tu asistente IA'), findsOneWidget); // l10n.homeSubtitle

    // Verify indexing status banner (it might be SizedBox.shrink() if not indexing)
    expect(find.byType(IndexingStatusBanner), findsOneWidget);

    // Verify health status grid
    expect(find.text('Frecuencia Cardíaca'), findsOneWidget);
    expect(find.text('Presión Arterial'), findsOneWidget);
    expect(find.text('Temperatura'), findsOneWidget);
    expect(find.text('Saturación de Oxígeno'), findsOneWidget);

    // Verify recent insights section
    expect(find.text('Información Reciente'), findsOneWidget);

    // Verify local agent promo
    expect(find.text('100% Local y Privado'), findsOneWidget);
    expect(find.text('Consulta a tu Asistente IA'), findsOneWidget);

    // In Spanish 'Iniciar Consulta' is used for the button label
    expect(find.text('Iniciar Consulta'), findsOneWidget);
  });
}
