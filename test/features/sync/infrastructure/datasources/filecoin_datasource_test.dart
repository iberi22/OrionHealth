import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/infrastructure/datasources/filecoin_datasource.dart';

void main() {
  late FilecoinDatasource datasource;

  setUp(() {
    datasource = FilecoinDatasource();
  });

  group('FilecoinDatasource', () {
    test('store returns a stub CID', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      final result = await datasource.store(data);

      expect(result, startsWith('bafy-filecoin-stub-'));
    });

    test('retrieve returns null (stub)', () async {
      final result = await datasource.retrieve('some-cid');
      expect(result, isNull);
    });
  });
}
