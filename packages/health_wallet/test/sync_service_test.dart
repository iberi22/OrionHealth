import 'dart:convert';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:health_wallet/health_wallet.dart';

class MockEncryptionService extends Mock implements EncryptionService {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late SyncService syncService;
  late MockEncryptionService mockEncryption;
  late MockDio mockDio;

  setUp(() {
    mockEncryption = MockEncryptionService();
    mockDio = MockDio();
    syncService = SyncService(mockEncryption, dio: mockDio);
  });

  group('SyncService', () {
    final testData = {'labs': []};

    test('pushToNode success (simulated)', () async {
      when(() => mockEncryption.encryptPayload(any(), any()))
          .thenAnswer((_) async => {'pinProtected': false, 'data': testData});

      final result = await syncService.pushToNode(
        targetNodeId: 'target',
        healthData: testData,
        senderNodeId: 'sender',
      );

      expect(result.success, isTrue);
      expect(result.recordsSynced, 0);
    });

    test('pushToNode encryption failure', () async {
      when(() => mockEncryption.encryptPayload(any(), any()))
          .thenThrow(Exception('Encryption failed'));

      final result = await syncService.pushToNode(
        targetNodeId: 'target',
        healthData: testData,
        senderNodeId: 'sender',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Encryption failed'));
    });

    test('pullFromNode success', () async {
      final package = {
        'version': '1.0',
        'payload': {'some': 'encrypted'},
      };
      final packageJson = jsonEncode(package);

      when(() => mockEncryption.decryptPayload(any(), any()))
          .thenAnswer((_) async => testData);

      final result = await syncService.pullFromNode(
        packageJson: packageJson,
        pin: '1234',
      );

      expect(result, equals(testData));
    });

    test('pullFromNode version mismatch', () async {
      final package = {
        'version': '2.0',
        'payload': {},
      };
      final packageJson = jsonEncode(package);

      final result = await syncService.pullFromNode(
        packageJson: packageJson,
        pin: '1234',
      );

      expect(result, isNull);
    });

    test('createTransferPackage returns valid JSON', () async {
      when(() => mockEncryption.encryptPayload(any(), any()))
          .thenAnswer((_) async => {'pinProtected': true, 'encryptedData': 'abc'});
      when(() => mockEncryption.signPackage(any()))
          .thenAnswer((_) async => 'sig123');

      final packageJson = await syncService.createTransferPackage(
        healthData: testData,
        senderNodeId: 's1',
        recipientNodeId: 'r1',
        expiresIn: const Duration(hours: 1),
      );

      final package = jsonDecode(packageJson);
      expect(package['header']['version'], '1.0');
      expect(package['header']['type'], 'ORION_HEALTH_TRANSFER');
      expect(package['payload']['pinProtected'], isTrue);
      expect(package['signature'], 'sig123');
    });

    test('syncMedicalStandards calls onProgress', () async {
      double lastProgress = 0;
      await syncService.syncMedicalStandards(onProgress: (p) => lastProgress = p);
      expect(lastProgress, 1.0);
    });

    test('discoverPeerNodes success', () async {
      final nodes = [{'id': 'node1'}];
      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.data).thenReturn({'nodes': nodes});

      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await syncService.discoverPeerNodes();
      expect(result, equals(nodes));
    });

    test('discoverPeerNodes network failure (offline mode)', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await syncService.discoverPeerNodes();
      expect(result, isEmpty);
    });

    test('hasRemoteUpdates returns false (simulated)', () async {
      final hasUpdates = await syncService.hasRemoteUpdates('hash');
      expect(hasUpdates, isFalse);
    });
  });
}
