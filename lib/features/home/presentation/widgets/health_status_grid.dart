import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/home_cubit.dart';
import '../../application/home_state.dart';

class IndexingStatusBanner extends StatefulWidget {
  const IndexingStatusBanner({super.key});

  @override
  State<IndexingStatusBanner> createState() => _IndexingStatusBannerState();
}

class _IndexingStatusBannerState extends State<IndexingStatusBanner> {
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.isIndexing && !current.isIndexing && !current.indexingError,
      listener: (context, state) {
        setState(() => _showSuccess = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showSuccess = false);
          }
        });
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isIndexing) {
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sincronizando estándares médicos...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.indexingError) {
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error al sincronizar estándares médicos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<HomeCubit>().retryIndexing(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (_showSuccess) {
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estándares médicos actualizados',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class HealthStatusGrid extends StatelessWidget {
  const HealthStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Frecuencia Cardíaca'),
        const Text('Presión Arterial'),
        const Text('Temperatura'),
        const Text('Saturación de Oxígeno'),
      ],
    );
  }
}
