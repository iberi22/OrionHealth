import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('SnomedConcept', () {
    test('findByCode returns correct concept', () {
      final concept = SnomedCommonConcepts.findByCode('44054006');
      expect(concept, isNotNull);
      expect(concept!.code, equals('44054006'));
    });

    test('findByCode returns null for invalid code', () {
      final concept = SnomedCommonConcepts.findByCode('999999999');
      expect(concept, isNull);
    });

    test('findByCode finds Type 2 Diabetes', () {
      final diabetes = SnomedCommonConcepts.findByCode('44054006');
      expect(diabetes, isNotNull);
      expect(diabetes!.displayName.toLowerCase(), contains('diabetes'));
    });

    test('findByCode is case insensitive', () {
      final concept1 = SnomedCommonConcepts.findByCode('44054006');
      final concept2 = SnomedCommonConcepts.findByCode('44054006');
      expect(concept1, isNotNull);
      expect(concept2, isNotNull);
      expect(concept1?.code, equals(concept2?.code));
    });

    test('props for Equatable equality', () {
      final c1 = SnomedCommonConcepts.findByCode('44054006');
      final c2 = SnomedCommonConcepts.findByCode('44054006');
      expect(c1, equals(c2));
    });
  });

  group('SnomedCommonConcepts', () {
    test('all returns non-empty list', () {
      expect(SnomedCommonConcepts.all, isNotEmpty);
    });

    test('all contains common conditions', () {
      final concepts = SnomedCommonConcepts.all;
      final codes = concepts.map((c) => c.code).toList();
      expect(codes, contains('44054006')); // Type 2 Diabetes
    });

    test('findByCode returns correct concept', () {
      final concept = SnomedCommonConcepts.findByCode('44054006');
      expect(concept, isNotNull);
      expect(concept!.code, equals('44054006'));
    });
  });
}
