import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';

void main() {
  group('DoctorRating Data Tests', () {
    test('categories getter parses categoriesJson correctly', () {
      final categoriesMap = {'Clinical': 5, 'Bedside': 4};
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'd1',
        overallScore: 5,
        categoriesJson: jsonEncode(categoriesMap),
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      expect(rating.categories, equals(categoriesMap));
      expect(rating.categories['Clinical'], 5);
      expect(rating.categories['Bedside'], 4);
    });

    test('validate returns true for valid rating', () {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'd1',
        overallScore: 3,
        categoriesJson: '{}',
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
        comment: 'Good',
      );

      expect(rating.validate(), isTrue);
    });

    test('validate returns false for invalid score (too low)', () {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'd1',
        overallScore: 0,
        categoriesJson: '{}',
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      expect(rating.validate(), isFalse);
    });

    test('validate returns false for invalid score (too high)', () {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'd1',
        overallScore: 6,
        categoriesJson: '{}',
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      expect(rating.validate(), isFalse);
    });

    test('validate returns false for excessively long comment', () {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'd1',
        overallScore: 5,
        categoriesJson: '{}',
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
        comment: 'a' * 501,
      );

      expect(rating.validate(), isFalse);
    });
  });
}
