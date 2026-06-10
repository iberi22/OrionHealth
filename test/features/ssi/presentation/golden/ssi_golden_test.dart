import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/services/ssi_service.dart';
import 'package:orionhealth_health/features/ssi/presentation/pages/share_credential_page.dart';
import '../../../../core/golden_test_utils.dart';

class MockSsiService extends Mock implements SsiService {}

void main() {
  late MockSsiService mockSsiService;
  late VerifiableCredential sampleCredential;

  setUp(() {
    mockSsiService = MockSsiService();
    sampleCredential = VerifiableCredential(
      id: 'cred:123',
      issuer: 'did:orion:clinic-001',
      subject: 'did:orion:patient-abc',
      type: 'VaccinationCredential',
      schemaId: 'orion:schemas:VaccinationCredential:v1',
      claims: {
        'vaccine': 'Pfizer-BioNTech',
        'lot': 'AA1234',
        'date': '2023-10-01',
        'patientName': 'John Doe',
      },
      issuanceDate: DateTime(2023, 10, 1),
    );
  });

  group('SSI Golden Tests', () {
    testWidgets('Share Credential Page - Selection Mode', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        ShareCredentialPage(
          ssiService: mockSsiService,
          credential: sampleCredential,
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ShareCredentialPage),
        matchesGoldenFile('goldens/share_credential_selection.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Share Credential Page - Preview Mode', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        ShareCredentialPage(
          ssiService: mockSsiService,
          credential: sampleCredential,
        ),
      ));
      await tester.pumpAndSettle();

      // Select a field to enable Preview button
      await tester.tap(find.text('Vaccine'));
      await tester.pump();

      // Tap Preview button
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ShareCredentialPage),
        matchesGoldenFile('goldens/share_credential_preview.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
