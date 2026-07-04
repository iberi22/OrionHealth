import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/infrastructure/models/dashboard_stats_dto.dart';

void main() {
  group('DashboardStatsDto Mapping', () {
    test('toEntity returns correct entity', () {
      const dto = DashboardStatsDto(
        totalMedications: 5,
        reportsCount: 3,
      );

      final entity = dto.toEntity();

      expect(entity.totalMedications, dto.totalMedications);
      expect(entity.reportsCount, dto.reportsCount);
    });

    test('fromJson works correctly', () {
      final json = {
        'totalMedications': 5,
        'reportsCount': 3,
      };

      final dto = DashboardStatsDto.fromJson(json);

      expect(dto.totalMedications, 5);
      expect(dto.reportsCount, 3);
    });
  });
}
