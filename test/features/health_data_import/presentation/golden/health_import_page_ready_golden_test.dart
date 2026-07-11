import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import '../../../../core/golden_test_utils.dart';

class MockHealthImportCubit extends Mock implements HealthImportCubit {}

void main() {
  late MockHealthImportCubit mockCubit;

  setUp(() async {
    await di.getIt.reset();
    mockCubit = MockHealthImportCubit();
    di.getIt.registerFactory<HealthImportCubit>(() => mockCubit);

    when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Health Import Page - Ready state', (WidgetTester tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthImportReady(
      availableSources: [HealthDataSource.googleFit],
      availability: {
        HealthDataSource.googleFit: true,
        HealthDataSource.appleHealth: false,
        HealthDataSource.samsungHealth: false,
      },
    ));

    await tester.pumpWidget(wrapWithMaterial(const HealthImportPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HealthImportPage),
      matchesGoldenFile("goldens/health_import_page_ready.png"),
    );

    resetGoldenTest(tester);
  });
}
