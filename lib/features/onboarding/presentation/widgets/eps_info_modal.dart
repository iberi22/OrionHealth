// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

/// Info modal explaining the EPS connection logic, session persistence,
/// and how to maintain the connection.
class EpsInfoModal extends StatelessWidget {
  const EpsInfoModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EpsInfoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A0E21),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: CyberTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CyberTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF00D4FF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Conectar mi EPS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Section 1: What is it ──
              _sectionTitle('🔐 ¿Qué es la conexión EPS?'),
              const SizedBox(height: 8),
              _bodyText(
                'OrionHealth se conecta al portal web de tu EPS para importar '
                'automáticamente tus datos de salud: nombre, documento, médico '
                'familiar, condiciones, medicamentos, alergias y vacunas.',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CyberTheme.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Color(0xFF4CAF50), size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tus credenciales NUNCA salen de tu dispositivo. '
                        'El scraping ocurre 100% on-device.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Section 2: How it works ──
              _sectionTitle('⚙️ ¿Cómo funciona?'),
              const SizedBox(height: 12),
              ..._steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: CyberTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_steps.indexOf(step) + 1}',
                        style: const TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 16),

              // ── Section 3: Session persistence ──
              _sectionTitle('🔄 Persistencia de sesión'),
              const SizedBox(height: 8),
              _bodyText(
                'Una vez inicias sesión en tu EPS, OrionHealth guarda las '
                'cookies y datos de navegación de forma segura. La próxima '
                'vez que entres, irás directo al panel de tu EPS sin volver '
                'a escribir tu contraseña.',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.amber, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'La sesión expira después de 7 días. Luego deberás '
                        'iniciar sesión nuevamente por seguridad.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Section 4: How to use ──
              _sectionTitle('📋 ¿Cómo usarla?'),
              const SizedBox(height: 8),
              _bodyText(
                '1. Toca "Conectar con mi EPS" y selecciona tu EPS.\n'
                '2. Ingresa con tu usuario y contraseña del portal.\n'
                '3. Cuando veas tu panel de afiliado, toca "Ya inicié sesión".\n'
                '4. OrionHealth extraerá tus datos automáticamente.\n'
                '5. Revisa los datos y continúa con tu perfil.',
              ),

              const SizedBox(height: 16),

              // ── Section 5: Maintaining the session ──
              _sectionTitle('💡 Mantener la conexión'),
              const SizedBox(height: 8),
              _bodyText(
                '• No cierres sesión en el portal de tu EPS desde el navegador.\n'
                '• Si tu EPS cambia su portal, los datos pueden requerir '
                're-autenticación.\n'
                '• Puedes actualizar tus datos en cualquier momento desde '
                'la pantalla principal (Home).\n'
                '• La conexión EPS es solo para Colombia (EPS del régimen '
                'contributivo y subsidiado).',
              ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberTheme.primary,
                    foregroundColor: CyberTheme.backgroundDark,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  static const _steps = [
    'Abrís el portal web de tu EPS dentro de OrionHealth (WebView seguro).',
    'Iniciás sesión manualmente con tu documento y contraseña.',
    'OrionHealth detecta que entraste al panel y empieza a escanear los endpoints de la API.',
    'Los datos se extraen (nombre, documento, médico, condiciones, medicamentos, etc.).',
    'Se borran las credenciales temporales — solo quedan los datos de salud extraídos.',
    'La sesión se guarda para que no tengas que volver a loguearte.',
  ];
}
