import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/habeas_data_consent.dart';

void main() {
  group('HabeasDataConsent', () {
    test('isFullyAccepted requires all three checkboxes', () {
      final base = HabeasDataConsent(
        userId: 'u1',
        acceptedAt: DateTime.now(),
        documentVersion: 'v1.0',
        arcoRightsAccepted: false,
        processingPurposeAccepted: false,
        dataSharingAccepted: false,
      );
      expect(base.isFullyAccepted, false);

      final partial = HabeasDataConsent(
        userId: 'u1',
        acceptedAt: DateTime.now(),
        documentVersion: 'v1.0',
        arcoRightsAccepted: true,
        processingPurposeAccepted: true,
        dataSharingAccepted: false,
      );
      expect(partial.isFullyAccepted, false);

      final full = HabeasDataConsent(
        userId: 'u1',
        acceptedAt: DateTime.now(),
        documentVersion: 'v1.0',
        arcoRightsAccepted: true,
        processingPurposeAccepted: true,
        dataSharingAccepted: true,
      );
      expect(full.isFullyAccepted, true);
    });

    test('toJson includes all required fields', () {
      final c = HabeasDataConsent(
        userId: 'u1',
        acceptedAt: DateTime.utc(2026, 8, 29),
        documentVersion: 'v1.0',
        arcoRightsAccepted: true,
        processingPurposeAccepted: true,
        dataSharingAccepted: true,
      );

      final json = c.toJson();
      expect(json['user_id'], 'u1');
      expect(json['accepted_at'], '2026-08-29T00:00:00.000Z');
      expect(json['document_version'], 'v1.0');
      expect(json['arco_rights_accepted'], true);
      expect(json['processing_purpose_accepted'], true);
      expect(json['data_sharing_accepted'], true);
    });
  });

  group('HabeasDataDocument', () {
    test('currentVersion is set', () {
      expect(HabeasDataDocument.currentVersion, isNotEmpty);
      expect(HabeasDataDocument.currentVersion, contains('2026'));
    });

    test('all required sections are non-empty', () {
      expect(HabeasDataDocument.title, isNotEmpty);
      expect(HabeasDataDocument.intro, isNotEmpty);
      expect(HabeasDataDocument.dataCollected, isNotEmpty);
      expect(HabeasDataDocument.purpose, isNotEmpty);
      expect(HabeasDataDocument.arcoRights, isNotEmpty);
      expect(HabeasDataDocument.dataSharing, isNotEmpty);
      expect(HabeasDataDocument.acceptance, isNotEmpty);
    });

    test('ARCO section mentions all 4 rights', () {
      final text = HabeasDataDocument.arcoRights.toLowerCase();
      expect(text.contains('acceso'), true);
      expect(text.contains('rectificación'), true);
      expect(text.contains('cancelación'), true);
      expect(text.contains('oposición'), true);
    });
  });
}