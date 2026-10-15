import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/services/data_export_service.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/data_export_consent_page.dart';

class MockDataExportService extends Mock implements DataExportService {
  @override
  Future<ExportSummary> getExportSummary() async {
    return const ExportSummary(total: 10, userProfile: 1, medicalRecords: 2);
  }

  @override
  Future<File> exportUserData({
    String? exportDir,
    required ExportMode mode,
    required bool userConsented,
    String? passphrase,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#exportUserData, [], {
        #exportDir: exportDir,
        #mode: mode,
        #userConsented: userConsented,
        #passphrase: passphrase,
      }),
      returnValue: Future.value(File('dummy.zip')),
      returnValueForMissingStub: Future.value(File('dummy.zip')),
    );
  }
}

void main() {
  group('DataExportConsentPage', () {
    testWidgets('Tapping Cancel does not export data and pops the screen', (WidgetTester tester) async {
      final mockService = MockDataExportService();

      await tester.pumpWidget(
        MaterialApp(
          home: DataExportConsentPage(exportService: mockService),
        ),
      );

      await tester.pumpAndSettle();

      final cancelBtn = find.text('Cancelar');
      expect(cancelBtn, findsOneWidget);

      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      verifyNever(mockService.exportUserData(
        exportDir: anyNamed('exportDir'),
        mode: anyNamed('mode'),
        userConsented: anyNamed('userConsented'),
        passphrase: anyNamed('passphrase'),
      ));

      // Page should be popped
      expect(find.byType(DataExportConsentPage), findsNothing);
    });

    testWidgets('Export button is disabled when consent is false', (WidgetTester tester) async {
      final mockService = MockDataExportService();

      await tester.pumpWidget(
        MaterialApp(
          home: DataExportConsentPage(exportService: mockService),
        ),
      );

      await tester.pumpAndSettle();

      final exportBtn = find.widgetWithText(ElevatedButton, 'Exportar');
      expect(exportBtn, findsOneWidget);

      final buttonWidget = tester.widget<ElevatedButton>(exportBtn);
      expect(buttonWidget.onPressed, isNull);
    });
  });
}