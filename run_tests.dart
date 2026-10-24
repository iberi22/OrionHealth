import 'dart:io';

void main() async {
  var result = await Process.run('flutter', ['test', 'test/features/health_sharing/infrastructure/wifi_direct_service_test.dart']);
  print(result.stdout);
  print(result.stderr);
}
