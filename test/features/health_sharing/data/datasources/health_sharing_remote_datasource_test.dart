import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/data/datasources/health_sharing_remote_datasource.dart';

void main() {
  late HealthSharingRemoteDataSource datasource;

  setUp(() {
    datasource = HealthSharingRemoteDataSource();
  });

  group('HealthSharingRemoteDataSource', () {
    test('sendPackageViaNfc returns false (placeholder)', () async {
      expect(await datasource.sendPackageViaNfc('payload'), isFalse);
    });
  });
}
