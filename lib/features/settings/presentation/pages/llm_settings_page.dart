import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/llm_settings_cubit.dart';
import '../../domain/services/device_capability_service.dart';
import '../../../local_agent/domain/services/llm_adapter.dart';
import '../../../local_agent/infrastructure/adapters/flutter_gemma_adapter.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../features/local_agent/domain/entities/local_model_descriptor.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const List<String> cloudProviders = ['openai', 'gemini', 'custom'];

const List<String> cloudModels = [
  'gpt-4o',
  'gpt-4o-mini',
  'gpt-5.4',
  'o4-mini',
  'gemini-2.0-flash',
  'gemini-2.5-flash',
  'gemini-2.5-pro',
];

// ---------------------------------------------------------------------------
// Download status enum
// ---------------------------------------------------------------------------

enum _DownloadStatus { notDownloaded, downloading, ready }

// ---------------------------------------------------------------------------
// Main page
// ---------------------------------------------------------------------------

class LlmSettingsPage extends StatelessWidget {
  const LlmSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LlmSettingsCubit>()..loadSettings(),
      child: BlocBuilder<LlmSettingsCubit, LlmSettingsState>(
        builder: (context, state) {
          if (state is LlmSettingsLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is LlmSettingsLoaded) {
            return _LlmSettingsView(
              config: state.config,
              appSettings: state.appSettings,
              deviceCapability: state.deviceCapability,
            );
          } else if (state is LlmSettingsError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: Text('Iniciando...')),
          );
        },
      ),
    );
  }
}

// ============================================================================
// VIEW – Tab-based redesign
// ============================================================================

class _LlmSettingsView extends StatelessWidget {
  final dynamic config;
  final dynamic appSettings;
  final DeviceCapability deviceCapability;

  const _LlmSettingsView({
    required this.config,
    required this.appSettings,
    required this.deviceCapability,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.llmSettings,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 10),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.phone_android, size: 18),
                    text: 'LOCAL',
                  ),
                  Tab(
                    icon: Icon(Icons.cloud, size: 18),
                    text: 'CLOUD',
                  ),
                  Tab(
                    icon: Icon(Icons.tune, size: 18),
                    text: 'MODO',
                  ),
                  Tab(
                    icon: Icon(Icons.settings, size: 18),
                    text: 'APP',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _LocalModelsTab(
              config: config,
              deviceCapability: deviceCapability,
            ),
            _CloudProviderTab(config: config),
            _ExecutionModeTab(config: config),
            _GeneralSettingsTab(appSettings: appSettings),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1 – Local Models
// ============================================================================

class _LocalModelsTab extends StatelessWidget {
  final dynamic config;
  final DeviceCapability deviceCapability;

  const _LocalModelsTab({
    required this.config,
    required this.deviceCapability,
  });

  int _getAvailableRamMb() {
    final totalRamGbTxt = deviceCapability.totalMemoryMb;
    return (totalRamGbTxt * 0.4).round();
  }

  bool _isCompatible(LocalModelDescriptor model) {
    return _getAvailableRamMb() >= model.minRamMb;
  }

  @override
  Widget build(BuildContext context) {
    final availableRamMb = _getAvailableRamMb();

    return BlocBuilder<LlmSettingsCubit, LlmSettingsState>(
      builder: (context, state) {
        if (state is! LlmSettingsLoaded) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 120, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeviceCapabilityCard(deviceCapability: deviceCapability),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Modelos Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${kAvailableLocalModels.length} modelos',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...kAvailableLocalModels.map((model) {
                final isInstalled = state.installedModels.contains(model.id);
                final progress = state.downloadProgress[model.id];
                final isDownloading = progress != null;

                final status = isInstalled
                    ? _DownloadStatus.ready
                    : isDownloading
                        ? _DownloadStatus.downloading
                        : _DownloadStatus.notDownloaded;

                final compatible = _isCompatible(model);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ModelListItem(
                    model: model,
                    status: status,
                    progress: progress ?? 0.0,
                    compatible: compatible,
                    availableRamMb: availableRamMb,
                    isCurrentModel: state.config.localModelId == model.id,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ModelListItem extends StatelessWidget {
  final LocalModelDescriptor model;
  final _DownloadStatus status;
  final double progress;
  final bool compatible;
  final int availableRamMb;
  final bool isCurrentModel;

  const _ModelListItem({
    required this.model,
    required this.status,
    required this.progress,
    required this.compatible,
    required this.availableRamMb,
    required this.isCurrentModel,
  });

  @override
  Widget build(BuildContext context) {
    final modelId = model.id;
    final modelName = model.displayName;
    final size = model.sizeLabel;
    final minRamStr = '${(model.minRamMb / 1024).toStringAsFixed(0)}GB';

    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          modelName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrentModel) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVO',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      size,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusBadge(status, progress),
            ],
          ),

          if (status == _DownloadStatus.downloading) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                    progress < 1.0
                        ? AppColors.secondary
                        : AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(sizeToMb(size) * progress).toInt()} MB / ${sizeToMb(size)} MB',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          Row(
            children: [
              if (status != _DownloadStatus.ready) ...[
                Icon(
                  compatible ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 14,
                  color: compatible ? Colors.greenAccent : Colors.orangeAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  compatible
                      ? 'Compatible con tu dispositivo'
                      : 'Requiere $minRamStr RAM',
                  style: TextStyle(
                    fontSize: 11,
                    color: compatible ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                ),
                const Spacer(),
              ],
              if (status == _DownloadStatus.notDownloaded) ...[
                const Spacer(),
                _actionButton(
                  label: 'Descargar',
                  icon: Icons.download,
                  onTap: () {
                    context.read<LlmSettingsCubit>().downloadModel(modelId);
                  },
                ),
              ],
              if (status == _DownloadStatus.downloading) ...[
                const Spacer(),
                _actionButton(
                  label: 'Cancelar',
                  icon: Icons.cancel_outlined,
                  isSecondary: true,
                  onTap: () {
                    context.read<LlmSettingsCubit>().cancelDownload(modelId);
                  },
                ),
              ],
              if (status == _DownloadStatus.ready) ...[
                _actionButton(
                  label: 'Usar',
                  icon: Icons.play_arrow,
                  onTap: () async {
                    final adapter = getIt<LlmAdapter>(instanceName: 'gemma')
                        as FlutterGemmaAdapter;

                    final isInstalled = await adapter.isModelInstalled(modelId);

                    if (!context.mounted) return;

                    if (!isInstalled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('El modelo $modelName no está instalado'),
                          backgroundColor: Colors.orangeAccent,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    await context
                        .read<LlmSettingsCubit>()
                        .updateLocalModel(modelId);
                    await adapter.reloadActiveModel();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$modelName activado para inferencia'),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.71),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                ),
                const SizedBox(width: 8),
                _actionButton(
                  label: 'Eliminar',
                  icon: Icons.delete_outline,
                  isSecondary: true,
                  onTap: () {
                    context.read<LlmSettingsCubit>().deleteModel(modelId);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_DownloadStatus status, double progress) {
    switch (status) {
      case _DownloadStatus.notDownloaded:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No descargado',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        );
      case _DownloadStatus.downloading:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.24), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Descargando',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      case _DownloadStatus.ready:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.24), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 12, color: Colors.greenAccent),
              SizedBox(width: 4),
              Text(
                'Listo',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
    }
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSecondary
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.primary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSecondary
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.31),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color:
                    isSecondary ? Colors.white54 : AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSecondary ? Colors.white54 : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int sizeToMb(String sizeStr) {
  final numPart =
      double.tryParse(sizeStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  if (sizeStr.contains('GB')) return (numPart * 1024).toInt();
  if (sizeStr.contains('MB')) return numPart.toInt();
  return numPart.toInt();
}

// ============================================================================
// TAB 2 – Cloud Provider
// ============================================================================

enum _ConnectionStatus { idle, testing, connected, error }

class _CloudProviderTab extends StatefulWidget {
  final dynamic config;

  const _CloudProviderTab({required this.config});

  @override
  State<_CloudProviderTab> createState() => _CloudProviderTabState();
}

class _CloudProviderTabState extends State<_CloudProviderTab> {
  bool _obscureApiKey = true;
  String _testPrompt = '';

  dynamic get config => widget.config;

  @override
  Widget build(BuildContext context) {
    final providerType = config.providerType ?? 'openai';
    final apiKey = config.apiKey ?? '';
    final baseUrl = config.baseUrl ?? '';
    final cloudModel = config.cloudModel ?? cloudModels.first;
    final isCustom = providerType == 'custom';

    return BlocBuilder<LlmSettingsCubit, LlmSettingsState>(
      builder: (context, state) {
        _ConnectionStatus status = _ConnectionStatus.idle;
        String? message;
        if (state is LlmSettingsLoaded) {
          if (state.connectionVerified == true) status = _ConnectionStatus.connected;
          if (state.connectionVerified == false) status = _ConnectionStatus.error;
          message = state.connectionError;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 120, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.cloud_outlined,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Configuración de Proveedor Cloud',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Conecta con APIs externas de IA',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.47),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),

                    _labeledField(
                      label: 'Proveedor',
                      child: DropdownButton<String>(
                        value: providerType,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceVariant,
                        underline: Container(
                          height: 1,
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        items: cloudProviders.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Icon(
                                  p == 'openai'
                                      ? Icons.bolt
                                      : p == 'gemini'
                                          ? Icons.auto_awesome
                                          : Icons.dns,
                                  size: 16,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  p == 'openai'
                                      ? 'OpenAI'
                                      : p == 'gemini'
                                          ? 'Gemini'
                                          : 'Custom (OpenAI compatible)',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<LlmSettingsCubit>()
                                .updateProviderType(value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (isCustom) ...[
                      _labeledField(
                        label: 'Base URL',
                        child: TextField(
                          controller: TextEditingController(text: baseUrl),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hint: 'https://api.ejemplo.com/v1',
                            prefixIcon: Icons.link,
                          ),
                          onChanged: (value) {
                            context
                                .read<LlmSettingsCubit>()
                                .updateBaseUrl(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _labeledField(
                      label: 'API Key',
                      child: TextField(
                        controller: TextEditingController(text: apiKey),
                        obscureText: _obscureApiKey,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: 'sk-...',
                          prefixIcon: Icons.vpn_key,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureApiKey
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureApiKey = !_obscureApiKey;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          context
                              .read<LlmSettingsCubit>()
                              .updateApiKey(value);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _labeledField(
                      label: 'Modelo',
                      child: DropdownButton<String>(
                        value: cloudModels.contains(cloudModel)
                            ? cloudModel
                            : cloudModels.first,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceVariant,
                        underline: Container(
                          height: 1,
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        items: cloudModels.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<LlmSettingsCubit>()
                                .updateCloudModel(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _ConnectionTestWidget(
                status: status,
                message: message,
                onTest: () {
                  context.read<LlmSettingsCubit>().verifyConnection();
                },
                testPrompt: _testPrompt,
                onPromptChanged: (value) {
                  setState(() => _testPrompt = value);
                },
              ),

              const SizedBox(height: 24),

              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          providerType == 'custom'
                              ? 'Usa cualquier endpoint compatible con OpenAI. '
                                  'Asegúrate de que la URL termine en /v1.'
                              : providerType == 'gemini'
                                  ? 'Gemini API de Google. '
                                      'Obtén tu API Key en ai.google.dev.'
                                  : 'OpenAI API. '
                                      'Obtén tu API Key en platform.openai.com.',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.59),
              letterSpacing: 0.5,
            ),
          ),
        ),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      prefixIcon: Icon(prefixIcon, color: Colors.white38, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: AppColors.primary.withValues(alpha: 0.39), width: 1.5),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connection test widget
// ---------------------------------------------------------------------------

class _ConnectionTestWidget extends StatelessWidget {
  final _ConnectionStatus status;
  final String? message;
  final VoidCallback onTest;
  final String testPrompt;
  final ValueChanged<String> onPromptChanged;

  const _ConnectionTestWidget({
    required this.status,
    required this.message,
    required this.onTest,
    required this.testPrompt,
    required this.onPromptChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns_outlined,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Verificar Conexión',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (status == _ConnectionStatus.testing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.secondary),
                ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: status == _ConnectionStatus.testing ? null : onTest,
              icon: const Icon(Icons.wifi_tethering, size: 18),
              label: Text(
                status == _ConnectionStatus.testing
                    ? 'Verificando...'
                    : 'Verificar Conexión',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.16),
                foregroundColor: AppColors.primary,
                side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.31), width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (status == _ConnectionStatus.connected) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.greenAccent.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    message ?? '✅ Conectado',
                    style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          if (status == _ConnectionStatus.error) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message ?? '❌ Error de conexión',
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          const Text(
            'Prueba rápida',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: testPrompt),
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Escribe un mensaje para probar...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.31), width: 1.5),
              ),
            ),
            onChanged: onPromptChanged,
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed:
                  testPrompt.isEmpty || status == _ConnectionStatus.testing
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Enviando: "$testPrompt"'),
                              backgroundColor: AppColors.surfaceVariant,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Probar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 3 – Execution Mode
// ============================================================================

enum _ExecutionStrategy { localOnly, localWithFallback, cloudOnly }

class _ExecutionModeTab extends StatelessWidget {
  final dynamic config;

  const _ExecutionModeTab({required this.config});

  _ExecutionStrategy _currentStrategy() {
    final useCloud = config.useCloudApi ?? false;
    final allowCloud = config.allowCloudApiCalls ?? false;
    if (!useCloud && !allowCloud) return _ExecutionStrategy.localOnly;
    if (!useCloud && allowCloud) return _ExecutionStrategy.localWithFallback;
    return _ExecutionStrategy.cloudOnly;
  }

  @override
  Widget build(BuildContext context) {
    final strategy = _currentStrategy();
    final allowCloudApiCalls = config.allowCloudApiCalls ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 120, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.route_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estrategia de Ejecución',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Define cómo se ejecutan los modelos de IA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),

                _ModeOption(
                  strategy: _ExecutionStrategy.localOnly,
                  isSelected: strategy == _ExecutionStrategy.localOnly,
                  icon: Icons.phone_android,
                  title: 'Solo local',
                  subtitle: '100% offline, sin conexiones externas',
                  description: 'Usa únicamente modelos descargados en el '
                      'dispositivo. No se realizan llamadas a la nube.',
                  onTap: () {
                    context
                        .read<LlmSettingsCubit>()
                        .updateUseCloudApi(false);
                    context
                        .read<LlmSettingsCubit>()
                        .updateAllowCloudApiCalls(false);
                  },
                ),
                const Divider(color: Colors.white10, indent: 16, endIndent: 16),

                _ModeOption(
                  strategy: _ExecutionStrategy.localWithFallback,
                  isSelected: strategy == _ExecutionStrategy.localWithFallback,
                  icon: Icons.swap_horiz,
                  title: 'Local → Cloud (fallback)',
                  subtitle: 'Intenta local, usa cloud si es necesario',
                  description: 'Primero intenta ejecutar localmente. Si el '
                      'modelo local no es suficiente, usa la nube como respaldo.',
                  onTap: () {
                    context
                        .read<LlmSettingsCubit>()
                        .updateUseCloudApi(false);
                    context
                        .read<LlmSettingsCubit>()
                        .updateAllowCloudApiCalls(true);
                  },
                ),
                const Divider(color: Colors.white10, indent: 16, endIndent: 16),

                _ModeOption(
                  strategy: _ExecutionStrategy.cloudOnly,
                  isSelected: strategy == _ExecutionStrategy.cloudOnly,
                  icon: Icons.cloud,
                  title: 'Solo cloud',
                  subtitle: 'Usa siempre la API en la nube',
                  description: 'Todas las consultas se envían al proveedor '
                      'cloud configurado. Requiere conexión a internet.',
                  onTap: () {
                    context
                        .read<LlmSettingsCubit>()
                        .updateUseCloudApi(true);
                    context
                        .read<LlmSettingsCubit>()
                        .updateAllowCloudApiCalls(true);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          GlassmorphicCard(
            child: _PrivacyToggle(
              allowCloudApiCalls: allowCloudApiCalls,
              onChanged: (allow) {
                context
                    .read<LlmSettingsCubit>()
                    .updateAllowCloudApiCalls(allow);
              },
            ),
          ),

          const SizedBox(height: 16),

          GlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.security,
                      color: AppColors.secondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strategy == _ExecutionStrategy.localOnly
                          ? '✅ Todos los datos permanecen en tu '
                              'dispositivo. Sin conexión a internet requerida.'
                          : strategy == _ExecutionStrategy.cloudOnly
                              ? '☁️ Los datos se envían al proveedor cloud '
                                  'configurado. Asegúrate de revisar la '
                                  'política de privacidad del proveedor.'
                              : '🔄 Modo híbrido: datos locales primero, '
                                  'cloud solo cuando sea necesario.',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 4 – General Settings (APP)
// ============================================================================

class _GeneralSettingsTab extends StatelessWidget {
  final dynamic appSettings;

  const _GeneralSettingsTab({required this.appSettings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 120, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.appPreferences, icon: Icons.settings_applications),
          const SizedBox(height: 12),
          GlassmorphicCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode,
                  title: l10n.theme,
                  subtitle: appSettings.themeMode,
                  trailing: DropdownButton<String>(
                    value: appSettings.themeMode,
                    dropdownColor: AppColors.surfaceVariant,
                    underline: const SizedBox.shrink(),
                    items: ['light', 'dark', 'system'].map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) context.read<LlmSettingsCubit>().updateThemeMode(v);
                    },
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: appSettings.languageCode,
                  trailing: DropdownButton<String>(
                    value: appSettings.languageCode,
                    dropdownColor: AppColors.surfaceVariant,
                    underline: const SizedBox.shrink(),
                    items: ['en', 'es'].map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) context.read<LlmSettingsCubit>().updateLanguage(v);
                    },
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active, color: AppColors.secondary),
                  title: Text(l10n.pushNotifications, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  value: appSettings.notificationsEnabled,
                  onChanged: (v) => context.read<LlmSettingsCubit>().updateNotificationsEnabled(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Datos y Privacidad', icon: Icons.security),
          const SizedBox(height: 12),
          GlassmorphicCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download, color: AppColors.primary),
                  title: const Text('Exportar Datos', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Descargar historial en formato FHIR JSON', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onTap: () async {
                    await context.read<LlmSettingsCubit>().exportData();
                    if (context.mounted) {
                      final state = context.read<LlmSettingsCubit>().state;
                      if (state is LlmSettingsLoaded && state.exportData != null) {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: AppColors.surfaceVariant,
                            title: const Text('Datos Exportados', style: TextStyle(color: Colors.white)),
                            content: SingleChildScrollView(child: Text(state.exportData!, style: const TextStyle(color: Colors.white70, fontSize: 10))),
                            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload, color: AppColors.secondary),
                  title: const Text('Importar Datos', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Cargar respaldo previo de datos médicos', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onTap: () {
                    // Mock import
                    context.read<LlmSettingsCubit>().importData('{}');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulación de importación completada')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: trailing,
    );
  }
}

class _ModeOption extends StatelessWidget {
  final _ExecutionStrategy strategy;
  final bool isSelected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _ModeOption({
    required this.strategy,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white38,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.16)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : Colors.white54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          isSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.47)),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PRESERVED WIDGETS
// ============================================================================

class _DeviceCapabilityCard extends StatelessWidget {
  final DeviceCapability deviceCapability;

  const _DeviceCapabilityCard({required this.deviceCapability});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                deviceCapability.tierEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Capacidad del Dispositivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceCapability.tierLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              _CapabilityBadge(tier: deviceCapability.tier),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.memory,
            label: 'Memoria Total',
            value: '${deviceCapability.totalMemoryMb} MB',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.memory_outlined,
            label: 'Memoria Disponible',
            value: '${deviceCapability.availableMemoryMb} MB',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.developer_board,
            label: 'Procesadores',
            value: '${deviceCapability.processorCount}',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modelo recomendado: ${deviceCapability.recommendedModel}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityBadge extends StatelessWidget {
  final DeviceCapabilityTier tier;

  const _CapabilityBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (tier) {
      case DeviceCapabilityTier.low:
        color = Colors.orange;
        label = 'Baja';
        break;
      case DeviceCapabilityTier.medium:
        color = AppColors.secondary;
        label = 'Media';
        break;
      case DeviceCapabilityTier.high:
        color = AppColors.primary;
        label = 'Alta';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final bool allowCloudApiCalls;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.allowCloudApiCalls,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text(
        'Permitir llamadas a la nube',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        'Permite el uso de modelos en la nube para mejorar las respuestas.',
        style: TextStyle(color: Colors.white70),
      ),
      value: allowCloudApiCalls,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      activeThumbColor: AppColors.primary,
    );
  }
}
