import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

/// HIPAA-style consent/privacy screen.
///
/// Explains what data is collected and why, requires explicit checkbox
/// acceptance before proceeding, provides a privacy policy dialog, and
/// persists consent to [FlutterSecureStorage].
class HipaaConsentPage extends StatefulWidget {
  const HipaaConsentPage({super.key});

  @override
  State<HipaaConsentPage> createState() => _HipaaConsentPageState();
}

class _HipaaConsentPageState extends State<HipaaConsentPage> {
  bool _consentGiven = false;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  static const _consentKey = 'hipaa_consent_granted';
  static const _consentDateKey = 'hipaa_consent_date';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Privacidad y Consentimiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            const Center(
              child: Column(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 56),
                  SizedBox(height: 12),
                  Text(
                    'Tu privacidad es primero',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'OrionHealth está diseñado para proteger tu información médica.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Data Collection Explanation ---
            GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        '¿Qué datos recogemos y por qué?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDataPoint(
                    Icons.person,
                    'Datos de perfil',
                    'Nombre, edad, género y datos demográficos para personalizar tu experiencia.',
                  ),
                  const SizedBox(height: 10),
                  _buildDataPoint(
                    Icons.monitor_heart_outlined,
                    'Datos de salud',
                    'Signos vitales, condiciones, medicamentos y alergias que ingreses voluntariamente.',
                  ),
                  const SizedBox(height: 10),
                  _buildDataPoint(
                    Icons.calendar_month,
                    'Historial médico',
                    'Citas, recordatorios y seguimientos generados localmente en tu dispositivo.',
                  ),
                  const SizedBox(height: 10),
                  _buildDataPoint(
                    Icons.security,
                    'Almacenamiento 100% local',
                    'Todos tus datos se almacenan exclusivamente en tu dispositivo.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- HIPAA / Privacy Commitment ---
            GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Nuestro compromiso',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildCommitmentItem('Cifrado completo de extremo a extremo en tu dispositivo.'),
                  const SizedBox(height: 6),
                  _buildCommitmentItem('Sin acceso remoto a tus datos por parte de terceros.'),
                  const SizedBox(height: 6),
                  _buildCommitmentItem('Tú mantienes el control total: puedes eliminar tus datos cuando quieras.'),
                  const SizedBox(height: 6),
                  _buildCommitmentItem('Código abierto y auditable por la comunidad.'),
                  const SizedBox(height: 6),
                  _buildCommitmentItem('Sin publicidad, sin venta de datos, sin tracking.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Privacy Policy Button ---
            GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: _showPrivacyPolicyDialog,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: Colors.purpleAccent, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Leer política de privacidad',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Consent Checkbox ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _consentGiven
                    ? AppColors.primary.withAlpha(20)
                    : Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _consentGiven
                      ? AppColors.primary.withAlpha(80)
                      : Colors.white12,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      value: _consentGiven,
                      onChanged: (v) => setState(() => _consentGiven = v ?? false),
                      activeColor: AppColors.primary,
                      side: const BorderSide(color: Colors.white38, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'He leído y acepto la política de privacidad. Entiendo que mis datos '
                      'se almacenan localmente en mi dispositivo y que puedo revocar '
                      'mi consentimiento en cualquier momento.',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Action Buttons ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _consentGiven ? AppColors.primary : Colors.grey[800],
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _consentGiven && !_isLoading ? _acceptConsent : null,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Aceptar y continuar',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Debes aceptar los términos para continuar usando OrionHealth',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withAlpha(180)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 12, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommitmentItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '✅ $text',
            style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 13, height: 1.3),
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            const Text('Política de Privacidad', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            _privacyPolicyText,
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptConsent() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now().toIso8601String();
      await _storage.write(key: _consentKey, value: 'true');
      await _storage.write(key: _consentDateKey, value: now);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar consentimiento: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Static method to check if consent has been previously granted.
  static Future<bool> hasConsent() async {
    const storage = FlutterSecureStorage();
    final value = await storage.read(key: _consentKey);
    return value == 'true';
  }
}

const String _privacyPolicyText = '''
POLÍTICA DE PRIVACIDAD DE ORIONHEALTH

Última actualización: Julio 2026

1. INFORMACIÓN QUE RECOPILAMOS

OrionHealth recopila la siguiente información que tú proporcionas voluntariamente:
- Datos de perfil (nombre, edad, género)
- Datos de salud (signos vitales, condiciones, medicamentos, alergias)
- Historial de citas y recordatorios
- Preferencias de configuración de la aplicación

2. ALMACENAMIENTO Y SEGURIDAD

Todos tus datos se almacenan exclusivamente en tu dispositivo mediante cifrado local.
No transmitimos, almacenamos ni procesamos tus datos en servidores externos.

3. USO DE LA INFORMACIÓN

Utilizamos tus datos únicamente para:
- Generar seguimientos médicos personalizados
- Recordatorios de citas y medicamentos
- Mejorar tu experiencia dentro de la aplicación

4. COMPARTIR INFORMACIÓN

No compartimos, vendemos ni transferimos tus datos a terceros.
OrionHealth es una aplicación 100% offline-first.

5. TUS DERECHOS

Tienes derecho a:
- Acceder a tus datos almacenados
- Eliminar todos tus datos en cualquier momento
- Revocar tu consentimiento
- Exportar tus datos
''';
