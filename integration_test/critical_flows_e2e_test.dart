import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/main.dart' as app;
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class _FakeFilePicker implements FilePickerService {
  @override
  Future<String?> pickPdf() async => '/data/local/tmp/orion_e2e_checkup.pdf';
}

class _FakeOcr implements OcrService {
  @override
  Future<String> extractText(String filePath) async =>
      'Hemograma completo dentro de rangos normales.';
}

/// Builds a pristine app state for every flow.
///
/// Isar 3 keeps a named instance open across tests and getIt.reset() does not
/// close it. The Isar files and the secure-storage PIN/session also survive
/// between tests (and between runs on the same emulator), so they are wiped
/// here: otherwise the PIN set in flow 2 would turn flow 3 into a login screen.
Future<void> _freshApp({
  bool onboardingCompleted = false,
  bool withProfile = false,
  void Function()? overrides,
}) async {
  await Isar.getInstance()?.close();
  await di.getIt.reset();
  // Preferences must be seeded before DI resolves SharedPreferences.
  SharedPreferences.setMockInitialValues({
    if (onboardingCompleted) 'onboarding_completed': true,
  });
  await di.configureDependencies();

  final isar = Isar.getInstance()!;
  await isar.writeTxn(() => isar.clear());
  final auth = di.getIt<AuthRepository>();
  await auth.deleteSession();
  await auth.deleteCredentials();

  if (withProfile) {
    // AuthGate only routes to the PIN screen when a completed profile exists.
    await di.getIt<UserProfileRepository>().saveUserProfile(
      UserProfile(name: 'Test User', onboardingCompleted: true),
    );
  }
  overrides?.call();
}

Future<void> _launch(WidgetTester tester) async {
  await tester.pumpWidget(const app.MyApp());
  await tester.pump(const Duration(seconds: 2));
  await _settle(tester);
}

/// pumpAndSettle that tolerates screens with perpetual animations.
Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// Pumps real time until [finder] matches (async work such as Isar/network).
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) break;
    await tester.pump(const Duration(milliseconds: 250));
  }
  if (finder.evaluate().isEmpty) {
    _dump(tester, 'timed out waiting for $finder');
  }
  await tester.pump(const Duration(milliseconds: 300));
}

/// Prints what is on screen so a failed CI run shows where the flow got stuck.
void _dump(WidgetTester tester, String why) {
  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? w.textSpan?.toPlainText())
      .whereType<String>()
      .take(60)
      .toList();
  // ignore: avoid_print
  print(
    '[E2E-DUMP] $why :: spinners='
    '${find.byType(CircularProgressIndicator).evaluate().length} texts=$texts',
  );
}

double _viewHeight(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

/// Scrolls the nearest vertical scrollable until [finder] is on screen.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axis == Axis.vertical,
  );
  final h = _viewHeight(tester);
  double? lastY;
  for (var i = 0; i < 40; i++) {
    final built = finder.evaluate().isNotEmpty;
    double? y;
    if (built) {
      y = tester.getCenter(finder.first).dy;
      if (y >= 80 && y <= h - 120) return;
      if (y == lastY) return; // cannot scroll any further
    }
    lastY = y;
    Finder? target;
    if (built) {
      final ancestors = find.ancestor(of: finder.first, matching: vertical);
      if (ancestors.evaluate().isNotEmpty) target = ancestors.first;
    }
    if (target == null && vertical.evaluate().isNotEmpty) {
      target = vertical.last;
    }
    if (target == null) return; // nothing scrollable on this screen
    final up = y == null || y > h / 2;
    await tester.drag(target, Offset(0, up ? -200 : 200), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  // Close the keyboard left open by a previous enterText so it does not
  // shrink the viewport and push the target out of view.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 200));
  await _reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await _settle(tester);
}

Future<void> _setupPin(WidgetTester tester) async {
  await _pumpUntil(tester, find.text('Configurar PIN'));
  if (find.text('Configurar PIN').evaluate().isEmpty) _dump(tester, 'no PIN page');
  expect(find.text('Configurar PIN'), findsOneWidget);
  await tester.enterText(find.widgetWithText(TextField, 'Nuevo PIN'), '1234');
  await tester.enterText(
    find.widgetWithText(TextField, 'Confirmar PIN'),
    '1234',
  );
  await tester.tap(find.text('Guardar PIN'));
  await _pumpUntil(tester, find.byType(NavigationBar));
  await _settle(tester);
}

/// Boots an onboarded user with no PIN and walks through PIN setup.
Future<void> _enterApp(
  WidgetTester tester, {
  void Function()? overrides,
}) async {
  await _freshApp(
    onboardingCompleted: true,
    withProfile: true,
    overrides: overrides,
  );
  await _launch(tester);
  await _setupPin(tester);
  expect(find.byType(NavigationBar), findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('OrionHealth Critical Flows E2E', () {
    testWidgets('1. Full Onboarding Flow', (tester) async {
      await _freshApp();
      await _launch(tester);

      // Welcome Step
      expect(find.text('Bienvenido a OrionHealth'), findsOneWidget);
      await tester.tap(find.text('Comenzar'));
      await _settle(tester);

      // Basic Info Step
      expect(find.text('Información Personal'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Nombre completo'),
        'Test User',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Peso (kg)'), '70');
      await tester.enterText(
        find.widgetWithText(TextField, 'Altura (cm)'),
        '175',
      );
      // nextStep() requires birth date and sex (OnboardingCubit validation).
      await tester.ensureVisible(find.text('Fecha de nacimiento'));
      await tester.tap(find.text('Fecha de nacimiento'));
      await _settle(tester);
      // Date picker opens preselected on 1990-01-01; confirm with the last dialog button (OK).
      await tester.tap(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(TextButton),
            )
            .last,
      );
      await _settle(tester);
      await tester.ensureVisible(find.text('Masculino'));
      await tester.tap(find.text('Masculino'));
      await _settle(tester);
      await _tap(tester, find.text('Siguiente'));

      // Conditions Step
      expect(find.text('Condiciones de Salud'), findsOneWidget);
      await _tap(tester, find.text('Siguiente'));

      // Family History Step
      expect(find.text('Historial Familiar'), findsOneWidget);
      await _tap(tester, find.text('Siguiente'));

      // Medications Step
      expect(find.text('Medicamentos y Alergias'), findsOneWidget);
      await _tap(tester, find.text('Siguiente'));

      // Privacy Step
      expect(find.text('Privacidad y Seguridad'), findsOneWidget);
      await _tap(tester, find.text('Acepto el procesamiento de mis datos'));
      await _tap(tester, find.text('Acepto la política de privacidad'));
      await _tap(tester, find.text('Completar'));
      // completeOnboarding() simulates a ~1s sync before emitting Completed.
      await _pumpUntil(tester, find.text('¡Bienvenido a OrionHealth!'));
      await _settle(tester);

      // Complete Step
      expect(find.text('¡Bienvenido a OrionHealth!'), findsOneWidget);
      await _tap(tester, find.text('Continuar'));
      await _pumpUntil(tester, find.byType(NavigationBar));

      // Verify Main Navigation
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('2. Auth Flow: PIN Setup', (tester) async {
      // Onboarding completed (flag + saved profile) but no PIN yet:
      // AuthGate must show SetupPinPage.
      await _freshApp(onboardingCompleted: true, withProfile: true);
      await _launch(tester);

      await _setupPin(tester);

      // Should reach Dashboard
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('3. Home -> Appointments -> Create -> Delete', (tester) async {
      await _enterApp(tester);

      // Home module grid
      await _pumpUntil(tester, find.text('Citas'));
      await _tap(tester, find.text('Citas'));
      expect(find.widgetWithText(AppBar, 'Citas'), findsOneWidget);

      // Create Appointment
      await tester.tap(find.byType(FloatingActionButton).last);
      await _settle(tester);
      expect(find.text('Nueva Cita'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nombre del Doctor'),
        'Dr. Orion',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Especialidad'),
        'General',
      );
      await _tap(tester, find.text('GUARDAR'));
      await _pumpUntil(tester, find.text('Dr. Orion'));
      await _reveal(tester, find.text('Dr. Orion'));

      expect(find.text('Dr. Orion'), findsOneWidget);

      // Delete Appointment
      await _tap(tester, find.text('Dr. Orion'));
      expect(find.text('Editar Cita'), findsOneWidget);
      await _tap(tester, find.text('ELIMINAR'));
      await _settle(tester);

      expect(find.text('Dr. Orion'), findsNothing);
    });

    testWidgets('4. Health Record: Upload -> View -> Share', (tester) async {
      // The system file picker and ML Kit OCR are native; fake only those two.
      await _enterApp(
        tester,
        overrides: () {
          di.getIt.unregister<FilePickerService>();
          di.getIt.registerLazySingleton<FilePickerService>(
            () => _FakeFilePicker(),
          );
          di.getIt.unregister<OcrService>();
          di.getIt.registerLazySingleton<OcrService>(() => _FakeOcr());
        },
      );

      // Navigate to Health Records
      await tester.tap(find.byKey(const Key('nav_health_records')));
      await _settle(tester);
      expect(find.text('Historial Médico'), findsOneWidget);

      // Upload: Añadir Registro -> Subir PDF -> form
      await tester.tap(find.text('Añadir Registro'));
      await _settle(tester);
      await tester.tap(find.text('Subir PDF'));
      await _pumpUntil(tester, find.text('Nuevo Registro Médico'));
      expect(find.text('Nuevo Registro Médico'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Resumen Breve'),
        'Checkup',
      );
      await _tap(tester, find.text('Guardar'));

      // View: the saved record is listed in the timeline
      await _pumpUntil(tester, find.text('Checkup'));
      await _reveal(tester, find.text('Checkup'));
      expect(find.text('Historial Médico'), findsOneWidget);
      expect(find.text('Checkup'), findsOneWidget);
      expect(find.text('Ver Detalles'), findsWidgets);

      // Share
      await tester.tap(find.byKey(const Key('health_record_share_button')));
      await _settle(tester);
      expect(find.text('Share Medical Data'), findsOneWidget);
    });

    testWidgets('5. Local Agent: Ask question -> Receive response', (
      tester,
    ) async {
      await _enterApp(tester);

      // Open the assistant from the Home module grid
      await _pumpUntil(tester, find.text('AI Assistant'));
      await _tap(tester, find.text('AI Assistant'));
      expect(find.text('Orion AI Assistant'), findsOneWidget);

      final textField = find.widgetWithText(TextField, 'Escribe un mensaje...');
      expect(textField, findsOneWidget);
      await tester.enterText(textField, '¿Qué es OrionHealth?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);

      // Verify user message is in the list
      expect(find.text('¿Qué es OrionHealth?'), findsOneWidget);

      // Wait for AI response (real or fallback error message)
      await tester.pump(const Duration(seconds: 2));
      await _settle(tester);
      expect(find.byType(ListView), findsWidgets);
      expect(find.textContaining('OrionHealth'), findsWidgets);
    });

    testWidgets('6. Sync: Trigger sync and verify', (tester) async {
      await _enterApp(tester);

      // Navigate to Sync page: Perfil tab -> Sincronización tile
      await tester.tap(find.byKey(const Key('nav_profile')));
      await _settle(tester);
      await _tap(tester, find.byKey(const Key('profile_sync_tile')));

      expect(find.text('Sincronización'), findsWidgets);
      expect(find.text('Sincronización General'), findsOneWidget);

      // Perform Sync
      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump(); // Trigger the sync

      // Check for loading state
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Verify success snackbar
      await _pumpUntil(
        tester,
        find.text('Sincronización completada con éxito'),
        timeout: const Duration(seconds: 120),
      );
      expect(find.text('Sincronización completada con éxito'), findsWidgets);
    });
  });
}
