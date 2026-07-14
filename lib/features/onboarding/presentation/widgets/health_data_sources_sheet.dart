// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../domain/entities/health_data_source.dart';

/// Bottom sheet for connecting external health/fitness data sources.
///
/// Shows a grid of supported sources (Strava, Google Fit, Apple Health,
/// Garmin, Fitbit, Oura, Whoop, etc.) with connection status and data types.
class HealthDataSourcesSheet extends StatefulWidget {
  final void Function(HealthDataSource source)? onSourceConnected;

  const HealthDataSourcesSheet({
    super.key,
    this.onSourceConnected,
  });

  @override
  State<HealthDataSourcesSheet> createState() =>
      _HealthDataSourcesSheetState();
}

class _HealthDataSourcesSheetState extends State<HealthDataSourcesSheet> {
  final Set<String> _connected = {};
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final sources = HealthDataSourcesCatalog.all;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E21),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CyberTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sync,
                    color: Color(0xFF00D4FF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sincronizar datos de salud',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Conectá tus apps deportivas y de salud',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_connected.isNotEmpty)
                  Text(
                    '${_connected.length}/${sources.length}',
                    style: TextStyle(
                      color: CyberTheme.success.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Body: grid of sources
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: sources.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (ctx, i) {
                  final source = sources[i];
                  final isConnected = _connected.contains(source.id);
                  return _SourceCard(
                    source: source,
                    isConnected: isConnected,
                    onTap: () => _connectToSource(source),
                    isLoading: _isConnecting,
                  );
                },
              ),
            ),
          ),

          // Bottom: Skip / Close
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, _connected),
                    child: Text(
                      _connected.isEmpty ? 'Omitir' : 'Continuar',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _connected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberTheme.primary,
                      foregroundColor: CyberTheme.backgroundDark,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _connected.isEmpty ? 'Más tarde' : 'Listo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _connectToSource(HealthDataSource source) async {
    if (_isConnecting) return;

    if (_connected.contains(source.id)) {
      // Disconnect
      setState(() => _connected.remove(source.id));
      return;
    }

    setState(() => _isConnecting = true);

    // Simulate connection (future: real OAuth flow via flutter_appauth)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _connected.add(source.id);
        _isConnecting = false;
      });
      widget.onSourceConnected?.call(source);
    }
  }
}

/// Card widget for a single health data source.
class _SourceCard extends StatelessWidget {
  final HealthDataSource source;
  final bool isConnected;
  final VoidCallback onTap;
  final bool isLoading;

  const _SourceCard({
    required this.source,
    required this.isConnected,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isConnected
            ? CyberTheme.success.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? CyberTheme.success.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00D4FF),
                          ),
                        )
                      : Icon(
                          source.icon,
                          color: isConnected
                              ? const Color(0xFF4CAF50)
                              : Colors.white.withValues(alpha: 0.5),
                          size: 22,
                        ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        source.description,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (source.dataTypes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: source.dataTypes
                              .take(4)
                              .map((dt) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _dataTypeLabel(dt),
                                      style: const TextStyle(
                                        color: Colors.white30,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Connect/Status
                const SizedBox(width: 8),
                if (isConnected)
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CyberTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Conectar',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dataTypeLabel(String dt) {
    switch (dt) {
      case 'steps': return 'pasos';
      case 'heart_rate': return 'ritmo cardíaco';
      case 'sleep': return 'sueño';
      case 'calories': return 'calorías';
      case 'workouts': return 'ejercicios';
      case 'weight': return 'peso';
      case 'blood_pressure': return 'presión';
      case 'glucose': return 'glucosa';
      case 'blood_oxygen': return 'oxígeno';
      case 'temperature': return 'temperatura';
      case 'hrv': return 'HRV';
      case 'stress': return 'estrés';
      case 'strain': return 'esfuerzo';
      case 'recovery': return 'recuperación';
      case 'readiness': return 'disposición';
      default: return dt;
    }
  }
}
