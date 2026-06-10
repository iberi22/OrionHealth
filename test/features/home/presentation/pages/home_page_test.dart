import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/domain/repositories/home_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  final getIt = GetIt.instance;
  late MockHomeRepository mockHomeRepository;

  setUpAll(() {
    mockHomeRepository = MockHomeRepository();

    getIt.registerLazySingleton<HomeRepository>(() => mockHomeRepository);
    getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepository>()));
  });

  setUp(() {
    // Default mock behavior for each test
    when(() => mockHomeRepository.hasIndexed).thenReturn(true);
    when(() => mockHomeRepository.indexingStatusStream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeRepository.getLatestVitals()).thenAnswer((_) async => <VitalSignType, VitalSign?>{});
    when(() => mockHomeRepository.getRecentInsights()).thenAnswer((_) async => []);
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

  testWidgets('IndexingStatusBanner shows syncing state', (WidgetTester tester) async {
    final controller = StreamController<bool>();
    when(() => mockHomeRepository.hasIndexed).thenReturn(false);
    when(() => mockHomeRepository.indexingStatusStream).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // HomeCubit listens to statusStream. If it emits false, isIndexing becomes true.
    controller.add(false);
    await tester.pump();

    expect(find.text('Sincronizando estándares médicos...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.close();
  });

  testWidgets('IndexingStatusBanner shows error state and retry works', (WidgetTester tester) async {
    when(() => mockHomeRepository.hasIndexed).thenReturn(false);
    when(() => mockHomeRepository.indexingStatusStream).thenAnswer((_) => Stream.value(false));
    when(() => mockHomeRepository.retryIndexing()).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Trigger retry to get to error state
    final finder = find.byType(IndexingStatusBanner);
    final HomeCubit cubit = tester.state<State<IndexingStatusBanner>>(finder).context.read<HomeCubit>();
    cubit.retryIndexing();

    await tester.pump(); // Start retry
    await tester.pump(); // Finish retry

    expect(find.text('Error al sincronizar estándares médicos'), findsOneWidget);
    // Button text in Spanish for retry is "Reintentar"
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    verify(() => mockHomeRepository.retryIndexing()).called(2); // once from our manual call, once from tap
  });

  testWidgets('IndexingStatusBanner shows success state then disappears', (WidgetTester tester) async {
    final controller = StreamController<bool>();
    when(() => mockHomeRepository.hasIndexed).thenReturn(false);
    when(() => mockHomeRepository.indexingStatusStream).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(createWidgetUnderTest());

    // Transition to indexing (not done)
    controller.add(false);
    await tester.pump();
    expect(find.text('Sincronizando estándares médicos...'), findsOneWidget);

    // Transition to idle (done)
    controller.add(true);
    await tester.pump();

    expect(find.text('Estándares médicos actualizados'), findsOneWidget);

    // Wait for timer (3 seconds)
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Estándares médicos actualizados'), findsNothing);

    controller.close();
  });
}
