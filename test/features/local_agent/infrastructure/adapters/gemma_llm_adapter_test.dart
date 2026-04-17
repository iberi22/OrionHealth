import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAicoreService extends Mock implements AicoreService {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  late GemmaLlmAdapter adapter;
  late MockAicoreService mockAicoreService;
  late MockPathProviderPlatform mockPathProvider;

  setUp(() {
    mockAicoreService = MockAicoreService();
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;

    when(() => mockPathProvider.getApplicationDocumentsPath())
        .thenAnswer((_) async => '/tmp');

    adapter = GemmaLlmAdapter(aicoreService: mockAicoreService);
  });

  test('modelName returns local model name by default', () {
    expect(adapter.modelName, 'gemma-4-e2b-aicore');
  });

  test('isAvailable returns true if AICore is available', () async {
    when(() => mockAicoreService.checkAvailability())
        .thenAnswer((_) async => AicoreStatus.available);

    final available = await adapter.isAvailable();
    expect(available, true);
  });
}
