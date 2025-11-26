import 'package:integration_test/integration_test_driver.dart';

/// Driver para ejecutar tests de integración en web con chromedriver
/// Uso: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome
Future<void> main() => integrationDriver();
