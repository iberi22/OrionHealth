import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/data/models/oauth_token_dto.dart';

void main() {
  group('OAuthTokenDto', () {
    test('toJson serializes all fields correctly', () {
      final expiresAt = DateTime(2026, 6, 17, 12, 0, 0);
      final dto = OAuthTokenDto(
        accessToken: 'access123',
        idToken: 'id456',
        refreshToken: 'refresh789',
        expiresAt: expiresAt,
      );

      final json = dto.toJson();
      expect(json['accessToken'], equals('access123'));
      expect(json['idToken'], equals('id456'));
      expect(json['refreshToken'], equals('refresh789'));
      expect(json['expiresAt'], equals(expiresAt.toIso8601String()));
    });

    test('toJson omits null fields', () {
      final dto = const OAuthTokenDto();

      final json = dto.toJson();
      expect(json.containsKey('accessToken'), isFalse);
      expect(json.containsKey('idToken'), isFalse);
      expect(json.containsKey('refreshToken'), isFalse);
      expect(json.containsKey('expiresAt'), isFalse);
    });

    test('fromJson parses all fields correctly', () {
      final expiresAt = DateTime(2026, 6, 17, 12, 0, 0);
      final json = {
        'accessToken': 'access123',
        'idToken': 'id456',
        'refreshToken': 'refresh789',
        'expiresAt': expiresAt.toIso8601String(),
      };

      final dto = OAuthTokenDto.fromJson(json);
      expect(dto.accessToken, equals('access123'));
      expect(dto.idToken, equals('id456'));
      expect(dto.refreshToken, equals('refresh789'));
      expect(dto.expiresAt, equals(expiresAt));
    });

    test('fromJson handles null expiresAt', () {
      final json = {
        'accessToken': 'access123',
        'idToken': 'id456',
        'refreshToken': 'refresh789',
      };

      final dto = OAuthTokenDto.fromJson(json);
      expect(dto.accessToken, equals('access123'));
      expect(dto.expiresAt, isNull);
    });

    test('fromJson handles empty map', () {
      final dto = OAuthTokenDto.fromJson({});
      expect(dto.accessToken, isNull);
      expect(dto.idToken, isNull);
      expect(dto.refreshToken, isNull);
      expect(dto.expiresAt, isNull);
    });

    test('round-trip serialization preserves data', () {
      final original = OAuthTokenDto(
        accessToken: 'access-roundtrip',
        idToken: 'id-roundtrip',
        refreshToken: 'refresh-roundtrip',
        expiresAt: DateTime(2026, 12, 31, 23, 59, 59),
      );

      final json = original.toJson();
      final restored = OAuthTokenDto.fromJson(json);

      expect(restored.accessToken, equals(original.accessToken));
      expect(restored.idToken, equals(original.idToken));
      expect(restored.refreshToken, equals(original.refreshToken));
      expect(restored.expiresAt, equals(original.expiresAt));
    });
  });
}
