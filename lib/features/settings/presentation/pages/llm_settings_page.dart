import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/llm_settings_cubit.dart';
import '../../domain/services/device_capability_service.dart';

class LlmSettingsPage extends StatelessWidget {
  const LlmSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LlmSettingsCubit>()..loadSettings(),
      child: Scaffold(
        body: BlocBuilder<LlmSettingsCubit, LlmSettingsState>(
          builder: (context, state) {
            if (state is LlmSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LlmSettingsLoaded) {
              return _LlmSettingsView(
                config: state.config,
                deviceCapability: state.deviceCapability,
              );
            } else if (state is LlmSettingsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Iniciando...'));
          },
        ),
      ),
    );
  }
}

class _LlmSettingsView extends StatelessWidget {
  final dynamic config;
  final DeviceCapability deviceCapability;

  const _LlmSettingsView({
    required this.config,
    required this.deviceCapability,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Configuración de LLM',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          pinned: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 24),
                _DeviceCapabilityCard(deviceCapability: deviceCapability),
                const SizedBox(height: 32),
                _Section(
                  title: 'Modelo de IA',
                  children: [
                    _ModelSelector(
                      selectedModel: config.selectedModel as String,
                      recommendedModel: deviceCapability.recommendedModel,
                      onChanged: (model) {
                        context.read<LlmSettingsCubit>().updateSelectedModel(model);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Modo de Ejecución',
                  children: [
                    _ModeToggle(
                      useCloudApi: config.useCloudApi as bool,
                      onChanged: (useCloud) {
                        context.read<LlmSettingsCubit>().updateUseCloudApi(useCloud);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Privacidad',
                  children: [
                    _PrivacyToggle(
                      allowCloudApiCalls: config.allowCloudApiCalls as bool,
                      onChanged: (allow) {
                        context.read<LlmSettingsCubit>().updateAllowCloudApiCalls(allow);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _InfoCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
                    Text(
                      'Capacidad del Dispositivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CyberTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceCapability.tierLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: CyberTheme.secondary,
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
              color: CyberTheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CyberTheme.primary.withAlpha(51)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: CyberTheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modelo recomendado: ${deviceCapability.recommendedModel}',
                    style: TextStyle(
                      color: CyberTheme.primary,
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
        color = CyberTheme.secondary;
        label = 'Media';
        break;
      case DeviceCapabilityTier.high:
        color = CyberTheme.primary;
        label = 'Alta';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
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

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GlassmorphicCard(
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: children,
              color: Colors.white.withValues(alpha: 0.1),
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class _ModelSelector extends StatelessWidget {
  final String selectedModel;
  final String recommendedModel;
  final ValueChanged<String> onChanged;

  const _ModelSelector({
    required this.selectedModel,
    required this.recommendedModel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.smart_toy, color: CyberTheme.secondary),
      title: const Text('Modelo Gemini'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: selectedModel,
            isExpanded: true,
            dropdownColor: CyberTheme.surfaceDark,
            underline: Container(
              height: 1,
              color: CyberTheme.primary.withAlpha(77),
            ),
            items: availableGeminiModels.map((model) {
              final isRecommended = model == recommendedModel;
              return DropdownMenuItem(
                value: model,
                child: Row(
                  children: [
                    Text(
                      model,
                      style: TextStyle(
                        color: isRecommended ? CyberTheme.primary : Colors.white,
                        fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CyberTheme.primary.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Recomendado',
                          style: TextStyle(
                            fontSize: 10,
                            color: CyberTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool useCloudApi;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({
    required this.useCloudApi,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        useCloudApi ? Icons.cloud : Icons.phone_android,
        color: CyberTheme.secondary,
      ),
      title: const Text('Modo de Ejecución'),
      subtitle: Text(
        useCloudApi
            ? 'Usando API en la nube (Gemini Cloud)'
            : 'Ejecutando localmente (Gemma)',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      trailing: Switch(
        value: useCloudApi,
        activeThumbColor: CyberTheme.primary,
        onChanged: onChanged,
      ),
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
    return ListTile(
      leading: Icon(
        allowCloudApiCalls ? Icons.lock_open : Icons.lock,
        color: allowCloudApiCalls ? Colors.orange : CyberTheme.primary,
      ),
      title: const Text('Permitir llamadas a la nube'),
      subtitle: Text(
        allowCloudApiCalls
            ? 'Se enviarán datos a servidores Gemini'
            : 'Tus datos permanecen en el dispositivo',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      trailing: Switch(
        value: allowCloudApiCalls,
        activeThumbColor: CyberTheme.primary,
        onChanged: onChanged,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: CyberTheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Acerca de los modelos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CyberTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ModelInfoRow(
            model: 'gemini-2.0-flash',
            description: 'Rápido y eficiente para la mayoría de tareas',
          ),
          const SizedBox(height: 8),
          _ModelInfoRow(
            model: 'gemini-2.0-flash-lite',
            description: 'Optimizado para dispositivos con capacidad baja',
          ),
          const SizedBox(height: 8),
          _ModelInfoRow(
            model: 'gemini-2.5-flash',
            description: 'Mayor capacidad de razonamiento',
          ),
          const SizedBox(height: 8),
          _ModelInfoRow(
            model: 'gemini-2.5-pro',
            description: 'Máximo rendimiento (requiere dispositivo de alta capacidad)',
          ),
        ],
      ),
    );
  }
}

class _ModelInfoRow extends StatelessWidget {
  final String model;
  final String description;

  const _ModelInfoRow({
    required this.model,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: CyberTheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            model,
            style: TextStyle(
              fontSize: 12,
              color: CyberTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
