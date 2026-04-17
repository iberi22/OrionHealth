import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/services/device_info_service.dart';
import '../application/bloc/settings_cubit.dart';
import '../domain/entities/llm_config.dart';

class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  SystemInfo? _systemInfo;
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    final info = await getIt<DeviceInfoService>().getSystemInfo();
    if (mounted) {
      setState(() {
        _systemInfo = info;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsCubit>()..loadSettings(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Configuración de LLM',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              _apiKeyController.text = state.config.apiKey ?? '';
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              return _buildContent(context, state.config);
            } else if (state is SettingsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Iniciando...'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LlmConfig config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceInfoSection(),
          const SizedBox(height: 24),
          _buildModelSelectionSection(context, config),
          const SizedBox(height: 24),
          _buildProviderSection(context, config),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'OrionHealth utiliza modelos locales por defecto para máxima privacidad.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text('Capacidad del Dispositivo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        GlassmorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _DeviceInfoRow(
                  icon: Icons.memory,
                  label: 'RAM Total',
                  value: _systemInfo != null
                      ? '${_systemInfo!.totalRamGb.toStringAsFixed(1)} GB'
                      : 'Cargando...',
                ),
                const Divider(color: Colors.white10),
                _DeviceInfoRow(
                  icon: Icons.developer_board,
                  label: 'GPU / Renderer',
                  value: _systemInfo?.gpuRenderer ?? 'Cargando...',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberTheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.recommend, color: CyberTheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          getIt<DeviceInfoService>().getModelRecommendation(
                              _systemInfo?.totalRamGb ?? 0.0),
                          style: const TextStyle(
                              color: CyberTheme.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelSelectionSection(BuildContext context, LlmConfig config) {
    final models = [
      'gemma-2b',
      'gemma-7b',
      'gemini-pro',
      'gemini-1.5-flash',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text('Modelo Seleccionado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        GlassmorphicCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: config.modelName,
                isExpanded: true,
                dropdownColor: CyberTheme.backgroundDark,
                items: models.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    context.read<SettingsCubit>().setModelName(newValue);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSection(BuildContext context, LlmConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text('Modo de Ejecución',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        GlassmorphicCard(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Ejecución Local'),
                subtitle: const Text('Privacidad total, sin internet'),
                value: config.useLocalModel,
                activeColor: CyberTheme.primary,
                onChanged: (value) {
                  context.read<SettingsCubit>().setUseLocalModel(value);
                },
              ),
              if (!config.useLocalModel) ...[
                const Divider(color: Colors.white10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: 'API Key de Gemini',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          context
                              .read<SettingsCubit>()
                              .setApiKey(_apiKeyController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('API Key guardada')),
                          );
                        },
                      ),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      // We save on button press or we could debounce
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DeviceInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: CyberTheme.secondary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
