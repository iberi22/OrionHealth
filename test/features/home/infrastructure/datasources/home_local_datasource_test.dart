import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/infrastructure/datasources/home_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late HomeLocalDataSource datasource;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    datasource = HomeLocalDataSource(mockPrefs);
  });

  group('HomeLocalDataSource', () {
    test('getHomeModules returns empty list when no cache', () async {
      when(() => mockPrefs.getString(any())).thenReturn(null);
      final result = await datasource.getHomeModules();
      expect(result, isEmpty);
    });

    test('getHealthSummary returns empty string when no cache', () async {
      when(() => mockPrefs.getString(any())).thenReturn(null);
      final result = await datasource.getHealthSummary();
      expect(result, '');
    });

    test('cacheHealthSummary saves to prefs', () async {
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
      await datasource.cacheHealthSummary('test summary');
      verify(() => mockPrefs.setString('home_summary_cache', 'test summary')).called(1);
    });
  });
}
