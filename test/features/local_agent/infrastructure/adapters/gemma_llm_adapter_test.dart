import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemma/flutter_gemma.dart' hide ModelType;
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart';

class MockFlutterGemmaWrapper extends Mock implements FlutterGemmaWrapper {}
class MockInferenceModel extends Mock implements InferenceModel {}
class MockInferenceModelSession extends Mock implements InferenceModelSession {}
class MockInferenceInstallationBuilder extends Mock
    implements InferenceInstallationBuilder {}
class MockModelSpec extends Mock implements ModelSpec {}
class MockInferenceInstallation extends Mock implements InferenceInstallation {}

void main() {
  late GemmaLlmAdapter adapter;
  late MockFlutterGemmaWrapper mockWrapper;
  late MockInferenceModel mockModel;
  late MockInferenceModelSession mockSession;

  setUpAll(() {
    registerFallbackValue(gemma.ModelType.gemmaIt);
    registerFallbackValue(Message.text(text: ''));
  });

  setUp(() {
    mockWrapper = MockFlutterGemmaWrapper();
    mockModel = MockInferenceModel();
    mockSession = MockInferenceModelSession();

    adapter = GemmaLlmAdapter(wrapper: mockWrapper);

    // Default stubs
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
    when(() => mockSession.getResponse()).thenAnswer((_) async => 'Gemma response');
    when(() => mockSession.close()).thenAnswer((_) async => {});
  });

  group('GemmaLlmAdapter', () {
    test('modelName returns spec name or none', () {
      final mockSpec = MockModelSpec();
      when(() => mockSpec.name).thenReturn('gemma-4');
      when(() => mockWrapper.activeInferenceModel).thenReturn(mockSpec);

      expect(adapter.modelName, equals('gemma-4'));

      when(() => mockWrapper.activeInferenceModel).thenReturn(null);
      expect(adapter.modelName, equals('none'));
    });

    test('isAvailable returns true when initialized and has active model', () async {
      // Pre-initialize by calling reloadActiveModel
      await adapter.reloadActiveModel();

      final available = await adapter.isAvailable();
      expect(available, isTrue);
    });

    test('isAvailable returns false when not initialized', () async {
      when(() => mockWrapper.hasActiveModel()).thenReturn(false);

      final available = await adapter.isAvailable();
      expect(available, isFalse);
    });

    test('generate performs inference and returns response', () async {
      const prompt = 'Describe the symptoms';

      final result = await adapter.generate(prompt);

      expect(result, equals('Gemma response'));
      verify(() => mockSession.addQueryChunk(any(that: isA<Message>()))).called(1);
      verify(() => mockSession.getResponse()).called(1);
      verify(() => mockSession.close()).called(1);
    });

    test('generate throws when session creation fails', () async {
      when(() => mockModel.createSession(
            temperature: any(named: 'temperature'),
            topK: any(named: 'topK'),
          )).thenThrow(Exception('Session creation failed'));

      await expectLater(
        () => adapter.generate('test'),
        throwsA(isA<Exception>()),
      );
    });

    test('isModelInstalled and listInstalledModels call wrapper', () async {
      when(() => mockWrapper.isModelInstalled(any())).thenAnswer((_) async => true);
      when(() => mockWrapper.listInstalledModels())
          .thenAnswer((_) async => ['gemma-4']);

      expect(await adapter.isModelInstalled('gemma-4'), isTrue);
      expect(await adapter.listInstalledModels(), equals(['gemma-4']));
    });

    test('uninstallModel when model name matches clears active model', () async {
      final mockSpec = MockModelSpec();
      when(() => mockSpec.name).thenReturn('model-to-delete');
      when(() => mockWrapper.activeInferenceModel).thenReturn(mockSpec);
      when(() => mockWrapper.uninstallModel(any())).thenAnswer((_) async => {});

      // Initialize adapter
      await adapter.isAvailable();
      await adapter.reloadActiveModel();

      // Now test uninstall
      await adapter.uninstallModel('model-to-delete');
      verify(() => mockWrapper.uninstallModel('model-to-delete')).called(1);
    });

    test('uninstallModel when name does not match does not clear active model', () async {
      final mockSpec = MockModelSpec();
      when(() => mockSpec.name).thenReturn('other-model');
      when(() => mockWrapper.activeInferenceModel).thenReturn(mockSpec);
      when(() => mockWrapper.uninstallModel(any())).thenAnswer((_) async => {});

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

    test('installModel streams progress', () async {
      final mockInstallBuilder = MockInferenceInstallationBuilder();
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
        progressController.add(25);
        progressController.add(75);
        progressController.add(100);
        await progressController.close();
        return MockInferenceInstallation();
      });

      final stream = adapter.installModel(
        modelId: 'gemma-4-2b',
        url: 'http://test.com/model',
      );

      final progressValues = <int>[];
      await stream.forEach(progressValues.add);

      expect(progressValues, [25, 75, 100]);
    });

    test('cancelDownload is supported', () async {
      when(() => mockWrapper.hasActiveModel()).thenReturn(true);

      await adapter.cancelDownload('model-123');
      // Should complete without error
    });
  });
}
