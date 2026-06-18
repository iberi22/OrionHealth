import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/data/models/oauth_token_dto.dart';

void main() {
  group('OAuthTokenDto', () {
    final now = DateTime.now();
    final dto = OAuthTokenDto(
      accessToken: 'access',
      idToken: 'id',
      refreshToken: 'refresh',
      expiresAt: now,
    );

    test('toJson', () {
      final json = dto.toJson();
      expect(json['accessToken'], 'access');
      expect(json['idToken'], 'id');
      expect(json['refreshToken'], 'refresh');
      expect(json['expiresAt'], now.toIso8601String());
    });

    test('fromJson', () {
      final json = {
        'accessToken': 'access',
        'idToken': 'id',
        'refreshToken': 'refresh',
        'expiresAt': now.toIso8601String(),
      };
      final fromJson = OAuthTokenDto.fromJson(json);
      expect(fromJson.accessToken, dto.accessToken);
      expect(fromJson.idToken, dto.idToken);
      expect(fromJson.refreshToken, dto.refreshToken);
      expect(fromJson.expiresAt?.toIso8601String(), dto.expiresAt?.toIso8601String());
    });

    test('toJson handles nulls', () {
      const dtoNull = OAuthTokenDto();
      final json = dtoNull.toJson();
      expect(json, isEmpty);
    });

    test('fromJson handles nulls', () {
      final fromJson = OAuthTokenDto.fromJson({});
      expect(fromJson.accessToken, isNull);
      expect(fromJson.expiresAt, isNull);
    });
  });
}
