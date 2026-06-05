import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    getIt.registerLazySingleton<LlmService>(() => MockLlmService());
  });

  tearDownAll(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: HomeDashboardPage(),
    );
  }

  testWidgets('HomeDashboardPage renders correctly', (WidgetTester tester) async {
    // Set a larger surface size for testing because the page uses a CustomScrollView and GridView
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('ORION HEALTH'), findsOneWidget);

    // Verify headers
    expect(find.text('ACCIONES RÁPIDAS'), findsOneWidget);
    expect(find.text('ACTIVIDAD RECIENTE'), findsOneWidget);

    // Verify quick action cards
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Salud'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Medicamentos'), findsOneWidget);

    // Verify recent activity tiles
    expect(find.text('Chequeo de presión'), findsOneWidget);
    expect(find.text('Medicamento: Vitamina C'), findsOneWidget);
    expect(find.text('Informe semanal generado'), findsOneWidget);
  });

  testWidgets('Quick action cards are present and have icons', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.psychology), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    expect(find.byIcon(Icons.medication), findsOneWidget);
  });
}
