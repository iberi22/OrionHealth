import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/application/ecosystem_link_inbox.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/ecosystem_import_service.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/parsers/health_data_parser.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/ecosystem_confirmation_page.dart';

Map<String, dynamic> meal() =>
    jsonDecode(
          File(
            'packages/health_contract/test/fixtures/valid/meal-log-01.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

void main() {
  test(
    'ecosystem parser validates files and does not silently discard invalid records',
    () {
      final parser = HealthDataParser();
      final record = meal();
      expect(
        parser.parseSwalHealth(jsonEncode([record])).single.toJson(),
        record,
      );
      expect(
        () => parser.parseSwalHealth(
          jsonEncode([
            {'schema': 'swal.health/v1/meal-log'},
          ]),
        ),
        throwsA(anything),
      );
    },
  );

  test('import link routing leaves OAuth callbacks alone', () {
    expect(
      EcosystemLinkInbox.isImportLink(Uri.parse('orionhealth://import?p=abc')),
      isTrue,
    );
    expect(
      EcosystemLinkInbox.isImportLink(
        Uri.parse('https://example.org/import#p=abc'),
      ),
      isTrue,
    );
    expect(
      EcosystemLinkInbox.isImportLink(
        Uri.parse('orionhealth://oauth2redirect?code=abc'),
      ),
      isFalse,
    );
    expect(
      EcosystemLinkInbox.isImportLink(
        Uri.parse('http://example.org/import#p=abc'),
      ),
      isFalse,
    );
  });

  testWidgets('review requires identity confirmation and explicit save', (
    tester,
  ) async {
    var saves = 0;
    var bound = false;
    final record = meal();
    await tester.pumpWidget(
      MaterialApp(
        home: EcosystemConfirmationPage(
          preview: EcosystemImportPreview(
            [record],
            record['subject'] as String,
            true,
          ),
          save: (bind) async {
            saves++;
            bound = bind;
            return 1;
          },
        ),
      ),
    );
    expect(saves, 0);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar importación'),
    );
    expect(button.onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Confirmar importación'));
    await tester.pumpAndSettle();
    expect(saves, 1);
    expect(bound, isTrue);
  });

  testWidgets('cancel does not call persistence', (tester) async {
    var saves = 0;
    final record = meal();
    await tester.pumpWidget(
      MaterialApp(
        home: EcosystemConfirmationPage(
          preview: EcosystemImportPreview(
            [record],
            record['subject'] as String,
            false,
          ),
          save: (_) async {
            saves++;
            return 1;
          },
        ),
      ),
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(saves, 0);
  });

  testWidgets('failed save remains reviewable without leaking input in error', (
    tester,
  ) async {
    final record = meal();
    await tester.pumpWidget(
      MaterialApp(
        home: EcosystemConfirmationPage(
          preview: EcosystemImportPreview(
            [record],
            record['subject'] as String,
            false,
          ),
          save: (_) async => throw Exception('private payload'),
        ),
      ),
    );
    await tester.tap(find.text('Confirmar importación'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo guardar'), findsOneWidget);
    expect(find.textContaining('private payload'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirmar importación'),
          )
          .onPressed,
      isNotNull,
    );
  });
}
