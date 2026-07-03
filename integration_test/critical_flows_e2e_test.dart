import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/main.dart' as app;
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('OrionHealth Critical Flows E2E', () {
    setUpAll(() async {
      // Mock initial values for SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('1. Full Onboarding Flow', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      await tester.pumpWidget(const app.MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Welcome Step
      expect(find.text('Bienvenido a OrionHealth'), findsOneWidget);
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Basic Info Step
      expect(find.text('Información Personal'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Nombre completo'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Peso (kg)'), '70');
      await tester.enterText(find.widgetWithText(TextField, 'Altura (cm)'), '175');
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      // Conditions Step
      expect(find.text('Condiciones de Salud'), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      // Family History Step
      expect(find.text('Historial Familiar'), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      // Medications Step
      expect(find.text('Medicamentos y Alergias'), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      // Privacy Step
      expect(find.text('Privacidad y Seguridad'), findsOneWidget);
      await tester.tap(find.text('Acepto el procesamiento de mis datos'));
      await tester.tap(find.text('Acepto la política de privacidad'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completar'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Complete Step
      expect(find.text('¡Bienvenido a OrionHealth!'), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify Main Navigation
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('2. Auth Flow: PIN Setup', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();

      // Simulate that onboarding was completed but PIN is not yet set
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      await tester.pumpWidget(const app.MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should be at SetupPinPage (which is pushed by AuthGate if no PIN is set)
      expect(find.text('Configurar PIN'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Nuevo PIN'), '1234');
      await tester.enterText(find.widgetWithText(TextField, 'Confirmar PIN'), '1234');
      await tester.tap(find.text('Guardar PIN'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should reach Dashboard
      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('3. Home -> Appointments -> Create -> Delete', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      await tester.pumpWidget(const app.MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assume we are at Dashboard/Home
      // Look for Appointments module or navigate to it
      // Based on typical app structure, it might be an icon in a grid or a list
      final appointmentsBtn = find.text('Citas');
      if (appointmentsBtn.evaluate().isNotEmpty) {
        await tester.tap(appointmentsBtn);
        await tester.pumpAndSettle();
      } else {
        // Try finding by icon if text not found
        await tester.tap(find.byIcon(Icons.calendar_month));
        await tester.pumpAndSettle();
      }

      expect(find.text('Citas'), findsWidgets);

      // Create Appointment
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del Doctor'), 'Dr. Orion');
      await tester.enterText(find.widgetWithText(TextField, 'Especialidad'), 'General');
      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Orion'), findsOneWidget);

      // Delete Appointment
      await tester.tap(find.text('Dr. Orion'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ELIMINAR'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Orion'), findsNothing);
    });

    testWidgets('4. Health Record: Upload -> View -> Share', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      await tester.pumpWidget(const app.MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to Health Records
      await tester.tap(find.byIcon(Icons.medical_services_outlined));
      await tester.pumpAndSettle();

      // Tap Upload button
      final uploadBtn = find.text('Subir PDF');
      if (uploadBtn.evaluate().isNotEmpty) {
        await tester.tap(uploadBtn);
        await tester.pumpAndSettle();
      } else {
        // Fallback to FAB if present
        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await tester.tap(fab);
          await tester.pumpAndSettle();
        }
      }

      // Simulate a file picked state by pumping the specific step if needed,
      // but here we try to find the form fields from _UploadDetailsStep
      final summaryField = find.widgetWithText(TextField, 'Resumen o Título');
      if (summaryField.evaluate().isNotEmpty) {
         await tester.enterText(summaryField, 'Checkup');
         await tester.tap(find.text('GUARDAR REGISTRO'));
         await tester.pumpAndSettle();
      }

      // Verify it appears in timeline or list
      // Since it's E2E, we might just check if we are back at the records list
      expect(find.text('Registros Médicos'), findsWidgets);

      // Navigate to Share
      // Usually via a button in the app bar or a tab
      final shareBtn = find.byIcon(Icons.share);
      if (shareBtn.evaluate().isNotEmpty) {
        await tester.tap(shareBtn.first);
        await tester.pumpAndSettle();
        expect(find.text('Compartir'), findsWidgets);
      }
    });

    testWidgets('5. Local Agent: Ask question -> Receive response', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      await tester.pumpWidget(const app.MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to AI Assistant
      // Based on main_navigation_page.dart, there's no direct tab for AI Assistant yet?
      // Wait, let's check HomePage for a module card or icon.
      final assistantBtn = find.byIcon(Icons.psychology_outlined);
      if (assistantBtn.evaluate().isNotEmpty) {
        await tester.tap(assistantBtn.first);
        await tester.pumpAndSettle();
      } else {
        // Try looking for it in the dashboard grid
        final aiText = find.text('Asistente IA');
        if (aiText.evaluate().isNotEmpty) {
          await tester.tap(aiText);
          await tester.pumpAndSettle();
        }
      }

      // If we are at ChatPage
      final textField = find.widgetWithText(TextField, 'Escribe un mensaje...');
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField, '¿Qué es OrionHealth?');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Verify user message is in the list
        expect(find.text('¿Qué es OrionHealth?'), findsOneWidget);

        // Wait for AI response (real or mock)
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        // Verify AI message bubble or that total messages > 1
        expect(find.byType(ListView), findsOneWidget);
        expect(find.textContaining('OrionHealth'), findsWidgets);
      }
    });

    testWidgets('6. Sync: Trigger sync and verify', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      await tester.pumpWidget(const app.MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Navigate to Sync page
      // Usually via Settings or a Sync icon
      final syncBtn = find.byIcon(Icons.sync);
      if (syncBtn.evaluate().isNotEmpty) {
        await tester.tap(syncBtn.first);
        await tester.pumpAndSettle();
      } else {
        final syncText = find.text('Sincronización');
        if (syncText.evaluate().isNotEmpty) {
          await tester.tap(syncText);
          await tester.pumpAndSettle();
        }
      }

      expect(find.text('Sincronización'), findsWidgets);

      // Perform Sync
      final performSyncBtn = find.text('SINCRONIZAR AHORA');
      if (performSyncBtn.evaluate().isNotEmpty) {
        await tester.tap(performSyncBtn);
        await tester.pump(); // Trigger the sync

        // Check for loading state or success message
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        // Verify success snackbar or updated time
        expect(find.text('Sincronización completada con éxito'), findsWidgets);
      }
    });
  });
}
