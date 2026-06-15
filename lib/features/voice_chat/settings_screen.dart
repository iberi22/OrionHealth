import 'package:flutter/material.dart';
import 'package:orion/services/agent_memory_service.dart';
import 'package:orion/services/local_data_service.dart';
import 'package:orion/utils/feedback_manager.dart';
import 'package:orion/utils/performance_monitor.dart';
import 'package:orion/utils/cache_manager.dart';
import 'package:orion/ui/welcome_screen.dart';
import 'package:orion/ui/settings/tts_models_page.dart';
import 'package:orion/ui/settings/asr_models_page.dart';
import 'package:orion/ui/settings/ai_settings_page.dart';
import 'package:orion/ui/privacy_policy_screen.dart';
import 'package:orion/ui/terms_of_service_screen.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _voiceFeedbackEnabled = true;
  bool _analyticsEnabled = true;

  late final LocalDataService _localDataService = LocalDataService(
    cacheManager: CacheManager(),
    memoryExporter: () async {
      final memory = AgentMemoryService();
      await memory.initialize();
      return memory.exportMemories();
    },
    memoryClearer: () async {
      final memory = AgentMemoryService();
      await memory.initialize();
      await memory.clearMemories();
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildSection(
              title: 'Perfil',
              children: [
                _buildUserProfileTile(),
                _buildSettingsTile(
                  icon: Icons.edit,
                  title: 'Editar Perfil',
                  subtitle: 'Actualizar información personal',
                  onTap: () => _showEditProfileDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Preferences
            _buildSection(
              title: 'Preferencias',
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Notificaciones',
                  subtitle: 'Recibir recordatorios y actualizaciones',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    FeedbackManager.showInfo(
                      value
                          ? 'Notificaciones activadas'
                          : 'Notificaciones desactivadas',
                    );
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Respuesta por Voz',
                  subtitle: 'Habilitar respuestas de voz del AI',
                  value: _voiceFeedbackEnabled,
                  onChanged: (value) {
                    setState(() {
                      _voiceFeedbackEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.analytics,
                  title: 'Análisis de Uso',
                  subtitle:
                      'Ayudar a mejorar la app compartiendo datos anónimos',
                  value: _analyticsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _analyticsEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Privacy
            _buildSection(
              title: 'Datos y Privacidad',
              children: [
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidad',
                  subtitle: 'Ver cómo protegemos tu información',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.description,
                  title: 'Términos de Servicio',
                  subtitle: 'Revisar términos y condiciones',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.download,
                  title: 'Exportar Datos',
                  subtitle: 'Descargar una copia de tus datos',
                  onTap: () => _exportUserData(),
                ),
                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Borrar Datos Locales',
                  subtitle:
                      'Eliminar permanentemente los datos del dispositivo',
                  onTap: () => _showDeleteLocalDataDialog(),
                  textColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Management
            _buildSection(
              title: 'Gestión de App',
              children: [
                _buildSettingsTile(
                  icon: Icons.psychology,
                  title: 'Configuración IA Local',
                  subtitle: 'Ajustar endpoint, modelo y comportamiento',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AISettingsPage(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.mic,
                  title: 'Modelos ASR (Offline)',
                  subtitle: 'Gestionar modelos de reconocimiento de voz',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AsrModelsPage(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.record_voice_over,
                  title: 'Modelos TTS (On-Device)',
                  subtitle: 'Descargar, eliminar y administrar voces locales',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TTSModelsPage(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.storage,
                  title: 'Gestionar Caché',
                  subtitle: 'Ver y limpiar datos almacenados',
                  onTap: () => _showCacheManagementDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.speed,
                  title: 'Rendimiento',
                  subtitle: 'Ver estadísticas de rendimiento',
                  onTap: () => _showPerformanceDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.bug_report,
                  title: 'Reportar Problema',
                  subtitle: 'Enviar feedback o reportar un error',
                  onTap: () => _showFeedbackDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About
            _buildSection(
              title: 'Acerca de',
              children: [
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'Versión de la App',
                  subtitle: '1.0.0 (Build 1)',
                  onTap: () => _showAppInfoDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.help,
                  title: 'Ayuda y Soporte',
                  subtitle: 'Obtener ayuda y contactar soporte',
                  onTap: () => _showHelpDialog(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Local reset button
            Center(
              child: ElevatedButton(
                onPressed: () => _showResetSessionDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reiniciar Perfil Local',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildUserProfileTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[600],
        child: const Text(
          'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: const Text(
        'Usuario Local',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'Modo offline',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        FeedbackManager.hapticFeedback(HapticFeedbackType.light);
        onTap();
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          FeedbackManager.hapticFeedback(HapticFeedbackType.light);
          onChanged(newValue);
        },
        activeColor: Colors.blue[600],
      ),
    );
  }

  void _showEditProfileDialog() {
    // Implementation for editing profile
    FeedbackManager.showInfo('Función de edición de perfil próximamente');
  }

  void _exportUserData() async {
    try {
      FeedbackManager.showInfo('Preparando exportacion local...');
      final exportJson = await _localDataService.exportLocalData();
      await Share.share(exportJson, subject: 'Orion Local Data Export');
      FeedbackManager.showSuccess('Datos locales exportados');
    } catch (e) {
      FeedbackManager.showError('Error al exportar datos locales: $e');
    }
  }

  void _showDeleteLocalDataDialog() async {
    final confirmed = await FeedbackManager.showConfirmation(
      context: context,
      title: 'Borrar Datos Locales',
      message:
          '¿Estás seguro de que quieres borrar los datos locales? Esta acción no se puede deshacer.',
      confirmText: 'Borrar',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        final result = await _localDataService.clearLocalData();
        FeedbackManager.showSuccess(
          'Datos locales borrados (${result.removedPreferenceCount} preferencias)',
        );
      } catch (e) {
        FeedbackManager.showError('Error al borrar datos locales: $e');
      }
    }
  }

  void _showCacheManagementDialog() async {
    final stats = await CacheManager().getCacheStats();
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Gestión de Caché',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Tamaño total: ${stats['totalSizeMB']} MB\n'
                'Imágenes: ${stats['imageCache']['sizeMB']} MB\n'
                'Datos: ${stats['dataCache']['sizeMB']} MB\n'
                'Audio: ${stats['audioCache']['sizeMB']} MB',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CacheManager().clearCache();
                    if (mounted) {
                      Navigator.pop(context);
                      FeedbackManager.showSuccess(
                        'Caché limpiado exitosamente',
                      );
                    }
                  },
                  child: Text('Limpiar Caché', style: TextStyle()),
                ),
              ],
            ),
      );
    }
  }

  void _showPerformanceDialog() {
    final stats = PerformanceMonitor().getPerformanceStats();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Estadísticas de Rendimiento',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              stats.toString(),
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
    );
  }

  void _showFeedbackDialog() {
    FeedbackManager.showInfo('Función de feedback próximamente');
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Información de la App',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Orion - AI Wellness Companion\n'
              'Versión: 1.0.0\n'
              'Build: 1\n'
              'Desarrollado con Flutter\n\n'
              'Tu compañero de bienestar impulsado por IA',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    FeedbackManager.showInfo('Función de ayuda próximamente');
  }

  void _showResetSessionDialog() async {
    final confirmed = await FeedbackManager.showConfirmation(
      context: context,
      title: 'Reiniciar Perfil Local',
      message: '¿Quieres volver a la pantalla inicial de Orion?',
      confirmText: 'Reiniciar',
    );

    if (confirmed) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }
}
