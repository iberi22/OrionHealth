import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/local_model_descriptor.dart';

void main() {
  group('ModelType enum', () {
    test('has all expected values', () {
      expect(ModelType.values, contains(ModelType.gemmaIt));
      expect(ModelType.values, contains(ModelType.qwen));
      expect(ModelType.values, contains(ModelType.deepSeek));
      expect(ModelType.values, contains(ModelType.llama));
      expect(ModelType.values.length, 4);
    });
  });

  group('LocalModelDescriptor', () {
    test('constructor assigns all fields correctly', () {
      const descriptor = LocalModelDescriptor(
        id: 'gemma-3-270m',
        displayName: 'Gemma 3 270M',
        modelType: ModelType.gemmaIt,
        sizeLabel: '270MB',
        minRamMb: 2048,
        url: 'https://huggingface.co/google/gemma-3-270m-it/resolve/main/model.bin',
      );

      expect(descriptor.id, 'gemma-3-270m');
      expect(descriptor.displayName, 'Gemma 3 270M');
      expect(descriptor.modelType, ModelType.gemmaIt);
      expect(descriptor.sizeLabel, '270MB');
      expect(descriptor.minRamMb, 2048);
      expect(descriptor.url, contains('huggingface.co'));
    });
  });

  group('kAvailableLocalModels', () {
    test('contains expected built-in models', () {
      expect(kAvailableLocalModels, hasLength(6));

      final gemma3 = kAvailableLocalModels.firstWhere(
        (m) => m.id == 'gemma-3-270m',
      );
      expect(gemma3.displayName, 'Gemma 3 270M');
      expect(gemma3.modelType, ModelType.gemmaIt);
      expect(gemma3.sizeLabel, '270MB');
      expect(gemma3.minRamMb, 2048);

      final qwen3 = kAvailableLocalModels.firstWhere(
        (m) => m.id == 'qwen3-0.6b',
      );
      expect(qwen3.modelType, ModelType.qwen);
      expect(qwen3.minRamMb, 3072);

      final deepseek = kAvailableLocalModels.firstWhere(
        (m) => m.id == 'deepseek-r1',
      );
      expect(deepseek.modelType, ModelType.deepSeek);
      expect(deepseek.minRamMb, 4096);

      final phi4 = kAvailableLocalModels.firstWhere(
        (m) => m.id == 'phi-4-mini',
      );
      expect(phi4.modelType, ModelType.llama);
      expect(phi4.sizeLabel, '3.9GB');

      final smolLM = kAvailableLocalModels.firstWhere(
        (m) => m.id == 'smolLM-135m',
      );
      expect(smolLM.sizeLabel, '135MB');
      expect(smolLM.minRamMb, 1024);

      final gemma4 = kAvailableLocalModels.firstWhere(
        (m) => m.id == 'gemma-4-e2b',
      );
      expect(gemma4.sizeLabel, '2.4GB');
      expect(gemma4.minRamMb, 6144);
    });

    test('all models have non-empty URLs', () {
      for (final model in kAvailableLocalModels) {
        expect(model.url.isNotEmpty, isTrue,
          reason: 'Model ${model.id} has empty URL');
        expect(model.url.startsWith('http'), isTrue,
          reason: 'Model ${model.id} URL does not start with http');
      }
    });

    test('all models have positive min RAM', () {
      for (final model in kAvailableLocalModels) {
        expect(model.minRamMb, greaterThan(0),
          reason: 'Model ${model.id} has invalid RAM requirement');
      }
    });

    test('all models have non-empty display names', () {
      for (final model in kAvailableLocalModels) {
        expect(model.displayName.isNotEmpty, isTrue,
          reason: 'Model ${model.id} has empty display name');
      }
    });
  });
}
