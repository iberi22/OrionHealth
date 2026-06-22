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
    test('getCachedHomeModules returns null when no cache', () async {
      when(() => mockPrefs.getString(any())).thenReturn(null);
      final result = await datasource.getCachedHomeModules();
      expect(result, isNull);
    });
  });
}
