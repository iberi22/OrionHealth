import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../application/onboarding_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class PrivacyStep extends StatefulWidget {
  const PrivacyStep({super.key});

  @override
  State<PrivacyStep> createState() => _PrivacyStepState();
}

class _PrivacyStepState extends State<PrivacyStep> {
  bool _dataProcessingConsent = false;
  bool _privacyPolicyConsent = false;
  bool _biometricEnabled = false;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (canCheck && isDeviceSupported) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (mounted && availableBiometrics.isNotEmpty) {
          setState(() => _biometricEnabled = true);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacidad y Seguridad',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Configura cómo quieres proteger el acceso a tu app.',
            style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 14),
          ),
          const SizedBox(height: 24),

          // --- Seguridad ---
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Protección de acceso',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBiometricToggle(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Tu privacidad ---
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tus datos están protegidos',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildPrivacyPoint(Icons.storage, 'Base de datos en formato binario, 100% local.'),
                const SizedBox(height: 8),
                _buildPrivacyPoint(Icons.security, 'Solo tu nodo de Orion puede abrir y leer tus datos.'),
                const SizedBox(height: 8),
                _buildPrivacyPoint(Icons.lock, 'Encriptación total, sin puertas traseras.'),
                const SizedBox(height: 8),
                _buildPrivacyPoint(Icons.delete_outline, 'Control total: borra tus datos cuando quieras.'),
                const SizedBox(height: 8),
                _buildPrivacyPoint(Icons.pin, 'Acceso protegido por pin y biometría.'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- App Gratuita y Apoyo ---
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.pinkAccent, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Proyecto Libre y Gratuito',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Orion siempre será una aplicación 100% gratuita. Nuestro desarrollo '
                  'se sostiene gracias al apoyo en forma de donaciones para el '
                  'laboratorio Southwest AI Labs (SWAL).',
                  style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Procesamiento de datos ---
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: Colors.amber, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Procesamiento de datos',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Entiendo que Orion procesa mis datos de salud de forma estrictamente '
                  'local en mi dispositivo, para generar seguimientos médicos y recordatorios. '
                  'Ningún dato sale de mi nodo de Orion hacia internet.',
                  style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                _buildCheckbox(
                  value: _dataProcessingConsent,
                  label: 'Acepto el procesamiento de mis datos',
                  onChanged: (v) => setState(() => _dataProcessingConsent = v ?? false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Política de privacidad ---
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, color: Colors.purple, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Política de privacidad',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'He leído y acepto la política de privacidad de OrionHealth. '
                  'Entiendo que puedo revocar mi consentimiento en cualquier momento.',
                  style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                _buildCheckbox(
                  value: _privacyPolicyConsent,
                  label: 'Acepto la política de privacidad',
                  onChanged: (v) => setState(() => _privacyPolicyConsent = v ?? false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _navButtons(context),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            _biometricEnabled ? Icons.fingerprint : Icons.lock_outline,
            color: _biometricEnabled ? AppColors.primary : Colors.white38,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbloqueo con huella',
                  style: TextStyle(
                    color: _biometricEnabled ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _biometricEnabled
                      ? 'Usa tu huella para acceder rápido y seguro'
                      : 'Huella no disponible en este dispositivo',
                  style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: (v) => setState(() => _biometricEnabled = v),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withAlpha(102),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              side: const BorderSide(color: Colors.white38, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButtons(BuildContext context) {
    final canComplete = _dataProcessingConsent && _privacyPolicyConsent;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<OnboardingCubit>().previousStep(),
            child: const Text('Atrás'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canComplete ? AppColors.primary : Colors.grey[800],
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: canComplete
                ? () => context.read<OnboardingCubit>().saveAndComplete()
                : null,
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                if (state is OnboardingLoading) {
                  return const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return const Text(
                  'Completar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
