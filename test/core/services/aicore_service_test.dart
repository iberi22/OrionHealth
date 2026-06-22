import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AicoreService', () {
    const channel = MethodChannel('com.orionhealth/aicore');
    late AicoreService service;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      service = AicoreService();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
            return true;
          case 'checkAvailability':
            return 'available';
          case 'downloadModel':
            return true;
          case 'generateContent':
            return 'Generated response';
          case 'generateContentStream':
            return null;
          case 'warmup':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('initialize calls channel with correct arguments', () async {
      final result = await service.initialize(useFullModel: true);
      expect(result, isTrue);
      expect(service.isInitialized, isTrue);
      expect(service.usesFullModel, isTrue);
      expect(log, [
        isMethodCall('initialize', arguments: {'useFullModel': true}),
      ]);
    });

    test('initialize returns false on channel error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw Exception('Error');
      });
      final result = await service.initialize();
      expect(result, isFalse);
      expect(service.isInitialized, isFalse);
    });

    test('checkAvailability returns correct status', () async {
      final status = await service.checkAvailability();
      expect(status, AicoreStatus.available);
      expect(log, [
        isMethodCall('checkAvailability', arguments: null),
      ]);
    });

    test('checkAvailability returns unavailable on error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw Exception('Error');
      });
      final status = await service.checkAvailability();
      expect(status, AicoreStatus.unavailable);
    });

    test('downloadModel calls channel', () async {
      final result = await service.downloadModel();
      expect(result, isTrue);
      expect(log, [
        isMethodCall('downloadModel', arguments: null),
      ]);
    });

    test('downloadModel returns false on error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw Exception('Error');
      });
      final result = await service.downloadModel();
      expect(result, isFalse);
    });

    test('generateContent calls channel and returns result', () async {
      final result = await service.generateContent('Hello');
      expect(result, 'Generated response');
      expect(log, [
        isMethodCall('generateContent', arguments: {'prompt': 'Hello'}),
      ]);
    });

    test('generateContent throws exception on error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw Exception('Native error');
      });
      expect(() => service.generateContent('Hello'), throwsException);
    });

    test('generateContentStream calls channel', () async {
      await service.generateContentStream('Hello stream');
      expect(log, [
        isMethodCall('generateContentStream', arguments: {'prompt': 'Hello stream'}),
      ]);
    });

    test('warmup calls channel', () async {
      final result = await service.warmup();
      expect(result, isTrue);
      expect(log, [
        isMethodCall('warmup', arguments: null),
      ]);
    });

    test('warmup returns false on error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw Exception('Error');
      });
      final result = await service.warmup();
      expect(result, isFalse);
    });

    test('setupEventListeners handles method calls', () async {
      int? progress;
      String? token;
      bool completed = false;
      String? error;

      await AicoreService.setupEventListeners(
        onDownloadProgress: (p) => progress = p,
        onToken: (t) => token = t,
        onComplete: () => completed = true,
        onError: (e) => error = e,
      );

      // Simulate native calls
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('onDownloadProgress', {'progress': 50})),
        (_) {},
      );
      expect(progress, 50);

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('onToken', {'token': 'abc'})),
        (_) {},
      );
      expect(token, 'abc');

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('onComplete')),
        (_) {},
      );
      expect(completed, true);

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('onError', {'error': 'fail'})),
        (_) {},
      );
      expect(error, 'fail');
    });
  });

  group('AIService Stub', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('initialize sets state to ready', () async {
      expect(aiService.currentState, AIServiceState.loading);

      final states = <AIServiceState>[];
      aiService.stateStream.listen(states.add);

      await aiService.initialize();

      expect(aiService.currentState, AIServiceState.ready);
      expect(states, [AIServiceState.ready]);
    });

    test('getResponse returns simulated response', () async {
      final response = await aiService.getResponse('Hello');
      expect(response, 'Respuesta simulada');
    });

    test('transcribeAudio returns simulated transcription', () async {
      final response = await aiService.transcribeAudio([1, 2, 3]);
      expect(response, 'Transcripción simulada');
    });

    test('dispose closes stream', () async {
      await aiService.initialize();
      aiService.dispose();
      // initialize calls add() on the controller, which should throw StateError if closed
      expect(() => aiService.initialize(), throwsStateError);
    });
  });

  group('AgentMemoryService Stub', () {
    late AgentMemoryService memoryService;

    setUp(() {
      memoryService = AgentMemoryService();
    });

    test('initialize completes', () async {
      await expectLater(memoryService.initialize(), completes);
    });

    test('searchMemories returns empty list', () async {
      final results = await memoryService.searchMemories(query: 'test');
      expect(results, isEmpty);
    });

    test('getRecentHistory returns empty list', () async {
      final results = await memoryService.getRecentHistory();
      expect(results, isEmpty);
    });

    test('getMemoryCount returns 0', () async {
      final count = await memoryService.getMemoryCount();
      expect(count, 0);
    });

    test('getContextForQuery returns empty string', () async {
      final context = await memoryService.getContextForQuery('test');
      expect(context, '');
    });

    test('addMemory completes', () async {
      await expectLater(
        memoryService.addMemory(input: 'in', output: 'out'),
        completes,
      );
    });

    test('dispose completes', () {
      expect(() => memoryService.dispose(), returnsNormally);
    });
  });
}
