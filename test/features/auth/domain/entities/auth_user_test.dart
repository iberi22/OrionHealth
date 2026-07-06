import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_user.dart';

void main() {
  group('AuthUser', () {
    test('should create AuthUser with correct values', () {
      const user = AuthUser(
        id: '123',
        email: 'test@example.com',
        role: 'user',
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.role, 'user');
    });

    test('toString should return correct string representation', () {
      const user = AuthUser(
        id: '123',
        email: 'test@example.com',
        role: 'user',
      );

      expect(user.toString(), 'AuthUser(id: 123, email: test@example.com, role: user)');
    });
  });
}
