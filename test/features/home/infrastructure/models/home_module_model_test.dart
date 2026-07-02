import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/infrastructure/models/home_module_model.dart';

void main() {
  test('HomeModuleModel fromJson', () {
    final json = {
      'title': 'Test',
      'icon': 0xe8b8,
      'color': 4278190335, // 0xFF0000FF
      'route': '/test',
    };
    final model = HomeModuleModel.fromJson(json);
    expect(model.title, 'Test');
    expect(model.iconCode, 0xe8b8);
  });
}
