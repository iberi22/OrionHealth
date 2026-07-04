import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfile More Tests', () {
    test('supports same values', () {
      final p1 = UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        birthDate: DateTime(1990),
        sex: 'M',
      );
      final p2 = UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        birthDate: DateTime(1990),
        sex: 'M',
      );
      // UserProfile doesn't implement Equatable, so it won't be equal by value unless it's the same instance.
      // But we can check values.
      expect(p1.name, p2.name);
      expect(p1.email, p2.email);
    });

    test('copyWith works correctly', () {
      final p1 = UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        birthDate: DateTime(1990),
        sex: 'M',
      );
      final p2 = p1.copyWith(name: 'Jane Doe');
      expect(p2.name, 'Jane Doe');
      expect(p2.email, 'john@example.com');
    });
  });
}
