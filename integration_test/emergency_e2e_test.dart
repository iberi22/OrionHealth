import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/emergency/domain/entities/medical_id.dart';
import 'package:orionhealth_health/features/emergency/domain/repositories/medical_id_repository.dart';
import 'package:orionhealth_health/features/emergency/presentation/cubit/emergency_cubit.dart';
import 'package:orionhealth_health/features/emergency/presentation/pages/emergency_id_page.dart';
import 'package:orionhealth_health/features/emergency/presentation/pages/emergency_edit_page.dart';
import 'package:orionhealth_health/features/emergency/presentation/widgets/medical_id_qr_view.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
  });

  group('FEAT-022: Emergency ID Real E2E Test', () {
    testWidgets('Create Medical ID -> see card -> QR visible', (
      WidgetTester tester,
    ) async {
      final repo = di.getIt<MedicalIdRepository>();
      const testUserId = 'test-user';

      try {
        await repo.delete(testUserId);
      } catch (_) {}

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => di.getIt<EmergencyCubit>(),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            home: Scaffold(
              body: ListView(
                children: [
                  const SizedBox(
                    height: 500,
                    child: EmergencyIdPage(userId: testUserId),
                  ),
                  BlocBuilder<EmergencyCubit, EmergencyState>(
                    builder: (context, state) {
                      if (state.medicalId != null) {
                        return MedicalIdQrView(medicalId: state.medicalId!);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            routes: {
              '/emergency/edit': (context) =>
                  const EmergencyEditPage(userId: testUserId),
            },
            theme: ThemeData.dark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EmergencyIdPage), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      final createButton = find.byType(FilledButton);
      expect(createButton, findsOneWidget);

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyEditPage), findsOneWidget);

      // The form is a lazy ListView: scroll each field into view first.
      final editList = find
          .descendant(
            of: find.byType(EmergencyEditPage),
            matching: find.byType(Scrollable),
          )
          .first;
      Future<void> fill(String label, String value) async {
        final field = find.widgetWithText(TextFormField, label);
        await tester.scrollUntilVisible(field, 100, scrollable: editList);
        await tester.pumpAndSettle();
        await tester.enterText(field, value);
        await tester.pumpAndSettle();
      }

      await fill('Nombre completo', 'John Doe');
      await fill('Fecha de nacimiento (YYYY-MM-DD)', '1990-01-01');

      final bloodType = find.byType(DropdownButtonFormField<BloodType>);
      await tester.scrollUntilVisible(bloodType, 100, scrollable: editList);
      await tester.pumpAndSettle();
      await tester.tap(bloodType);
      await tester.pumpAndSettle();
      await tester.tap(find.text('O Positivo').last);
      await tester.pumpAndSettle();

      await fill('Alergias (separadas por coma)', 'Penicilina');
      await fill('Nombre', 'Jane Doe');
      await fill('Teléfono', '555-1234');

      final saveButton = find.byIcon(Icons.save);
      await tester.scrollUntilVisible(saveButton, 100, scrollable: editList);
      await tester
          .pumpAndSettle(); // let the scroll fling finish before tapping
      await tester.tap(saveButton);

      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.textContaining('O Positivo'), findsOneWidget);
      expect(find.textContaining('Penicilina'), findsOneWidget);

      expect(find.text('QR Médico'), findsOneWidget);
      expect(find.byType(MedicalIdQrView), findsOneWidget);
    });
  });
}
