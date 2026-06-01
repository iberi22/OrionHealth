/// REAL End-to-End Smoke Test — Sin mocks
///
/// Prueba que ORIONHEALTH se inicialice correctamente en dispositivo real:
/// - GetIt con todas las dependencias registradas
/// - Sin crash de DI
/// - Sin pantalla de error de inicialización
///
/// Usa configureDependencies() primero, luego MyApp para simular el arranque real.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/main.dart' as app;
import 'package:orionhealth_health/core/di/injection.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Inicializar DI primero antes de construir cualquier widget
    await di.configureDependencies();
  });

  group('🚀 OrionHealth REAL Smoke Test — no mocks', () {
    testWidgets('App se inicializa sin crash ni pantalla de error', (
      WidgetTester tester,
    ) async {
      // Capturar errores de Flutter
      String? flutterError;
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        flutterError ??= details.exceptionAsString();
      };

      // Renderizar MyApp real (configureDependencies ya se llamó en setUpAll)
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 6));

      FlutterError.onError = originalHandler;

      print('🔍 All widgets: ${tester.allWidgets.length}');

      // Assert: sin error fatal de DI
      if (flutterError != null) {
        if (flutterError!.contains('GetIt') || flutterError!.contains('not registered')) {
          fail('❌ CRASH DE DI: $flutterError');
        }
        print('⚠️ Other Flutter error: $flutterError');
      }

      // Verificar que NO se muestra la pantalla de error de inicialización
      expect(find.text('Error de Inicialización'), findsNothing,
          reason: 'NO debe aparecer la pantalla de error — el DI debe funcionar');

      // La app debe tener widgets renderizados
      expect(tester.allWidgets.length, greaterThan(5),
          reason: 'Debe haber widgets renderizados (más de 5)');

      // Si hay navegación, probar interacción
      final navBars = find.byType(NavigationBar);
      if (navBars.evaluate().isNotEmpty) {
        print('✅ NavigationBar found — app initialized correctly');
        final destinations = find.byType(NavigationDestination);
        if (destinations.evaluate().length > 1) {
          await tester.tap(destinations.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Sin excepción
      final exc = tester.takeException();
      if (exc != null) {
        fail('❌ Unhandled exception after interaction: $exc');
      }
    });
  });
}
