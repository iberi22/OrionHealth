import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  group('SharedHealthPackage Decoding Extended', () {
    test('decode throws error for invalid base64', () {
      expect(() => SharedHealthPackage.decode('invalid-base64!'), throwsException);
    });

    test('decode throws error for invalid JSON content', () {
      // Valid base64 but invalid JSON
      const invalidJsonBase64 = 'bm90LWpzb24='; // "not-json"
      expect(() => SharedHealthPackage.decode(invalidJsonBase64), throwsException);
    });
  });

  group('DataCategory Enum Extended', () {
    test('valueOf handles all known categories', () {
      for (final category in DataCategory.values) {
        expect(DataCategory.valueOf(category.name), equals(category));
      }
    });

    test('all categories have non-empty display names', () {
      for (final category in DataCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });
  });

  group('TransferMethod Enum Extended', () {
    test('all methods have display names and descriptions', () {
      for (final method in TransferMethod.values) {
        expect(method.displayName, isNotEmpty);
        expect(method.description, isNotEmpty);
      }
    });
  });
}
