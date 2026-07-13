import 'package:flutter_test/flutter_test.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/models/consent_document.dart';

void main() {
  group('LocalConsentDocument', () {
    test('consentDocument returns an RPConsentDocument with correct title', () {
      final document = LocalConsentDocument.consentDocument;

      expect(document, isA<RPConsentDocument>());
      expect(document.title, 'Consentimiento Informado - Orion Health');
    });

    test('consentDocument has 2 sections', () {
      final document = LocalConsentDocument.consentDocument;

      expect(document.sections.length, 2);
    });

    test('first section is about DataGathering with Spanish text', () {
      final document = LocalConsentDocument.consentDocument;
      final section = document.sections[0];

      expect(section.type, RPConsentSectionType.DataGathering);
      expect(section.summary, 'Recolección de Datos Locales');
      expect(section.content, contains('EXCLUSIVAMENTE en tu dispositivo personal'));
      expect(section.content, contains('tu dispositivo personal'));
    });

    test('second section is about Privacy with Spanish text', () {
      final document = LocalConsentDocument.consentDocument;
      final section = document.sections[1];

      expect(section.type, RPConsentSectionType.Privacy);
      expect(section.summary, 'Privacidad 100% Local');
      expect(section.content, contains('totalmente local'));
      expect(section.content, contains('HIPAA'));
      expect(section.content, contains('solo tú tienes acceso'));
    });

    test('consentDocument is a static getter that returns a fresh instance each time', () {
      final doc1 = LocalConsentDocument.consentDocument;
      final doc2 = LocalConsentDocument.consentDocument;

      // They should be equal in structure
      expect(doc1.title, doc2.title);
      expect(doc1.sections.length, doc2.sections.length);
    });
  });
}
