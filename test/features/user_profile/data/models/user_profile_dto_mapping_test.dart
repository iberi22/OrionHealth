import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/data/models/user_profile_dto.dart';

void main() {
  group('UserProfileDto Mapping', () {
    test('toJson returns correct map', () {
      final dto = UserProfileDto(
        name: 'John',
        birthDate: DateTime(1990),
        sex: 'M',
      );

      final json = dto.toJson();

      expect(json['name'], 'John');
    });

    test('fromJson works correctly', () {
      final json = {
        'name': 'John',
        'birthDate': DateTime(1990).toIso8601String(),
        'sex': 'M',
      };

      final dto = UserProfileDto.fromJson(json);

      expect(dto.name, 'John');
    });
  });
}
