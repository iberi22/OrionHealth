import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/core/di/database_module.dart';
import 'package:orionhealth_health/features/workouts/domain/entities/workout_session.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/models/meal_log.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.createTempSync('isar_test').path;
  }
}

class TestModule extends DatabaseModule {}

void main() {
  setUpAll(() async {
    // Como el resto de tests de Isar del repo: sin el binario nativo, Isar.open falla (libisar.so).
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  test('DatabaseModule opens Isar with MealLog and WorkoutSession schemas', () async {
    final module = TestModule();
    final isar = await module.isar;

    expect(isar.isOpen, isTrue);
    expect(isar.name, 'default');

    // Check schemas are registered (this throws if they are not)
    final workoutCollection = isar.collection<WorkoutSession>();
    final mealLogCollection = isar.collection<MealLog>();

    expect(workoutCollection, isNotNull);
    expect(mealLogCollection, isNotNull);

    await isar.close();
  });
}
