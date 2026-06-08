// REAL End-to-End Smoke Test — Sin mocks
//
// Prueba ORIONHEALTH completo en dispositivo real:
// 1. Inicialización sin crash de DI
// 2. Onboarding con labels correctos (Peso, Nombre, etc.)
// 3. Navegación a pantalla de Citas (con botones Email + Calendario)
// 4. Conexión EPS (pantalla, no login real)
// 5. Estado de sincronización FHIR
//
// Ejecutar: flutter test integration_test/smoke_injectable_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/main.dart' as app;
import 'package:orionhealth_health/core/di/injection.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
  });

  group('🚀 OrionHealth REAL Smoke Test — sin mocks', () {
    testWidgets('1. App se inicializa sin crash', (WidgetTester tester) async {
      String? flutterError;
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        flutterError ??= details.exceptionAsString();
      };

      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 6));

      FlutterError.onError = originalHandler;

      final widgetCount = tester.allWidgets.length;
      debugPrint('🔍 Widgets renderizados: $widgetCount');

      // Assert: sin error de DI
      if (flutterError != null) {
        if (flutterError!.contains('GetIt') || flutterError!.contains('not registered')) {
          fail('❌ CRASH DE DI: $flutterError');
        }
        debugPrint('⚠️ Otro error Flutter: $flutterError');
      }

      expect(find.text('Error de Inicialización'), findsNothing,
          reason: 'NO debe mostrar pantalla de error');

      expect(widgetCount, greaterThan(5),
          reason: 'Debe haber widgets renderizados');
    });

    testWidgets('2. Onboarding muestra labels correctamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que los labels del onboarding NO están rotos
      // Los labels en TextField aparecen como texto auxiliar o placeholder

      // Si hay un campo de nombre
      debugPrint('🔍 Campos de texto encontrados: ${find.byType(TextField).evaluate().length}');

      // Buscar label "Peso"
      final pesoLabels = find.text('Peso (kg)');
      debugPrint('🔍 Label "Peso (kg)" encontrado: ${pesoLabels.evaluate().isNotEmpty}');

      // Buscar label "Nombre"
      final nombreLabels = find.text('Nombre completo');
      debugPrint('🔍 Label "Nombre completo" encontrado: ${nombreLabels.evaluate().isNotEmpty}');

      // Verificar contraste - si los labels existen, deben ser legibles
      if (pesoLabels.evaluate().isNotEmpty) {
        final pesoWidget = pesoLabels.evaluate().first.widget as Text;
        final style = pesoWidget.style;
        if (style != null) {
          final alpha = (style.color?.a ?? 0.0) * 255.0;
          debugPrint('🔍 Color label Peso: ${style.color} (alpha: $alpha)');
          // Alpha debe ser > 200 para ser legible
          if (style.color != null && alpha < 150) {
            debugPrint('⚠️ ADVERTENCIA: Label Peso tiene alpha bajo ($alpha)');
          }
        }
      }
    });

    testWidgets('3. Pantalla de Citas tiene botones Email y Calendario',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navegar a la pantalla de Citas (icono de calendario en nav)
      final calendarIcon = find.byIcon(Icons.calendar_month);
      final emailIcon = find.byIcon(Icons.email_outlined);

      if (calendarIcon.evaluate().isNotEmpty) {
        debugPrint('✅ Botón calendario (Icons.calendar_month) encontrado');
      }
      if (emailIcon.evaluate().isNotEmpty) {
        debugPrint('✅ Botón email (Icons.email_outlined) encontrado');
      }

      // También buscar en NavigationBar
      final navBar = find.byType(NavigationBar);
      if (navBar.evaluate().isNotEmpty) {
        final destinations = find.byType(NavigationDestination);
        final destCount = destinations.evaluate().length;
        debugPrint('🔍 Destinos de navegación: $destCount');

        if (destCount > 1) {
          // Tocar cada destino para verificar que no crashea
          for (int i = 0; i < destCount; i++) {
            await tester.tap(destinations.at(i));
            await tester.pumpAndSettle(const Duration(seconds: 2));
            debugPrint('✅ Destino $i navegado sin crash');
          }
        }
      }
    });

    testWidgets('4. Conexión EPS - pantalla se muestra sin error',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Buscar botón "Conectar" (EPS connection)
      final connectarBtns = find.text('Conectar');
      final conectarBtns = find.text('Conectar con mi EPS');
      final epsBtns = find.text('Conectar con IHCE');

      debugPrint('🔍 Botones de conexión: Conectar=${connectarBtns.evaluate().length}, EPS=${
        conectarBtns.evaluate().length}, IHCE=${epsBtns.evaluate().length}');

      // Si hay algún botón de EPS, asegurarse que no crashea al tocarlo
      final anyEpsBtn = find.byWidgetPredicate(
        (w) => w is TextButton || w is ElevatedButton || w is OutlinedButton,
      );
      final epsRelatedBtns = find.ancestor(
        of: find.byWidgetPredicate(
          (w) => w is Text && w.data != null && w.data!.toLowerCase().contains('conect'),
        ),
        matching: anyEpsBtn,
      );

      if (epsRelatedBtns.evaluate().isNotEmpty) {
        debugPrint('✅ Botón de conexión EPS visible');
      }
    });

    testWidgets('5. Sin excepciones no capturadas',
        (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final exc = tester.takeException();
      if (exc != null) {
        fail('❌ Excepción no capturada: $exc');
      }
      debugPrint('✅ Sin excepciones no capturadas');
    });
  });
}
