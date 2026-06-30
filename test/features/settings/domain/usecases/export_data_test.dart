import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/export_data.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late ExportData usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = ExportData(mockRepository);
  });

  const tExportedData = '{"data": "test"}';

  test('should call exportData from repository', () async {
    // arrange
    when(() => mockRepository.exportData()).thenAnswer((_) async => tExportedData);

    // act
    final result = await usecase();

    // assert
    expect(result, tExportedData);
    verify(() => mockRepository.exportData()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
