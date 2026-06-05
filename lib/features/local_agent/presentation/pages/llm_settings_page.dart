import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../infrastructure/services/model_download_service.dart';

enum LlmProvider {
  mock('Mock'),
  gemini('Gemini'),
  local('Local LLM');

  final String name;
  const LlmProvider(this.name);

  static LlmProvider fromName(String? name) {
    return LlmProvider.values.firstWhere(
      (e) => e.name == name,
      orElse: () => LlmProvider.mock,
    );
  }
}

class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  final _secureStorage = const FlutterSecureStorage();
  final _modelDownloadService = GetIt.I<ModelDownloadService>();

  LlmProvider _selectedProvider = LlmProvider.mock;
  final _geminiApiKeyController = TextEditingController();
  List<ModelInfo> _downloadedModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final apiKey = await _secureStorage.read(key: 'gemini_api_key');
    final savedProvider = await _secureStorage.read(key: 'llm_provider');

    if (savedProvider != null) {
      _selectedProvider = LlmProvider.fromName(savedProvider);
    }

    _geminiApiKeyController.text = apiKey ?? '';
    _downloadedModels = await _modelDownloadService.listDownloadedModels();

    setState(() => _isLoading = false);
  }

  Future<void> _saveProvider(LlmProvider provider) async {
    await _secureStorage.write(key: 'llm_provider', value: provider.name);
    setState(() => _selectedProvider = provider);
  }

  Future<void> _saveApiKey() async {
    await _secureStorage.write(key: 'gemini_api_key', value: _geminiApiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API Key saved')),
      );
    }
  }

  @override
  void dispose() {
    _geminiApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProviderSelection(),
              const Divider(height: 32),
              if (_selectedProvider == LlmProvider.gemini) _buildGeminiSettings(),
              if (_selectedProvider == LlmProvider.local) _buildLocalSettings(),
              if (_selectedProvider == LlmProvider.mock) _buildMockSettings(),
            ],
          ),
    );
  }

  Widget _buildProviderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LLM Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CyberTheme.primary)),
        const SizedBox(height: 16),
        RadioGroup<LlmProvider>(
          groupValue: _selectedProvider,
          onChanged: (val) => val != null ? _saveProvider(val) : null,
          child: Column(
            children: LlmProvider.values.map((provider) => RadioListTile<LlmProvider>(
              title: Text(provider.name.toUpperCase()),
              value: provider,
              activeColor: CyberTheme.primary,
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGeminiSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gemini API Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CyberTheme.secondary)),
        const SizedBox(height: 16),
        TextField(
          controller: _geminiApiKeyController,
          decoration: InputDecoration(
            labelText: 'Gemini API Key',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveApiKey,
            ),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLocalSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Local LLM (Ollama/GGUF)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CyberTheme.secondary)),
        const SizedBox(height: 16),
        const Text('Downloaded Models:', style: TextStyle(fontWeight: FontWeight.bold)),
        if (_downloadedModels.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No models downloaded yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54)),
          ),
        ..._downloadedModels.map((model) => ListTile(
          title: Text(model.filename),
          subtitle: Text('${(model.size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB - ${model.parameters ?? "Unknown"}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await _modelDownloadService.deleteModel(model.filename);
              _loadSettings();
            },
          ),
          onTap: () async {
            await _secureStorage.write(key: 'local_model_name', value: model.filename);
            setState(() {});
          },
          selected: _downloadedModels.any((m) => m.filename == model.filename),
          selectedTileColor: CyberTheme.primary.withValues(alpha: 0.1),
        )),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            _showDownloadDialog();
          },
          icon: const Icon(Icons.download),
          label: const Text('Download Gemma 4 E2B'),
          style: ElevatedButton.styleFrom(backgroundColor: CyberTheme.primary, foregroundColor: Colors.black),
        ),
      ],
    );
  }

  void _showDownloadDialog() {
    double progress = 0;
    String speed = "";
    int downloadedMB = 0;
    int totalMB = 0;

    // Capture setDialogState from StatefulBuilder to use in async callback
    void Function(void Function())? dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDS) {
          dialogSetState = setDS;
          return AlertDialog(
            title: const Text('Downloading Gemma 4 E2B'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),
                Text('$downloadedMB MB / $totalMB MB'),
                Text(speed),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              )
            ],
          );
        },
      ),
    );

    _modelDownloadService.downloadModel(
      'https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/google_gemma-4-E2B-it-Q4_K_M.gguf',
      (p, s, d, t) {
        dialogSetState?.call(() {
          progress = p;
          speed = s;
          downloadedMB = d;
          totalMB = t;
        });
      }
    ).then((_) {
      if (mounted) Navigator.pop(context);
      _loadSettings();
    });
  }

  Widget _buildMockSettings() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mock Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CyberTheme.secondary)),
        SizedBox(height: 16),
        Text('Uses a simulated response for testing without an internet connection or local setup.'),
      ],
    );
  }
}
