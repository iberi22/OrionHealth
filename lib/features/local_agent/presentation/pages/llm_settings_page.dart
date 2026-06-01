import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/rag_llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/model_download_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  final _secureStorage = const FlutterSecureStorage();
  final _userProfileRepository = GetIt.I<UserProfileRepository>();
  final _modelDownloadService = GetIt.I<ModelDownloadService>();

  LlmProvider _selectedProvider = LlmProvider.mock;
  final _geminiApiKeyController = TextEditingController();
  UserProfile? _profile;
  List<ModelInfo> _downloadedModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    _profile = await _userProfileRepository.getUserProfile();
    final apiKey = await _secureStorage.read(key: 'gemini_api_key');

    if (_profile?.llmProvider != null) {
      _selectedProvider = LlmProvider.values.firstWhere(
        (e) => e.name == _profile!.llmProvider,
        orElse: () => LlmProvider.mock,
      );
    }

    _geminiApiKeyController.text = apiKey ?? '';
    _downloadedModels = await _modelDownloadService.listDownloadedModels();

    setState(() => _isLoading = false);
  }

  Future<void> _saveProvider(LlmProvider provider) async {
    if (_profile == null) return;
    _profile!.llmProvider = provider.name;
    await _userProfileRepository.saveUserProfile(_profile!);
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
        ...LlmProvider.values.map((provider) => RadioListTile<LlmProvider>(
          title: Text(provider.name.toUpperCase()),
          value: provider,
          groupValue: _selectedProvider,
          onChanged: (val) => val != null ? _saveProvider(val) : null,
          activeColor: CyberTheme.primary,
        )),
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
            if (_profile != null) {
              _profile!.localModelName = model.filename;
              await _userProfileRepository.saveUserProfile(_profile!);
              setState(() {});
            }
          },
          selected: _profile?.localModelName == model.filename,
          selectedTileColor: CyberTheme.primary.withOpacity(0.1),
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
