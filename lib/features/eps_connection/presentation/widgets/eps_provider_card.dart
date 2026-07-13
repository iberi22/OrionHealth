import 'package:flutter/material.dart';
import '../../domain/entities/eps_provider.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/theme/app_colors.dart';

class EpsProviderCard extends StatelessWidget {
  final EPSProvider provider;
  final VoidCallback? onConnect;

  const EpsProviderCard({
    super.key,
    required this.provider,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _providerIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _regimeLabel(provider.id),
                      style: TextStyle(
                        color: _regimeColor(provider.id),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.id,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (onConnect != null)
                _connectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerIcon() {
    final isEpsi = provider.id.startsWith('EPSI');
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isEpsi
            ? Colors.orange.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isEpsi ? Icons.eco : Icons.local_hospital,
        color: isEpsi ? Colors.orange : AppColors.primary,
        size: 22,
      ),
    );
  }

  Widget _connectButton() {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onConnect,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Conectar',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────

  String _regimeLabel(String id) {
    if (id.startsWith('EPSI')) return 'Régimen Especial (EPSI)';
    // Ambos regímenes
    const ambos = ['EPS020', 'EPS037', 'EPS033', 'EPS050'];
    if (ambos.contains(id)) return 'Contributivo + Subsidiado';
    // Contributivo
    const contributivo = [
      'EPS001', 'EPS002', 'EPS005', 'EPS025', 'EPS017',
      'EPS016', 'EPS010', 'EPS008', 'EPS035', 'EPS046'
    ];
    if (contributivo.contains(id)) return 'Régimen Contributivo';
    return 'Régimen Subsidiado';
  }

  Color _regimeColor(String id) {
    if (id.startsWith('EPSI')) return Colors.orange;
    const ambos = ['EPS020', 'EPS037', 'EPS033', 'EPS050'];
    if (ambos.contains(id)) return Colors.cyanAccent;
    const contributivo = [
      'EPS001', 'EPS002', 'EPS005', 'EPS025', 'EPS017',
      'EPS016', 'EPS010', 'EPS008', 'EPS035', 'EPS046'
    ];
    if (contributivo.contains(id)) return AppColors.primary;
    return Colors.greenAccent;
  }
}
