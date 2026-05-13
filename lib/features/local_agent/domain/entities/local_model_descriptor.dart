enum ModelType {
  gemmaIt,
  qwen,
  deepSeek,
  llama,
}

class LocalModelDescriptor {
  final String id;
  final String displayName;
  final ModelType modelType;
  final String sizeLabel;
  final int minRamMb;
  final String url;

  const LocalModelDescriptor({
    required this.id,
    required this.displayName,
    required this.modelType,
    required this.sizeLabel,
    required this.minRamMb,
    required this.url,
  });
}

/// Built-in catalog of supported local models.
const List<LocalModelDescriptor> kAvailableLocalModels = [
  LocalModelDescriptor(
    id: 'gemma-3-270m',
    displayName: 'Gemma 3 270M',
    modelType: ModelType.gemmaIt,
    sizeLabel: '270MB',
    minRamMb: 2048,
    url: 'https://huggingface.co/google/gemma-3-270m-it/resolve/main/model.bin',
  ),
  LocalModelDescriptor(
    id: 'qwen3-0.6b',
    displayName: 'Qwen3 0.6B',
    modelType: ModelType.qwen,
    sizeLabel: '600MB',
    minRamMb: 3072,
    url: 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct/resolve/main/model.bin',
  ),
  LocalModelDescriptor(
    id: 'deepseek-r1',
    displayName: 'DeepSeek R1',
    modelType: ModelType.deepSeek,
    sizeLabel: '1.7GB',
    minRamMb: 4096,
    url: 'https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B/resolve/main/model.bin',
  ),
  LocalModelDescriptor(
    id: 'phi-4-mini',
    displayName: 'Phi-4 Mini',
    modelType: ModelType.llama,
    sizeLabel: '3.9GB',
    minRamMb: 6144,
    url: 'https://huggingface.co/microsoft/phi-4-mini/resolve/main/model.bin',
  ),
  LocalModelDescriptor(
    id: 'smolLM-135m',
    displayName: 'SmolLM 135M',
    modelType: ModelType.gemmaIt,
    sizeLabel: '135MB',
    minRamMb: 1024,
    url: 'https://huggingface.co/HuggingFaceTB/SmolLM-135M-Instruct/resolve/main/model.bin',
  ),
  LocalModelDescriptor(
    id: 'gemma-4-e2b',
    displayName: 'Gemma 4 E2B',
    modelType: ModelType.gemmaIt,
    sizeLabel: '2.4GB',
    minRamMb: 6144,
    url: 'https://huggingface.co/google/gemma-4-2b-it/resolve/main/model.bin',
  ),
];
