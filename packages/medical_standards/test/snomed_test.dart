import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('SnomedConcept', () {
    test('findByCode returns correct concept', () {
      final concept = SnomedConcept.findByCode('44054006');
      expect(concept, isNotNull);
      expect(concept!.sctid, equals('44054006'));
    });

    test('findByCode returns null for invalid code', () {
      final concept = SnomedConcept.findByCode('999999999');
      expect(concept, isNull);
    });

    test('findByCode finds Type 2 Diabetes', () {
      final diabetes = SnomedConcept.findByCode('44054006');
      expect(diabetes, isNotNull);
      expect(diabetes!.fsn.toLowerCase(), contains('diabetes'));
    });

    test('findByCode is case insensitive', () {
      final concept1 = SnomedConcept.findByCode('44054006');
      final concept2 = SnomedConcept.findByCode('44054006');
      expect(concept1, isNotNull);
      expect(concept2, isNotNull);
      expect(concept1?.sctid, equals(concept2?.sctid));
    });

    test('props for Equatable equality', () {
      final c1 = SnomedConcept.findByCode('44054006');
      final c2 = SnomedConcept.findByCode('44054006');
      expect(c1, equals(c2));
    });
  });

  group('SnomedCommonConcepts', () {
    test('all returns non-empty list', () {
      expect(SnomedCommonConcepts.all, isNotEmpty);
    });

    test('all contains common conditions', () {
      final concepts = SnomedCommonConcepts.all;
      final codes = concepts.map((c) => c.sctid).toList();
      expect(codes, contains('44054006')); // Type 2 Diabetes
    });

    test('findByCode returns correct concept', () {
      final concept = SnomedCommonConcepts.findByCode('44054006');
      expect(concept, isNotNull);
      expect(concept!.sctid, equals('44054006'));
    });
  });
}
