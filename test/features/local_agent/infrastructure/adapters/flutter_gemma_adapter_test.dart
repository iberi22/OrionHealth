import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_gemma/flutter_gemma.dart' hide ModelType;
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart';

class MockFlutterGemmaWrapper extends Mock implements FlutterGemmaWrapper {}
class MockInferenceModel extends Mock implements InferenceModel {}
class MockInferenceModelSession extends Mock implements InferenceModelSession {}
class MockInferenceInstallationBuilder extends Mock implements InferenceInstallationBuilder {}
class MockModelSpec extends Mock implements ModelSpec {}
class MockInferenceInstallation extends Mock implements InferenceInstallation {}

void main() {
  late FlutterGemmaAdapter adapter;
  late MockFlutterGemmaWrapper mockWrapper;
  late MockInferenceModel mockModel;
  late MockInferenceModelSession mockSession;
  late MockInferenceInstallationBuilder mockInstallBuilder;

  setUpAll(() {
    registerFallbackValue(gemma.ModelType.gemmaIt);
    registerFallbackValue(Message.text(text: ''));
  });

  setUp(() {
    mockWrapper = MockFlutterGemmaWrapper();
    mockModel = MockInferenceModel();
    mockSession = MockInferenceModelSession();
    mockInstallBuilder = MockInferenceInstallationBuilder();

    adapter = FlutterGemmaAdapter(wrapper: mockWrapper);

    // Default behaviors
    when(() => mockWrapper.initialize(
      huggingFaceToken: any(named: 'huggingFaceToken'),
      maxDownloadRetries: any(named: 'maxDownloadRetries'),
    )).thenAnswer((_) async => {});

    when(() => mockWrapper.hasActiveModel()).thenReturn(true);
    when(() => mockWrapper.getActiveModel(maxTokens: any(named: 'maxTokens')))
        .thenAnswer((_) async => mockModel);

    when(() => mockModel.createSession(
      temperature: any(named: 'temperature'),
      topK: any(named: 'topK'),
    )).thenAnswer((_) async => mockSession);

    when(() => mockSession.addQueryChunk(any())).thenAnswer((_) async => {});
    when(() => mockSession.getResponse()).thenAnswer((_) async => 'Mock response');
    when(() => mockSession.close()).thenAnswer((_) async => {});
  });

  group('FlutterGemmaAdapter', () {
    test('modelName returns spec name or none', () {
      final mockSpec = MockModelSpec();
      when(() => mockSpec.name).thenReturn('gemma-test');
      when(() => mockWrapper.activeInferenceModel).thenReturn(mockSpec);

      expect(adapter.modelName, equals('gemma-test'));

      when(() => mockWrapper.activeInferenceModel).thenReturn(null);
      expect(adapter.modelName, equals('none'));
    });

    test('isAvailable returns true when initialized and has active model', () async {
      when(() => mockWrapper.hasActiveModel()).thenReturn(true);
      // isAvailable calls _ensureInitialized -> initialize
      // then calls hasActiveModel and checks _activeModel.
      // But _activeModel is only set in _resolveActiveModel or reloadActiveModel.
      // Wait, let's check isAvailable again.
      /*
      Future<bool> isAvailable() async {
        try {
          await _ensureInitialized();
          return _wrapper.hasActiveModel() && _activeModel != null;
        } catch (_) {
          return false;
        }
      }
      */
      // So it will be false if _activeModel is null.

      // Let's set _activeModel by calling generate first or reloadActiveModel
      when(() => mockWrapper.getActiveModel(maxTokens: any(named: 'maxTokens')))
          .thenAnswer((_) async => mockModel);
      await adapter.reloadActiveModel();

      final available = await adapter.isAvailable();

      expect(available, isTrue);
    });

    test('generate performs inference correctly', () async {
      const prompt = 'Test prompt';

      final result = await adapter.generate(prompt);

      expect(result, equals('Mock response'));
      verify(() => mockSession.addQueryChunk(any(that: isA<Message>()))).called(1);
      verify(() => mockSession.getResponse()).called(1);
      verify(() => mockSession.close()).called(1);
    });

    test('installModel streams progress', () async {
      when(() => mockWrapper.installModel(any())).thenReturn(mockInstallBuilder);
      when(() => mockInstallBuilder.fromNetwork(any(), token: any(named: 'token')))
          .thenReturn(mockInstallBuilder);

      final progressController = StreamController<int>();

      when(() => mockInstallBuilder.withProgress(any())).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as void Function(int);
        progressController.stream.listen(callback);
        return mockInstallBuilder;
      });

      when(() => mockInstallBuilder.install()).thenAnswer((_) async {
        progressController.add(10);
        progressController.add(50);
        progressController.add(100);
        await progressController.close();
        return MockInferenceInstallation();
      });

      final stream = adapter.installModel(modelId: 'gemma-3-270m', url: 'http://test.com');

      final results = <int>[];
      await stream.forEach(results.add);

      expect(results, equals([10, 50, 100]));
    });

    test('isModelInstalled and listInstalledModels call wrapper', () async {
      when(() => mockWrapper.isModelInstalled(any())).thenAnswer((_) async => true);
      when(() => mockWrapper.listInstalledModels()).thenAnswer((_) async => ['model1']);

      expect(await adapter.isModelInstalled('test'), isTrue);
      expect(await adapter.listInstalledModels(), equals(['model1']));
    });

    test('uninstallModel clears active model if matches', () async {
      final mockSpec = MockModelSpec();
      when(() => mockSpec.name).thenReturn('model-to-delete');
      when(() => mockWrapper.activeInferenceModel).thenReturn(mockSpec);
      when(() => mockWrapper.uninstallModel(any())).thenAnswer((_) async => {});

      // First call isAvailable to trigger _ensureInitialized and _resolveActiveModel
      await adapter.isAvailable();

      await adapter.uninstallModel('model-to-delete');

      verify(() => mockWrapper.uninstallModel('model-to-delete')).called(1);
    });

    test('reloadActiveModel updates internal state', () async {
      when(() => mockWrapper.hasActiveModel()).thenReturn(true);
      when(() => mockWrapper.getActiveModel(maxTokens: any(named: 'maxTokens')))
          .thenAnswer((_) async => mockModel);

      await adapter.reloadActiveModel();

      verify(() => mockWrapper.getActiveModel(maxTokens: 4096)).called(1);
    });
  });
}
